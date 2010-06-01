Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B8B2F6B0229
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 04:19:44 -0400 (EDT)
Received: by iwn39 with SMTP id 39so707645iwn.14
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 01:19:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100531135227.GC19784@uudg.org>
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
	<20100531135227.GC19784@uudg.org>
Date: Tue, 1 Jun 2010 17:19:42 +0900
Message-ID: <AANLkTil5gnDaVt9FXtGnPgQQQ2XLl4MYbNS_hsjdcsVa@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 10:52 PM, Luis Claudio R. Goncalves
<lclaudio@uudg.org> wrote:
> On Mon, May 31, 2010 at 03:51:02PM +0900, KAMEZAWA Hiroyuki wrote:
> | On Mon, 31 May 2010 15:09:41 +0900
> | Minchan Kim <minchan.kim@gmail.com> wrote:
> | > On Mon, May 31, 2010 at 2:54 PM, KAMEZAWA Hiroyuki
> | > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> ...
> | > >> > IIUC, the purpose of rising priority is to accerate dying thread=
 to exit()
> | > >> > for freeing memory AFAP. But to free memory, exit, all threads w=
hich share
> | > >> > mm_struct should exit, too. I'm sorry if I miss something.
> | > >>
> | > >> How do we kill only some thread and what's the benefit of it?
> | > >> I think when if some thread receives =C2=A0KILL signal, the proces=
s include
> | > >> the thread will be killed.
> | > >>
> | > > yes, so, if you want a _process_ die quickly, you have to acceralte=
 the whole
> | > > threads on a process. Acceralating a thread in a process is not big=
 help.
> | >
> | > Yes.
> | >
> | > I see the code.
> | > oom_kill_process is called by
> | >
> | > 1. mem_cgroup_out_of_memory
> | > 2. __out_of_memory
> | > 3. out_of_memory
> | >
> | >
> | > (1,2) calls select_bad_process which select victim task in processes
> | > by do_each_process.
> | > But 3 isn't In case of =C2=A0CONSTRAINT_MEMORY_POLICY, it kills curre=
nt.
> | > In only the case, couldn't we pass task of process, not one of thread=
?
> | >
> |
> | Hmm, my point is that priority-acceralation is against a thread, not ag=
ainst a process.
> | So, most of threads in memory-eater will not gain high priority even wi=
th this patch
> | and works slowly.
>
> This is a good point...
>
> | I have no objections to this patch. I just want to confirm the purpose.=
 If this patch
> | is for accelating exiting process by SIGKILL, it seems not enough.
>
> I understand (from the comments in the code) the badness calculation give=
s more
> points to the siblings in a thread that have their own mm. I wonder if wh=
at you
> are describing is not a corner case.
>
> Again, your idea sounds like an interesting refinement to the patch. I am
> just not sure this change should implemented now or in a second round of
> changes.

First of all, I think your patch is first.
That's because I am not sure this logic is effective.


        /*
         * We give our sacrificial lamb high priority and access to
         * all the memory it needs. That way it should be able to
         * exit() and clear out its resources quickly...
         */
        p->rt.time_slice =3D HZ;

Peter changed it in fa717060f1ab.
Now if we change rt.time_slice as HZ, it means the task have high priority?
I am not a scheduler expert. but as I looked through scheduler code,
rt.time_slice is only related to RT scheduler. so if we uses CFS, it
doesn't make task high priority.
Perter, Right?

If it is right, I think Luis patch will fix it.

Secondly, as Kame pointed out, we have to raise whole thread's
priority to kill victim process for reclaiming pages. But I think it
has deadlock problem.
If we raise whole threads's priority and some thread has dependency of
other thread which is blocked, it makes system deadlock. So I think
it's not easy part.

If this part is really big problem, we should consider it more carefully.

>
> | If an explanation as "acceralating all thread's priority in a process s=
eems overkill"
> | is given in changelog or comment, it's ok to me.
>
> If my understanding of badness() is right, I wouldn't be ashamed of sayin=
g
> that it seems to be _a bit_ overkill. But I may be wrong in my
> interpretation.
>
> While re-reading the code I noticed that in select_bad_process() we can
> eventually bump on an already dying task, case in which we just wait for
> the task to die and avoid killing other tasks. Maybe we could boost the
> priority of the dying task here too.

Yes. It is good where we boost priority of task, I think.

>
> Luis
> --
> [ Luis Claudio R. Goncalves =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0Bass - Gospel - RT ]
> [ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9 =C2=A02696 7203 D980 A448 C8F8 ]
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
