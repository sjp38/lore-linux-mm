Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB3G8Dtk022994
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Dec 2008 01:08:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 87B9445DE58
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:08:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA9D45DE57
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:08:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B981DB8042
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:08:13 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DE6011DB803E
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 01:08:12 +0900 (JST)
Message-ID: <16817.10.75.179.62.1228320492.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081203134024.GD17701@balbir.in.ibm.com>
References: <200811291259.27681.knikanth@suse.de>
    <20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
    <200812010951.36392.knikanth@suse.de>
    <20081201133030.0a330c7b.kamezawa.hiroyu@jp.fujitsu.com>
    <20081203134024.GD17701@balbir.in.ibm.com>
Date: Thu, 4 Dec 2008 01:08:12 +0900 (JST)
Subject: Re: [PATCH] Unused check for thread group leader
     inmem_cgroup_move_task
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nikanth Karthikesan <knikanth@suse.de>, containers@lists.linux-foundation.org, xemul@openvz.org, linux-mm@kvack.org, nikanth@gmail.com
List-ID: <linux-mm.kvack.org>

Balbir Singh said:
>> On Mon, 1 Dec 2008 09:51:35 +0530
>> Nikanth Karthikesan <knikanth@suse.de> wrote:
>>
>> > Ok. Then should we remove the unused code which simply checks for
>> thread group
>> > leader but does nothing?
>> >
>> > Thanks
>> > Nikanth
>> >
>> Hmm, it seem that code is obsolete. thanks.
>> Balbir, how do you think ?
>>
>> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Anyway we have to visit here, again.
>
> Sorry, I did not review this patch. The correct thing was nikanth did
> at first, move this to can_attach(). Why would we allow threads to
> exist in different groups, but still mark them as being accounted to
> the thread group leader.
>
Considering following case,

  # mount -t cgroup none /cgroup -t memory,cpuset
  # mkdir /cgroup/grpA/
  # echo 1 > /cgroup/grpA/memory.use_hierarchy
  # echo 1G > /cgroup/grpA/memory.limit_in_bytes
  # mkdir /cgroup/grpA/01
  # mkdir /cgroup/grpA/02
  limit grpA/01's cpu to 0
  limit grpA/02's cpu to 1

  Run multithread program under grpA and move threads to grpA/01, grpA/02
  if necessary to bind cpu.

Your "hierarchy" added this kind of flexibility and this is very useful.
And, of course, cgroup generic interface allows per-thread group attaching.

This is why I changed my mind and agreed to handle hierarchy management
under the kernel.

This can be an answer for use case to explain why thread-leader-check is
bad ? If we add limitation as "memcgroup should be mounted without
others",

And, if we only allows attaching thread-group-leader, how to migrate
multi-threaded program's all thread ?

I'm sorry I misunderstand something.

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
