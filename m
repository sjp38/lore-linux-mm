Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 990158D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 02:03:41 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p2V63cTg024951
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 23:03:38 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe14.cbf.corp.google.com with ESMTP id p2V63b9S013229
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 23:03:37 -0700
Received: by qyk7 with SMTP id 7so3280468qyk.19
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 23:03:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 30 Mar 2011 23:03:36 -0700
Message-ID: <BANLkTi=A5nnQDZRXKAz-b3DzrCw57nFDBQ@mail.gmail.com>
Subject: Re: [LSF][MM] rough agenda for memcg.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84cad985eb049fc10db2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, walken@google.com

--00248c6a84cad985eb049fc10db2
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Mar 30, 2011 at 7:01 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

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
>
> I'd like to sort out topics before going. Please fix if I don't catch
> enough.
>
> mentiont to 1. later...
>
> Main topics on 2. Memcg Dirty Limit and writeback ....is
>
>  a) How to implement per-memcg dirty inode finding method (list) and
>    how flusher threads handle memcg.
>
>  b) Hot to interact with IO-Less dirty page reclaim.
>    IIUC, if memcg doesn't handle this correctly, OOM happens.
>
>  Greg, do we need to have a shared session with I/O guys ?
>  If needed, current schedule is O.K. ?
>
> Main topics on 3. Memcg LRU management
>
>  a) Isolation/Gurantee for memcg.
>    Current memcg doesn't have enough isolation when globarl reclaim runs.
>    .....Because it's designed not to affect global reclaim.
>    But from user's point of view, it's nonsense and we should have some
> hints
>    for isolate set of memory or implement a guarantee.
>
>    One way to go is updating softlimit better. To do this, we should know
> what
>    is problem now. I'm sorry I can't prepare data on this until LSF/MM.
>
I generated example which shows the inefficiency of soft_limit reclaim,
which is so far based on the code
inspection. I am not sure if I can get some data before LSF.


>    Another way is implementing a guarantee. But this will require some
> interaction
>    with page allocator and pgscan mechanism. This will be a big work.
>
Not sure about this..

>
>  b) single LRU and per memcg zone->lru_lock.
>    I hear zone->lru_lock contention caused by memcg is a problem on Google
> servers.
>    Okay, please show data. (I've never seen it.)
>

To clarify, the lock contention is bad after per-memcg background reclaim
patch. The worst case we have #-of-cpu per-memcg kswapd
reclaiming on per-memcg lru and all competing the zone->lru_lock.

--Ying

   Then, we need to discuss Pros. and Cons. of current design and need to
> consinder
>    how to improve it. I think Google and Michal have their own
> implementation.
>
>    Current design of double-LRU is from the 1st inclusion of memcg to the
> kernel.
>    But I don't know that discussion was there. Balbir, could you explain
> the reason
>    of this design ? Then, we can go ahead, somewhere.
>
>
> Main topics on 4. Page cgroup on diet is...
>
>  a) page_cgroup is too big!, we need diet....
>     I think Johannes removes -> page pointer already. Ok, what's the next
> to
>     be removed ?
>
>  I guess the next candidate is ->lru which is related to 3-b).
>
> Main topics on 1.Memory control groups: where next? is..
>
> To be honest, I just do bug fixes in these days. And hot topics are on
> above..
> I don't have concrete topics. What I can think of from recent linux-mm
> emails are...
>
>  a) Kernel memory accounting.
>  b) Need some work with Cleancache ?
>  c) Should we provide a auto memory cgroup for file caches ?
>     (Then we can implement a file-cache-limit.)
>  d) Do we have a problem with current OOM-disable+notifier design ?
>  e) ROOT cgroup should have a limit/softlimit, again ?
>  f) vm_overcommit_memory should be supproted with memcg ?
>     (I remember there was a trial. But I think it should be done in other
> cgroup
>      as vmemory cgroup.)
> ...
>
> I think
>  a) discussing about this is too early. There is no patch.
>     I think we'll just waste time.


