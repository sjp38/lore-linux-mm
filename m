Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EC6B86B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 16:52:44 -0500 (EST)
Date: Tue, 4 Jan 2011 13:51:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 25042] New: RAM buffer I/O resource badly interacts with
 memory hot-add
Message-Id: <20110104135148.112d89c5.akpm@linux-foundation.org>
In-Reply-To: <bug-25042-27@https.bugzilla.kernel.org/>
References: <bug-25042-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, petr@vandrovec.name, akataria@vmware.com
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

I'm not sure who to blame here so I'll just spray it at everyone I've
ever met ;)

On Thu, 16 Dec 2010 23:00:12 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=25042
> 
>            Summary: RAM buffer I/O resource badly interacts with memory
>                     hot-add
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.35
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: petr@vandrovec.name
>                 CC: akataria@vmware.com
>         Regression: Yes
> 
> 
> Created an attachment (id=40502)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=40502)
> /proc/iomem after issuing hot-add, one from 3076 to 3200, other from 3200 to
> 3456MB
> 
> Linus's commit 45fbe3ee01b8e463b28c2751b5dcc0cbdc142d90 in May 2009 added code
> to create 'RAM buffer' above top of RAM to ensure that I/O resources do not
> start immediately after RAM, but sometime later.  Originally it was enforcing
> 32MB alignment, now it enforces 64MB.  Which means that in VMs with memory size
> which is not multiple of 64MB there will be additional 'RAM buffer' resource
> present:
> 
> 100000000-1003fffff : System RAM
> 100400000-103ffffff : RAM buffer
> 
> When we try to hot-add memory, kernel complains that there was resource
> conflict with this fake 'RAM buffer' and hot-added memory is not recognized:
> 
> [  115.324952] Hotplug Mem Device 
> [  115.325549] System RAM resource 100400000 - 10fffffff cannot be added
> [  115.325553] ACPI:memory_hp:add_memory failed
> [  115.326519] ACPI:memory_hp:Error in acpi_memory_enable_device
> [  115.327183] acpi_memhotplug: probe of PNP0C80:00 failed with error -22
> [  115.327347] 
> [  115.327350]  driver data not found
> [  115.328808] ACPI:memory_hp:Cannot find driver data
> 
> For now we've modified hotplug code to split hot-added request into smaller
> ranges, so only first <= 252MB are unusable, rather than whole xxxGB chunk, but
> if 'RAM buffer' could be made dependent on memory hot-plug not available on the
> platform, it would be much better.
> 
> Another approach is resurrecting
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-07/msg06501.html and using
> this range instead of all "unclaimed" ranges for placing I/O devices.  Then
> "RAM buffer" would not be necessary at all.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
