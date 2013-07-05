Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6D3326B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 00:07:16 -0400 (EDT)
Message-ID: <51D6463B.7050207@asianux.com>
Date: Fri, 05 Jul 2013 12:06:19 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: 'lru' may be used without initialized after
 the patch "3abf380..." in next-20130607 tree
References: <51C155D1.3090304@asianux.com> <20130619001029.ee623fae.akpm@linux-foundation.org> <51C15B7B.9060804@asianux.com>
In-Reply-To: <51C15B7B.9060804@asianux.com>
Content-Type: multipart/mixed;
 boundary="------------070505090509030405020205"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------070505090509030405020205
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 06/19/2013 03:19 PM, Chen Gang wrote:
> On 06/19/2013 03:10 PM, Andrew Morton wrote:
>> On Wed, 19 Jun 2013 14:55:13 +0800 Chen Gang <gang.chen@asianux.com> wrote:
>>
>>>>
>>>> 'lru' may be used without initialized, so need regressing part of the
>>>> related patch.
>>>>
>>>> The related patch:
>>>>   "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
>>>>
>>>> ...
>>>>
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -595,6 +595,7 @@ redo:
>>>>  		 * unevictable page on [in]active list.
>>>>  		 * We know how to handle that.
>>>>  		 */
>>>> +		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
>>>>  		lru_cache_add(page);
>>>>  	} else {
>>>>  		/*
>> That looks right.  Why the heck didn't gcc-4.4.4 (at least) warn about it?
>>
> 
> Sorry I don't know either, I find it by reading code, this time.
> 
> It is really necessary to continue analyzing why. In 2nd half of 2013, I
> have planned to make some patches outside kernel but related with kernel
> (e.g. LTP, gcc patches).
> 
> This kind of issue is a good chance for me to start in 2nd half of 2013
> (start from next month).
> 
> So if no others reply for it, I will start analyzing it in the next
> month, and plan to finish within a month (before 2013-07-31).
> 
> 
> Welcome additional suggestions or completions.
> 
> Thanks.
> 

Under gcc 4.7.2 20120921 (Red Hat 4.7.2-2) also cause this issue.

The root cause is:

  for putback_lur_page() in mm/vmscan.c for next-20130621 tree.
  the compiler assumes "lru == LRU_UNEVICTABLE" instead of report warnings (uninitializing lru)

The details are below, and the related info and warn are in
attachments, please check, thanks.

Next, I will compile gcc compiler with the gcc latest code, if also has
this issue, I should communicate with gcc mailing list for it.

Thanks.

------------------------------analyzing begin---------------------------------

/* source code in mm/vmscan.c for next-20130621 */

 580 void putback_lru_page(struct page *page)
 581 {
 582         int lru;
 583         int was_unevictable = PageUnevictable(page);
 584 
 585         VM_BUG_ON(PageLRU(page));
 586 
 587 redo:
 588         ClearPageUnevictable(page);
 589 
 590         if (page_evictable(page)) {
 591                 /*
 592                  * For evictable pages, we can use the cache.
 593                  * In event of a race, worst case is we end up with an
 594                  * unevictable page on [in]active list.
 595                  * We know how to handle that.
 596                  */
 597                 lru_cache_add(page);
 598         } else {
 599                 /*
 600                  * Put unevictable pages directly on zone's unevictable
 601                  * list.
 602                  */
 603                 lru = LRU_UNEVICTABLE;
 604                 add_page_to_unevictable_list(page);
 605                 /*
 606                  * When racing with an mlock or AS_UNEVICTABLE clearing
 607                  * (page is unlocked) make sure that if the other thread
 608                  * does not observe our setting of PG_lru and fails
 609                  * isolation/check_move_unevictable_pages,
 610                  * we see PG_mlocked/AS_UNEVICTABLE cleared below and move
 611                  * the page back to the evictable list.
 612                  *
 613                  * The other side is TestClearPageMlocked() or shmem_lock().
 614                  */
 615                 smp_mb();
 616         }
 617 
 618         /*
 619          * page's status can change while we move it among lru. If an evictable
 620          * page is on unevictable list, it never be freed. To avoid that,
 621          * check after we added it to the list, again.
 622          */
 623         if (lru == LRU_UNEVICTABLE && page_evictable(page)) {
 624                 if (!isolate_lru_page(page)) {
 625                         put_page(page);
 626                         goto redo;
 627                 }
 628                 /* This means someone else dropped this page from LRU
 629                  * So, it will be freed or putback to LRU again. There is
 630                  * nothing to do here.
 631                  */
 632         }
 633 
 634         if (was_unevictable && lru != LRU_UNEVICTABLE)
 635                 count_vm_event(UNEVICTABLE_PGRESCUED);
 636         else if (!was_unevictable && lru == LRU_UNEVICTABLE)
 637                 count_vm_event(UNEVICTABLE_PGCULLED);
 638 
 639         put_page(page);         /* drop ref from isolate */
 640 }


/*
 * Related disassemble code:
 *   make defconfig under x86_64 PC.
 *   make menuconfig (choose "Automount devtmpfs at /dev..." and KGDB)
 *   make V=1 EXTRA_CFLAGS=-W (not find related warnings, ref warn.log in attachment)
 *   objdump -d vmlinux > vmlinux.S
 *   vi vmlinux.S
 *
 * The issue is: compiler assumes "lru == LRU_UNEVICTABLE" instead of report warnings (uninitializing lru)
 */

ffffffff810ffda0 <putback_lru_page>:
ffffffff810ffda0:	55                   	push   %rbp
ffffffff810ffda1:	48 89 e5             	mov    %rsp,%rbp
ffffffff810ffda4:	41 55                	push   %r13
ffffffff810ffda6:	41 54                	push   %r12
ffffffff810ffda8:	4c 8d 67 02          	lea    0x2(%rdi),%r12		; %r12 for ClearPageUnevictable(page);
ffffffff810ffdac:	53                   	push   %rbx
ffffffff810ffdad:	48 89 fb             	mov    %rdi,%rbx		; %rbx = page
ffffffff810ffdb0:	48 83 ec 08          	sub    $0x8,%rsp		; for lru, was_unevictable, but not used.

ffffffff810ffdb4:	4c 8b 2f             	mov    (%rdi),%r13		; %r13 = "was_unevictable = PageUnevictable(page);"
ffffffff810ffdb7:	49 c1 ed 14          	shr    $0x14,%r13
ffffffff810ffdbb:	41 83e5 01          	and    $0x1,%r13d
ffffffff810ffdbf:	90                   	nop

/* redo */
ffffffff810ffdc0:	f0 41 80 24 24 ef    	lock andb $0xef,(%r12)		; ClearPageUnevictable(page);

/* if (page_evictable(page)) { */
ffffffff810ffdc6:	48 89 df             	mov    %rbx,%rdi
ffffffff810ffdc9:	e8 92 ff ff ff       	callq  ffffffff810ffd60 <page_evictable>
ffffffff810ffdce:	85 c0                	test   %eax,%eax
ffffffff810ffdd0:	48 89 df             	mov    %rbx,%rdi
ffffffff810ffdd3:	74 0b                	je     ffffffff810ffde0 <putback_lru_page+0x40>

ffffffff810ffdd5:	e8 96 c5 ff ff       	callq  ffffffff810fc370 <lru_cache_add>
ffffffff810ffdda:	eb 0c                	jmp    ffffffff810ffde8 <putback_lru_page+0x48>
ffffffff810ffddc:	0f 1f 40 00          	nopl   0x0(%rax)

/* } else { */
						; assume lru == LRU_UNEVICTABLE
ffffffff810ffde0:	e8 ab c5 ff ff       	callq  ffffffff810fc390 <add_page_to_unevictable_list>
ffffffff810ffde5:	0f ae f0             	mfence 

/* } */

/* if (lru == LRU_UNEVICTABLE && page_evictable(page)) { */
ffffffff810ffde8:	48 89 df             	mov    %rbx,%rdi
ffffffff810ffdeb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
ffffffff810ffdf0:	e8 6b ff ff ff       	callq  ffffffff810ffd60 <page_evictable>
ffffffff810ffdf5:	85 c0                	test   %eax,%eax
ffffffff810ffdf7:	74 1f                	je     ffffffff810ffe18 <putback_lru_page+0x78>  ; assume lru == LRU_UNEVICTABLE

ffffffff810ffdf9:	48 89 df             	mov    %rbx,%rdi
ffffffff810ffdfc:	e8 0f fb ff ff       	callq  ffffffff810ff910 <isolate_lru_page>
ffffffff810ffe01:	85 c0                	test   %eax,%eax
ffffffff810ffe03:	75 13                	jne    ffffffff810ffe18 <putback_lru_page+0x78>
ffffffff810ffe05:	48 89 df             	mov    %rbx,%rdi
ffffffff810ffe08:	e8 93 c0 ff ff       	callq  ffffffff810fbea0 <put_page>
ffffffff810ffe0d:	0f 1f 00             	nopl   (%rax)
ffffffff810ffe10:	eb ae                	jmp    ffffffff810ffdc0 <putback_lru_page+0x20>	; goto redo;
ffffffff810ffe12:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

/* } */

/* if (was_unevictable && lru != LRU_UNEVICTABLE) */
	/* skip... */

/* else if (!was_unevictable && lru == LRU_UNEVICTABLE) */
ffffffff810ffe18:	4d 85 ed             	test   %r13,%r13		; !was_unevictable, and assume lru == LRU_UNEVICTABLE
ffffffff810ffe1b:	75 09                	jne    ffffffff810ffe26 <putback_lru_page+0x86>
ffffffff810ffe1d:	65 48 ff 04 25 68 f0 	incq   %gs:0xf068	; it is for count_vm_event(UNEVICTABLE_PGCULLED)
									; and "incq   %gs:0xf078" is for count_vm_event(UNEVICTABLE_PGRESCUED)
ffffffff810ffe24:	00 00 

/* put_page(); */
ffffffff810ffe26:	48 89 df             	mov    %rbx,%rdi
ffffffff810ffe29:	e8 72 c0 ff ff       	callq  ffffffff810fbea0 <put_page>
ffffffff810ffe2e:	48 83 c4 08          	add    $0x8,%rsp
ffffffff810ffe32:	5b                   	pop    %rbx
ffffffff810ffe33:	41 5c                	pop    %r12
ffffffff810ffe35:	41 5d                	pop    %r13
ffffffff810ffe37:	5d                   	pop    %rbp
ffffffff810ffe38:	c3                   	retq   
ffffffff810ffe39:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)


------------------------------analyzing end-----------------------------------



Thanks.
-- 
Chen Gang

--------------070505090509030405020205
Content-Type: text/x-log;
 name="info.log"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="info.log"


