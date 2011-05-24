Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4393E6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 19:55:49 -0400 (EDT)
Date: Tue, 24 May 2011 16:55:43 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 3/3] Add documentation and credits for BadRAM
Message-Id: <20110524165543.3c31d9ea.rdunlap@xenotime.net>
In-Reply-To: <1306236048-18150-4-git-send-email-sassmann@kpanic.de>
References: <1306236048-18150-1-git-send-email-sassmann@kpanic.de>
	<1306236048-18150-4-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: linux-mm@kvack.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org

On Tue, 24 May 2011 13:20:48 +0200 Stefan Assmann wrote:

> Add Documentation/BadRAM.txt for in-depth information and update
> Documentation/kernel-parameters.txt.
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  CREDITS                             |    9 +
>  Documentation/BadRAM.txt            |  370 +++++++++++++++++++++++++++++++++++
>  Documentation/kernel-parameters.txt |    6 +
>  3 files changed, 385 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/BadRAM.txt
> 
> diff --git a/CREDITS b/CREDITS
> index dca6abc..d57d4af 100644
> --- a/CREDITS
> +++ b/CREDITS
> @@ -2899,6 +2899,15 @@ S: 6 Karen Drive
>  S: Malvern, Pennsylvania 19355
>  S: USA
>  
> +N: Rick van Rein
> +E: rick@vanrein.org
> +W: http://rick.vanrein.org/
> +D: Memory, the BadRAM subsystem dealing with defective RAM modules.
> +S: Haarlebrink 5
> +S: 7544 WP  Enschede
> +S: The Netherlands
> +P: 1024D/89754606  CD46 B5F2 E876 A5EE 9A85  1735 1411 A9C2 8975 4606
> +
>  N: Stefan Reinauer
>  E: stepan@linux.de
>  W: http://www.freiburg.linux.de/~stepan/
> diff --git a/Documentation/BadRAM.txt b/Documentation/BadRAM.txt
> new file mode 100644
> index 0000000..3fb4994
> --- /dev/null
> +++ b/Documentation/BadRAM.txt
> @@ -0,0 +1,370 @@
> +INFORMATION ON USING BAD RAM MODULES
> +====================================
> +
> +The BadRAM feature enables Linux to run on broken memory.  The
> +resulting system will be stable and healthy, because the kernel
> +simply never allocates the faulty pages for use.  This is how
> +to setup BadRAM if your memory is failing.
> +
> +
> +Introduction
> +------------
> +
> +As RAM memory grows smaller, it also becomes harder to manufacture
> +chips that are perfect.  Each single cell that is failing could cause
> +an entire memory module to fail.  Even though manufacturers put in
> +extra cells to replace failed ones, it is still possible that the
> +sensitive small structures get damaged by an electric discharge on

I would say:                                    electrical
but I can't say why...

> +their pins.  Such damage leads to problems in fixed locations of
> +the address space of a memory module, which is what theory predicts
> +and has been confirmed by years of experience with bad memory.
> +
> +It is not necessary for such a memory module to be discarded.  All
> +pages of memory behave the same, and if only we skip the failing
> +pages we can continue to use the module for many more years.  The
> +operating system kernel simply has to avoid using the blocks that
> +are damaged.  This is easy to do in the part of the kernel where
> +memory pages are allocated.
> +
> +
> +Reasons for using BadRAM
> +------------------------
> +
> +Chip manufacturing processes use lots of harsh chemicals, and the less
> +of these used, the better.  Being able to make good use of partially
> +failed memory chips means that far less of those chemicals are needed
> +to provide storage.  This reduces expenses and it is lighter on the
> +environment in which we live.
> +
> +This kernel feature clearly shows that Linux is "the flexible OS".
> +If something does not work, fix it.  Also, share it with all the
> +others that could use it.  After more than a decennium of BadRAM,

          who                                   or decade

> +the response has been purely positive, because it has helped real
> +people to solve real problems.
> +
> +One important use for this feature is with laptops that have their
> +memory soldered in.  Such laptops would have to be discarded as a
> +whole, but with BadRAM in place they can continue to be used
> +without further restrictions.
> +
> +Finally, running a system on broken memory is just plain cool ;-)
> +
> +
> +Running example
> +---------------
> +
> +To run this project, I was given two DIMMs, 32 MB each. One, that we
> +shall use as a running example in this text, contained 512 faulty bits,
> +spread over 1/4 of the address range in a regular pattern.  This looks
> +a lot like the fauly pattern that many others have reported; the only
> +common other pattern is a single faulty spot.  With such memory, a few
> +tricks with a thorough RAM tester and some binary calculations suffice
> +to write these fault patterns down in 2 longword numbers.  The format
> +of these is hexadecimal, which is a condensed way of writing down the
> +binary patterns that make the hardware patterns recognisable.
> +
> +After being patched and invoked with the properly formatted description,
> +the kernel held back only the memory pages with faults, and never handed
> +them out for allocation. The allocation routines could therefore
> +progress as normally, without any adaption.  This is important, since

                                     adaptation.

