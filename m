Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 370728D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 05:31:41 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p0SAVamC003820
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 02:31:39 -0800
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe17.cbf.corp.google.com with ESMTP id p0SAVUv3011730
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 02:31:35 -0800
Received: by pzk37 with SMTP id 37so932506pzk.40
        for <linux-mm@kvack.org>; Fri, 28 Jan 2011 02:31:30 -0800 (PST)
Date: Fri, 28 Jan 2011 02:31:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: known oom issues on numa in -mm tree?
In-Reply-To: <1830247931.201921.1296197255760.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1101280227440.28081@chino.kir.corp.google.com>
References: <1830247931.201921.1296197255760.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011, CAI Qian wrote:

> I can still reproduce this similar failure on both AMD and Intel NUMA
> systems using the latest linus tree with the commit you mentioned.
> Unfortunately, I can't get a clear sysrq/console output of it but only
> a part of it (screenshot attached).
> 
> It at least very easy to reproduce it for me by running LTP oom01 test
> for both Magny-Cours and Nehalem-EX NUMA systems.
> 

Are you sure this is the same issue?  The picture you provided doesn't 
show the top of the stack so I don't know what it's doing, but the 
original report had this:

oom02           R  running task        0  2023   1969 0x00000088
 0000000000000282 ffff88041d219df0 ffff88041fbf8ef0 ffffffff81100800
 ffff880418ab5b18 0000000000000282 ffffffff8100c9ee ffff880418ab5ba8
 0000000087654321 0000000000000000 ffff880000000000 0000000000000001
Call Trace:
 [<ffffffff81100800>] ? drain_local_pages+0x0/0x20
 [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff81097ea6>] ? smp_call_function_many+0x1b6/0x210
 [<ffffffff81097e82>] ? smp_call_function_many+0x192/0x210
 [<ffffffff81100800>] ? drain_local_pages+0x0/0x20
 [<ffffffff81097f22>] ? smp_call_function+0x22/0x30
 [<ffffffff81068184>] ? on_each_cpu+0x24/0x50
 [<ffffffff810fe68c>] ? drain_all_pages+0x1c/0x20
 [<ffffffff81100d04>] ? __alloc_pages_nodemask+0x4e4/0x840
 [<ffffffff81138e09>] ? alloc_page_vma+0x89/0x140
 [<ffffffff8111c481>] ? handle_mm_fault+0x871/0xd80
 [<ffffffff814a4ecd>] ? schedule+0x3fd/0x980
 [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
 [<ffffffff814aadd3>] ? do_page_fault+0x143/0x4b0
 [<ffffffff8100a7b4>] ? __switch_to+0x194/0x320
 [<ffffffff814a4ecd>] ? schedule+0x3fd/0x980
 [<ffffffff814a7ad5>] ? page_fault+0x25/0x30

and the reported symptom was kswapd running excessively.  I'm pretty sure 
I fixed that with 2ff754fa8f41 (mm: clear pages_scanned only if draining a 
pcp adds pages to the buddy allocator).

Absent the dmesg, it's going to be very difficult to diagnose an issue 
that isn't a panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