>  b) enable/disable cleancache per memcg or some share/limit ??
>     But we can discuss this kind of things after cleancache is in
> production use...
>
>  c) AFAIK, some other OSs have this kind of feature, a box for file-cache.
>     Because file-cache is a shared object between all cgroups, it's
> difficult
>     to handle. It may be better to have a auto cgroup for file caches and
> add knobs
>     for memcg.
>
>  d) I think it works well.
>
>  e) It seems Michal wants this for lazy users. Hmm, should we have a knob ?
>     It's helpful that some guy have a performance number on the latest
> kernel
>     with and without memcg (in limitless case).
>     IIUC, with THP enabled as 'always', the number of page fault
> dramatically reduced and
>     memcg's accounting cost gets down...
>
>  f) I think someone mention about this...
>
> Maybe c) and d) _can_ be a topic but seems not very important.
>
> So, for this slot, I'd like to discuss
>
>  I) Softlimit/Isolation (was 3-A) for 1hour
>     If we have extra time, kernel memory accounting or file-cache handling
>     will be good.
>
>  II) Dirty page handling. (for 30min)
>     Maybe we'll discuss about per-memcg inode queueing issue.
>
>  III) Discussing the current and future design of LRU.(for 30+min)
>
>  IV) Diet of page_cgroup (for 30-min)
>      Maybe this can be combined with III.
>
> Thanks,
> -Kame
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>

--00248c6a84cad985eb049fc10db2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Mar 30, 2011 at 7:01 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<br>
Hi,<br>
<br>
In this LSF/MM, we have some memcg topics in the 1st day.<br>
<br>
>From schedule,<br>
<br>
1. Memory cgroup : Where next ? 1hour (Balbir Singh/Kamezawa)<br>
2. Memcg Dirty Limit and writeback 30min(Greg Thelen)<br>
3. Memcg LRU management 30min (Ying Han, Michal Hocko)<br>
4. Page cgroup on a diet (Johannes Weiner)<br>
<br>
2.5 hours. This seems long...or short ? ;)<br>
<br>
I&#39;d like to sort out topics before going. Please fix if I don&#39;t cat=
ch enough.<br>
<br>
mentiont to 1. later...<br>
<br>
Main topics on 2. Memcg Dirty Limit and writeback ....is<br>
<br>
=A0a) How to implement per-memcg dirty inode finding method (list) and<br>
 =A0 =A0how flusher threads handle memcg.<br>
<br>
=A0b) Hot to interact with IO-Less dirty page reclaim.<br>
 =A0 =A0IIUC, if memcg doesn&#39;t handle this correctly, OOM happens.<br>
<br>
=A0Greg, do we need to have a shared session with I/O guys ?<br>
=A0If needed, current schedule is O.K. ?<br>
<br>
Main topics on 3. Memcg LRU management<br>
<br>
=A0a) Isolation/Gurantee for memcg.<br>
 =A0 =A0Current memcg doesn&#39;t have enough isolation when globarl reclai=
m runs.<br>
 =A0 =A0.....Because it&#39;s designed not to affect global reclaim.<br>
 =A0 =A0But from user&#39;s point of view, it&#39;s nonsense and we should =
have some hints<br>
 =A0 =A0for isolate set of memory or implement a guarantee.<br>
<br>
 =A0 =A0One way to go is updating softlimit better. To do this, we should k=
now what<br>
 =A0 =A0is problem now. I&#39;m sorry I can&#39;t prepare data on this unti=
l LSF/MM.<br></blockquote><div>I generated example which shows the ineffici=
ency of soft_limit reclaim, which is so far based on the code</div><div>ins=
pection. I am not sure if I can get some data before LSF.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
 =A0 =A0Another way is implementing a guarantee. But this will require some=
 interaction<br>
 =A0 =A0with page allocator and pgscan mechanism. This will be a big work.<=
br></blockquote><div>Not sure about this..=A0</div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex;">

