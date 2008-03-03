Date: Mon, 3 Mar 2008 09:38:51 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
Message-Id: <20080303093851.b9ba55f3.randy.dunlap@oracle.com>
In-Reply-To: <20080302134221.GA25196@phantom.vanrein.org>
References: <20080302134221.GA25196@phantom.vanrein.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 2 Mar 2008 13:42:21 +0000 Rick van Rein wrote:

> This is the latest version of the BadRAM patch, which makes it possible to
> run Linux on broken memory.  The patch supports the use of a lesser grade
> of memory, which could be marketed more cheaply and which would thereby
> decrease the environmental stress caused by the process of (memory) chip
> manufacturing.

Patch needs to be made against (i.e., applyable against) the latest
linus-mainline kernel, not a few-weeks old kernel.
Of course, you could be lucky and it applies to either one.

> diff -pruN linux-2.6.24.orig/Documentation/badram.txt linux-2.6.24/Documentation/badram.txt
> --- linux-2.6.24.orig/Documentation/badram.txt	1969-12-31 19:00:00.000000000 -0500
> +++ linux-2.6.24/Documentation/badram.txt	2008-02-05 23:29:49.000000000 -0500
> @@ -0,0 +1,275 @@
> +INFORMATION ON USING BAD RAM MODULES
> +====================================
> +
> +
> +Initial checks
> +       If you experience RAM trouble, first read /usr/src/linux/memory.txt

