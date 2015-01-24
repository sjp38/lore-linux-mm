Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4A86B006E
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 22:05:59 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id nt9so704382obb.9
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 19:05:58 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id x192si1694328oix.89.2015.01.23.19.05.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 19:05:58 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YEr2r-002Pft-Rz
	for linux-mm@kvack.org; Sat, 24 Jan 2015 03:05:58 +0000
Message-ID: <54C30C06.7010408@roeck-us.net>
Date: Fri, 23 Jan 2015 19:05:42 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>	<20150123050445.GA22751@roeck-us.net>	<20150123111304.GA5975@node.dhcp.inet.fi>	<54C263CC.1060904@roeck-us.net> <20150123135519.9f1061caf875f41f89298d59@linux-foundation.org> <54C3072A.1030604@roeck-us.net>
In-Reply-To: <54C3072A.1030604@roeck-us.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 01/23/2015 06:44 PM, Guenter Roeck wrote:
> On 01/23/2015 01:55 PM, Andrew Morton wrote:
>> On Fri, 23 Jan 2015 07:07:56 -0800 Guenter Roeck <linux@roeck-us.net> wrote:
>>
>>>>>
>>>>> qemu:microblaze generates warnings to the console.
>>>>>
>>>>> WARNING: CPU: 0 PID: 32 at mm/mmap.c:2858 exit_mmap+0x184/0x1a4()
>>>>>
>>>>> with various call stacks. See
>>>>> http://server.roeck-us.net:8010/builders/qemu-microblaze-mmotm/builds/15/steps/qemubuildcommand/logs/stdio
>>>>> for details.
>>>>
>>>> Could you try patch below? Completely untested.
>>>>
>>>> >From b584bb8d493794f67484c0b57c161d61c02599bc Mon Sep 17 00:00:00 2001
>>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>> Date: Fri, 23 Jan 2015 13:08:26 +0200
>>>> Subject: [PATCH] microblaze: define __PAGETABLE_PMD_FOLDED
>>>>
>>>> Microblaze uses custom implementation of PMD folding, but doesn't define
>>>> __PAGETABLE_PMD_FOLDED, which generic code expects to see. Let's fix it.
>>>>
>>>> Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
>>>> It also fixes problems with recently-introduced pmd accounting.
>>>>
>>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>> Reported-by: Guenter Roeck <linux@roeck-us.net>
>>>
>>> Tested working.
>>>
>>> Tested-by: Guenter Roeck <linux@roeck-us.net>
>>>
>>> Any idea how to fix the sh problem ?
>>
>> Can you tell us more about it?  All I'm seeing is "qemu:sh fails to
>> shut down", which isn't very clear.
>>
>
> qemu command line:
>
> /opt/buildbot/bin/qemu-system-sh4 -M r2d -kernel ./arch/sh/boot/zImage \
>          -drive file=rootfs.ext2,if=ide \
>          -append "root=/dev/sda console=ttySC1,115200 noiotrap"
>          -serial null -serial stdio -net nic,model=rtl8139 -net user
>          -nographic -monitor null
>
> --
> Poweroff log in mainline (v3.19-rc5-119-gb942c65):
>
> / # poweroff
> The system is going down NOW!
> Sent SIGTERM to all processes
> Sent SIGKILL to all processes
> Requesting system poweroff
> sd 0:0:0:0: [sda] Synchronizing SCSI cache
> sd 0:0:0:0: [sda] Stopping disk
> reboot: Power down
>
> --
> Poweroff log in mmotm (v3.19-rc5-417-gc64429b):
>
> / # poweroff
>
> [ nothing else happens until I kill the qemu session ]
>
> The "halt" command does not work either.
>
> --
> The message "The system is going down NOW" is from the init process.
> If I use "kill -12 1" instead of "halt" or "poweroff", the system does
> shut down as expected. "poweroff -f" also works.
>
> Trying to debug this further, I noticed that the "ps" command hangs
> as well, so the problem is not limited to poweroff or halt.
>
> I'll be happy to debug this further, I just have no idea where to start.
>

Another data point: Reverting commit 22310c209483 does fix the problem.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
