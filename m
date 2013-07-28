Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 0D9F26B0031
	for <linux-mm@kvack.org>; Sun, 28 Jul 2013 06:05:41 -0400 (EDT)
Message-ID: <51F4ECF2.6040408@parallels.com>
Date: Sun, 28 Jul 2013 14:05:38 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] pram: persistent over-kexec memory file system
References: <1374841763-11958-1-git-send-email-vdavydov@parallels.com> <51F3EA2A.3090905@gmail.com> <51F404D0.6070004@parallels.com> <51F40570.9050209@gmail.com>
In-Reply-To: <51F40570.9050209@gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com

On 07/27/2013 09:37 PM, Marco Stornelli wrote:
> Il 27/07/2013 19:35, Vladimir Davydov ha scritto:
>> On 07/27/2013 07:41 PM, Marco Stornelli wrote:
>>> Il 26/07/2013 14:29, Vladimir Davydov ha scritto:
>>>> Hi,
>>>>
>>>> We want to propose a way to upgrade a kernel on a machine without
>>>> restarting all the user-space services. This is to be done with CRIU
>>>> project, but we need help from the kernel to preserve some data in
>>>> memory while doing kexec.
>>>>
>>>> The key point of our implementation is leaving process memory in-place
>>>> during reboot. This should eliminate most io operations the services
>>>> would produce during initialization. To achieve this, we have
>>>> implemented a pseudo file system that preserves its content during
>>>> kexec. We propose saving CRIU dump files to this file system, 
>>>> kexec'ing
>>>> and then restoring the processes in the newly booted kernel.
>>>>
>>>
>>> http://pramfs.sourceforge.net/
>>
>> AFAIU it's a bit different thing: PRAMFS as well as pstore, which has
>> already been merged, requires hardware support for over-reboot
>> persistency, so called non-volatile RAM, i.e. RAM which is not directly
>> accessible and so is not used by the kernel. On the contrary, what we'd
>> like to have is preserving usual RAM on kexec. It is possible, because
>> RAM is not reset during kexec. This would allow leaving applications
>> working set as well as filesystem caches in place, speeding the reboot
>> process as a whole and reducing the downtime significantly.
>>
>> Thanks.
>
> Actually not. You can use normal system RAM reserved at boot with mem 
> parameter without any kernel change. Until an hard reset happens, that 
> area will be "persistent".

Thank you, we'll look at PRAMFS closer, but right now, after trying it I 
have a couple of concerns I'd appreciate if you could clarify:

1) As you advised, I tried to reserve a range of memory (passing 
memmap=4G$4G at boot) and mounted PRAMFS using the following options:

# mount -t pramfs -o physaddr=0x100000000,init=4G,bs=4096 none /mnt/pramfs

And it turned out that PRAMFS is very slow as compared to ramfs:

# dd if=/dev/zero of=/mnt/pramfs if=/dev/zero of=/mnt/pramfs/dummy 
bs=4096 count=$[100*1024]
102400+0 records in
102400+0 records out
419430400 bytes (419 MB) copied, 9.23498 s, 45.4 MB/s
# dd if=/dev/zero of=/mnt/pramfs if=/dev/zero of=/mnt/pramfs/dummy 
bs=4096 count=$[100*1024] conv=notrunc
102400+0 records in
102400+0 records out
419430400 bytes (419 MB) copied, 3.04692 s, 138 MB/s

We need it to be as fast as usual RAM, because otherwise the benefit of 
it over hdd disappears. So before diving into the code, I'd like to ask 
you if it's intrinsic to PRAMFS, or can it be fixed? Or, perhaps, I used 
wrong mount/boot/config options (btw, I enabled only CONFIG_PRAMFS)?

2) To enable saving application dump files in memory using PRAMFS, one 
should reserve half of RAM for it. That's too expensive. While with 
ramfs, once SPLICE_F_MOVE flag is implemented, one could move anonymous 
memory pages to ramfs page cache and after kexec move it back so that 
almost no extra memory space costs would be required. Of course, 
SPLICE_F_MOVE is to be yet implemented, but with PRAMFS significant 
memory costs are inevitable... or am I wrong?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
