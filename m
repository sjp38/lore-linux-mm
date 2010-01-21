Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD10A6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:18:49 -0500 (EST)
Date: Thu, 21 Jan 2010 10:04:16 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100121100416.88074a46.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <4B56BC09.2090508@linux.vnet.ibm.com>
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107083440.GS3059@balbir.in.ibm.com>
	<20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107092736.GW3059@balbir.in.ibm.com>
	<20100108084727.429c40fc.kamezawa.hiroyu@jp.fujitsu.com>
	<661de9471001171130p2b0ac061he6f3dab9ef46fd06@mail.gmail.com>
	<20100118094920.151e1370.nishimura@mxp.nes.nec.co.jp>
	<4B541B44.3090407@linux.vnet.ibm.com>
	<20100119102208.59a16397.nishimura@mxp.nes.nec.co.jp>
	<661de9471001181749y2fe22a15j1c01c94aa1838e99@mail.gmail.com>
	<20100119113443.562e38ba.nishimura@mxp.nes.nec.co.jp>
	<4B552C89.8000004@linux.vnet.ibm.com>
	<20100120130902.865d8269.nishimura@mxp.nes.nec.co.jp>
	<4B56BC09.2090508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010 13:47:13 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> On Wednesday 20 January 2010 09:39 AM, Daisuke Nishimura wrote:
> > On Tue, 19 Jan 2010 09:22:41 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> On Tuesday 19 January 2010 08:04 AM, Daisuke Nishimura wrote:
> >>> On Tue, 19 Jan 2010 07:19:42 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >>>> On Tue, Jan 19, 2010 at 6:52 AM, Daisuke Nishimura
> >>>> <nishimura@mxp.nes.nec.co.jp> wrote:
> >>>> [snip]
> >>>>>> Correct, file cache is almost always considered shared, so it has
> >>>>>>
> >>>>>> 1. non-private or shared usage of 10MB
> >>>>>> 2. 10 MB of file cache
> >>>>>>
> >>>>>>> I don't think "non private usage" is appropriate to this value.
> >>>>>>> Why don't you just show "sum_of_each_process_rss" ? I think it would be easier
> >>>>>>> to understand for users.
> >>>>>>
> >>>>>> Here is my concern
> >>>>>>
> >>>>>> 1. The gap between looking at memcg stat and sum of all RSS is way
> >>>>>> higher in user space
> >>>>>> 2. Summing up all rss without walking the tasks atomically can and
> >>>>>> will lead to consistency issues. Data can be stale as long as it
> >>>>>> represents a consistent snapshot of data
> >>>>>>
> >>>>>> We need to differentiate between
> >>>>>>
> >>>>>> 1. Data snapshot (taken at a time, but valid at that point)
> >>>>>> 2. Data taken from different sources that does not form a uniform
> >>>>>> snapshot, because the timestamping of the each of the collected data
> >>>>>> items is different
> >>>>>>
> >>>>> Hmm, I'm sorry I can't understand why you need "difference".
> >>>>> IOW, what can users or middlewares know by the value in the above case
> >>>>> (0MB in 01 and 10MB in 02)? I've read this thread, but I can't understande about
> >>>>> this point... Why can this value mean some of the groups are "heavy" ?
> >>>>>
> >>>>
> >>>> Consider a default cgroup that is not root and assume all applications
> >>>> move there initially. Now with a lot of shared memory,
> >>>> the default cgroup will be the first one to page in a lot of the
> >>>> memory and its usage will be very high. Without the concept of
> >>>> showing how much is non-private, how does one decide if the default
> >>>> cgroup is using a lot of memory or sharing it? How
> >>>> do we decide on limits of a cgroup without knowing its actual usage -
> >>>> PSS equivalent for a region of memory for a task.
> >>>>
> >>> As for limit, I think we should decide it based on the actual usage because
> >>> we account and limit the accual usage. Why we should take account of the sum of rss ?
> >>
> >> I am talking of non-private pages or potentially shared pages - which is
> >> derived as follows
> >>
> >> sum_of_all_rss - (rss + file_mapped) (from .stat file)
> >>
> >> file cache is considered to be shared always
> >>
> >>
> >>> I agree that we'd better not to ignore the sum of rss completely, but could you show me
> >>> how the value 0MB/10MB can be used to caluculate the limit in 01/02 in detail ?
> >>
> >> In your example, usage shows that the real usage of the cgroup is 20 MB
> >> for 01 and 10 MB for 02.
> > right.
> > 
> >> Today we show that we are using 40MB instead of
> >> 30MB (when summed).
> > Sorry, I can't understand here.
> > If we sum usage_in_bytes in both groups, it would be 30MB.
> 
> Right
> 
> > If we sum "actual rss(rss_file, rss_anon) via stat file" in both groups, it would be 30M.
> > If we sum "total rss(rss_file, rss_anon) of all process via mm_counter" in both groups,
> > it would be 40MB.
> > 
> 
> mm_counter would show 40GB, memcgroup would show 30MB you are right. But
> of the 30MB, do we say the one using 20MB is consuming more resources?
> 
> >> If an administrator has to make a decision to say
> >> add more resources, the one with 20MB would be the right place w.r.t.
> >> memory.
> >>
> > You mean he would add the additional resource to 00, right? Then, 
> > the smaller "shared_usage_in_bytes" is, the more likely an administrator should
> > add additional resources to the group ?
> > 
> > But when both /cgroup/memory/aa and /cgroup/memory/bb has 20MB as acutual usage,
> > and aa has 10MB "shared"(used by multiple processes *in aa*) usage while bb has none,
> > "shared_usage_in_bytes" is 10MB in aa and 0MB in bb(please consider there is
> > no "shared" usage between aa and bb).
> > Should an administrator consider bb is heavier than aa ? I don't think so.
> > 
> 
> No.. but before OOM killing or considering moving in a virtual
> environment the cgorup "aa", the real usage should be considered or
> at-least the fact that moving "bb" would require 20MB.
> 
> > IOW, "shared_usage_in_bytes" doesn't have any consistent meaning about which
> > group is unfairly "heavy".
> > 
> 
> No, but it gives an idea of the sharing, which can be important for
> making decisions and estimating the real usage. In the case of aa, one
> can estimate private usage to be 20MB - 10MB (10MB) which is one correct
> way of looking at the heaviness of the cgroup.
> 
This incosistency is the problem I worry about the most. The bigger "shared_usage_in_bytes" is,
the more likey the group is "heavy", or the opposite ? It only confuses users.