> +all the work is done at booting time.  After booting, the kernel does
> +not have to do spend any time to implement BadRAM.
> +
> +As a result of this initial exercise, I gained 30 MB out of the 32 MB
> +DIMM that would otherwise have been thrown away.  Of course, these
> +numbers scale up with larger memory modules, but the principle is
> +the same.
> +
> +
> +The structure of memory failures
> +--------------------------------
> +
> +Memory chips are usually laid out in a roughly equal number of rows
> +and columns, making it a square of cells that each store one bit.
> +When addressing a bit, the processor sends the row and column in
> +separate phases, and then reads or writes its value.  The rows and
> +columns are therefore visible on the outside of a chip.
> +
> +The connections of row and column lines to the outside world is
> +usually protected by a buffer.  It can happen that a static
> +discharge damages such a buffer, causing an entire row or an
> +entire column to fail.  This means that a series of bits become
> +unusable in a single page or in a regular pattern of pages,
> +depending on whether it was a row or column that got damaged.
> +
> +For this reason, BadRAM was designed to describe memory faults
> +in a pattern of address/mask pairs.  An address locates an
> +error and a zero on the corresponding position in the mask
> +defines which bits in the address may be replaced with any
> +other value.  This has shown to work as a tight description
> +of error patterns: it is very compact, but does not waste pages
> +that are good.
> +
> +
> +BadRAM's notation for memory faults
> +-----------------------------------
> +
> +Instead of manually providing all 512 errors in the running example
> +to the kernel, it's easier to use a pattern notation. Since the
> +regularity is based on address decoding software, which generally
> +takes certain bits into account and ignores others, we shall
> +provide a faulty address F, together with a bit mask M that
> +specifies which bits must be equal to F. In C code, an address A
> +is faulty if and only if
> +
> +	(F & M) == (A & M)
> +
> +or alternately (closer to a hardware implementation):
> +
> +	~((F ^ A) & M)
> +
> +In the example 32 MB chip, I had the faulty addresses in 8MB-16MB:
> +
> +	xxx42f4         ....0100....
> +	xxx62f4         ....0110....
> +	xxxc2f4         ....1100....
> +	xxxe2f4         ....1110....
> +
> +The second column represents the alternating hex digit in binary form.
> +Apparently, the first and next to last binary digit can be anything,
> +so the binary mask for that part is 0101. The mask for the part after
> +this is 0xfff, and the part before should select anything in the range
> +8MB-16MB, or 0x00800000-0x01000000; this is done with a bitmask
> +0xff80xxxx. Combining these partial masks, we get:
> +
> +	F=0x008042f4    M=0xff805fff
> +
> +That covers every fault in this DIMM; for more complicated failing
> +DIMMs, or for a combination of multiple failing DIMMs, it can be
> +necessary to set up a number of such F/M pairs.
> +
> +
> +Getting started
> +---------------
> +
> +If you experience RAM trouble, first read Documentation/memory.txt
> +and try out the mem=4M trick to see if at least some initial parts
> +of your RAM work well.  Note that 4 MB will not be able to hold a
> +modern desktop, so if you rely on that you would have to set the
> +limit higher (and accept that your sanity check is not as tight as
> +possible).
> +
> +The BadRAM routines halt the kernel in panic if the reserved area
> +of memory (containing kernel stuff) contains a faulty address.  It
> +will only do that when supplied with the patterns below; this
> +initial check is merely to see if this is likely to happen.
> +
> +
> +Running a memory checker
> +------------------------
> +
> +There is no memory checker built into the kernel, to avoid delays
> +at runtime or while booting. If you experience problems that may
> +be caused by RAM, run a good outside RAM checker.  The Memtest86
> +checker is a popular, free, high-quality checker.  Many Linux
> +distributions include it as an alternate boot option, so you may
> +simply find it in your boot loader's boot menu.
> +
> +
> +The memory checker lists all addresses that have a fault.  It will
> +do this for a given configuration of the DIMMs in your motherboard;
> +if you replace or move memory modules you may find other addresses.
> +In the running example's 32 MB chip, with the DIMM in slot #0 on
> +the motherboard, the errors were found in the 8MB-16MB range:
> +
> +	xxx42f4
> +	xxx62f4
> +	xxxc2f4
> +	xxxe2f4
> +
> +The error reported was a "sticky 1 bit", a memory bit that always
> +reads as "1" even if a "0" was just written to it.  This is
> +probably caused by a damaged buffer on one of the rows or columns
> +in one of the memory chips.
> +
> +It would be a lot of work to collect the individual errors and
> +condense them into a pattern.  That is why I patched the
> +Memtest86 (v2.3+) checker to directly print out the address/mask
> +pairs that are used by this kernel feature. All you would do is
> +select the BadRAM printout option at the start of the scan, and
> +then leave it running for hours and hours, until it has made at
> +least one pass.  The patterns are printed each time a bit is
> +added, but each line contains all faults found up to that point,
> +so you would write down the last set of patterns printed, and
> +supply that as a boot option in your next run of a
> +BadRAM-capable Linux kernel.
> +
> +If you use this patch on an x86_64 architecture, your addresses are
> +twice as long.  Fill up with zeroes in the address and with f's in
> +the mask.  The latter example would thus become:
> +
> +	mem=24M badram=0x0000000000f00000,0xfffffffffff00000
> +
> +The patch applies the changes to both x86 and x86_64 code bases
> +at the same time.  Patching but not compiling maps the entire
> +source tree at once, which makes more sense than splitting the
> +patch into an x86 and x86_64 branch, because those two branches
> +could not be applied at the same time because they would overlap.
> +
> +
> +Rebooting Linux
> +---------------
> +
> +Once the fault patterns are known we simply restart Linux with
> +these F/M pairs as a parameter If your normal boot options look

                        parameter. If

