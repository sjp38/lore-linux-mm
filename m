Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
References: <200003081857.KAA74251@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 09 Mar 2000 19:15:15 +0100
Message-ID: <qww7lfcnh70.fsf@sap.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, Ingo Molnar <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

--=-=-=


kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> > Because I think the current shm code should be redone in a way that
> > shared anonymous pages live in the swap cache. You could say the shm
> > code is a workaround :-)
> 
> No arguments there :-) But it seems a little ambitious to me to
> implement shmfs, dev-zero and rework the swapcache at the same time.
> We are probably on the right track, having done /dev/zero, getting 
> done with shmfs. Then, if we want to take the risk, we can improve
> the core shm/swapcache interactions in 2.3/2.4/2.5.

O.K. I would really like to work on that further.

> > BTW: I am just running these tests on your patch and it seems to work
> > quite well. (I will let it run over night) If it survives that I will
> > also throw some quite complicated /dev/zero tests on it later.
> 
> Great! Is there a way to capture tests written by individual
> developers and testers and have them be shared, so everyone can use
> them (when there are no licensing/copyright issues)? I would
> definitely like to get your test programs and throw them at the
> kernel myself. Lets talk offline if you are willing to share your
> tests.

Unfortunately I do not have web/ftp space to put the programs on, but
they are in the attachments. I normally run them in two steps:
1) Many processes runing against a nunber of segments which fit into
   the main memory.
2) 2 processes wich access more segments so they get it swapping.
All processes run with 20% probability for deletion.

My tests with your patch went so far mostly well. The machine locks up
after some while or kills init, but this is AFAICS stock behaviour.

One bug was introduced by your patch. On swapoff we get an oops:

ksymoops 0.7c on i686 2.3.50.  Options used
     -V (default)
     -K (specified)
     -l /proc/modules (default)
     -o /lib/modules/2.3.50/ (default)
     -m /boot/System.map-2.3.50 (specified)

No modules in ksyms, skipping objects
No ksyms, skipping lsmod
Unable to handle kernel NULL pointer dereference at virtual address 00000000
*pde = 21118001
Oops: 0000
CPU:    7
EIP:    0010:[<c0185d17>]
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010246
eax: 00000000   ebx: 00000000   ecx: 00000000   edx: 00000000
esi: 00000000   edi: c029ac74   ebp: c0185474   esp: d1c63f24
ds: 0018   es: 0018   ss: 0018
Process swapoff (pid: 624, stackpage=d1c63000)
Stack: c029ac74 c032cb74 c19daa94 02944c00 00000000 c0186889 c029ac74 02944c00 
       c19daa94 00000001 c19daa94 02944c00 0002944c c0185e62 02944c00 c19daa94 
       c02aa000 c19daa94 02944c00 c013baa7 02944c00 c19daa94 d1c62000 00000000 
Call Trace: [<c0186889>] [<c0185e62>] [<c013baa7>] [<c013bec9>] [<c010b49c>] 
Code: 8b 14 91 8b 04 da 89 44 24 10 0b 44 da 04 74 3e 8b 04 da 8b 

>>EIP; c0185d17 <shm_unuse_core+33/90>   <=====
Trace; c0186889 <zmap_unuse+121/1d8>
Trace; c0185e62 <shm_unuse+ee/f8>
Trace; c013baa7 <try_to_unuse+1fb/3a0>
Trace; c013bec9 <sys_swapoff+27d/4b8>
Trace; c010b49c <system_call+34/38>
Code;  c0185d17 <shm_unuse_core+33/90>
00000000 <_EIP>:
Code;  c0185d17 <shm_unuse_core+33/90>   <=====
   0:   8b 14 91                  movl   (%ecx,%edx,4),%edx   <=====
Code;  c0185d1a <shm_unuse_core+36/90>
   3:   8b 04 da                  movl   (%edx,%ebx,8),%eax
Code;  c0185d1d <shm_unuse_core+39/90>
   6:   89 44 24 10               movl   %eax,0x10(%esp,1)
Code;  c0185d21 <shm_unuse_core+3d/90>
   a:   0b 44 da 04               orl    0x4(%edx,%ebx,8),%eax
Code;  c0185d25 <shm_unuse_core+41/90>
   e:   74 3e                     je     4e <_EIP+0x4e> c0185d65 <shm_unuse_core+81/90>
Code;  c0185d27 <shm_unuse_core+43/90>
  10:   8b 04 da                  movl   (%edx,%ebx,8),%eax
Code;  c0185d2a <shm_unuse_core+46/90>
  13:   8b 00                     movl   (%eax),%eax

Greetings
		Christoph

-- 

--=-=-=
Content-Disposition: attachment; filename=ipctst.c

#include <stdlib.h>
#include <stdio.h>

#include <errno.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>