[root@dhcp122 linux-next]# gcc -v
Using built-in specs.
COLLECT_GCC=3Dgcc
COLLECT_LTO_WRAPPER=3D/usr/libexec/gcc/x86_64-redhat-linux/4.7.2/lto-wrap=
per
Target: x86_64-redhat-linux
Configured with: ../configure --prefix=3D/usr --mandir=3D/usr/share/man -=
-infodir=3D/usr/share/info --with-bugurl=3Dhttp://bugzilla.redhat.com/bug=
zilla --enable-bootstrap --enable-shared --enable-threads=3Dposix --enabl=
e-checking=3Drelease --disable-build-with-cxx --disable-build-poststage1-=
with-cxx --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exc=
eptions --enable-gnu-unique-object --enable-linker-build-id --with-linker=
-hash-style=3Dgnu --enable-languages=3Dc,c++,objc,obj-c++,java,fortran,ad=
a,go,lto --enable-plugin --enable-initfini-array --enable-java-awt=3Dgtk =
--disable-dssi --with-java-home=3D/usr/lib/jvm/java-1.5.0-gcj-1.5.0.0/jre=
 --enable-libgcj-multifile --enable-java-maintainer-mode --with-ecj-jar=3D=
/usr/share/java/eclipse-ecj.jar --disable-libjava-multilib --with-ppl --w=
ith-cloog --with-tune=3Dgeneric --with-arch_32=3Di686 --build=3Dx86_64-re=
dhat-linux
Thread model: posix
gcc version 4.7.2 20120921 (Red Hat 4.7.2-2) (GCC)=20


  gcc -Wp,-MD,mm/.vmscan.o.d  -nostdinc -isystem /usr/lib/gcc/x86_64-redh=
at-linux/4.7.2/include -I/root/linux-next/arch/x86/include -Iarch/x86/inc=
lude/generated  -Iinclude -I/root/linux-next/arch/x86/include/uapi -Iarch=
/x86/include/generated/uapi -I/root/linux-next/include/uapi -Iinclude/gen=
erated/uapi -include /root/linux-next/include/linux/kconfig.h -D__KERNEL_=
_ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -=
fno-common -Werror-implicit-function-declaration -Wno-format-security -fn=
o-delete-null-pointer-checks -O2 -m64 -mtune=3Dgeneric -mno-red-zone -mcm=
odel=3Dkernel -funit-at-a-time -maccumulate-outgoing-args -DCONFIG_AS_CFI=
=3D1 -DCONFIG_AS_CFI_SIGNAL_FRAME=3D1 -DCONFIG_AS_CFI_SECTIONS=3D1 -DCONF=
IG_AS_FXSAVEQ=3D1 -DCONFIG_AS_AVX=3D1 -DCONFIG_AS_AVX2=3D1 -pipe -Wno-sig=
n-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mn=
o-3dnow -mno-avx -Wframe-larger-than=3D2048 -fno-stack-protector -Wno-unu=
sed-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls =
-Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fco=
nserve-stack -DCC_HAVE_ASM_GOTO -W    -D"KBUILD_STR(s)=3D#s" -D"KBUILD_BA=
SENAME=3DKBUILD_STR(vmscan)"  -D"KBUILD_MODNAME=3DKBUILD_STR(vmscan)" -c =
-o mm/vmscan.o mm/vmscan.c


--------------070505090509030405020205
Content-Type: text/x-log;
 name="warn.log"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="warn.log"

In file included from /root/linux-next/arch/x86/include/asm/bitops.h:16:0,
                 from include/linux/bitops.h:22,
                 from include/linux/kernel.h:10,
                 from include/asm-generic/bug.h:13,
                 from /root/linux-next/arch/x86/include/asm/bug.h:38,
                 from include/linux/bug.h:4,
                 from include/linux/thread_info.h:11,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/alternative.h: In function a??apply_paravirta??:
/root/linux-next/arch/x86/include/asm/alternative.h:203:63: warning: unused parameter a??starta?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/alternative.h:204:35: warning: unused parameter a??enda?? [-Wunused-parameter]
In file included from include/linux/kernel.h:13:0,
                 from include/asm-generic/bug.h:13,
                 from /root/linux-next/arch/x86/include/asm/bug.h:38,
                 from include/linux/bug.h:4,
                 from include/linux/thread_info.h:11,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/printk.h: In function a??no_printka??:
include/linux/printk.h:95:27: warning: unused parameter a??fmta?? [-Wunused-parameter]
In file included from include/linux/kernel.h:14:0,
                 from include/asm-generic/bug.h:13,
                 from /root/linux-next/arch/x86/include/asm/bug.h:38,
                 from include/linux/bug.h:4,
                 from include/linux/thread_info.h:11,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/dynamic_debug.h: In function a??ddebug_remove_modulea??:
include/linux/dynamic_debug.h:114:52: warning: unused parameter a??moda?? [-Wunused-parameter]
include/linux/dynamic_debug.h: In function a??ddebug_dyndbg_module_param_cba??:
include/linux/dynamic_debug.h:119:68: warning: unused parameter a??vala?? [-Wunused-parameter]
include/linux/dynamic_debug.h:120:19: warning: unused parameter a??modnamea?? [-Wunused-parameter]
In file included from include/asm-generic/bug.h:13:0,
                 from /root/linux-next/arch/x86/include/asm/bug.h:38,
                 from include/linux/bug.h:4,
                 from include/linux/thread_info.h:11,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/kernel.h: In function a??__might_sleepa??:
include/linux/kernel.h:166:48: warning: unused parameter a??filea?? [-Wunused-parameter]
include/linux/kernel.h:166:58: warning: unused parameter a??linea?? [-Wunused-parameter]
include/linux/kernel.h:167:12: warning: unused parameter a??preempt_offseta?? [-Wunused-parameter]
include/linux/kernel.h: In function a??____trace_printk_check_formata??:
include/linux/kernel.h:496:48: warning: unused parameter a??fmta?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/thread_info.h:11:0,
                 from include/linux/thread_info.h:54,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/page.h: In function a??clear_user_pagea??:
/root/linux-next/arch/x86/include/asm/page.h:24:62: warning: unused parameter a??vaddra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/page.h:25:21: warning: unused parameter a??pga?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/page.h: In function a??copy_user_pagea??:
/root/linux-next/arch/x86/include/asm/page.h:30:71: warning: unused parameter a??vaddra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/page.h:31:20: warning: unused parameter a??topagea?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/vm86.h:5:0,
                 from /root/linux-next/arch/x86/include/asm/processor.h:10,
                 from /root/linux-next/arch/x86/include/asm/thread_info.h:22,
                 from include/linux/thread_info.h:54,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/ptrace.h: In function a??v8086_modea??:
/root/linux-next/arch/x86/include/asm/ptrace.h:113:46: warning: unused parameter a??regsa?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/processor.h:10:0,
                 from /root/linux-next/arch/x86/include/asm/thread_info.h:22,
                 from include/linux/thread_info.h:54,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/vm86.h: In function a??handle_vm86_trapa??:
/root/linux-next/arch/x86/include/asm/vm86.h:75:61: warning: unused parameter a??aa?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/vm86.h:75:69: warning: unused parameter a??ba?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/vm86.h:75:76: warning: unused parameter a??ca?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/cpumask.h:4:0,
                 from /root/linux-next/arch/x86/include/asm/msr.h:10,
                 from /root/linux-next/arch/x86/include/asm/processor.h:20,
                 from /root/linux-next/arch/x86/include/asm/thread_info.h:22,
                 from include/linux/thread_info.h:54,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/cpumask.h: In function a??alloc_cpumask_vara??:
include/linux/cpumask.h:676:53: warning: unused parameter a??maska?? [-Wunused-parameter]
include/linux/cpumask.h:676:65: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??alloc_cpumask_var_nodea??:
include/linux/cpumask.h:681:58: warning: unused parameter a??maska?? [-Wunused-parameter]
include/linux/cpumask.h:681:70: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/cpumask.h:682:12: warning: unused parameter a??nodea?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??zalloc_cpumask_vara??:
include/linux/cpumask.h:687:66: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??zalloc_cpumask_var_nodea??:
include/linux/cpumask.h:693:71: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/cpumask.h:694:12: warning: unused parameter a??nodea?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??alloc_bootmem_cpumask_vara??:
include/linux/cpumask.h:700:61: warning: unused parameter a??maska?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??free_cpumask_vara??:
include/linux/cpumask.h:704:51: warning: unused parameter a??maska?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??free_bootmem_cpumask_vara??:
include/linux/cpumask.h:708:59: warning: unused parameter a??maska?? [-Wunused-parameter]
include/linux/cpumask.h: In function a??__check_is_bitmapa??:
include/linux/cpumask.h:748:58: warning: unused parameter a??bitmapa?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/thread_info.h:22:0,
                 from include/linux/thread_info.h:54,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/processor.h: In function a??native_set_iopl_maska??:
/root/linux-next/arch/x86/include/asm/processor.h:496:50: warning: unused parameter a??maska?? [-Wunused-parameter]
In file included from include/linux/spinlock_types.h:18:0,
                 from include/linux/spinlock.h:81,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/lockdep.h: In function a??print_irqtrace_eventsa??:
include/linux/lockdep.h:465:62: warning: unused parameter a??curra?? [-Wunused-parameter]
In file included from include/linux/spinlock.h:87:0,
                 from include/linux/mmzone.h:7,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/spinlock.h: In function a??arch_spin_lock_flagsa??:
/root/linux-next/arch/x86/include/asm/spinlock.h:127:23: warning: unused parameter a??flagsa?? [-Wunused-parameter]
In file included from include/linux/mmzone.h:9:0,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/wait.h: In function a??__remove_wait_queuea??:
include/linux/wait.h:137:59: warning: unused parameter a??heada?? [-Wunused-parameter]
In file included from include/linux/notifier.h:13:0,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/mutex.h: In function a??mutex_destroya??:
include/linux/mutex.h:98:48: warning: unused parameter a??locka?? [-Wunused-parameter]
In file included from include/linux/rwsem.h:40:0,
                 from include/linux/notifier.h:14,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/rwsem.h: In function a??__down_write_nesteda??:
/root/linux-next/arch/x86/include/asm/rwsem.h:102:70: warning: unused parameter a??subclassa?? [-Wunused-parameter]
In file included from include/linux/rcupdate.h:44:0,
                 from include/linux/srcu.h:33,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/debugobjects.h: In function a??debug_object_inita??:
