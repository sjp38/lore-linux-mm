Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 116C76B005A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 01:30:57 -0400 (EDT)
Received: by fxm5 with SMTP id 5so6900fxm.38
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 22:53:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090710135340.97b82f17.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
	 <20090710135340.97b82f17.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 10 Jul 2009 11:23:11 +0530
Message-ID: <661de9470907092253r8bbe353kbcbf96559ced021c@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v8)
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 10:23 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 09 Jul 2009 22:44:41 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>>
>> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>>
>> New Feature: Soft limits for memory resource controller.
>>
>> Here is v8 of the new soft limit implementation. Soft limits is a new fe=
ature
>> for the memory resource controller, something similar has existed in the
>> group scheduler in the form of shares. The CPU controllers interpretatio=
n
>> of shares is very different though.
>>
>> Soft limits are the most useful feature to have for environments where
>> the administrator wants to overcommit the system, such that only on memo=
ry
>> contention do the limits become active. The current soft limits implemen=
tation
>> provides a soft_limit_in_bytes interface for the memory controller and n=
ot
>> for memory+swap controller. The implementation maintains an RB-Tree of g=
roups
>> that exceed their soft limit and starts reclaiming from the group that
>> exceeds this limit by the maximum amount.
>>
>> v8 has come out after a long duration, we were held back by bug fixes
>> (most notably swap cache leak fix) and Kamezawa-San has his series of
>> patches for soft limits. Kamezawa-San asked me to refactor these patches
>> to make the data structure per-node-per-zone.
>>
>> TODOs
>>
>> 1. The current implementation maintains the delta from the soft limit
>> =A0 =A0and pushes back groups to their soft limits, a ratio of delta/sof=
t_limit
>> =A0 =A0might be more useful
>> 2. Small optimizations that I intend to push in v9, if the v8 design loo=
ks
>> =A0 =A0good and acceptable.
>>
>> Tests
>> -----
>>
>> I've run two memory intensive workloads with differing soft limits and
>> seen that they are pushed back to their soft limit on contention. Their =
usage
>> was their soft limit plus additional memory that they were able to grab
>> on the system. Soft limit can take a while before we see the expected
>> results.
>>
>
> Before pointing out nitpicks, here are my impressions.
>
> =A01. seems good in general.
>

Thanks

> =A02. Documentation is not enough. I think it's necessary to write "excus=
e" as
> =A0 =A0"soft-limit is built on complex memory management system's behavio=
r, then,
> =A0 =A0 this may not work as you expect. But in many case, this works wel=
l.
> =A0 =A0 please take this as best-effort service" or some.
>

Sure, I'll revisit it and update.

> =A03. Using "jiffies" again is not good. plz use other check or event cou=
nter.
>

Yes, I considered event based sampling and update. I wrote the code,
but then realized that it works really well if I keep the sampling per
cpu, otherwise it does not scale well. My problem with per-cpu
sampling is that the view we get could vary drastically if we migrated
or the task migrated to a different node and allocated memory.

> =A04. I think it's better to limit soltlimit only against root of hierarc=
y node.
> =A0 =A0(use_hierarchy=3D1) I can't explain how the system works if severa=
l soft limits
> =A0 =A0are set to root and its children under a hierarchy.
>

The idea is that if we add a node and it has children and that node
goes above the soft limit, we'll do hierarchical reclaim from the
children underneath almost like a normal reclaim, where the unused
pages would be reclaimed/ Having said that I am open to your
suggestion, my concern is that semantics can get a bit confusing as to
when the administrator can setup soft limits. We can come up with
guidelines and recommend your suggestion.

> =A05. I'm glad if you extract patch 4/5 as an independent clean up patch.
>

Thanks,

> =A06. no overheads ?
>

I ran some tests and saw no additional overheads, I'll test some more
and post results. There are some cleanups pending like the ones you
pointed, where we can use page_to_* instead of pc_* routines. I did
not clean them up as I wanted to get out the RFC soon with working
functionality and post v9 with those cleaned up.

Thanks for the review.
Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
