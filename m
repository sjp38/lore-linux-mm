Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 19D3B6B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 09:52:40 -0400 (EDT)
Received: by pvc21 with SMTP id 21so1724660pvc.14
        for <linux-mm@kvack.org>; Mon, 31 May 2010 06:52:38 -0700 (PDT)
Date: Mon, 31 May 2010 10:52:27 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100531135227.GC19784@uudg.org>
References: <20100528152842.GH11364@uudg.org>
 <20100528154549.GC12035@barrios-desktop>
 <20100528164826.GJ11364@uudg.org>
 <20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
 <20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTil75ziCd6bivhpmwojvhaJ2LVxwEaEaBEmZf2yN@mail.gmail.com>
 <20100531145415.5e53f837.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTilcuY5e1DNmLhUWfXtiQgPUafz2zRTUuTVl-88l@mail.gmail.com>
 <20100531155102.9a122772.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100531155102.9a122772.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 03:51:02PM +0900, KAMEZAWA Hiroyuki wrote:
| On Mon, 31 May 2010 15:09:41 +0900
| Minchan Kim <minchan.kim@gmail.com> wrote:
| > On Mon, May 31, 2010 at 2:54 PM, KAMEZAWA Hiroyuki
| > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
...
| > >> > IIUC, the purpose of rising priority is to accerate dying thread to exit()
| > >> > for freeing memory AFAP. But to free memory, exit, all threads which share
| > >> > mm_struct should exit, too. I'm sorry if I miss something.
| > >>
| > >> How do we kill only some thread and what's the benefit of it?
| > >> I think when if some thread receives  KILL signal, the process include
| > >> the thread will be killed.
| > >>
| > > yes, so, if you want a _process_ die quickly, you have to acceralte the whole
| > > threads on a process. Acceralating a thread in a process is not big help.
| > 
| > Yes.
| > 
| > I see the code.
| > oom_kill_process is called by
| > 
| > 1. mem_cgroup_out_of_memory
| > 2. __out_of_memory
| > 3. out_of_memory
| > 
| > 
| > (1,2) calls select_bad_process which select victim task in processes
| > by do_each_process.
| > But 3 isn't In case of  CONSTRAINT_MEMORY_POLICY, it kills current.
| > In only the case, couldn't we pass task of process, not one of thread?
| > 
| 
| Hmm, my point is that priority-acceralation is against a thread, not against a process.
| So, most of threads in memory-eater will not gain high priority even with this patch
| and works slowly.

This is a good point...

| I have no objections to this patch. I just want to confirm the purpose. If this patch
| is for accelating exiting process by SIGKILL, it seems not enough.

I understand (from the comments in the code) the badness calculation gives more
points to the siblings in a thread that have their own mm. I wonder if what you
are describing is not a corner case.

Again, your idea sounds like an interesting refinement to the patch. I am
just not sure this change should implemented now or in a second round of
changes.

| If an explanation as "acceralating all thread's priority in a process seems overkill"
| is given in changelog or comment, it's ok to me.

If my understanding of badness() is right, I wouldn't be ashamed of saying
that it seems to be _a bit_ overkill. But I may be wrong in my
interpretation.

While re-reading the code I noticed that in select_bad_process() we can
eventually bump on an already dying task, case in which we just wait for
the task to die and avoid killing other tasks. Maybe we could boost the
priority of the dying task here too.

Luis
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
