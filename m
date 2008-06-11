Date: Wed, 11 Jun 2008 13:43:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
Message-Id: <20080611134323.936063d3.akpm@linux-foundation.org>
In-Reply-To: <485032C8.4010001@gmail.com>
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>
	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>
	<4850070F.6060305@gmail.com>
	<20080611121510.d91841a3.akpm@linux-foundation.org>
	<485032C8.4010001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 22:17:12 +0200
Andrea Righi <righi.andrea@gmail.com> wrote:

> Andrew Morton wrote:
> > On Wed, 11 Jun 2008 19:10:40 +0200 (MEST)
> > Andrea Righi <righi.andrea@gmail.com> wrote:
> > 
> >> Balbir Singh wrote:
> >>> +static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)
> >>> +{
> >>> +	*tmp = memparse(buf, &buf);
> >>> +	if (*buf != '\0')
> >>> +		return -EINVAL;
> >>> +
> >>> +	*tmp = PAGE_ALIGN(*tmp);
> >>> +	return 0;
> >>> +}
> >> We shouldn't use PAGE_ALIGN() here, otherwise we limit the address space
> >> to 4GB on 32-bit architectures (that could be reasonable, because this
> >> is a per-cgroup limit and not per-process).
> >>
> >> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> >> ---
> >>  mm/memrlimitcgroup.c |    4 +++-
> >>  1 files changed, 3 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/memrlimitcgroup.c b/mm/memrlimitcgroup.c
> >> index 9a03d7d..2d42ff3 100644
> >> --- a/mm/memrlimitcgroup.c
> >> +++ b/mm/memrlimitcgroup.c
> >> @@ -29,6 +29,8 @@
> >>  #include <linux/res_counter.h>
> >>  #include <linux/memrlimitcgroup.h>
> >>  
> >> +#define PAGE_ALIGN64(addr) (((((addr)+PAGE_SIZE-1))>>PAGE_SHIFT)<<PAGE_SHIFT)
> >> +
> >>  struct cgroup_subsys memrlimit_cgroup_subsys;
> >>  
> >>  struct memrlimit_cgroup {
> >> @@ -124,7 +126,7 @@ static int memrlimit_cgroup_write_strategy(char *buf, unsigned long long *tmp)
> >>  	if (*buf != '\0')
> >>  		return -EINVAL;
> >>  
> >> -	*tmp = PAGE_ALIGN(*tmp);
> >> +	*tmp = PAGE_ALIGN64(*tmp);
> >>  	return 0;
> >>  }
> >>  
> > 
> > I don't beleive the change is needed.
> > 
> > #define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
> > 
> > that implementation will behaved as desired when passed a 64-bit addr?
> 
> If I'm not doing something wrong, here is what happens on my i386 box:
> 
> $ uname -m
> i686
> $ cat 64-bit-page-align.c
> #include <stdio.h>
> #include <asm/page.h>
> 
> #define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
> #define PAGE_ALIGN64(addr) (((((addr)+PAGE_SIZE-1))>>PAGE_SHIFT)<<PAGE_SHIFT)
> 
> #define SIZE ((1ULL << 32) - 1)
> 
> int main(int argc, char **argv)
> {
> 	unsigned long long good, bad;
> 
> 	good = (unsigned long long)PAGE_ALIGN64(SIZE);
> 	bad = (unsigned long long)PAGE_ALIGN(SIZE);
> 
> 	fprintf(stdout, "good = %llu, bad = %llu\n", good, bad);
> 
> 	return 0;
> }
> $ gcc -O2 -o 64-bit-page-align 64-bit-page-align.c
> $ ./64-bit-page-align
> good = 4294967296, bad = 0
>                    ^^^^^^^
> On a x86_64, instead, both PAGE_ALIGN()s work as expected:

That's weird.  We have an expression which contains a combination of UL
constants and ULL constants, and the compiler _isn't_ converting
everything into ULL.


> $ uname -m
> x86_64
> $ gcc -O2 -o 64-bit-page-align 64-bit-page-align.c
> $ ./64-bit-page-align
> good = 4294967296, bad = 4294967296
> 
> At least we could add something like:
> 
> #ifdef CONFIG_32BIT
> #define PAGE_ALIGN64(addr) (((((addr)+PAGE_SIZE-1))>>PAGE_SHIFT)<<PAGE_SHIFT)
> #else
> #define PAGE_ALIGN64(addr) PAGE_ALIGN(addr)
> #endif
> 
> But IMHO the single PAGE_ALIGN64() implementation is more clear.

No, we should just fix PAGE_ALIGN.  It should work correctly when
passed a long-long.  Otherwse it's just a timebomb.

This:

#define PAGE_ALIGN(addr) ({				\
	typeof(addr) __size = PAGE_SIZE;		\
	typeof(addr) __mask = PAGE_MASK;		\
	(addr + __size - 1) & __mask;			\
})

(with a suitable comment) does what we want.  I didn't check to see
whether this causes the compiler to generate larger code, but it
shouldn't.

If we go this way then first we should hoist the PAGE_ALIGN definitions
out of include/asm-*/page.h and into, umm, include/linux/mm.h. 
That might cause build errors but from a bit of grepping around, only
include/asm-arm/cacheflush.h is at risk, and it already includes
linux/mm.h.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