include/linux/debugobjects.h:85:31: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:85:61: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_object_init_on_stacka??:
include/linux/debugobjects.h:87:34: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:87:64: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_object_activatea??:
include/linux/debugobjects.h:89:31: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:89:61: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_object_deactivatea??:
include/linux/debugobjects.h:91:31: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:91:61: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_object_destroya??:
include/linux/debugobjects.h:93:31: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:93:61: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_object_freea??:
include/linux/debugobjects.h:95:31: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:95:61: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_object_assert_inita??:
include/linux/debugobjects.h:97:32: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/debugobjects.h:97:62: warning: unused parameter a??descra?? [-Wunused-parameter]
include/linux/debugobjects.h: In function a??debug_check_no_obj_freeda??:
include/linux/debugobjects.h:107:38: warning: unused parameter a??addressa?? [-Wunused-parameter]
include/linux/debugobjects.h:107:61: warning: unused parameter a??sizea?? [-Wunused-parameter]
In file included from include/linux/srcu.h:33:0,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/rcupdate.h: In function a??rcu_user_hooks_switcha??:
include/linux/rcupdate.h:239:62: warning: unused parameter a??preva?? [-Wunused-parameter]
include/linux/rcupdate.h:240:27: warning: unused parameter a??nexta?? [-Wunused-parameter]
In file included from include/linux/srcu.h:33:0,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/rcupdate.h: In function a??init_rcu_head_on_stacka??:
include/linux/rcupdate.h:295:60: warning: unused parameter a??heada?? [-Wunused-parameter]
include/linux/rcupdate.h: In function a??destroy_rcu_head_on_stacka??:
include/linux/rcupdate.h:299:63: warning: unused parameter a??heada?? [-Wunused-parameter]
include/linux/rcupdate.h: In function a??rcu_is_nocb_cpua??:
include/linux/rcupdate.h:1014:40: warning: unused parameter a??cpua?? [-Wunused-parameter]
In file included from include/linux/workqueue.h:8:0,
                 from include/linux/srcu.h:34,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/timer.h: In function a??destroy_timer_on_stacka??:
include/linux/timer.h:103:62: warning: unused parameter a??timera?? [-Wunused-parameter]
In file included from include/linux/srcu.h:34:0,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/workqueue.h: In function a??__init_worka??:
include/linux/workqueue.h:199:52: warning: unused parameter a??worka?? [-Wunused-parameter]
include/linux/workqueue.h:199:62: warning: unused parameter a??onstacka?? [-Wunused-parameter]
include/linux/workqueue.h: In function a??destroy_work_on_stacka??:
include/linux/workqueue.h:200:62: warning: unused parameter a??worka?? [-Wunused-parameter]
include/linux/workqueue.h: In function a??work_statica??:
include/linux/workqueue.h:201:60: warning: unused parameter a??worka?? [-Wunused-parameter]
In file included from include/linux/notifier.h:15:0,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:797,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/srcu.h: In function a??srcu_read_lock_helda??:
include/linux/srcu.h:167:59: warning: unused parameter a??spa?? [-Wunused-parameter]
In file included from include/linux/mmzone.h:797:0,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/memory_hotplug.h: In function a??pgdat_resize_locka??:
include/linux/memory_hotplug.h:201:58: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/memory_hotplug.h:201:76: warning: unused parameter a??fa?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??pgdat_resize_unlocka??:
include/linux/memory_hotplug.h:202:60: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/memory_hotplug.h:202:78: warning: unused parameter a??fa?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??pgdat_resize_inita??:
include/linux/memory_hotplug.h:203:58: warning: unused parameter a??pgdata?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??zone_span_seqbegina??:
include/linux/memory_hotplug.h:205:56: warning: unused parameter a??zonea?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??zone_span_seqretrya??:
include/linux/memory_hotplug.h:209:51: warning: unused parameter a??zonea?? [-Wunused-parameter]
include/linux/memory_hotplug.h:209:66: warning: unused parameter a??iva?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??zone_span_writelocka??:
include/linux/memory_hotplug.h:213:53: warning: unused parameter a??zonea?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??zone_span_writeunlocka??:
include/linux/memory_hotplug.h:214:55: warning: unused parameter a??zonea?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??zone_seqlock_inita??:
include/linux/memory_hotplug.h:215:51: warning: unused parameter a??zonea?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??register_page_bootmem_info_nodea??:
include/linux/memory_hotplug.h:224:72: warning: unused parameter a??pgdata?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??is_mem_section_removablea??:
include/linux/memory_hotplug.h:241:58: warning: unused parameter a??pfna?? [-Wunused-parameter]
include/linux/memory_hotplug.h:242:20: warning: unused parameter a??nr_pagesa?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??try_offline_nodea??:
include/linux/memory_hotplug.h:247:41: warning: unused parameter a??nida?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??offline_pagesa??:
include/linux/memory_hotplug.h:249:47: warning: unused parameter a??start_pfna?? [-Wunused-parameter]
include/linux/memory_hotplug.h:249:72: warning: unused parameter a??nr_pagesa?? [-Wunused-parameter]
include/linux/memory_hotplug.h: In function a??remove_memorya??:
include/linux/memory_hotplug.h:254:38: warning: unused parameter a??nida?? [-Wunused-parameter]
include/linux/memory_hotplug.h:254:47: warning: unused parameter a??starta?? [-Wunused-parameter]
include/linux/memory_hotplug.h:254:58: warning: unused parameter a??sizea?? [-Wunused-parameter]
In file included from include/linux/gfp.h:4:0,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/mmzone.h: In function a??is_highmem_idxa??:
include/linux/mmzone.h:865:49: warning: unused parameter a??idxa?? [-Wunused-parameter]
include/linux/mmzone.h: In function a??is_highmema??:
include/linux/mmzone.h:881:43: warning: unused parameter a??zonea?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/uapi/asm/bootparam.h:33:0,
                 from /root/linux-next/arch/x86/include/asm/x86_init.h:5,
                 from /root/linux-next/arch/x86/include/asm/mpspec.h:7,
                 from /root/linux-next/arch/x86/include/asm/smp.h:12,
                 from /root/linux-next/arch/x86/include/asm/mmzone_64.h:10,
                 from /root/linux-next/arch/x86/include/asm/mmzone.h:4,
                 from include/linux/mmzone.h:920,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/e820.h: In function a??early_memtesta??:
/root/linux-next/arch/x86/include/asm/e820.h:48:48: warning: unused parameter a??starta?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/e820.h:48:69: warning: unused parameter a??enda?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/numa.h:6:0,
                 from /root/linux-next/arch/x86/include/asm/acpi.h:28,
                 from /root/linux-next/arch/x86/include/asm/fixmap.h:19,
                 from /root/linux-next/arch/x86/include/asm/apic.h:12,
                 from /root/linux-next/arch/x86/include/asm/smp.h:13,
                 from /root/linux-next/arch/x86/include/asm/mmzone_64.h:10,
                 from /root/linux-next/arch/x86/include/asm/mmzone.h:4,
                 from include/linux/mmzone.h:920,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/topology.h: In function a??arch_fix_phys_package_ida??:
/root/linux-next/arch/x86/include/asm/topology.h:132:49: warning: unused parameter a??numa?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/topology.h:132:58: warning: unused parameter a??slota?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/smp.h:13:0,
                 from /root/linux-next/arch/x86/include/asm/mmzone_64.h:10,
                 from /root/linux-next/arch/x86/include/asm/mmzone.h:4,
                 from include/linux/mmzone.h:920,
                 from include/linux/gfp.h:4,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/apic.h: In function a??flat_vector_allocation_domaina??:
/root/linux-next/arch/x86/include/asm/apic.h:622:35: warning: unused parameter a??cpua?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/apic.h:623:32: warning: unused parameter a??maska?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/apic.h: In function a??default_vector_allocation_domaina??:
/root/linux-next/arch/x86/include/asm/apic.h:639:28: warning: unused parameter a??maska?? [-Wunused-parameter]
In file included from include/linux/gfp.h:4:0,
                 from include/linux/mm.h:8,
                 from mm/vmscan.c:14:
include/linux/mmzone.h: In function a??memmap_valid_withina??:
include/linux/mmzone.h:1271:53: warning: unused parameter a??pfna?? [-Wunused-parameter]
include/linux/mmzone.h:1272:19: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mmzone.h:1272:38: warning: unused parameter a??zonea?? [-Wunused-parameter]
In file included from include/linux/mm.h:8:0,
                 from mm/vmscan.c:14:
include/linux/gfp.h: In function a??arch_free_pagea??:
include/linux/gfp.h:293:48: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/gfp.h:293:58: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/gfp.h: In function a??arch_alloc_pagea??:
include/linux/gfp.h:296:49: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/gfp.h:296:59: warning: unused parameter a??ordera?? [-Wunused-parameter]
In file included from include/linux/mm.h:14:0,
                 from mm/vmscan.c:14:
include/linux/debug_locks.h: In function a??debug_show_held_locksa??:
include/linux/debug_locks.h:60:62: warning: unused parameter a??taska?? [-Wunused-parameter]
include/linux/debug_locks.h: In function a??debug_check_no_locks_freeda??:
include/linux/debug_locks.h:65:40: warning: unused parameter a??froma?? [-Wunused-parameter]
include/linux/debug_locks.h:65:60: warning: unused parameter a??lena?? [-Wunused-parameter]
In file included from include/linux/mm_types.h:14:0,
                 from include/linux/mm.h:15,
                 from mm/vmscan.c:14:
include/linux/uprobes.h: In function a??uprobe_registera??:
include/linux/uprobes.h:132:31: warning: unused parameter a??inodea?? [-Wunused-parameter]
include/linux/uprobes.h:132:45: warning: unused parameter a??offseta?? [-Wunused-parameter]
include/linux/uprobes.h:132:77: warning: unused parameter a??uca?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_applya??:
include/linux/uprobes.h:137:28: warning: unused parameter a??inodea?? [-Wunused-parameter]
include/linux/uprobes.h:137:42: warning: unused parameter a??offseta?? [-Wunused-parameter]
include/linux/uprobes.h:137:74: warning: unused parameter a??uca?? [-Wunused-parameter]
include/linux/uprobes.h:137:83: warning: unused parameter a??adda?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_unregistera??:
include/linux/uprobes.h:142:33: warning: unused parameter a??inodea?? [-Wunused-parameter]
include/linux/uprobes.h:142:47: warning: unused parameter a??offseta?? [-Wunused-parameter]
include/linux/uprobes.h:142:79: warning: unused parameter a??uca?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_mmapa??:
include/linux/uprobes.h:145:54: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_munmapa??:
include/linux/uprobes.h:150:38: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/uprobes.h:150:57: warning: unused parameter a??starta?? [-Wunused-parameter]
include/linux/uprobes.h:150:78: warning: unused parameter a??enda?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_dup_mmapa??:
include/linux/uprobes.h:160:35: warning: unused parameter a??oldmma?? [-Wunused-parameter]
include/linux/uprobes.h:160:60: warning: unused parameter a??newmma?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_notify_resumea??:
include/linux/uprobes.h:163:57: warning: unused parameter a??regsa?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_get_swbp_addra??:
include/linux/uprobes.h:170:66: warning: unused parameter a??regsa?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_free_utaska??:
include/linux/uprobes.h:174:58: warning: unused parameter a??ta?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_copy_processa??:
include/linux/uprobes.h:177:60: warning: unused parameter a??ta?? [-Wunused-parameter]
include/linux/uprobes.h: In function a??uprobe_clear_statea??:
include/linux/uprobes.h:180:57: warning: unused parameter a??mma?? [-Wunused-parameter]
In file included from include/linux/mm.h:15:0,
                 from mm/vmscan.c:14:
include/linux/mm_types.h: In function a??mm_init_cpumaska??:
include/linux/mm_types.h:443:54: warning: unused parameter a??mma?? [-Wunused-parameter]
In file included from mm/vmscan.c:14:0:
include/linux/mm.h: In function a??set_max_mapnra??:
include/linux/mm.h:36:48: warning: unused parameter a??limita?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/pgtable.h:413:0,
                 from include/linux/mm.h:50,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/pgtable_64.h: In function a??native_pte_cleara??:
