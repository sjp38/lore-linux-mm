Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C2ECA8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 01:53:20 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p2V5rDYc004940
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:53:13 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by hpaq7.eem.corp.google.com with ESMTP id p2V5rBEC002534
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:53:12 -0700
Received: by qwj9 with SMTP id 9so1759228qwj.35
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:53:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 30 Mar 2011 22:52:49 -0700
Message-ID: <BANLkTikLPTr46S6k5LaZ3sfsXG=PrQNvGA@mail.gmail.com>
Subject: Re: [LSF][MM] rough agenda for memcg.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, walken@google.com

On Wed, Mar 30, 2011 at 7:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hi,
>
> In this LSF/MM, we have some memcg topics in the 1st day.
>
> From schedule,
>
> 1. Memory cgroup : Where next ? 1hour (Balbir Singh/Kamezawa)
> 2. Memcg Dirty Limit and writeback 30min(Greg Thelen)
> 3. Memcg LRU management 30min (Ying Han, Michal Hocko)
> 4. Page cgroup on a diet (Johannes Weiner)
>
> 2.5 hours. This seems long...or short ? ;)

I think it is a good starting plan.

> I'd like to sort out topics before going. Please fix if I don't catch eno=
ugh.
>
> mentiont to 1. later...
>
> Main topics on 2. Memcg Dirty Limit and writeback ....is
>
> =A0a) How to implement per-memcg dirty inode finding method (list) and
> =A0 =A0how flusher threads handle memcg.

I have some very rough code implementing the ideas discussed in
http://thread.gmane.org/gmane.linux.kernel.mm/59707
Unfortunately, I do not yet have good patches, but maybe an RFC series
soon.  I can provide update on the direction I am thinking.

> =A0b) Hot to interact with IO-Less dirty page reclaim.
> =A0 =A0IIUC, if memcg doesn't handle this correctly, OOM happens.

The last posted memcg dirty writeback patches were based on -mm at the
time, which did not have IO-less balance_dirty_pages.  I have an
approach which I _think_ will be compatible with IO-less
balance_dirty_pages(), but I need to talk with some writeback guys to
confirm.  Seeing the Writeback talk Mon 9:30am should be very useful
for me.

> =A0Greg, do we need to have a shared session with I/O guys ?
> =A0If needed, current schedule is O.K. ?

We can contact any interested writeback guys to see if they want to
attend memcg-writeback discussion.  We might be able to defer this
detail until Mon morning.

> Main topics on 3. Memcg LRU management
>
> =A0a) Isolation/Gurantee for memcg.
> =A0 =A0Current memcg doesn't have enough isolation when globarl reclaim r=
uns.
> =A0 =A0.....Because it's designed not to affect global reclaim.
> =A0 =A0But from user's point of view, it's nonsense and we should have so=
me hints
> =A0 =A0for isolate set of memory or implement a guarantee.
>
> =A0 =A0One way to go is updating softlimit better. To do this, we should =
know what
> =A0 =A0is problem now. I'm sorry I can't prepare data on this until LSF/M=
M.
> =A0 =A0Another way is implementing a guarantee. But this will require som=
e interaction
> =A0 =A0with page allocator and pgscan mechanism. This will be a big work.
>
> =A0b) single LRU and per memcg zone->lru_lock.
> =A0 =A0I hear zone->lru_lock contention caused by memcg is a problem on G=
oogle servers.
> =A0 =A0Okay, please show data. (I've never seen it.)
> =A0 =A0Then, we need to discuss Pros. and Cons. of current design and nee=
d to consinder
> =A0 =A0how to improve it. I think Google and Michal have their own implem=
entation.
>
> =A0 =A0Current design of double-LRU is from the 1st inclusion of memcg to=
 the kernel.
> =A0 =A0But I don't know that discussion was there. Balbir, could you expl=
ain the reason
> =A0 =A0of this design ? Then, we can go ahead, somewhere.
>
>
> Main topics on 4. Page cgroup on diet is...
>
> =A0a) page_cgroup is too big!, we need diet....
> =A0 =A0 I think Johannes removes -> page pointer already. Ok, what's the =
next to
> =A0 =A0 be removed ?
>
> =A0I guess the next candidate is ->lru which is related to 3-b).
>
> Main topics on 1.Memory control groups: where next? is..
>
> To be honest, I just do bug fixes in these days. And hot topics are on ab=
ove..
> I don't have concrete topics. What I can think of from recent linux-mm em=
ails are...
>
> =A0a) Kernel memory accounting.
> =A0b) Need some work with Cleancache ?
> =A0c) Should we provide a auto memory cgroup for file caches ?
> =A0 =A0 (Then we can implement a file-cache-limit.)
> =A0d) Do we have a problem with current OOM-disable+notifier design ?
> =A0e) ROOT cgroup should have a limit/softlimit, again ?
> =A0f) vm_overcommit_memory should be supproted with memcg ?
> =A0 =A0 (I remember there was a trial. But I think it should be done in o=
ther cgroup
> =A0 =A0 =A0as vmemory cgroup.)
> ...
>
> I think
> =A0a) discussing about this is too early. There is no patch.
> =A0 =A0 I think we'll just waste time.
>
> =A0b) enable/disable cleancache per memcg or some share/limit ??
> =A0 =A0 But we can discuss this kind of things after cleancache is in pro=
duction use...
>
> =A0c) AFAIK, some other OSs have this kind of feature, a box for file-cac=
he.
> =A0 =A0 Because file-cache is a shared object between all cgroups, it's d=
ifficult
> =A0 =A0 to handle. It may be better to have a auto cgroup for file caches=
 and add knobs
> =A0 =A0 for memcg.
>
> =A0d) I think it works well.
>
> =A0e) It seems Michal wants this for lazy users. Hmm, should we have a kn=
ob ?
> =A0 =A0 It's helpful that some guy have a performance number on the lates=
t kernel
> =A0 =A0 with and without memcg (in limitless case).
> =A0 =A0 IIUC, with THP enabled as 'always', the number of page fault dram=
atically reduced and
> =A0 =A0 memcg's accounting cost gets down...
>
> =A0f) I think someone mention about this...
>
> Maybe c) and d) _can_ be a topic but seems not very important.
>
> So, for this slot, I'd like to discuss
>
> =A0I) Softlimit/Isolation (was 3-A) for 1hour
> =A0 =A0 If we have extra time, kernel memory accounting or file-cache han=
dling
> =A0 =A0 will be good.
>
> =A0II) Dirty page handling. (for 30min)
> =A0 =A0 Maybe we'll discuss about per-memcg inode queueing issue.
>
> =A0III) Discussing the current and future design of LRU.(for 30+min)
>
> =A0IV) Diet of page_cgroup (for 30-min)
> =A0 =A0 =A0Maybe this can be combined with III.
>
> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
