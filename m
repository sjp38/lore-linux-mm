Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 078606B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 03:06:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9E76AY3015573
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Oct 2009 16:06:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B581A2AF3F7
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:06:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 96EB345DD6C
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:06:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 755ECE38005
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:06:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0DFE38002
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:06:10 +0900 (JST)
Date: Wed, 14 Oct 2009 16:03:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/8] memcg: recharge at task move (Oct13)
Message-Id: <20091014160350.22185f3f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Oct 2009 13:49:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> These are my current patches for recharge at task move.
> 
> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task move. These patches are for this feature, that is, for recharging to
> the new cgroup and, of course, uncharging from old cgroup at task move.
> 
> I've tested these patches on 2.6.32-rc3(+ some patches) with memory pressure
> and rmdir, they didn't cause any BUGs during last weekend.
> 
> Major Changes from Sep24:
> - rebased on mmotm-2009-10-09-01-07 + KAMEZAWA-san's batched charge/uncharge(Oct09)
>   + part of KAMEZAWA-san's cleanup/fix patches(4,5,7 of Sep25 with some fixes).
> - changed the term "migrate" to "recharge".
> 
> TODO:
> - update Documentation/cgroup/memory.txt
> - implement madvise(2) (MADV_MEMCG_RECHARGE/NORECHARGE)
> 

Seems nice in general.

But, as 1st version, could you postpone recharging "shared pages" ?
I think automatic recharge of them is not very good. I don't like
Moving anonymous "shared" pages and file pages.

When a user use this method.
==
   if (fork()) {
	add this to cgroup
	execve()
   }
==
All parent's memory will be recharged.

I wonder, use madivse(MADV_MEMCG_AUTO_RECHARGE) to set flag to vmas
and use the flag as hint to auto-recharge will be good idea, finally.

(*) To be honest, I believe users will not want to modify their program
    only for this. So, recharging secified vma/file/shmem by external
    program will be necessary.


For another example, an admin tries to charge libXYZ.so into /group_A.
He can do
   # echo 0 > ..../group_A/tasks.
   # cat libXYZ.so > /dev/null

After that, if a user moves a program in group_A which uses libXYZ.so,
libXYZ.so will be recharged automatically.

There will be several policy around this. But start-from-minimum is not very
bad for this functionality because we have no feature now.

Could you start from recharge "not shared pages" ?
We'll be able to update feature, for example, add flag to memcg as
your 1st version does.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