/root/linux-next/arch/x86/include/asm/pgtable_64.h:46:55: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable_64.h:46:73: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable_64.h: In function a??pgd_largea??:
/root/linux-next/arch/x86/include/asm/pgtable_64.h:128:35: warning: unused parameter a??pgda?? [-Wunused-parameter]
In file included from include/linux/mm.h:50:0,
                 from mm/vmscan.c:14:
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??native_set_pte_ata??:
/root/linux-next/arch/x86/include/asm/pgtable.h:665:56: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:665:74: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??native_set_pmd_ata??:
/root/linux-next/arch/x86/include/asm/pgtable.h:671:56: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:671:74: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??ptep_get_and_cleara??:
/root/linux-next/arch/x86/include/asm/pgtable.h:718:58: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:718:76: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??ptep_set_wrprotecta??:
/root/linux-next/arch/x86/include/asm/pgtable.h:745:57: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:746:25: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??pmdp_get_and_cleara??:
/root/linux-next/arch/x86/include/asm/pgtable.h:781:58: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:781:76: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??pmdp_set_wrprotecta??:
/root/linux-next/arch/x86/include/asm/pgtable.h:790:57: warning: unused parameter a??mma?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:791:25: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??update_mmu_cachea??:
/root/linux-next/arch/x86/include/asm/pgtable.h:830:60: warning: unused parameter a??vmaa?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:831:17: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:831:30: warning: unused parameter a??ptepa?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h: In function a??update_mmu_cache_pmda??:
/root/linux-next/arch/x86/include/asm/pgtable.h:834:64: warning: unused parameter a??vmaa?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:835:17: warning: unused parameter a??addra?? [-Wunused-parameter]
/root/linux-next/arch/x86/include/asm/pgtable.h:835:30: warning: unused parameter a??pmda?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/pgtable.h:839:0,
                 from include/linux/mm.h:50,
                 from mm/vmscan.c:14:
include/asm-generic/pgtable.h: In function a??pte_clear_not_present_fulla??:
include/asm-generic/pgtable.h:126:16: warning: unused parameter a??fulla?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??pmd_samea??:
include/asm-generic/pgtable.h:203:34: warning: unused parameter a??pmd_aa?? [-Wunused-parameter]
include/asm-generic/pgtable.h:203:47: warning: unused parameter a??pmd_ba?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??my_zero_pfna??:
include/asm-generic/pgtable.h:496:55: warning: unused parameter a??addra?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??pmd_trans_hugea??:
include/asm-generic/pgtable.h:506:40: warning: unused parameter a??pmda?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??pmd_trans_splittinga??:
include/asm-generic/pgtable.h:510:45: warning: unused parameter a??pmda?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??pmd_trans_unstablea??:
include/asm-generic/pgtable.h:599:45: warning: unused parameter a??pmda?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??pmd_numaa??:
include/asm-generic/pgtable.h:683:34: warning: unused parameter a??pmda?? [-Wunused-parameter]
include/asm-generic/pgtable.h: In function a??pte_numaa??:
include/asm-generic/pgtable.h:688:34: warning: unused parameter a??ptea?? [-Wunused-parameter]
In file included from include/linux/mm.h:271:0,
                 from mm/vmscan.c:14:
include/linux/page-flags.h: In function a??PageHighMema??:
include/linux/page-flags.h:242:1: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/page-flags.h: In function a??PageHWPoisona??:
include/linux/page-flags.h:274:1: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/page-flags.h: In function a??PageTransHugea??:
include/linux/page-flags.h:439:46: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/page-flags.h: In function a??PageTransCompounda??:
include/linux/page-flags.h:444:50: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/page-flags.h: In function a??PageTransTaila??:
include/linux/page-flags.h:449:46: warning: unused parameter a??pagea?? [-Wunused-parameter]
In file included from include/linux/mm.h:272:0,
                 from mm/vmscan.c:14:
include/linux/huge_mm.h: In function a??split_huge_page_to_lista??:
include/linux/huge_mm.h:194:38: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/huge_mm.h:194:62: warning: unused parameter a??lista?? [-Wunused-parameter]
include/linux/huge_mm.h: In function a??split_huge_pagea??:
include/linux/huge_mm.h:198:48: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/huge_mm.h: In function a??hugepage_madvisea??:
include/linux/huge_mm.h:209:59: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/huge_mm.h:210:23: warning: unused parameter a??vm_flagsa?? [-Wunused-parameter]
include/linux/huge_mm.h:210:37: warning: unused parameter a??advicea?? [-Wunused-parameter]
include/linux/huge_mm.h: In function a??vma_adjust_trans_hugea??:
include/linux/huge_mm.h:215:65: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/huge_mm.h:216:21: warning: unused parameter a??starta?? [-Wunused-parameter]
include/linux/huge_mm.h:217:21: warning: unused parameter a??enda?? [-Wunused-parameter]
include/linux/huge_mm.h:218:12: warning: unused parameter a??adjust_nexta?? [-Wunused-parameter]
include/linux/huge_mm.h: In function a??pmd_trans_huge_locka??:
include/linux/huge_mm.h:221:46: warning: unused parameter a??pmda?? [-Wunused-parameter]
include/linux/huge_mm.h:222:34: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/huge_mm.h: In function a??do_huge_pmd_numa_pagea??:
include/linux/huge_mm.h:227:59: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/huge_mm.h:227:86: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/huge_mm.h:228:20: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/huge_mm.h:228:32: warning: unused parameter a??pmda?? [-Wunused-parameter]
include/linux/huge_mm.h:228:44: warning: unused parameter a??pmdpa?? [-Wunused-parameter]
In file included from mm/vmscan.c:14:0:
include/linux/mm.h: In function a??compound_locka??:
include/linux/mm.h:336:47: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h: In function a??compound_unlocka??:
include/linux/mm.h:344:49: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h: In function a??compound_lock_irqsavea??:
include/linux/mm.h:352:64: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h: In function a??compound_unlock_irqrestorea??:
include/linux/mm.h:362:60: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h:363:26: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/mm.h: In function a??page_nid_xchg_lasta??:
include/linux/mm.h:708:61: warning: unused parameter a??nida?? [-Wunused-parameter]
include/linux/mm.h: In function a??page_nid_reset_lasta??:
include/linux/mm.h:718:53: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h: In function a??set_page_linksa??:
include/linux/mm.h:754:36: warning: unused parameter a??pfna?? [-Wunused-parameter]
In file included from include/linux/mm.h:766:0,
                 from mm/vmscan.c:14:
include/linux/vmstat.h: In function a??__mod_zone_freepage_statea??:
include/linux/vmstat.h:264:15: warning: unused parameter a??migratetypea?? [-Wunused-parameter]
In file included from mm/vmscan.c:14:0:
include/linux/mm.h: In function a??kernel_map_pagesa??:
include/linux/mm.h:1745:31: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h:1745:41: warning: unused parameter a??numpagesa?? [-Wunused-parameter]
include/linux/mm.h:1745:55: warning: unused parameter a??enablea?? [-Wunused-parameter]
include/linux/mm.h: In function a??kernel_page_presenta??:
include/linux/mm.h:1747:53: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/mm.h: In function a??page_is_guarda??:
include/linux/mm.h:1842:47: warning: unused parameter a??pagea?? [-Wunused-parameter]
In file included from include/linux/stat.h:19:0,
                 from include/linux/module.h:10,
                 from mm/vmscan.c:15:
include/linux/uidgid.h: In function a??make_kuida??:
include/linux/uidgid.h:152:55: warning: unused parameter a??froma?? [-Wunused-parameter]
include/linux/uidgid.h: In function a??make_kgida??:
include/linux/uidgid.h:157:55: warning: unused parameter a??froma?? [-Wunused-parameter]
include/linux/uidgid.h: In function a??from_kuida??:
include/linux/uidgid.h:162:54: warning: unused parameter a??toa?? [-Wunused-parameter]
include/linux/uidgid.h: In function a??from_kgida??:
include/linux/uidgid.h:167:54: warning: unused parameter a??toa?? [-Wunused-parameter]
include/linux/uidgid.h: In function a??kuid_has_mappinga??:
include/linux/uidgid.h:188:60: warning: unused parameter a??nsa?? [-Wunused-parameter]
include/linux/uidgid.h:188:71: warning: unused parameter a??uida?? [-Wunused-parameter]
include/linux/uidgid.h: In function a??kgid_has_mappinga??:
include/linux/uidgid.h:193:60: warning: unused parameter a??nsa?? [-Wunused-parameter]
include/linux/uidgid.h:193:71: warning: unused parameter a??gida?? [-Wunused-parameter]
In file included from include/linux/module.h:14:0,
                 from mm/vmscan.c:15:
include/linux/elf.h: In function a??elf_coredump_extra_notes_writea??:
include/linux/elf.h:45:63: warning: unused parameter a??filea?? [-Wunused-parameter]
include/linux/elf.h:46:12: warning: unused parameter a??foffseta?? [-Wunused-parameter]
In file included from include/linux/module.h:17:0,
                 from mm/vmscan.c:15:
include/linux/moduleparam.h: In function a??__check_old_set_parama??:
include/linux/moduleparam.h:197:29: warning: unused parameter a??oldseta?? [-Wunused-parameter]
In file included from include/linux/static_key.h:1:0,
                 from include/linux/tracepoint.h:20,
                 from include/linux/module.h:18,
                 from mm/vmscan.c:15:
include/linux/jump_label.h: In function a??jump_label_text_reserveda??:
include/linux/jump_label.h:177:50: warning: unused parameter a??starta?? [-Wunused-parameter]
include/linux/jump_label.h:177:63: warning: unused parameter a??enda?? [-Wunused-parameter]
include/linux/jump_label.h: In function a??jump_label_apply_nopsa??:
include/linux/jump_label.h:185:56: warning: unused parameter a??moda?? [-Wunused-parameter]
include/linux/jump_label.h: In function a??jump_label_rate_limita??:
include/linux/jump_label.h:191:51: warning: unused parameter a??keya?? [-Wunused-parameter]
include/linux/jump_label.h:192:17: warning: unused parameter a??rla?? [-Wunused-parameter]
In file included from include/linux/hardirq.h:7:0,
                 from include/linux/interrupt.h:12,
                 from include/linux/kernel_stat.h:8,
                 from mm/vmscan.c:17:
