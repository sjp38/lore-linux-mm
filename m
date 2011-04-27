Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 15FFB6B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:05:37 -0400 (EDT)
Message-ID: <4DB8770A.2080703@kpanic.de>
Date: Wed, 27 Apr 2011 22:05:30 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/3] Add documentation and credits for BadRAM
References: <1303921007-1769-1-git-send-email-sassmann@kpanic.de>	<1303921007-1769-4-git-send-email-sassmann@kpanic.de> <20110427094953.57f01df1.rdunlap@xenotime.net>
In-Reply-To: <20110427094953.57f01df1.rdunlap@xenotime.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-mm@kvack.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com

On 27.04.2011 18:49, Randy Dunlap wrote:
> On Wed, 27 Apr 2011 18:16:47 +0200 Stefan Assmann wrote:
> 
>> Add Documentation/BadRAM.txt for in-depth information and update
>> Documentation/kernel-parameters.txt.
>>
>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>> ---
>>  CREDITS                             |    9 +
>>  Documentation/BadRAM.txt            |  369 +++++++++++++++++++++++++++++++++++
>>  Documentation/kernel-parameters.txt |    5 +
>>  3 files changed, 383 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/BadRAM.txt
> 
>> diff --git a/Documentation/BadRAM.txt b/Documentation/BadRAM.txt
>> new file mode 100644
>> index 0000000..67a7ccc
>> --- /dev/null
>> +++ b/Documentation/BadRAM.txt
>> @@ -0,0 +1,369 @@
> 

[snip]

Spelling errors will be fixed in next version. Thanks!

> I thought that /boot/grub/grub.conf was the current file name. (?)

Not sure about that, some distros use menu.lst others grub.conf for
GRUB. Also GRUB 2 uses /boot/grub/grub.cfg. Either of these would be
fine with me, /boot/grub/menu.lst sometimes is a symlink to
/boot/grub/grub.conf and I felt it's the most convenient one, but I have
no strong preference here.

> 
>> +
>> +When the kernel now boots, it should not give any trouble with RAM.
>> +Mind you, this is under the assumption that the kernel and its data
>> +storage do not overlap an erroneous part. If they do, and the
>> +kernel does not choke on it right away, BadRAM itself will stop the
>> +system with a kernel panic.  When the error is that low in memory,
>> +you will need additional bootloader magic, to load the kernel at an
>> +alternative address.
>> +
>> +Now look up your memory status with
>> +
>> +	cat /proc/meminfo |grep HardwareCorrupted
>> +
>> +which prints a single line with information like
>> +
>> +HardwareCorrupted:  2048 kB
>> +
>> +The entry HardwareCorrupted: 2048k represents the loss of 2MB
>> +of general purpose RAM due to the errors. Or, positively rephrased,
>> +instead of throwing out 32MB as useless, you only throw out 2MB.
>> +Note that 2048 kB equals 512 pages of 4kB.  The size of a page is
>> +defined by the processor architecture.
>> +
>> +If the system is stable (which you can test by compiling a few
>> +kernels, and a few file finds in / or so) you can decide to add
>> +the boot parameter to /boot/grub/menu.lst, in addition to any
> 
> file name?

See above comment.

> 
>> +other boot parameters that may already be there.  For example,
>> +
>> +	kernel /boot/vmlinuz root=/dev/sda1 ro
>> +
>> +would become
>> +
>> +	kernel /boot/vmlinuz root=/dev/sda1 ro badram=0x008042f4,0xff805fff
>> +
>> +Depending on how helpful your Linux distribution is, you may
>> +have to add this feature again after upgrading your kernel.  If
>> +your boot loader is GRUB, you can always do this manually if you
>> +rebooted before you remembered to make that adaption.
>> +
>> +
> ...
> 
> 
>> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>> index f4a04c0..84f9ef5 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -373,6 +373,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  
>>  	autotest	[IA64]
>>  
>> +	badram=		When CONFIG_MEMORY_FAILURE is set, this parameter
>> +			allows memory areas to be flagged as hwpoison.
> 
> hwpoison??  undefined.

BadRAM depends on hwpoison to be available. The code is located in
mm/memory-failure.c. That file is only compiled if CONFIG_MEMORY_FAILURE
is defined.
grep CONFIG_MEMORY_FAILURE mm/Makefile
obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o

So for your question, if hwpoison is not available BadRAM also won't be
available.

> 
>> +			Format: <addr>,<mask>[,...]
>> +			See Documentation/BadRAM.txt
>> +
> 
> 
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***

Thanks for the review Randy!

  Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
