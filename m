Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 34A186B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 03:08:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 728803EE0BD
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:08:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 59F7945DE4E
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:08:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 43D4545DE4D
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:08:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 36556E08001
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:08:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED8A11DB8038
	for <linux-mm@kvack.org>; Mon, 30 May 2011 16:08:31 +0900 (JST)
Date: Mon, 30 May 2011 16:01:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110529231948.e1439ce5.akpm@linux-foundation.org>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
	<20110529231948.e1439ce5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Sun, 29 May 2011 23:19:48 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 30 May 2011 02:38:33 GMT bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=36192
> > 
> >            Summary: Kernel panic when boot the 2.6.39+ kernel based off of
> >                     2.6.32 kernel
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.39+
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Page Allocator
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: qcui@redhat.com
> >         Regression: Yes
> > 
> > 
> > Created an attachment (id=60012)
> >  --> (https://bugzilla.kernel.org/attachment.cgi?id=60012)
> > kernel panic console output
> > 
> > When I updated the kernel from 2.6.32 to 2.6.39+ on a server with AMD
> > Magny-Cours CPU, the server can not boot the 2.6.39+ kernel successfully. The
> > console ouput showed 'Kernel panic - not syncing: Attempted to kill the idle
> > task!' I have tried to set the kernel parameter idle=poll in the grub file. It
> > still failed to reboot due to the same error. But it can reboot successfully on
> > the server with Intel CPU. The full console output is attached.
> > 
> > Steps to reproduce:
> > 1. install the 2.6.32 kernel
> > 2. compile and install the kernel 2.6.39+
> > 3. reboot
> > 
> 
> hm, this is not good.  Might be memcg-related?
> 

yes, and the system may be able to boot with a boot option of cgroup_disable=memory.
but the problem happens in __alloc_pages_nodemask with NULL pointer access.
Hmm, doesn't this imply some error in building zone/pgdat ?

Thanks,
-Kame


> > BUG: unable to handle kernel paging request at 0000000000001c08
> > IP: [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
> > PGD 0 
> > Oops: 0000 [#1] SMP 
> > last sysfs file: 
> > CPU 0 
> > Modules linked in:
> > 
> > Pid: 0, comm: swapper Not tainted 2.6.39+ #1 AMD DRACHMA/DRACHMA
> > RIP: 0010:[<ffffffff811076cc>]  [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
> > RSP: 0000:ffffffff81a01e48  EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
> > RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00000000000002d0
> > RBP: ffffffff81a01ea8 R08: ffffffff81c03680 R09: 0000000000000000
> > R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000002d0
> > R13: 0000000000001c00 R14: ffffffff81a01fa8 R15: 0000000000000000
> > FS:  0000000000000000(0000) GS:ffff880437800000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000001c08 CR3: 0000000001a03000 CR4: 00000000000006b0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0b020)
> > Stack:
> >  0000000000000000 0000000000000000 ffffffff81a01eb8 000002d000000008
> >  ffffffff00000020 ffffffff81a01ec8 ffffffff81a01e88 0000000000000008
> >  0000000000100000 0000000000000000 ffffffff81a01fa8 0000000000093cf0
> > Call Trace:
> >  [<ffffffff81107d7f>] alloc_pages_exact_nid+0x5f/0xc0
> >  [<ffffffff814b2dea>] alloc_page_cgroup+0x2a/0x80
> >  [<ffffffff814b2ece>] init_section_page_cgroup+0x8e/0x110
> >  [<ffffffff81c4a2f1>] page_cgroup_init+0x6e/0xa7
> >  [<ffffffff81c22de4>] start_kernel+0x2ae/0x366
> >  [<ffffffff81c22346>] x86_64_start_reservations+0x131/0x135
> >  [<ffffffff81c2244d>] x86_64_start_kernel+0x103/0x112
> > Code: e0 08 83 f8 01 44 89 e0 19 db c1 e8 13 f7 d3 83 e0 01 83 e3 02 09 c3 8b 05 22 e5 af 00 44 21 e0 a8 10 89 45 bc 0f 85 c4 00 00 00 
> >  83 7d 08 00 0f 84 dd 00 00 00 65 4c 8b 34 25 c0 cc 00 00 41 
> > RIP  [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
> >  RSP <ffffffff81a01e48>
> > CR2: 0000000000001c08
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