include/linux/vtime.h: In function a??vtime_task_switcha??:
include/linux/vtime.h:19:58: warning: unused parameter a??preva?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_account_systema??:
include/linux/vtime.h:20:61: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_account_usera??:
include/linux/vtime.h:21:59: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_account_irq_entera??:
include/linux/vtime.h:22:64: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_user_entera??:
include/linux/vtime.h:44:57: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_user_exita??:
include/linux/vtime.h:45:56: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_guest_entera??:
include/linux/vtime.h:46:58: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_guest_exita??:
include/linux/vtime.h:47:57: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h: In function a??vtime_init_idlea??:
include/linux/vtime.h:48:56: warning: unused parameter a??tska?? [-Wunused-parameter]
include/linux/vtime.h:48:65: warning: unused parameter a??cpua?? [-Wunused-parameter]
include/linux/vtime.h: In function a??irqtime_account_irqa??:
include/linux/vtime.h:54:60: warning: unused parameter a??tska?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/sections.h:4:0,
                 from /root/linux-next/arch/x86/include/asm/hw_irq.h:26,
                 from include/linux/irq.h:363,
                 from /root/linux-next/arch/x86/include/asm/hardirq.h:5,
                 from include/linux/hardirq.h:8,
                 from include/linux/interrupt.h:12,
                 from include/linux/kernel_stat.h:8,
                 from mm/vmscan.c:17:
include/asm-generic/sections.h: In function a??arch_is_kernel_texta??:
include/asm-generic/sections.h:49:53: warning: unused parameter a??addra?? [-Wunused-parameter]
include/asm-generic/sections.h: In function a??arch_is_kernel_dataa??:
include/asm-generic/sections.h:56:53: warning: unused parameter a??addra?? [-Wunused-parameter]
In file included from /root/linux-next/arch/x86/include/asm/hardirq.h:5:0,
                 from include/linux/hardirq.h:8,
                 from include/linux/interrupt.h:12,
                 from include/linux/kernel_stat.h:8,
                 from mm/vmscan.c:17:
include/linux/irq.h: In function a??irq_set_parenta??:
include/linux/irq.h:400:38: warning: unused parameter a??irqa?? [-Wunused-parameter]
include/linux/irq.h:400:47: warning: unused parameter a??parent_irqa?? [-Wunused-parameter]
In file included from include/linux/interrupt.h:16:0,
                 from include/linux/kernel_stat.h:8,
                 from mm/vmscan.c:17:
include/linux/hrtimer.h: In function a??destroy_hrtimer_on_stacka??:
include/linux/hrtimer.h:356:61: warning: unused parameter a??timera?? [-Wunused-parameter]
In file included from include/linux/kernel_stat.h:8:0,
                 from mm/vmscan.c:17:
include/linux/interrupt.h: In function a??disable_irq_nosync_lockdep_irqsavea??:
include/linux/interrupt.h:312:88: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/interrupt.h: In function a??enable_irq_lockdep_irqrestorea??:
include/linux/interrupt.h:336:83: warning: unused parameter a??flagsa?? [-Wunused-parameter]
In file included from include/linux/sched.h:42:0,
                 from include/linux/kernel_stat.h:9,
                 from mm/vmscan.c:17:
include/linux/rtmutex.h: In function a??rt_mutex_debug_check_no_locks_freeda??:
include/linux/rtmutex.h:48:68: warning: unused parameter a??froma?? [-Wunused-parameter]
include/linux/rtmutex.h:49:28: warning: unused parameter a??lena?? [-Wunused-parameter]
In file included from include/linux/sched.h:50:0,
                 from include/linux/kernel_stat.h:9,
                 from mm/vmscan.c:17:
include/linux/latencytop.h: In function a??account_scheduler_latencya??:
include/linux/latencytop.h:43:47: warning: unused parameter a??taska?? [-Wunused-parameter]
include/linux/latencytop.h:43:57: warning: unused parameter a??usecsa?? [-Wunused-parameter]
include/linux/latencytop.h:43:68: warning: unused parameter a??intera?? [-Wunused-parameter]
include/linux/latencytop.h: In function a??clear_all_latency_tracinga??:
include/linux/latencytop.h:47:66: warning: unused parameter a??pa?? [-Wunused-parameter]
In file included from include/linux/sched.h:51:0,
                 from include/linux/kernel_stat.h:9,
                 from mm/vmscan.c:17:
include/linux/cred.h: In function a??validate_credsa??:
include/linux/cred.h:188:54: warning: unused parameter a??creda?? [-Wunused-parameter]
include/linux/cred.h: In function a??validate_creds_for_do_exita??:
include/linux/cred.h:191:67: warning: unused parameter a??tska?? [-Wunused-parameter]
In file included from include/linux/kernel_stat.h:9:0,
                 from mm/vmscan.c:17:
include/linux/sched.h: In function a??prefetch_stacka??:
include/linux/sched.h:910:55: warning: unused parameter a??ta?? [-Wunused-parameter]
include/linux/sched.h: In function a??task_numa_faulta??:
include/linux/sched.h:1423:40: warning: unused parameter a??nodea?? [-Wunused-parameter]
include/linux/sched.h:1423:50: warning: unused parameter a??pagesa?? [-Wunused-parameter]
include/linux/sched.h:1423:62: warning: unused parameter a??migrateda?? [-Wunused-parameter]
include/linux/sched.h: In function a??set_numabalancing_statea??:
include/linux/sched.h:1426:49: warning: unused parameter a??enableda?? [-Wunused-parameter]
include/linux/sched.h: In function a??rcu_copy_processa??:
include/linux/sched.h:1732:57: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/sched.h: In function a??sched_autogroup_create_attacha??:
include/linux/sched.h:1880:70: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/sched.h: In function a??sched_autogroup_detacha??:
include/linux/sched.h:1881:63: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/sched.h: In function a??sched_autogroup_forka??:
include/linux/sched.h:1882:63: warning: unused parameter a??siga?? [-Wunused-parameter]
include/linux/sched.h: In function a??sched_autogroup_exita??:
include/linux/sched.h:1883:63: warning: unused parameter a??siga?? [-Wunused-parameter]
include/linux/sched.h: In function a??spin_needbreaka??:
include/linux/sched.h:2454:46: warning: unused parameter a??locka?? [-Wunused-parameter]
include/linux/sched.h: In function a??mm_update_next_ownera??:
include/linux/sched.h:2616:59: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/sched.h: In function a??mm_init_ownera??:
include/linux/sched.h:2620:52: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/sched.h:2620:76: warning: unused parameter a??pa?? [-Wunused-parameter]
In file included from include/linux/slub_def.h:15:0,
                 from include/linux/slab.h:297,
                 from include/linux/xattr.h:14,
                 from include/linux/cgroup.h:21,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/kmemleak.h: In function a??kmemleak_alloca??:
include/linux/kmemleak.h:64:47: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h:64:59: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemleak.h:64:69: warning: unused parameter a??min_counta?? [-Wunused-parameter]
include/linux/kmemleak.h:65:13: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_alloc_recursivea??:
include/linux/kmemleak.h:68:57: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h:68:69: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemleak.h:69:14: warning: unused parameter a??min_counta?? [-Wunused-parameter]
include/linux/kmemleak.h:69:39: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/kmemleak.h:70:16: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_alloc_percpua??:
include/linux/kmemleak.h:73:63: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h:73:75: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_freea??:
include/linux/kmemleak.h:76:46: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_free_parta??:
include/linux/kmemleak.h:79:51: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h:79:63: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_free_recursivea??:
include/linux/kmemleak.h:82:56: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h:82:75: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_free_percpua??:
include/linux/kmemleak.h:85:62: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_not_leaka??:
include/linux/kmemleak.h:88:50: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_ignorea??:
include/linux/kmemleak.h:91:48: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_scan_areaa??:
include/linux/kmemleak.h:94:51: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h:94:63: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemleak.h:94:75: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_erasea??:
include/linux/kmemleak.h:97:42: warning: unused parameter a??ptra?? [-Wunused-parameter]
include/linux/kmemleak.h: In function a??kmemleak_no_scana??:
include/linux/kmemleak.h:100:49: warning: unused parameter a??ptra?? [-Wunused-parameter]
In file included from include/linux/fs.h:7:0,
                 from include/linux/cgroup.h:22,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/kdev_t.h: In function a??new_valid_deva??:
include/linux/kdev_t.h:38:39: warning: unused parameter a??deva?? [-Wunused-parameter]
include/linux/kdev_t.h: In function a??huge_valid_deva??:
include/linux/kdev_t.h:57:40: warning: unused parameter a??deva?? [-Wunused-parameter]
In file included from include/linux/fs.h:15:0,
                 from include/linux/cgroup.h:22,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/radix-tree.h: In function a??radix_tree_deref_slot_protecteda??:
include/linux/radix-tree.h:166:20: warning: unused parameter a??treelocka?? [-Wunused-parameter]
In file included from include/linux/quota.h:48:0,
                 from include/linux/fs.h:247,
                 from include/linux/cgroup.h:22,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/projid.h: In function a??make_kprojida??:
include/linux/projid.h:79:61: warning: unused parameter a??froma?? [-Wunused-parameter]
include/linux/projid.h: In function a??from_kprojida??:
include/linux/projid.h:84:60: warning: unused parameter a??toa?? [-Wunused-parameter]
include/linux/projid.h: In function a??kprojid_has_mappinga??:
include/linux/projid.h:97:63: warning: unused parameter a??nsa?? [-Wunused-parameter]
include/linux/projid.h:97:77: warning: unused parameter a??projida?? [-Wunused-parameter]
In file included from include/linux/cgroup.h:22:0,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/fs.h: In function a??file_take_writea??:
include/linux/fs.h:863:49: warning: unused parameter a??filpa?? [-Wunused-parameter]
include/linux/fs.h: In function a??file_release_writea??:
include/linux/fs.h:864:52: warning: unused parameter a??filpa?? [-Wunused-parameter]
include/linux/fs.h: In function a??file_reset_writea??:
include/linux/fs.h:865:50: warning: unused parameter a??filpa?? [-Wunused-parameter]
include/linux/fs.h: In function a??file_check_statea??:
include/linux/fs.h:866:50: warning: unused parameter a??filpa?? [-Wunused-parameter]
include/linux/fs.h: In function a??file_check_writeablea??:
include/linux/fs.h:867:53: warning: unused parameter a??filpa?? [-Wunused-parameter]
In file included from include/linux/cgroup.h:22:0,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/fs.h: In function a??i_readcount_deca??:
include/linux/fs.h:2287:50: warning: unused parameter a??inodea?? [-Wunused-parameter]
include/linux/fs.h: In function a??i_readcount_inca??:
include/linux/fs.h:2291:50: warning: unused parameter a??inodea?? [-Wunused-parameter]
In file included from include/linux/cgroup.h:22:0,
                 from include/linux/memcontrol.h:22,
                 from include/linux/swap.h:8,
                 from mm/vmscan.c:18:
include/linux/fs.h: In function a??lockdep_annotate_inode_mutex_keya??:
include/linux/fs.h:2342:67: warning: unused parameter a??inodea?? [-Wunused-parameter]
include/linux/fs.h: In function a??xip_truncate_pagea??:
include/linux/fs.h:2436:59: warning: unused parameter a??mappinga?? [-Wunused-parameter]
include/linux/fs.h:2436:75: warning: unused parameter a??froma?? [-Wunused-parameter]
include/linux/fs.h: In function a??__simple_attr_check_formata??:
include/linux/fs.h:2650:45: warning: unused parameter a??fmta?? [-Wunused-parameter]
In file included from include/linux/swap.h:8:0,
                 from mm/vmscan.c:18:
include/linux/memcontrol.h: In function a??mem_cgroup_newpage_chargea??:
include/linux/memcontrol.h:206:58: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:207:24: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/memcontrol.h:207:34: warning: unused parameter a??gfp_maska?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_cache_chargea??:
include/linux/memcontrol.h:212:56: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:213:24: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/memcontrol.h:213:34: warning: unused parameter a??gfp_maska?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_try_charge_swapina??:
include/linux/memcontrol.h:218:66: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/memcontrol.h:219:16: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:219:28: warning: unused parameter a??gfp_maska?? [-Wunused-parameter]
include/linux/memcontrol.h:219:58: warning: unused parameter a??memcgpa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_commit_charge_swapina??:
include/linux/memcontrol.h:224:65: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:225:27: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_cancel_charge_swapina??:
include/linux/memcontrol.h:229:71: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_uncharge_pagea??:
include/linux/memcontrol.h:241:58: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_uncharge_cache_pagea??:
include/linux/memcontrol.h:245:64: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_zone_lruveca??:
include/linux/memcontrol.h:250:30: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_page_lruveca??:
include/linux/memcontrol.h:255:66: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??try_get_mem_cgroup_from_pagea??:
include/linux/memcontrol.h:261:76: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??try_get_mem_cgroup_from_mma??:
include/linux/memcontrol.h:266:79: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mm_match_cgroupa??:
include/linux/memcontrol.h:271:54: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/memcontrol.h:272:22: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??task_in_mem_cgroupa??:
include/linux/memcontrol.h:277:59: warning: unused parameter a??taska?? [-Wunused-parameter]
include/linux/memcontrol.h:278:36: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_cssa??:
include/linux/memcontrol.h:284:38: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_prepare_migrationa??:
include/linux/memcontrol.h:290:43: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:290:62: warning: unused parameter a??newpagea?? [-Wunused-parameter]
include/linux/memcontrol.h:291:29: warning: unused parameter a??memcgpa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_end_migrationa??:
include/linux/memcontrol.h:295:64: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h:296:16: warning: unused parameter a??oldpagea?? [-Wunused-parameter]
include/linux/memcontrol.h:296:38: warning: unused parameter a??newpagea?? [-Wunused-parameter]
include/linux/memcontrol.h:296:52: warning: unused parameter a??migration_oka?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_itera??:
include/linux/memcontrol.h:301:36: warning: unused parameter a??roota?? [-Wunused-parameter]
include/linux/memcontrol.h:302:22: warning: unused parameter a??preva?? [-Wunused-parameter]
include/linux/memcontrol.h:303:37: warning: unused parameter a??reclaima?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_iter_breaka??:
include/linux/memcontrol.h:308:61: warning: unused parameter a??roota?? [-Wunused-parameter]
include/linux/memcontrol.h:309:26: warning: unused parameter a??preva?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_inactive_anon_is_lowa??:
include/linux/memcontrol.h:319:48: warning: unused parameter a??lruveca?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_get_lru_sizea??:
include/linux/memcontrol.h:325:40: warning: unused parameter a??lruveca?? [-Wunused-parameter]
include/linux/memcontrol.h:325:62: warning: unused parameter a??lrua?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_update_lru_sizea??:
include/linux/memcontrol.h:331:43: warning: unused parameter a??lruveca?? [-Wunused-parameter]
include/linux/memcontrol.h:331:65: warning: unused parameter a??lrua?? [-Wunused-parameter]
include/linux/memcontrol.h:332:14: warning: unused parameter a??incrementa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_print_oom_infoa??:
include/linux/memcontrol.h:337:46: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h:337:73: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_begin_update_page_stata??:
include/linux/memcontrol.h:341:67: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:342:12: warning: unused parameter a??lockeda?? [-Wunused-parameter]
include/linux/memcontrol.h:342:35: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_end_update_page_stata??:
include/linux/memcontrol.h:346:65: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:347:12: warning: unused parameter a??lockeda?? [-Wunused-parameter]
include/linux/memcontrol.h:347:35: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_inc_page_stata??:
include/linux/memcontrol.h:351:58: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:352:41: warning: unused parameter a??idxa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_dec_page_stata??:
include/linux/memcontrol.h:356:58: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:357:41: warning: unused parameter a??idxa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_soft_limit_reclaima??:
include/linux/memcontrol.h:362:58: warning: unused parameter a??zonea?? [-Wunused-parameter]
include/linux/memcontrol.h:362:68: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/memcontrol.h:363:16: warning: unused parameter a??gfp_maska?? [-Wunused-parameter]
include/linux/memcontrol.h:364:25: warning: unused parameter a??total_scanneda?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_split_huge_fixupa??:
include/linux/memcontrol.h:369:61: warning: unused parameter a??heada?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_count_vm_eventa??:
include/linux/memcontrol.h:374:50: warning: unused parameter a??mma?? [-Wunused-parameter]
include/linux/memcontrol.h:374:73: warning: unused parameter a??idxa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_replace_page_cachea??:
include/linux/memcontrol.h:377:63: warning: unused parameter a??oldpagea?? [-Wunused-parameter]
include/linux/memcontrol.h:378:18: warning: unused parameter a??newpagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_bad_page_checka??:
include/linux/memcontrol.h:385:40: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??mem_cgroup_print_bad_pagea??:
include/linux/memcontrol.h:391:40: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??sock_update_memcga??:
include/linux/memcontrol.h:407:51: warning: unused parameter a??ska?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??sock_release_memcga??:
include/linux/memcontrol.h:410:52: warning: unused parameter a??ska?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_kmem_newpage_chargea??:
include/linux/memcontrol.h:575:33: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/memcontrol.h:575:58: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h:575:69: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_kmem_uncharge_pagesa??:
include/linux/memcontrol.h:580:59: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:580:69: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_kmem_commit_chargea??:
include/linux/memcontrol.h:585:39: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/memcontrol.h:585:64: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h:585:75: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_cache_ida??:
include/linux/memcontrol.h:589:53: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_register_cachea??:
include/linux/memcontrol.h:595:41: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h:595:67: warning: unused parameter a??sa?? [-Wunused-parameter]
include/linux/memcontrol.h:596:27: warning: unused parameter a??root_cachea?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_release_cachea??:
include/linux/memcontrol.h:601:59: warning: unused parameter a??cachepa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_cache_list_adda??:
include/linux/memcontrol.h:605:60: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/memcontrol.h:606:25: warning: unused parameter a??sa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??memcg_kmem_get_cachea??:
include/linux/memcontrol.h:611:55: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/memcontrol.h: In function a??kmem_cache_destroy_memcg_childrena??:
include/linux/memcontrol.h:616:73: warning: unused parameter a??sa?? [-Wunused-parameter]
In file included from include/linux/device.h:24:0,
                 from include/linux/node.h:17,
                 from include/linux/swap.h:10,
                 from mm/vmscan.c:18:
include/linux/pinctrl/devinfo.h: In function a??pinctrl_bind_pinsa??:
include/linux/pinctrl/devinfo.h:43:52: warning: unused parameter a??deva?? [-Wunused-parameter]
In file included from mm/vmscan.c:18:0:
include/linux/swap.h: In function a??mem_cgroup_swappinessa??:
include/linux/swap.h:325:60: warning: unused parameter a??mema?? [-Wunused-parameter]
include/linux/swap.h: In function a??mem_cgroup_uncharge_swapa??:
include/linux/swap.h:333:57: warning: unused parameter a??enta?? [-Wunused-parameter]
include/linux/swap.h: In function a??mem_cgroup_uncharge_swapcachea??:
include/linux/swap.h:410:44: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/swap.h:410:62: warning: unused parameter a??enta?? [-Wunused-parameter]
include/linux/swap.h:410:72: warning: unused parameter a??swapouta?? [-Wunused-parameter]
In file included from include/linux/pagemap.h:10:0,
                 from mm/vmscan.c:19:
include/linux/highmem.h: In function a??flush_anon_pagea??:
include/linux/highmem.h:14:59: warning: unused parameter a??vmaa?? [-Wunused-parameter]
include/linux/highmem.h:14:77: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/highmem.h:14:97: warning: unused parameter a??vmaddra?? [-Wunused-parameter]
include/linux/highmem.h: In function a??flush_kernel_dcache_pagea??:
include/linux/highmem.h:20:58: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/highmem.h: In function a??flush_kernel_vmap_rangea??:
include/linux/highmem.h:23:50: warning: unused parameter a??vaddra?? [-Wunused-parameter]
include/linux/highmem.h:23:61: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/highmem.h: In function a??invalidate_kernel_vmap_rangea??:
include/linux/highmem.h:26:55: warning: unused parameter a??vaddra?? [-Wunused-parameter]
include/linux/highmem.h:26:66: warning: unused parameter a??sizea?? [-Wunused-parameter]
In file included from include/linux/pagemap.h:10:0,
                 from mm/vmscan.c:19:
include/linux/highmem.h: In function a??kunmapa??:
include/linux/highmem.h:62:40: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/highmem.h: In function a??__kunmap_atomica??:
include/linux/highmem.h:73:42: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/highmem.h: In function a??copy_user_highpagea??:
include/linux/highmem.h:225:46: warning: unused parameter a??vmaa?? [-Wunused-parameter]
In file included from mm/vmscan.c:22:0:
include/linux/vmpressure.h: In function a??vmpressurea??:
include/linux/vmpressure.h:42:37: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/vmpressure.h:42:61: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/vmpressure.h:43:24: warning: unused parameter a??scanneda?? [-Wunused-parameter]
include/linux/vmpressure.h:43:47: warning: unused parameter a??reclaimeda?? [-Wunused-parameter]
include/linux/vmpressure.h: In function a??vmpressure_prioa??:
include/linux/vmpressure.h:44:42: warning: unused parameter a??gfpa?? [-Wunused-parameter]
include/linux/vmpressure.h:44:66: warning: unused parameter a??memcga?? [-Wunused-parameter]
include/linux/vmpressure.h:45:12: warning: unused parameter a??prioa?? [-Wunused-parameter]
In file included from include/linux/blkdev.h:14:0,
                 from mm/vmscan.c:26:
include/linux/backing-dev.h: In function a??bdi_stat_errora??:
include/linux/backing-dev.h:209:69: warning: unused parameter a??bdia?? [-Wunused-parameter]
include/linux/backing-dev.h: In function a??bdi_sched_waita??:
include/linux/backing-dev.h:353:40: warning: unused parameter a??worda?? [-Wunused-parameter]
In file included from include/linux/blkdev.h:17:0,
                 from mm/vmscan.c:26:
include/linux/bio.h: In function a??bio_flush_dcache_pagesa??:
include/linux/bio.h:291:55: warning: unused parameter a??bia?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_associate_currenta??:
include/linux/bio.h:314:53: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_disassociate_taska??:
include/linux/bio.h:315:54: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bvec_kmap_irqa??:
include/linux/bio.h:348:72: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bvec_kunmap_irqa??:
include/linux/bio.h:353:42: warning: unused parameter a??buffera?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integritya??:
include/linux/bio.h:594:45: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_enableda??:
include/linux/bio.h:599:53: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bioset_integrity_createa??:
include/linux/bio.h:604:59: warning: unused parameter a??bsa?? [-Wunused-parameter]
include/linux/bio.h:604:67: warning: unused parameter a??pool_sizea?? [-Wunused-parameter]
include/linux/bio.h: In function a??bioset_integrity_freea??:
include/linux/bio.h:609:59: warning: unused parameter a??bsa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_prepa??:
include/linux/bio.h:614:50: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_freea??:
include/linux/bio.h:619:51: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_clonea??:
include/linux/bio.h:624:51: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h:624:68: warning: unused parameter a??bio_srca?? [-Wunused-parameter]
include/linux/bio.h:625:17: warning: unused parameter a??gfp_maska?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_splita??:
include/linux/bio.h:630:52: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h:630:74: warning: unused parameter a??bpa?? [-Wunused-parameter]
include/linux/bio.h:631:16: warning: unused parameter a??sectorsa?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_advancea??:
include/linux/bio.h:636:54: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h:637:20: warning: unused parameter a??bytes_donea?? [-Wunused-parameter]
include/linux/bio.h: In function a??bio_integrity_trima??:
include/linux/bio.h:642:51: warning: unused parameter a??bioa?? [-Wunused-parameter]
include/linux/bio.h:642:69: warning: unused parameter a??offseta?? [-Wunused-parameter]
include/linux/bio.h:643:24: warning: unused parameter a??sectorsa?? [-Wunused-parameter]
In file included from mm/vmscan.c:26:0:
include/linux/blkdev.h: In function a??rq_flush_dcache_pagesa??:
include/linux/blkdev.h:726:58: warning: unused parameter a??rqa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_pm_runtime_inita??:
include/linux/blkdev.h:979:62: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h:980:17: warning: unused parameter a??deva?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_pre_runtime_suspenda??:
include/linux/blkdev.h:981:65: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_post_runtime_suspenda??:
include/linux/blkdev.h:985:67: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h:985:74: warning: unused parameter a??erra?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_pre_runtime_resumea??:
include/linux/blkdev.h:986:65: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_post_runtime_resumea??:
include/linux/blkdev.h:987:66: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h:987:73: warning: unused parameter a??erra?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??set_start_time_nsa??:
include/linux/blkdev.h:1348:54: warning: unused parameter a??reqa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??set_io_start_time_nsa??:
include/linux/blkdev.h:1349:57: warning: unused parameter a??reqa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??rq_start_time_nsa??:
include/linux/blkdev.h:1350:57: warning: unused parameter a??reqa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??rq_io_start_time_nsa??:
include/linux/blkdev.h:1354:60: warning: unused parameter a??reqa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_rqa??:
include/linux/blkdev.h:1450:52: warning: unused parameter a??rqa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_rq_count_integrity_sga??:
include/linux/blkdev.h:1454:67: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h:1455:22: warning: unused parameter a??ba?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_rq_map_integrity_sga??:
include/linux/blkdev.h:1459:65: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h:1460:20: warning: unused parameter a??ba?? [-Wunused-parameter]
include/linux/blkdev.h:1461:28: warning: unused parameter a??sa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??bdev_get_integritya??:
include/linux/blkdev.h:1465:77: warning: unused parameter a??ba?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_get_integritya??:
include/linux/blkdev.h:1469:71: warning: unused parameter a??diska?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_comparea??:
include/linux/blkdev.h:1473:57: warning: unused parameter a??aa?? [-Wunused-parameter]
include/linux/blkdev.h:1473:76: warning: unused parameter a??ba?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_registera??:
include/linux/blkdev.h:1477:58: warning: unused parameter a??da?? [-Wunused-parameter]
include/linux/blkdev.h:1478:29: warning: unused parameter a??ba?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_unregistera??:
include/linux/blkdev.h:1482:61: warning: unused parameter a??da?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_queue_max_integrity_segmentsa??:
include/linux/blkdev.h:1485:75: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h:1486:24: warning: unused parameter a??segsa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??queue_max_integrity_segmentsa??:
include/linux/blkdev.h:1489:81: warning: unused parameter a??qa?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_merge_rqa??:
include/linux/blkdev.h:1493:64: warning: unused parameter a??rqa?? [-Wunused-parameter]
include/linux/blkdev.h:1494:23: warning: unused parameter a??r1a?? [-Wunused-parameter]
include/linux/blkdev.h:1495:23: warning: unused parameter a??r2a?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_merge_bioa??:
include/linux/blkdev.h:1499:65: warning: unused parameter a??rqa?? [-Wunused-parameter]
include/linux/blkdev.h:1500:24: warning: unused parameter a??ra?? [-Wunused-parameter]
include/linux/blkdev.h:1501:20: warning: unused parameter a??ba?? [-Wunused-parameter]
include/linux/blkdev.h: In function a??blk_integrity_is_initializeda??:
include/linux/blkdev.h:1505:65: warning: unused parameter a??ga?? [-Wunused-parameter]
In file included from mm/vmscan.c:45:0:
include/linux/prefetch.h: In function a??prefetch_rangea??:
include/linux/prefetch.h:53:41: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/prefetch.h:53:54: warning: unused parameter a??lena?? [-Wunused-parameter]
In file included from mm/vmscan.c:50:0:
include/linux/swapops.h: In function a??make_hwpoison_entrya??:
include/linux/swapops.h:177:60: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/swapops.h: In function a??is_hwpoison_entrya??:
include/linux/swapops.h:182:49: warning: unused parameter a??swpa?? [-Wunused-parameter]
In file included from mm/vmscan.c:55:0:
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_kswapd_sleepa??:
include/trace/events/vmscan.h:39:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_kswapd_wakea??:
include/trace/events/vmscan.h:56:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_wakeup_kswapda??:
include/trace/events/vmscan.h:75:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_direct_reclaim_begina??:
include/trace/events/vmscan.h:123:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_memcg_reclaim_begina??:
include/trace/events/vmscan.h:130:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_memcg_softlimit_reclaim_begina??:
include/trace/events/vmscan.h:137:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_direct_reclaim_enda??:
include/trace/events/vmscan.h:161:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_memcg_reclaim_enda??:
include/trace/events/vmscan.h:168:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_memcg_softlimit_reclaim_enda??:
include/trace/events/vmscan.h:175:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_shrink_slab_starta??:
include/trace/events/vmscan.h:182:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_shrink_slab_enda??:
include/trace/events/vmscan.h:227:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_lru_isolatea??:
include/trace/events/vmscan.h:298:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_memcg_isolatea??:
include/trace/events/vmscan.h:311:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_writepagea??:
include/trace/events/vmscan.h:324:1: warning: unused parameter a??cba?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??check_trace_callback_type_mm_vmscan_lru_shrink_inactivea??:
include/trace/events/vmscan.h:347:1: warning: unused parameter a??cba?? [-Wunused-parameter]
In file included from include/linux/ring_buffer.h:4:0,
                 from include/linux/ftrace_event.h:4,
                 from include/trace/ftrace.h:19,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/linux/kmemcheck.h: In function a??kmemcheck_alloc_shadowa??:
include/linux/kmemcheck.h:93:37: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/kmemcheck.h:93:47: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/kmemcheck.h:93:60: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/linux/kmemcheck.h:93:71: warning: unused parameter a??nodea?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_free_shadowa??:
include/linux/kmemcheck.h:98:36: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/linux/kmemcheck.h:98:46: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_slab_alloca??:
include/linux/kmemcheck.h:103:41: warning: unused parameter a??sa?? [-Wunused-parameter]
include/linux/kmemcheck.h:103:50: warning: unused parameter a??gfpflagsa?? [-Wunused-parameter]
include/linux/kmemcheck.h:103:66: warning: unused parameter a??objecta?? [-Wunused-parameter]
include/linux/kmemcheck.h:104:15: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_slab_freea??:
include/linux/kmemcheck.h:108:59: warning: unused parameter a??sa?? [-Wunused-parameter]
include/linux/kmemcheck.h:108:68: warning: unused parameter a??objecta?? [-Wunused-parameter]
include/linux/kmemcheck.h:109:19: warning: unused parameter a??sizea?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_pagealloc_alloca??:
include/linux/kmemcheck.h:113:59: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/kmemcheck.h:114:15: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/linux/kmemcheck.h:114:28: warning: unused parameter a??gfpflagsa?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_page_is_trackeda??:
include/linux/kmemcheck.h:118:59: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_unallocateda??:
include/linux/kmemcheck.h:123:53: warning: unused parameter a??addressa?? [-Wunused-parameter]
include/linux/kmemcheck.h:123:75: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_uninitializeda??:
include/linux/kmemcheck.h:127:55: warning: unused parameter a??addressa?? [-Wunused-parameter]
include/linux/kmemcheck.h:127:77: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_initializeda??:
include/linux/kmemcheck.h:131:53: warning: unused parameter a??addressa?? [-Wunused-parameter]
include/linux/kmemcheck.h:131:75: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_freeda??:
include/linux/kmemcheck.h:135:47: warning: unused parameter a??addressa?? [-Wunused-parameter]
include/linux/kmemcheck.h:135:69: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_unallocated_pagesa??:
include/linux/kmemcheck.h:139:66: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/kmemcheck.h:140:24: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_uninitialized_pagesa??:
include/linux/kmemcheck.h:144:68: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/kmemcheck.h:145:26: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_mark_initialized_pagesa??:
include/linux/kmemcheck.h:149:66: warning: unused parameter a??pa?? [-Wunused-parameter]
include/linux/kmemcheck.h:150:24: warning: unused parameter a??na?? [-Wunused-parameter]
include/linux/kmemcheck.h: In function a??kmemcheck_is_obj_initializeda??:
include/linux/kmemcheck.h:154:63: warning: unused parameter a??addra?? [-Wunused-parameter]
include/linux/kmemcheck.h:154:76: warning: unused parameter a??sizea?? [-Wunused-parameter]
In file included from include/linux/ring_buffer.h:6:0,
                 from include/linux/ftrace_event.h:4,
                 from include/trace/ftrace.h:19,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/linux/seq_file.h: In function a??seq_user_nsa??:
include/linux/seq_file.h:136:67: warning: unused parameter a??seqa?? [-Wunused-parameter]
In file included from include/linux/ftrace_event.h:4:0,
                 from include/trace/ftrace.h:19,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/linux/ring_buffer.h: In function a??ring_buffer_swap_cpua??:
include/linux/ring_buffer.h:150:42: warning: unused parameter a??buffer_aa?? [-Wunused-parameter]
include/linux/ring_buffer.h:151:28: warning: unused parameter a??buffer_ba?? [-Wunused-parameter]
include/linux/ring_buffer.h:151:42: warning: unused parameter a??cpua?? [-Wunused-parameter]
In file included from include/linux/perf_event.h:35:0,
                 from include/linux/ftrace_event.h:8,
                 from include/trace/ftrace.h:19,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