The "shared_usage_in_bytes" of A can be used to roughly estimate a sum of

i) memory usage used by multiple processes in A.
ii) memroy usage processes in A charges to OTHER GROUPS.
                                ^^^^^^^^^^^^^^^^^^^^^^^
I would say "yes, it might be usefull to decide the weight of A" if it can be used
to estimate a sum of i) and

iii) memory usage processes in OTHER GROUPS charges to A.
                                            ^^^^^^^^^^^^

Anyway, I wouldn't say any more about the usefullness of "shared_usage_in_bytes".

But if you dare to add this interface to kernel, please and please write the documentation
that it can be used to roughly estimate a sum of i) and ii), not sum of i) and iii), and
can be used to decide the weight of the group only when few pages are shared between groups.
So that users doesn't misunderstand nor misuse the interface.

And I think you should answer what Kamezawa-san pointed in http://lkml.org/lkml/2010/1/17/186.


Thanks,
Daisuke Nishimura.

> > The problem here is, "shared_usage_in_bytes" doesn't show neither one of nor the sum
> > of the following value(*IFF* we have only one cgroup, "shared_usage_in_bytes" would
> > mean a), but it has no use in real case).
> > 
> >   a) memory usage used by multiple processes inside this group.
> >   b) memory usage used by both processes inside this and another group.
> >   c) memory usage not used by any processes inside this group, but used by
> >      that of in another group.
> > 
> > IMHO, we should take account of all the above values to determine which group
> > is unfairly "heavy". I agree that the bigger the size of a) is, the bigger
> > "shared_usage_in_bytes" of the group would be, but we cannot know any information about
> > the size of b) by it, becase those usages are included in both actual usage(rss via stat)
> 
> (b) IMHO is a longer term goal and can be estimated from the PSS of the
> processes within the cgroup
> 
> > and sum of rss(via mm_counter). To make matters warse, "shared_usage_in_bytes" has
> > the opposite meaning about b), i.e., the more a processe in some group(foo) has actual
> > charges in *another* group(baa), the bigger "shared_usage_in_bytes" in "foo" would be
> > (as 00 and 01 in my example).
> > 
> > I would agree with you if you add interfaces to show some hints to users about above values,
> > but "shared_usage_in_bytes" doesn't meet it at all.
> > 
> 
> Not sure I follow your suggestion here.
> 
> Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