> +like
> +
> +       root=/dev/sda1 ro
> +
> +you should now boot with options
> +
> +       root=/dev/sda1 ro badram=0x008042f4,0xff805fff
> +
> +or perhaps by mentioning more F/M pairs in an order F0,M0,F1,M1,...
> +When you provide an odd number of arguments to badram, the default
> +mask 0xffffffff (meaning that only one address is matched) is
> +applied to the last address.
> +
> +If your bootloader is GRUB, you can supply this additional
> +parameter interactively during boot.  This way, you can try them
> +before you edit /boot/grub/grub.conf to put them in forever.
> +
> +When the kernel now boots, it should not give any trouble with RAM.
> +Mind you, this is under the assumption that the kernel and its data
> +storage do not overlap an erroneous part. If they do, and the
> +kernel does not choke on it right away, BadRAM itself will stop the
> +system with a kernel panic.  When the error is that low in memory,
> +you will need additional bootloader magic, to load the kernel at an
> +alternative address.
> +
> +Now look up your memory status with
> +
> +	cat /proc/meminfo |grep HardwareCorrupted
> +
> +which prints a single line with information like
> +
> +HardwareCorrupted:  2048 kB
> +
> +The entry HardwareCorrupted: 2048k represents the loss of 2MB
> +of general purpose RAM due to the errors. Or, positively rephrased,
> +instead of throwing out 32MB as useless, you only throw out 2MB.
> +Note that 2048 kB equals 512 pages of 4kB.  The size of a page is
> +defined by the processor architecture.
> +
> +If the system is stable (which you can test by compiling a few
> +kernels, and a few file finds in / or so) you can decide to add
> +the boot parameter to /boot/grub/grub.conf, in addition to any
> +other boot parameters that may already be there.  For example,
> +
> +	kernel /boot/vmlinuz root=/dev/sda1 ro
> +
> +would become
> +
> +	kernel /boot/vmlinuz root=/dev/sda1 ro badram=0x008042f4,0xff805fff
> +
> +Depending on how helpful your Linux distribution is, you may
> +have to add this feature again after upgrading your kernel.  If
> +your boot loader is GRUB, you can always do this manually if you
> +rebooted before you remembered to make that adaption.

                                               adaptation.

