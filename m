Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D93F46B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 20:36:43 -0400 (EDT)
Date: Thu, 15 Oct 2009 09:27:31 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 0/8] memcg: recharge at task move (Oct13)
Message-Id: <20091015092731.a13456fb.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091014160350.22185f3f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
	<20091014160350.22185f3f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Thank you for your comments.

On Wed, 14 Oct 2009 16:03:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 13 Oct 2009 13:49:03 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > These are my current patches for recharge at task move.
> > 
> > In current memcg, charges associated with a task aren't moved to the new cgroup
> > at task move. These patches are for this feature, that is, for recharging to
> > the new cgroup and, of course, uncharging from old cgroup at task move.
> > 
> > I've tested these patches on 2.6.32-rc3(+ some patches) with memory pressure
> > and rmdir, they didn't cause any BUGs during last weekend.
> > 
> > Major Changes from Sep24:
> > - rebased on mmotm-2009-10-09-01-07 + KAMEZAWA-san's batched charge/uncharge(Oct09)
> >   + part of KAMEZAWA-san's cleanup/fix patches(4,5,7 of Sep25 with some fixes).
> > - changed the term "migrate" to "recharge".
> > 
> > TODO:
> > - update Documentation/cgroup/memory.txt
> > - implement madvise(2) (MADV_MEMCG_RECHARGE/NORECHARGE)
> > 
> 
> Seems nice in general.
> 
Thanks.

> But, as 1st version, could you postpone recharging "shared pages" ?
> I think automatic recharge of them is not very good. I don't like
> Moving anonymous "shared" pages and file pages.
> 
Just for clarification, you mean "page_mapcount > 1" by "shared", right?

> When a user use this method.
> ==
>    if (fork()) {
> 	add this to cgroup
> 	execve()
>    }
> ==
> All parent's memory will be recharged.
> 
yes.

> I wonder, use madivse(MADV_MEMCG_AUTO_RECHARGE) to set flag to vmas
> and use the flag as hint to auto-recharge will be good idea, finally.
> 
> (*) To be honest, I believe users will not want to modify their program
>     only for this. So, recharging secified vma/file/shmem by external
>     program will be necessary.
> 
I think adding new MADV_MEMCG_** would make sense, I agree that users
will not want to modify their program though and it would be a desirable feature
to specify a vma to be recharged by external program(I don't have any idea now to do it).

I think extending the meaning of memory.recharge_at_immigrate(or adding
new flag file) can be used to some extent for an administrator(or a middle ware)
to decide the type of pages to be recharged.

> 
> For another example, an admin tries to charge libXYZ.so into /group_A.
> He can do
>    # echo 0 > ..../group_A/tasks.
>    # cat libXYZ.so > /dev/null
> 
> After that, if a user moves a program in group_A which uses libXYZ.so,
> libXYZ.so will be recharged automatically.
> 
hmm, yes.

> There will be several policy around this. But start-from-minimum is not very
> bad for this functionality because we have no feature now.
> 
> Could you start from recharge "not shared pages" ?
> We'll be able to update feature, for example, add flag to memcg as
> your 1st version does.
> 
I see your concern and I agree that we can start from minimum and enhance later.

I adopted mandatory policy just because, without support for shared pages for example,
we can never recharge those pages even after all of the processes that uses those
shared pages are moved to new group.

I've not considered thoroughly yet, my current plan is
  - add support for new page type
    - file pages
    - shmem/tmpfs page
  - add support for shared(page_mapcount > 1) pages

Anyway, I'll repost my patches with only support for non-shared-anon pages
(and swaps of those pages if possible) as a 1st version.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