<br>
=A0b) single LRU and per memcg zone-&gt;lru_lock.<br>
 =A0 =A0I hear zone-&gt;lru_lock contention caused by memcg is a problem on=
 Google servers.<br>
 =A0 =A0Okay, please show data. (I&#39;ve never seen it.)<br></blockquote><=
div>=A0</div><div>To clarify, the lock contention is bad after per-memcg ba=
ckground reclaim patch. The worst case we have #-of-cpu per-memcg kswapd</d=
iv>
<div>reclaiming on per-memcg lru and all competing the zone-&gt;lru_lock.</=
div><div><br></div><div>--Ying</div><div><br></div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex;">

 =A0 =A0Then, we need to discuss Pros. and Cons. of current design and need=
 to consinder<br>
 =A0 =A0how to improve it. I think Google and Michal have their own impleme=
ntation.<br>
<br>
 =A0 =A0Current design of double-LRU is from the 1st inclusion of memcg to =
the kernel.<br>
 =A0 =A0But I don&#39;t know that discussion was there. Balbir, could you e=
xplain the reason<br>
 =A0 =A0of this design ? Then, we can go ahead, somewhere.<br>
<br>
<br>
Main topics on 4. Page cgroup on diet is...<br>
<br>
 =A0a) page_cgroup is too big!, we need diet....<br>
 =A0 =A0 I think Johannes removes -&gt; page pointer already. Ok, what&#39;=
s the next to<br>
 =A0 =A0 be removed ?<br>
<br>
 =A0I guess the next candidate is -&gt;lru which is related to 3-b).<br>
<br>
Main topics on 1.Memory control groups: where next? is..<br>
<br>
To be honest, I just do bug fixes in these days. And hot topics are on abov=
e..<br>
I don&#39;t have concrete topics. What I can think of from recent linux-mm =
emails are...<br>
<br>
 =A0a) Kernel memory accounting.<br>
 =A0b) Need some work with Cleancache ?<br>
 =A0c) Should we provide a auto memory cgroup for file caches ?<br>
 =A0 =A0 (Then we can implement a file-cache-limit.)<br>
 =A0d) Do we have a problem with current OOM-disable+notifier design ?<br>
 =A0e) ROOT cgroup should have a limit/softlimit, again ?<br>
 =A0f) vm_overcommit_memory should be supproted with memcg ?<br>
 =A0 =A0 (I remember there was a trial. But I think it should be done in ot=
her cgroup<br>
 =A0 =A0 =A0as vmemory cgroup.)<br>
...<br>
<br>
I think<br>
 =A0a) discussing about this is too early. There is no patch.<br>
 =A0 =A0 I think we&#39;ll just waste time.=A0</blockquote><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex;">
<br>
 =A0b) enable/disable cleancache per memcg or some share/limit ??<br>
 =A0 =A0 But we can discuss this kind of things after cleancache is in prod=
uction use...<br>
<br>
 =A0c) AFAIK, some other OSs have this kind of feature, a box for file-cach=
e.<br>
 =A0 =A0 Because file-cache is a shared object between all cgroups, it&#39;=
s difficult<br>
 =A0 =A0 to handle. It may be better to have a auto cgroup for file caches =
and add knobs<br>
 =A0 =A0 for memcg.<br>
<br>
 =A0d) I think it works well.<br>
<br>
 =A0e) It seems Michal wants this for lazy users. Hmm, should we have a kno=
b ?<br>
 =A0 =A0 It&#39;s helpful that some guy have a performance number on the la=
test kernel<br>
 =A0 =A0 with and without memcg (in limitless case).<br>
 =A0 =A0 IIUC, with THP enabled as &#39;always&#39;, the number of page fau=
lt dramatically reduced and<br>
 =A0 =A0 memcg&#39;s accounting cost gets down...<br>
<br>
 =A0f) I think someone mention about this...<br>
<br>
Maybe c) and d) _can_ be a topic but seems not very important.<br>
<br>
So, for this slot, I&#39;d like to discuss<br>
<br>
 =A0I) Softlimit/Isolation (was 3-A) for 1hour<br>
 =A0 =A0 If we have extra time, kernel memory accounting or file-cache hand=
ling<br>
 =A0 =A0 will be good.<br>
<br>
 =A0II) Dirty page handling. (for 30min)<br>
 =A0 =A0 Maybe we&#39;ll discuss about per-memcg inode queueing issue.<br>
<br>
 =A0III) Discussing the current and future design of LRU.(for 30+min)<br>
<br>
 =A0IV) Diet of page_cgroup (for 30-min)<br>
 =A0 =A0 =A0Maybe this can be combined with III.<br>
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--00248c6a84cad985eb049fc10db2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