Incorrect path.  Insert "Documentation/".  But we usually don't include
the full path (i.e., drop "/usr/src/linux" or say
"read Documentation/memory.txt in the kernel source tree".

> +       and try out the mem=4M trick to see if at least some initial parts
> +       of your RAM work well. The BadRAM routines halt the kernel in panic
> +       if the reserved area of memory (containing kernel stuff) contains
> +       a faulty address.
> +
> +Running a RAM checker
> +       The memory checker is not built into the kernel, to avoid delays at
> +       runtime. If you experience problems that may be caused by RAM, run
> +       a good RAM checker, such as
> +               http://reality.sgi.com/cbrady_denver/memtest86
> +       The output of a RAM checker provides addresses that went wrong. In
> +       the 32 MB chip with 512 faulty bits mentioned above, the errors were
> +       found in the 8MB-16MB range (the DIMM was in slot #0) at addresses
> +               xxx42f4
> +               xxx62f4
> +               xxxc2f4
> +               xxxe2f4
> +       and the error was a "sticky 1 bit", a memory bit that stayed "1" no
> +       matter what was written to it. The regularity of this pattern
> +       suggests the death of a buffer at the output stages of a row on one of
> +       the chips. I expect such regularity to be commonplace. Finding this
> +       regularity currently is human effort, but it should not be hard to
> +       alter a RAM checker to capture it in some sort of pattern, possibly
> +       the BadRAM patterns described below.
> +
> +       By the way, if you manage to get hold of memtest86 version 2.3 or
> +       beyond, you can configure the printing mode to produce BadRAM patterns,
> +       which find out exactly what you must enter on the LILO: commandline,

Drop ":".

> +       except that you shouldn't mention the added spacing. That means that
> +       you can skip the following step, which saves you a *lot* of work.
> +
> +       Also by the way, if your machine has the ISA memory gap in the 15M-16M
> +       range unstoppable, Linux can get in trouble. One way of handling that
> +       situation is by specifying the total memory size to Linux with a boot
> +       parameter mem=... and then to tell it to treat the 15M-16M range as
> +       faulty with an additional boot parameter, for instance:
> +               mem=24M badram=0x00f00000,0xfff00000
> +       if you installed 24MB of RAM in total.
> +
> +
> +Capturing errors in a pattern
> +       Instead of manually providing all 512 errors to the kernel, it's nicer
> +       to generate a pattern. Since the regularity is based on address decoding
> +       software, which generally takes certain bits into account and ignores
> +       others, we shall provide a faulty address F, together with a bit mask M
> +       that specifies which bits must be equal to F. In C code, an address A
> +       is faulty if and only if
> +               (F & M) == (A & M)
> +       or alternately (closer to a hardware implementation):
> +               ~((F ^ A) & M)
> +       In the example 32 MB chip, we had the faulty addresses in 8MB-16MB:
> +               xxx42f4         ....0100....
> +               xxx62f4         ....0110....
> +               xxxc2f4         ....1100....
> +               xxxe2f4         ....1110....
> +       The second column represents the alternating hex digit in binary form.
> +       Apperantly, the first and one-but last binary digit can be anything,

          Apparently
s/one-but last/next to last/ ?

> +       so the binary mask for that part is 0101. The mask for the part after
> +       this is 0xfff, and the part before should select anything in the range
> +       8MB-16MB, or 0x00800000-0x01000000; this is done with a bitmask
> +       0xff80xxxx. Combining these partial masks, we get:
> +               F=0x008042f4    M=0xff805fff
> +       That covers everything for this DIMM; for more complicated failing
> +       DIMMs, or for a combination of multiple failing DIMMs, it can be
> +       necessary to set up a number of such F/M pairs.
> +
> +Rebooting Linux
> +       Now that these patterns are known (and double-checked, the calculations
> +       are highly error-prone... it would be neat to test them in the RAM
> +       checker...) we simply restart Linux with these F/M pairs as a parameter

End above sentence with period (".").

> +       If you normally boot as follows:
> +              LILO: linux
> +       you should now boot with
> +              LILO: linux badram=0x008042f4,0xff805fff

Does the choice of bootloader matter?

> +       or perhaps by mentioning more F/M pairs in an order F0,M0,F1,M1,...
> +       When you provide an odd number of arguments to badram, the default mask
> +       0xffffffff (only one address matched) is applied to the pattern.
> +
> +       Beware of the commandline length. At least up to LILO version 0.21,
> +       the commandline is cut off after the 78th character; later versions
> +       may go as far as the kernel goes, namely 255 characters. In no way is
> +       it possible to enter more than 10 numbers to the badram boot option.

x86 command line length is now 2048.
I don't know if bootloaders can handle that.

> +       When the kernel now boots, it should not give any trouble with RAM.
> +       Mind you, this is under the assumption that the kernel and its data
> +       storage do not overlap an erroneous part. If this happens, and the
> +       kernel does not choke on it right away, it will stop with a panic.
> +       You will need to provide a RAM where the initial, say 2MB, is faultless

End with period (".").

> +
> +       Now look up your memory status with
> +              dmesg | grep ^Memory:
> +       which prints a single line with information like
> +               Memory: 158524k/163840k available
> +                       (940k kernel code,
> +                       412k reserved,
> +                       1856k data,
> +                       60k init,
> +                       0k highmem,
> +                       2048k BadRAM)

> +Known Bugs
> +       LILO is known to cut off commandlines which are too long. For the
> +       lilo-0.21 distribution, a commandline may not exceed 78 characters,
> +       while actually, 255 would be possible [on x86, kernel 2.2.16].

Ancient kernel alert.

> +       LILO does _not_ report too-long commandlines, but the error will
> +       show up as either a panic at boot time, stating
> +               panic: BadRAM page in initial area
> +       or the dmesg line starting with Memory: will mention an unpredicted
> +       number of kilobytes. (Note that the latter number only includes
> +       errors in accessed memory.)
> +
> +Future Possibilities
> +       It would be possible to use even more of the faulty RAMs by employing
> +       them for slabs. The smaller allocation granularity of slabs makes it
> +       possible to throw out just, say, 32 bytes surrounding an error. This
> +       would mean that the example DIMM only looses 16kB instead of 2MB.

                                                loses

> +       It might even be possible to allocate the slabs in such a way that,
> +       where possible, the remaining bytes in a slab structure are allocated
> +       around the error, reducing the RAM loss to 0 in the optimal situation!
> +
> +       However, this yield is somewhat faked: It is possible to provide 512
> +       pages of 32-byte slabs, but it is not certain that anyone would use
> +       that many 32-byte slabs at any time.
> +
> +       A better solution might be to alter the page allocation for a slab to
> +       have a preference for BadRAM pages, and given those a special treatment.
> +       This way, the BadRAM would be spread over all the slabs, which seems
> +       more likely to be a `true' pay-off. This would yield more overhead at
> +       slab allocation time, but on the other hand, by the nature of slabs,
> +       such allocations are made as rare as possible, so it might not matter
> +       that much. I am uncertain where to go.
> +
> +       Many suggestions have been made to insert a RAM checker at boot time;
> +       since this would leave the time to do only very meager checking, it
> +       is not a reasonable option; we already have a BIOS doing that in most
> +       systems!
> +
> +       It would be interesting to integrate this functionality with the
> +       self-verifying nature of ECC RAM. These memories can even distinguish
> +       between recorable and unrecoverable errors! Such memory has been

                  recoverable

> +       handled in older operating systems by `testing' once-failed memory
> +       blocks for a while, by placing only (reloadable) program code in it.
> +       Unfortunately, I possess no faulty ECC modules to work this out.
> +

> diff -pruN linux-2.6.24.orig/Documentation/kernel-parameters.txt linux-2.6.24/Documentation/kernel-parameters.txt
> --- linux-2.6.24.orig/Documentation/kernel-parameters.txt	2008-01-24 17:58:37.000000000 -0500
> +++ linux-2.6.24/Documentation/kernel-parameters.txt	2008-02-05 23:33:55.000000000 -0500
> @@ -322,6 +323,8 @@ and is between 256 and 4096 characters. 
>  
>  	autotest	[IA64]
>  
> +	badram=		[BADRAM] Avoid allocating faulty RAM addresses.

			See Documentation/badram.txt for parameter details.

> +
>  	baycom_epp=	[HW,AX25]
>  			Format: <io>,<mode>
>  
> diff -pruN linux-2.6.24.orig/Documentation/memory.txt linux-2.6.24/Documentation/memory.txt
> --- linux-2.6.24.orig/Documentation/memory.txt	2008-01-24 17:58:37.000000000 -0500
> +++ linux-2.6.24/Documentation/memory.txt	2008-02-05 23:39:04.000000000 -0500
> @@ -18,11 +18,22 @@ systems.
>  	   as you add more memory.  Consider exchanging your 
>             motherboard.
>  
> +	4) A static discharge or production fault causes a RAM module
> +	  to have (predictable) errors, usually meaning that certain
> +	  bits cannot be set or reset. Instead of throwing away your
> +	  RAM module, you may read /usr/src/linux/Documentation/badram.txt
> +	  to learn how to detect, locate and circuimvent such errors

                                             circumvent

> +	  in your RAM module.
> +
> +
> diff -pruN linux-2.6.24.orig/include/asm-x86/page_32.h linux-2.6.24/include/asm-x86/page_32.h
> --- linux-2.6.24.orig/include/asm-x86/page_32.h	2008-01-24 17:58:37.000000000 -0500
> +++ linux-2.6.24/include/asm-x86/page_32.h	2008-02-05 23:43:00.000000000 -0500
> @@ -189,6 +189,7 @@ extern int page_is_ram(unsigned long pag
>  #define pfn_valid(pfn)		((pfn) < max_mapnr)
>  #endif /* CONFIG_FLATMEM */
>  #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
> +#define phys_to_page(x)         pfn_to_page((unsigned long)(x) >> PAGE_SHIFT)

Use tab(s), not spaces.

>  
>  #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
>  
> diff -pruN linux-2.6.24.orig/include/asm-x86/page_64.h linux-2.6.24/include/asm-x86/page_64.h
> --- linux-2.6.24.orig/include/asm-x86/page_64.h	2008-01-24 17:58:37.000000000 -0500
> +++ linux-2.6.24/include/asm-x86/page_64.h	2008-02-05 23:44:26.000000000 -0500
> @@ -126,6 +126,7 @@ extern unsigned long __phys_addr(unsigne
>  #endif
>  
>  #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
> +#define phys_to_page(x)         pfn_to_page((unsigned long)(x) >> PAGE_SHIFT)

Ditto.

>  #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
>  #define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
>  
> diff -pruN linux-2.6.24.orig/mm/page_alloc.c linux-2.6.24/mm/page_alloc.c
> --- linux-2.6.24.orig/mm/page_alloc.c	2008-01-24 17:58:37.000000000 -0500
> +++ linux-2.6.24/mm/page_alloc.c	2008-02-06 00:03:28.000000000 -0500
> @@ -4378,6 +4381,91 @@ EXPORT_SYMBOL(pfn_to_page);
>  EXPORT_SYMBOL(page_to_pfn);
>  #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
>  
> +
> +#ifdef CONFIG_BADRAM
> +
> +
> +void __init badram_markpages (int argc, unsigned long *argv) {
> +       unsigned long addr, mask;
> +       while (argc-- > 0) {
> +               addr = *argv++;
> +               mask = (argc-- > 0) ? *argv++ : ~0L;
> +               mask |= ~PAGE_MASK;     /* Optimalisation */

                                             Optimisation ?

> +               addr &= mask;           /* Normalisation */
> +               do {
> +                       struct page *pg = phys_to_page(addr);
> +                       printk(KERN_DEBUG "%016lx =%016lx\n",
> +                                       addr >> PAGE_SHIFT,
> +                                       (unsigned long)(pg-mem_map));
> +                       if (PageTestandSetBad (pg))
> +                               reserve_bootmem (addr, PAGE_SIZE);
> +               } while (next_masked_address (&addr,mask));
> +       }
> +}
> +
> +
> +
> +static int __init badram_setup (char *str)
> +{
> +       unsigned long opts[3];
> +       BUG_ON(!mem_map);
> +       printk (KERN_INFO "PAGE_OFFSET=0x%08lx\n", PAGE_OFFSET);
> +       printk (KERN_INFO "BadRAM option is %s\n", str);

No space after function name (2x).

> +       if (*str++ == '=')
> +               while ((str = get_longoptions (str, 3, (long *) opts), *opts)) {
> +                       printk (KERN_INFO "   --> marking 0x%08lx, 0x%08lx  [%ld]\n",
> +                                       opts[1], opts[2], opts[0]);
> +                       badram_markpages (*opts, opts+1);
> +                       if (*opts == 1)
> +                               break;
> +               };
> +       badram_markpages (*badram_custom, badram_custom+1);
> +       return 0;
> +}


---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