/root/linux-next/arch/x86/include/asm/hw_breakpoint.h: In function a??hw_breakpoint_slotsa??:
/root/linux-next/arch/x86/include/asm/hw_breakpoint.h:45:43: warning: unused parameter a??typea?? [-Wunused-parameter]
In file included from include/linux/ftrace.h:10:0,
                 from include/linux/perf_event.h:47,
                 from include/linux/ftrace_event.h:8,
                 from include/trace/ftrace.h:19,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/linux/kallsyms.h: In function a??__check_printsym_formata??:
include/linux/kallsyms.h:112:42: warning: unused parameter a??fmta?? [-Wunused-parameter]
In file included from include/linux/perf_event.h:47:0,
                 from include/linux/ftrace_event.h:8,
                 from include/trace/ftrace.h:19,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/linux/ftrace.h: In function a??skip_tracea??:
include/linux/ftrace.h:531:44: warning: unused parameter a??ipa?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_release_moda??:
include/linux/ftrace.h:535:54: warning: unused parameter a??moda?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??register_ftrace_commanda??:
include/linux/ftrace.h:536:71: warning: unused parameter a??cmda?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??unregister_ftrace_commanda??:
include/linux/ftrace.h:540:51: warning: unused parameter a??cmd_namea?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_text_reserveda??:
include/linux/ftrace.h:544:46: warning: unused parameter a??starta?? [-Wunused-parameter]
include/linux/ftrace.h:544:59: warning: unused parameter a??enda?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_locationa??:
include/linux/ftrace.h:548:59: warning: unused parameter a??ipa?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_filter_writea??:
include/linux/ftrace.h:565:56: warning: unused parameter a??filea?? [-Wunused-parameter]
include/linux/ftrace.h:565:81: warning: unused parameter a??ubufa?? [-Wunused-parameter]
include/linux/ftrace.h:566:15: warning: unused parameter a??cnta?? [-Wunused-parameter]
include/linux/ftrace.h:566:28: warning: unused parameter a??pposa?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_notrace_writea??:
include/linux/ftrace.h:567:57: warning: unused parameter a??filea?? [-Wunused-parameter]
include/linux/ftrace.h:567:82: warning: unused parameter a??ubufa?? [-Wunused-parameter]
include/linux/ftrace.h:568:16: warning: unused parameter a??cnta?? [-Wunused-parameter]
include/linux/ftrace.h:568:29: warning: unused parameter a??pposa?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_regex_releasea??:
include/linux/ftrace.h:570:36: warning: unused parameter a??inodea?? [-Wunused-parameter]
include/linux/ftrace.h:570:56: warning: unused parameter a??filea?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??__ftrace_enabled_restorea??:
include/linux/ftrace.h:601:49: warning: unused parameter a??enableda?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??time_hardirqs_ona??:
include/linux/ftrace.h:632:53: warning: unused parameter a??a0a?? [-Wunused-parameter]
include/linux/ftrace.h:632:71: warning: unused parameter a??a1a?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??time_hardirqs_offa??:
include/linux/ftrace.h:633:54: warning: unused parameter a??a0a?? [-Wunused-parameter]
include/linux/ftrace.h:633:72: warning: unused parameter a??a1a?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_graph_init_taska??:
include/linux/ftrace.h:761:63: warning: unused parameter a??ta?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_graph_exit_taska??:
include/linux/ftrace.h:762:63: warning: unused parameter a??ta?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??ftrace_graph_init_idle_taska??:
include/linux/ftrace.h:763:68: warning: unused parameter a??ta?? [-Wunused-parameter]
include/linux/ftrace.h:763:75: warning: unused parameter a??cpua?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??register_ftrace_grapha??:
include/linux/ftrace.h:765:64: warning: unused parameter a??retfunca?? [-Wunused-parameter]
include/linux/ftrace.h:766:29: warning: unused parameter a??entryfunca?? [-Wunused-parameter]
include/linux/ftrace.h: In function a??task_curr_ret_stacka??:
include/linux/ftrace.h:772:59: warning: unused parameter a??tska?? [-Wunused-parameter]
In file included from include/trace/ftrace.h:285:0,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_kswapd_sleepa??:
include/trace/events/vmscan.h:39:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_kswapd_wakea??:
include/trace/events/vmscan.h:56:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_wakeup_kswapda??:
include/trace/events/vmscan.h:75:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_direct_reclaim_begin_templatea??:
include/trace/events/vmscan.h:99:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_direct_reclaim_end_templatea??:
include/trace/events/vmscan.h:144:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_shrink_slab_starta??:
include/trace/events/vmscan.h:182:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_shrink_slab_enda??:
include/trace/events/vmscan.h:227:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_lru_isolate_templatea??:
include/trace/events/vmscan.h:260:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_writepagea??:
include/trace/events/vmscan.h:324:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_raw_output_mm_vmscan_lru_shrink_inactivea??:
include/trace/events/vmscan.h:347:1: warning: unused parameter a??flagsa?? [-Wunused-parameter]
In file included from include/trace/ftrace.h:393:0,
                 from include/trace/define_trace.h:86,
                 from include/trace/events/vmscan.h:383,
                 from mm/vmscan.c:55:
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_kswapd_sleepa??:
include/trace/events/vmscan.h:39:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:39:1: warning: unused parameter a??nida?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_kswapd_wakea??:
include/trace/events/vmscan.h:56:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:56:1: warning: unused parameter a??nida?? [-Wunused-parameter]
include/trace/events/vmscan.h:56:1: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_wakeup_kswapda??:
include/trace/events/vmscan.h:75:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:75:1: warning: unused parameter a??nida?? [-Wunused-parameter]
include/trace/events/vmscan.h:75:1: warning: unused parameter a??zida?? [-Wunused-parameter]
include/trace/events/vmscan.h:75:1: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_direct_reclaim_begin_templatea??:
include/trace/events/vmscan.h:99:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:99:1: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/trace/events/vmscan.h:99:1: warning: unused parameter a??may_writepagea?? [-Wunused-parameter]
include/trace/events/vmscan.h:99:1: warning: unused parameter a??gfp_flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_direct_reclaim_end_templatea??:
include/trace/events/vmscan.h:144:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:144:1: warning: unused parameter a??nr_reclaimeda?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_shrink_slab_starta??:
include/trace/events/vmscan.h:182:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??shra?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??sca?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??nr_objects_to_shrinka?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??pgs_scanneda?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??lru_pgsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??cache_itemsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??deltaa?? [-Wunused-parameter]
include/trace/events/vmscan.h:182:1: warning: unused parameter a??total_scana?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_shrink_slab_enda??:
include/trace/events/vmscan.h:227:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:227:1: warning: unused parameter a??shra?? [-Wunused-parameter]
include/trace/events/vmscan.h:227:1: warning: unused parameter a??shrinker_retvala?? [-Wunused-parameter]
include/trace/events/vmscan.h:227:1: warning: unused parameter a??unused_scan_cnta?? [-Wunused-parameter]
include/trace/events/vmscan.h:227:1: warning: unused parameter a??new_scan_cnta?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_lru_isolate_templatea??:
include/trace/events/vmscan.h:260:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:260:1: warning: unused parameter a??ordera?? [-Wunused-parameter]
include/trace/events/vmscan.h:260:1: warning: unused parameter a??nr_requesteda?? [-Wunused-parameter]
include/trace/events/vmscan.h:260:1: warning: unused parameter a??nr_scanneda?? [-Wunused-parameter]
include/trace/events/vmscan.h:260:1: warning: unused parameter a??nr_takena?? [-Wunused-parameter]
include/trace/events/vmscan.h:260:1: warning: unused parameter a??isolate_modea?? [-Wunused-parameter]
include/trace/events/vmscan.h:260:1: warning: unused parameter a??filea?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_writepagea??:
include/trace/events/vmscan.h:324:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:324:1: warning: unused parameter a??pagea?? [-Wunused-parameter]
include/trace/events/vmscan.h:324:1: warning: unused parameter a??reclaim_flagsa?? [-Wunused-parameter]
include/trace/events/vmscan.h: In function a??ftrace_get_offsets_mm_vmscan_lru_shrink_inactivea??:
include/trace/events/vmscan.h:347:1: warning: unused parameter a??__data_offsetsa?? [-Wunused-parameter]
include/trace/events/vmscan.h:347:1: warning: unused parameter a??nida?? [-Wunused-parameter]
include/trace/events/vmscan.h:347:1: warning: unused parameter a??zida?? [-Wunused-parameter]
include/trace/events/vmscan.h:347:1: warning: unused parameter a??nr_scanneda?? [-Wunused-parameter]
include/trace/events/vmscan.h:347:1: warning: unused parameter a??nr_reclaimeda?? [-Wunused-parameter]
include/trace/events/vmscan.h:347:1: warning: unused parameter a??prioritya?? [-Wunused-parameter]
include/trace/events/vmscan.h:347:1: warning: unused parameter a??reclaim_flagsa?? [-Wunused-parameter]
mm/vmscan.c: In function a??global_reclaima??:
mm/vmscan.c:143:49: warning: unused parameter a??sca?? [-Wunused-parameter]
mm/vmscan.c: In function a??may_write_to_queuea??:
mm/vmscan.c:364:31: warning: unused parameter a??sca?? [-Wunused-parameter]
mm/vmscan.c: In function a??throttle_direct_reclaima??:
mm/vmscan.c:2507:18: warning: unused parameter a??nodemaska?? [-Wunused-parameter]
mm/vmscan.c: In function a??cpu_callbacka??:
mm/vmscan.c:3381:48: warning: unused parameter a??nfba?? [-Wunused-parameter]
mm/vmscan.c:3382:10: warning: unused parameter a??hcpua?? [-Wunused-parameter]
mm/vmscan.c: In function a??read_scan_unevictable_nodea??:
mm/vmscan.c:3763:58: warning: unused parameter a??deva?? [-Wunused-parameter]
mm/vmscan.c:3764:33: warning: unused parameter a??attra?? [-Wunused-parameter]
mm/vmscan.c: In function a??write_scan_unevictable_nodea??:
mm/vmscan.c:3771:59: warning: unused parameter a??deva?? [-Wunused-parameter]
mm/vmscan.c:3772:34: warning: unused parameter a??attra?? [-Wunused-parameter]
mm/vmscan.c:3773:18: warning: unused parameter a??bufa?? [-Wunused-parameter]
mm/vmscan.c:3773:30: warning: unused parameter a??counta?? [-Wunused-parameter]

In file included from /root/linux-next/arch/x86/include/asm/bitops.h:16:0,
                 from include/linux/bitops.h:22,
                 from include/linux/kernel.h:10,
                 from include/asm-generic/bug.h:13,
                 from /root/linux-next/arch/x86/include/asm/bug.h:38,
                 from include/linux/bug.h:4,
                 from include/linux/thread_info.h:11,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/wait.h:7,
                 from include/linux/fs.h:6,
                 from mm/shmem.c:24:

--------------070505090509030405020205--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
