Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F3ABF6B00B0
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 21:18:24 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7F58A3EE0BB
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:18:22 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 65B9445DE53
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:18:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 422C145DE4E
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:18:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3119DEF8003
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:18:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E133F1DB803B
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 11:18:21 +0900 (JST)
Date: Thu, 6 Jan 2011 11:12:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bug 25042] New: RAM buffer I/O resource badly interacts with
 memory hot-add
Message-Id: <20110106111231.4fc98855.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110104135148.112d89c5.akpm@linux-foundation.org>
References: <bug-25042-27@https.bugzilla.kernel.org/>
	<20110104135148.112d89c5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-acpi@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, petr@vandrovec.name, akataria@vmware.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jan 2011 13:51:48 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> I'm not sure who to blame here so I'll just spray it at everyone I've
> ever met ;)
> 
> On Thu, 16 Dec 2010 23:00:12 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=25042
> > 
> >            Summary: RAM buffer I/O resource badly interacts with memory
> >                     hot-add
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.35
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: petr@vandrovec.name
> >                 CC: akataria@vmware.com
> >         Regression: Yes
> > 
> > 
> > Created an attachment (id=40502)
> >  --> (https://bugzilla.kernel.org/attachment.cgi?id=40502)
> > /proc/iomem after issuing hot-add, one from 3076 to 3200, other from 3200 to
> > 3456MB
> > 
> > Linus's commit 45fbe3ee01b8e463b28c2751b5dcc0cbdc142d90 in May 2009 added code
> > to create 'RAM buffer' above top of RAM to ensure that I/O resources do not
> > start immediately after RAM, but sometime later.  Originally it was enforcing
> > 32MB alignment, now it enforces 64MB.  Which means that in VMs with memory size
> > which is not multiple of 64MB there will be additional 'RAM buffer' resource
> > present:
> > 
> > 100000000-1003fffff : System RAM
> > 100400000-103ffffff : RAM buffer
> > 
> > When we try to hot-add memory, kernel complains that there was resource
> > conflict with this fake 'RAM buffer' and hot-added memory is not recognized:
> > 
> > [  115.324952] Hotplug Mem Device 
> > [  115.325549] System RAM resource 100400000 - 10fffffff cannot be added
> > [  115.325553] ACPI:memory_hp:add_memory failed
> > [  115.326519] ACPI:memory_hp:Error in acpi_memory_enable_device
> > [  115.327183] acpi_memhotplug: probe of PNP0C80:00 failed with error -22
> > [  115.327347] 
> > [  115.327350]  driver data not found
> > [  115.328808] ACPI:memory_hp:Cannot find driver data
> > 
> > For now we've modified hotplug code to split hot-added request into smaller
> > ranges, so only first <= 252MB are unusable, rather than whole xxxGB chunk, but
> > if 'RAM buffer' could be made dependent on memory hot-plug not available on the
> > platform, it would be much better.
> > 

Hmm ? Why do you need to place "hot-added" memory's address range next to System
RAM ? Sparsemem allows sparse memory layout.

Is it very difficult ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
