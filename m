Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E80A46B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:49:59 -0400 (EDT)
Date: Wed, 27 Apr 2011 09:49:53 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC PATCH 3/3] Add documentation and credits for BadRAM
Message-Id: <20110427094953.57f01df1.rdunlap@xenotime.net>
In-Reply-To: <1303921007-1769-4-git-send-email-sassmann@kpanic.de>
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de>
	<1303921007-1769-4-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: linux-mm@kvack.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com

On Wed, 27 Apr 2011 18:16:47 +0200 Stefan Assmann wrote:

> Add Documentation/BadRAM.txt for in-depth information and update
> Documentation/kernel-parameters.txt.
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  CREDITS                             |    9 +
>  Documentation/BadRAM.txt            |  369 +++++++++++++++++++++++++++++++++++
>  Documentation/kernel-parameters.txt |    5 +
>  3 files changed, 383 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/BadRAM.txt

> diff --git a/Documentation/BadRAM.txt b/Documentation/BadRAM.txt
> new file mode 100644
> index 0000000..67a7ccc
> --- /dev/null
> +++ b/Documentation/BadRAM.txt
> @@ -0,0 +1,369 @@

> +Reasons for using BadRAM
> +------------------------
> +
> +Chip manufacturing process use lots of harsh chemicals, and the less

                      processes

> +of these used, the better.  Being able to make good use of partially
> +failed memory chips means that far less of those chemicals are needed
> +to provide storage.  This reduces expenses and it is lighter on the
> +environment in which we live.
> +
...

> +
> +
> +Running example
> +---------------
> +
...
> +
> +After being patched and invoked with the properly formatted description,
> +the kernel held back only the memory pages with faults, and never haded

                                                                     handed

> +them out for allocation. The allocation routines could therefore
> +progress as normally, without any adaption.  This is important, since
> +all the work is done at booting time.  After booting, the kernel does
> +not have to do spend any time to implement BadRAM.
> +
> +As a result of this initial exercise, I gained 30 MB out of the 32 MB
> +DIMM that would otherwise have been thrown away.  Of course, these
> +numbers scale up with larger memory modules, but the principle is
> +the same.
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
> +Apperantly, the first and next to last binary digit can be anything,

   Apparently,

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
> +Running a memory checker
> +------------------------
> +
> +There is no memory checker built into the kernel, to avoid delays
> +at runtime or while booting. If you experience problems that may
> +be caused by RAM, run a good outside RAM checker.  The Memtest86
> +checker is a popular, free, high-quality checker.  Many Linux
> +distributions include it as an alternate boot option, so you may
> +simply find it in your GRUB boot menu.

                          boot loader's boot menu.

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
...
> +
> +Rebooting Linux
> +---------------
> +
> +Once the fault patterns are known we simply restart Linux with
> +these F/M pairs as a parameter If your normal boot options look
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
> +before you edit /boot/grub/menu.lst to put them in forever.

I thought that /boot/grub/grub.conf was the current file name. (?)

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
> +the boot parameter to /boot/grub/menu.lst, in addition to any

file name?

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
> +
> +
...


> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index f4a04c0..84f9ef5 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -373,6 +373,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  
>  	autotest	[IA64]
>  
> +	badram=		When CONFIG_MEMORY_FAILURE is set, this parameter
> +			allows memory areas to be flagged as hwpoison.

hwpoison??  undefined.

> +			Format: <addr>,<mask>[,...]
> +			See Documentation/BadRAM.txt
> +


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
