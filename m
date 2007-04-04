Date: Wed, 4 Apr 2007 18:32:20 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [rfc] no ZERO_PAGE?
Message-Id: <20070404183220.2455465b.dada1@cosmosbay.com>
In-Reply-To: <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
References: <20070329075805.GA6852@wotan.suse.de>
	<Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com>
	<20070330024048.GG19407@wotan.suse.de>
	<20070404033726.GE18507@wotan.suse.de>
	<Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007 08:35:30 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Anyway, I'm not against this, but I can see somebody actually *wanting* 
> the ZERO page in some cases. I've used the fact for TLB testing, for 
> example, by just doing a big malloc(), and knowing that the kernel will 
> re-use the ZERO_PAGE so that I don't get any cache effects (well, at least 
> not any *physical* cache effects. Virtually indexed cached will still show 
> effects of it, of course, but I haven't cared).
> 
> That's an example of an app that actually cares about the page allocation 
> (or, in this case, the lack there-of). Not an important one, but maybe 
> there are important ones that care?

I dont know if this small prog is of any interest :

But results on an Intel Pentium-M are interesting, in particular 2) & 3)

If a page is first allocated as page_zero then cow to a full rw page, this is more expensive.
(2660 cycles instead of 2300)

Is there an app somewhere that depends on 2) being ultra-fast but then future write accesses *slow* ???

$ ./page_bench >RES; cat RES
1) pagefault tp bring a rw page:
Poke (addr=0x804c000): 2360 cycles
1) pagefault to bring a rw page:
Poke (addr=0x804d000): 2368 cycles
1) pagefault to bring a rw page:
Poke (addr=0x804e000): 2120 cycles
2) pagefault to bring a zero page, readonly
Peek(addr=0x804f000): ->0 891 cycles
3) pagefault to make this page rw
Poke (addr=0x804f000): 2660 cycles
1) pagefault to bring a rw page:
Poke (addr=0x8050000): 2099 cycles
1) pagefault to bring a rw page:
Poke (addr=0x8051000): 2062 cycles
4) memset 4096 bytes to 0x55:
Poke_full (addr=0x804f000, len=4096): 2719 cycles
5) fill the whole table
Poke_full (addr=0x804c000, len=4194304): 6563661 cycles
6) fill again whole table (no more faults, but cpu cache too small)
Poke_full (addr=0x804c000, len=4194304): 5188925 cycles
7.1) faulting a mmap zone, read access
Peek(addr=0xb7f8a000): ->0 40453 cycles
8.1) faulting a mmap zone, write access
Poke (addr=0xb7f89000): 10599 cycles
7.2) faulting a mmap zone, read access
Peek(addr=0xb7f88000): ->0 8167 cycles
8.3) faulting a mmap zone, write access
Poke (addr=0xb7f87000): 5701 cycles


$ cat page_bench.c

# include <errno.h>
# include <stdlib.h>
# include <unistd.h>
# include <fcntl.h>
# include <stdio.h>
# include <sys/time.h>
# include <time.h>
# include <sys/mman.h>
# include <string.h>

#ifdef __x86_64

#define rdtscll(val) do { \
     unsigned int __a,__d; \
     asm volatile("rdtsc" : "=a" (__a), "=d" (__d)); \
     (val) = ((unsigned long)__a) | (((unsigned long)__d)<<32); \
} while(0)

#elif  __i386

#define rdtscll(val) \
     __asm__ __volatile__("rdtsc" : "=A" (val))

#endif

int var;



int *addr1, *addr2, *addr3, *addr4;

void map_many_vmas(unsigned int nb)
{
size_t sz = getpagesize();
int ui;
for (ui = 0 ; ui < nb ; ui++) {
	void *p = mmap(NULL, sz,
			(ui == 0) ? PROT_READ : PROT_READ|PROT_WRITE,
			(ui & 1) ? MAP_PRIVATE|MAP_ANONYMOUS : MAP_ANONYMOUS|MAP_SHARED, -1, 0);
	if (p == (void *)-1) {
		fprintf(stderr, "Only %u mappings could be set\n", ui);
		break;
		}
	if (!addr1) addr1 = (int *)p;
	else if (!addr2) addr2 = (int *)p;
	else if (!addr3) addr3 = (int *)p;
	else if (!addr4) addr4 = (int *)p;
	}
}

void show_maps()
{
char buffer[4096];
int fd, lu;

fd = open("/proc/self/maps", 0);
if (fd != -1) {
	while ((lu = read(fd, buffer, sizeof(buffer))) > 0)
		write(2, buffer, lu);
	close(fd);
	}
}

void poke_int(void *addr, int val)
{
unsigned long long start, end;
long delta;
	rdtscll(start);
	*(int *)addr = val;
	rdtscll(end);
	delta = (end - start);
	printf("Poke (addr=%p): %ld cycles\n", addr, delta);
}

void poke_full(void *addr, int val, int len)
{
unsigned long long start, end;
long delta;
	rdtscll(start);
	memset(addr, val, len);
	rdtscll(end);
	delta = (end - start);
	printf("Poke_full (addr=%p, len=%d): %ld cycles\n", addr, len, delta);
}

int  peek_int(void *addr)
{
unsigned long long start, end;
long delta;
int val;
	rdtscll(start);
	val = *(int *)addr;
	rdtscll(end);
	delta = (end - start);
	printf("Peek(addr=%p): ->%d %ld cycles\n", addr, val, delta);
	return val;
}

int big_table[1024*1024] __attribute__((aligned(4096)));

void usage(int code)
{
fprintf(stderr, "Usage : page_bench [-m mappings]\n");
exit(code);
}

int main(int argc, char *argv[])
{
	unsigned int nb_mappings = 200;
	int c;

	while ((c = getopt(argc, argv, "Vm:")) != EOF) {
		if (c == 'm')
			nb_mappings = atoi(optarg);
		else if (c == 'V')
			usage(0);
	}
	if (nb_mappings < 4)
		nb_mappings = 4;
	map_many_vmas(nb_mappings);
//	show_maps();
	printf("1) pagefault tp bring a rw page:\n") ;
		poke_int(&big_table[0], 10);
	printf("1) pagefault to bring a rw page:\n") ;
		poke_int(&big_table[1024], 10);
	printf("1) pagefault to bring a rw page:\n") ;
		poke_int(&big_table[2048], 10);
	printf("2) pagefault to bring a zero page, readonly\n");
		peek_int(&big_table[3*1024]);
	printf("3) pagefault to make this page rw\n");
		poke_int(&big_table[3*1024], 10);

	printf("1) pagefault to bring a rw page:\n") ;
	poke_int(&big_table[4*1024], 10);
	printf("1) pagefault to bring a rw page:\n") ;
	poke_int(&big_table[5*1024], 10);

	printf("4) memset 4096 bytes to 0x55:\n");
	poke_full(&big_table[3*1024], 0x55, 4096);

	printf("5) fill the whole table\n");
	poke_full(big_table, 1, sizeof(big_table));
	printf("6) fill again whole table (no more faults, but cpu cache too small)\n");
	poke_full(big_table, 1, sizeof(big_table));

	printf("7.1) faulting a mmap zone, read access\n");
	peek_int(addr1);

	printf("8.1) faulting a mmap zone, write access\n");
	poke_int(addr2, 10);
	printf("7.2) faulting a mmap zone, read access\n");
	peek_int(addr3);
	printf("8.3) faulting a mmap zone, write access\n");
	poke_int(addr4, 10);

	return 0;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