> +
> +
> +BadRAM classification
> +---------------------
> +
> +This technique might start a lively market for "dead" RAM. It is
> +important to realise that some RAMs are more dead than others. So,
> +instead of just providing a RAM size, it is also important to know
> +the BadRAM class, which is defined as follows:
> +
> +	A BadRAM class N means that at most 2^N bytes have a problem,
> +	and that all problems with the RAMs are persistent: They
> +	are predictable and always show up.
> +
> +The DIMM that serves as an example here was of class 9, since 512=2^9
> +errors were found. Higher classes are worse, "correct" RAM is of class
> +-1 (or even less, at your choice).
> +Class N also means that the bitmask for your chip (if there's just one,
> +that is) counts N bits "0" and it means that (if no faults fall in the
> +same page) an amount of 2^N*PAGESIZE memory is lost, in the example on
> +an x86 architecture that would be 2^9*4k=2MB, which accounts for the
> +initial claim of 30MB RAM gained with this DIMM.
> +
> +Note that this scheme has deliberately been defined to be independent
> +of memory technology and of computer architecture.
> +
> +
> +Further Possibilities
> +---------------------
> +
> +**Slab allocation support**
> +
> +It would be possible to use even more of the faulty RAMs by employing
> +them for slabs. The smaller allocation granularity of slabs makes it
> +possible to throw out just, say, 32 bytes surrounding an error. This
> +would mean that the example DIMM only caused a loss of 16kB instead
> +of 2MB, or scaled-up similar values for larger memory sizes.  One
> +specific area that could benefit from this is the growing market
> +for embedded devices, which usually wants to meet tight budgets.
> +
> +It should be possible to make the slab allocator prefer pages with
> +broken memory, and allocate the faulty places in memory before the
> +other slabs are made available to the kernel.  In the best possible
> +situation, this could reduce the loss of good RAM cells to zero!
> +
> +**Support for low-memory errors**
> +
> +To the best of my knowledge, boot loaders like GRUB cannot load
> +the Linux kernel in non-standard locations.  This means that any
> +errors at low memory locations cannot be overcome with BadRAM.
> +
> +Anything that physically alters the memory layout can be used
> +to overcome such problems; this may be achieved through BIOS
> +settings, or by adding or swapping memory modules.
> +
> +A general solution could be to use a boot loader that can load
> +the Linux kernel (and its initial memory allocation) at other
> +memory addresses than are standard.
> +
> +
> +**Boot-time memory checking**
> +
> +Many suggestions have been made to insert a RAM checker at boot time;
> +since this would leave the time to do only very meager checking, it
> +is not a reasonable option; we already have a half-done BIOS check
> +doing that!
> +
> +**ECC RAM integration**
> +
> +It would be interesting to integrate this functionality with the
> +self-verifying nature of ECC RAM. These memories can even distinguish
> +between recoverable and unrecoverable errors! Such memory has been
> +handled in older operating systems by `testing' once-failed memory
> +blocks for a while, by placing only (reloadable) program code in it.
> +
> +I possess no faulty ECC modules to work this out, and there is no
> +general use for it either.
> +
> +
> +Names and Places
> +----------------
> +
> +The home page of this project is on
> +	http://rick.vanrein.org/linux/badram
> +This page also links to Nico Schmoigl's experimental extensions to
> +this patch (with debugging and a few other fancy things).
> +
> +In case you have experiences with the BadRAM software which differ from
> +the test reportings on that site, I hope you will mail me with that
> +new information.
> +
> +The BadRAM project is an idea and implementation by
> +	Rick van Rein
> +	Haarlebrink 5
> +	7544 WP  Enschede
> +	The Netherlands
> +	rick@vanrein.org
> +If you like it, a postcard would be much appreciated ;-)
> +
> +
> +							Enjoy,
> +							 -Rick.
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index cc85a92..ba3e984 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -51,6 +51,7 @@ parameter is applicable:
>  	FB	The frame buffer device is enabled.
>  	GCOV	GCOV profiling is enabled.
>  	HW	Appropriate hardware is enabled.
> +	HWPOISON Handling of memory pages reported as being corrupt

These entries are normally used as in my example below.  I'm not sure that
it makes sense here.

>  	IA-64	IA-64 architecture is enabled.
>  	IMA     Integrity measurement architecture is enabled.
>  	IOSCHED	More than one I/O scheduler is enabled.
> @@ -373,6 +374,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  
>  	autotest	[IA64]
>  
> +	badram=		When CONFIG_MEMORY_FAILURE is set, this parameter

        badram=		[HWPOISON] When CONFIG_MEMORY_FAILURE is set, this parameter

> +			allows memory areas to be flagged as HWPOISON.
> +			Format: <addr>,<mask>[,...]
> +			See Documentation/BadRAM.txt
> +
>  	baycom_epp=	[HW,AX25]
>  			Format: <io>,<mode>
>  
> -- 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