int main (int ac, char **av) {
	int segs, size, proc, rmpr;
	unsigned long long iter;
	struct shmid_ds buf;
	pid_t pid;

	if (ac < 6) {
		printf ("usage: shmtst segs size proc iter rm%%\n");
		exit (1);
	}
	segs = atoi (av[1]);
	size = atoi (av[2]);
	proc = atoi (av[3]);
	iter = atoi (av[4]);
	rmpr = atoi (av[5]);

	iter = 1 << iter;
	printf ("using %d segs of size %d (%llu iterations)\n", 
		segs, size, iter);
	while (-- proc) {
		if ((pid = fork()) > 0) {
			printf ("started process %d\n", (int) pid);
		} else {
			break;
		}
	}
	srandom (getpid());
	while (iter--) {
		key_t key;
		int seg, i;
		unsigned char c, *ptr;
		volatile unsigned char *p;

		key = random() % segs +1;
		if ((seg = shmget (key, size, IPC_CREAT| 0600)) == -1) {
			perror("shmget");
			if (errno != EIDRM)
				exit (1);
			continue;
		}
		if (0) sched_yield();
		if ((ptr = shmat (seg, 0, 0)) == (unsigned char *) -1) {
			perror ("shmat");
			continue;
		}
		for (p = ptr; p < ptr + size; p += 4097)
			*p = (unsigned char) (p - ptr);
		for (p = ptr; p < ptr + size; p += 4097) {
			c = *p;
			if (c == (unsigned char)(p-ptr)) 
				continue;
			shmctl (seg, IPC_STAT, &buf);
			printf ("n=%i, m = %i: %i != %i", (int) buf.shm_nattch,
				(int)buf.shm_perm.mode,
				(int)(unsigned char)(p-ptr), (int) c);
			for (i = 0 ; i < 5; i++) {
				printf (", %i", (int)*p);
				sched_yield();
			}
			printf ("\n");
		}

		if (shmdt (ptr) != 0) {
			perror("shmdt");
			exit (1);
		}
		if (random () % 100 < rmpr &&
		    shmctl (seg, IPC_RMID, NULL) == -1) 
			perror("shmctl IPC_RMID");
	}
}	

--=-=-=
Content-Disposition: attachment; filename=shmtst.c

#include <stdlib.h>
#include <stdio.h>

#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

int main (int ac, char **av) {
	int segs, size, proc, rmpr;
	unsigned long long iter;
	pid_t pid;
	struct stat buf;

	if (ac < 6) {
		printf ("usage: shmtst segs size proc iter rm%%\n");
		exit (1);
	}
	segs = atoi (av[1]);
	size = atoi (av[2]);
	proc = atoi (av[3]);
	iter = atoi (av[4]);
	rmpr = atoi (av[5]);

	iter = 1 << iter;
	printf ("using %d segs of size %d (%llu iterations)\n", 
		segs, size, iter);
	while (-- proc) {
		if ((pid = fork()) > 0) {
			printf ("started process %d\n", (int) pid);
		} else {
			break;
		}
	}
	srandom (getpid());
	while (iter--) {
		int seg, key;
		char name[20];
		char *ptr, *p;

		key = random() % segs;
		sprintf (name, "my%d", key);
		if ((seg = shm_open (name, O_CREAT| O_RDWR , 0666)) == -1) {
			perror("shm_open");
			exit (1);
		}
	        if (ftruncate (seg, size) == -1) {
			perror ("ftruncate");
			exit (2);
		}
	        if ((ptr = mmap (0, size, PROT_READ|PROT_WRITE,MAP_SHARED,
				 seg, 0)) == MAP_FAILED) {	
			perror ("mmap");
			exit (3);
		}
		for (p = ptr; p < ptr + size; p += 4097)
			*p = (char) p;
		for (p = ptr; p < ptr + size; p += 4097)
			if (*p != (char)p)
				printf ("*p(%i) != p(%i)\n", (int)*p, (int)p & 0xff);

	    	if (munmap (ptr, size) == -1)
			perror ("munmap");

	    	if (close(seg) == -1)
			perror ("close");

		if (random () % 100 < rmpr &&
		    shm_unlink (name) == -1) 
			perror("shm_unlink");
	}
}	

--=-=-=
Content-Disposition: attachment; filename=libposix4.c

#include <asm/unistd.h>
#include <errno.h>

#define PREFIX "/var/shm"
int shm_open (const char *pathname, int flags, int mode) {
	char name[strlen(pathname) + sizeof(PREFIX)];
	sprintf (name, PREFIX "/%s", pathname);
	return open (name, flags, mode);
}

int shm_unlink(const char *pathname){
	char name[strlen(pathname) + sizeof(PREFIX)];
	sprintf (name, PREFIX "/%s", pathname);
	return unlink (name);
}




--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
