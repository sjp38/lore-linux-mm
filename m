Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D525D90016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:27:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 810963EE0AE
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:27:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6781645DE91
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:27:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5331445DE89
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:27:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 484531DB8042
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:27:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B4FF1DB8047
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:27:37 +0900 (JST)
Date: Wed, 22 Jun 2011 19:20:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: "make -j" with memory.(memsw.)limit_in_bytes smaller than
 required -> livelock,  even for unlimited processes
Message-Id: <20110622192039.87d96a16.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110622100615.0ab22219.kamezawa.hiroyu@jp.fujitsu.com>
References: <4E00AFE6.20302@5t9.de>
	<20110622091018.16c14c78.kamezawa.hiroyu@jp.fujitsu.com>
	<20110622100615.0ab22219.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lutz Vieweg <lvml@5t9.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 22 Jun 2011 10:06:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 22 Jun 2011 09:10:18 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 21 Jun 2011 16:51:18 +0200
> > Lutz Vieweg <lvml@5t9.de> wrote:
> 
> > > - but also at this time, if any other user (who has not exhausted
> > >    his memory limits) tries to access any file (at least on /tmp/,
> > >    as e.g. gcc does), even a simple "ls /tmp/", this operation
> > >    waits forever. (But "iostat" does not indicate any I/O activity.)
> > > 
> > 
> > Hmm, it means your 'ls' gets some lock and wait for it. Then, what lock
> > you wait for ? what w_chan is shown in 'ps -elf' ?
> > 
> 
> I reproduced. And checked sysrq t.
> 
> At first, some oom killers run.
> Second, oom killer stops by some reason. (I think there are a KILLED process in memcg
> but it doesn't exit. I'll check memcg' bypass logic.)
> 
> Third, ls /tmp stops.
> 
> Here is sysrq log.
> ==
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012] ls              D 0000000000000082  5448 22307   2799 0x10000000
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  ffff880623a7bb08 0000000000000086 ffff88033fffcc08 ffff88033fffbe70
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  ffff8805fa70c530 0000000000012880 ffff880623a7bfd8 ffff880623a7a010
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  ffff880623a7bfd8 0000000000012880 ffff8805f9c30000 ffff8805fa70c530
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012] Call Trace:
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810ee900>] ? sleep_on_page+0x20/0x20
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff8154f40c>] io_schedule+0x8c/0xd0
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810ee90e>] sleep_on_page_killable+0xe/0x40
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff8154fddf>] __wait_on_bit+0x5f/0x90
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810eeab5>] wait_on_page_bit_killable+0x75/0x80
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810791f0>] ? autoremove_wake_function+0x40/0x40
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810eec35>] __lock_page_or_retry+0x95/0xc0
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810efe7f>] filemap_fault+0x2df/0x4b0
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81115685>] __do_fault+0x55/0x530
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81119150>] ? unmap_region+0x110/0x140
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81115c57>] handle_pte_fault+0xf7/0xb50
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff8112f87a>] ? alloc_pages_current+0xaa/0x110
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff8103a857>] ? pte_alloc_one+0x37/0x50
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81011ea9>] ? sched_clock+0x9/0x10
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810c0ec9>] ? trace_clock_local+0x9/0x10
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81116885>] handle_mm_fault+0x1d5/0x350
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81555090>] do_page_fault+0x140/0x470
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff810ce4c3>] ? trace_nowake_buffer_unlock_commit+0x43/0x60
> Jun 22 10:04:29 bluextal kernel: [ 1366.149012]  [<ffffffff81015c83>] ? ftrace_raw_event_sys_exit+0xb3/
> ==
> 
> Then, waiting for some page bit...I/O of libc mapped pages ?
> 
> Hmm. it seems buggy behavior. Okay, I'll dig this.
> 

IIUC, because of many many threads in a small memcg, it seems a loaded page from a filesystem
is dropped before mapped. Yes, it's verrrrry bad for shared pages as libc.

I'll consider a way to handle shared caches in clean and scalable way.
(An idea is avoiding pageout and put it to a victim cache/uncharge for
 avoiding ping-pong.)

But it seems there are no instant fix. please wait a little.
I may miss somthing...

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
