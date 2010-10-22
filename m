Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CC8846B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 09:26:16 -0400 (EDT)
Received: from [10.10.7.10] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001458834.msg
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 08:26:11 -0500
Subject: Re: [PATCH V3] nommu: add anonymous page memcg accounting
From: "Steven J. Magnani" <steve@digidescorp.com>
Reply-To: steve@digidescorp.com
In-Reply-To: <20101022122010.793bebac.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
	 <20101022122010.793bebac.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Oct 2010 08:26:08 -0500
Message-ID: <1287753968.2589.58.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-10-22 at 12:20 +0900, KAMEZAWA Hiroyuki wrote:
> BTW, have you tried oom_notifier+NOMMU memory limit oom-killer ?
> It may be a chance to implement a custom OOM-Killer in userland on
> EMBEDED systems.

No - for what I need (simple sandboxing) just running my 'problem'
process in a memory cgroup is sufficient. I might even be able to get
away with oom_kill_allocating_task and no cgroup, but since that would
allow dosfsck to run the system completely out of memory there's no
guarantee that it would be the one that pushes the system over the edge.

What do you mean by "NOMMU memory limit"? (Is there some other way to
achieve the same functionality?)

I looked into David's initial suggestion of using ulimit to create a
sandbox but it seems that nommu.c doesn't respect RLIMIT_AS. When I can
find some time I'll try to cook up a patch for that.

Also it seems that nommu.c doesn't ever decrement mm->total_vm, which if
I'm reading the code correctly (before the 2.6.36 OOM-killer rewrite)
could throw off badness calculations for processes that do lots of
malloc/free operations. In 2.6.36 it doesn't look to me like this would
have any ill effects.

Thanks for all the feedback. I fully agree that maintenance should be a
strong consideration when merging new code.

Regards,
------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
