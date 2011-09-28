Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A74E29000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:57:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 889A73EE0AE
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:57:31 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 70DCE45DE5A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:57:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 58D7245DE58
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:57:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49B0F1DB8048
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:57:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0884E1DB804A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 09:57:31 +0900 (JST)
Date: Wed, 28 Sep 2011 09:56:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
Message-Id: <20110928095643.30b97483.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E8100FC.10906@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-3-git-send-email-glommer@parallels.com>
	<CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
	<4E7A342B.5040608@parallels.com>
	<CAHH2K0Z_2LJPL0sLVHqkh_6b_BLQnknULTB9a9WfEuibk5kONg@mail.gmail.com>
	<CAKTCnz=59HuEg9T-USi5oKSK=F+vr2QxCA17+i-rGj73k49rzw@mail.gmail.com>
	<4E7DECF0.9050804@parallels.com>
	<20110926195213.12da87b4.kamezawa.hiroyu@jp.fujitsu.com>
	<4E8100FC.10906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Mon, 26 Sep 2011 19:47:24 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 09/26/2011 07:52 AM, KAMEZAWA Hiroyuki wrote:
> > On Sat, 24 Sep 2011 11:45:04 -0300
> > Glauber Costa<glommer@parallels.com>  wrote:
> >
> >> On 09/22/2011 12:09 PM, Balbir Singh wrote:
> >>> On Thu, Sep 22, 2011 at 11:30 AM, Greg Thelen<gthelen@google.com>   wrote:
> >>>> On Wed, Sep 21, 2011 at 11:59 AM, Glauber Costa<glommer@parallels.com>   wrote:
> >>>>> Right now I am working under the assumption that tasks are long lived inside
> >>>>> the cgroup. Migration potentially introduces some nasty locking problems in
> >>>>> the mem_schedule path.
> >>>>>
> >>>>> Also, unless I am missing something, the memcg already has the policy of
> >>>>> not carrying charges around, probably because of this very same complexity.
> >>>>>
> >>>>> True that at least it won't EBUSY you... But I think this is at least a way
> >>>>> to guarantee that the cgroup under our nose won't disappear in the middle of
> >>>>> our allocations.
> >>>>
> >>>> Here's the memcg user page behavior using the same pattern:
> >>>>
> >>>> 1. user page P is allocate by task T in memcg M1
> >>>> 2. T is moved to memcg M2.  The P charge is left behind still charged
> >>>> to M1 if memory.move_charge_at_immigrate=0; or the charge is moved to
> >>>> M2 if memory.move_charge_at_immigrate=1.
> >>>> 3. rmdir M1 will try to reclaim P (if P was left in M1).  If unable to
> >>>> reclaim, then P is recharged to parent(M1).
> >>>>
> >>>
> >>> We also have some magic in page_referenced() to remove pages
> >>> referenced from different containers. What we do is try not to
> >>> penalize a cgroup if another cgroup is referencing this page and the
> >>> page under consideration is being reclaimed from the cgroup that
> >>> touched it.
> >>>
> >>> Balbir Singh
> >> Do you guys see it as a showstopper for this series to be merged, or can
> >> we just TODO it ?
> >>
> >
> > In my experience, 'I can't rmdir cgroup.' is always an important/difficult
> > problem. The users cannot know where the accouting is leaking other than
> > kmem.usage_in_bytes or memory.usage_in_bytes. and can't fix the issue.
> >
> > please add EXPERIMENTAL to Kconfig until this is fixed.
> 
> I am working on something here that may allow it.
> But I think it is independent of the rest, and I can repost the series 
> fixing the problems raised here without it, + EXPERIMENTAL.
> 
> Btw, using EXPERIMENTAL here is a very good idea. I think that we should
> turn EXPERIMENTAL on even if I fix for that exists, for a least a couple
> of months until we see how this thing really evolves.
> 
> What do you think?
> 

Yes, I think so. IIRC, SWAP accounting was EXPERIMENTAL for a year.

> >> I can push a proposal for it, but it would be done in a separate patch
> >> anyway. Also, we may be in better conditions to fix this when the slab
> >> part is merged - since it will likely have the same problems...
> >>
> >
> > Yes. considering sockets which can be shared between tasks(cgroups)
> > you'll finally need
> >    - owner task of socket
> >    - account moving callback
> >
> > Or disallow task moving once accounted.
> 
> I personally think disallowing task movement once accounted is 
> reasonable. At least for starters.
> 

Hmm. I'm ok with that...but I'm not very sure how that will be trouble.
So, please make it debuggable why task cannot be moved.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
