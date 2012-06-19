Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D6BC26B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:11:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DD63B3EE0BB
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:11:55 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C63F845DE55
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:11:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B083145DD74
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:11:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A238B1DB803A
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:11:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DE6C1DB8038
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:11:55 +0900 (JST)
Message-ID: <4FDFC34B.3010003@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 09:09:47 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg: remove -EINTR at rmdir()
References: <4FDF17A3.9060202@jp.fujitsu.com> <20120618133012.GB2313@tiehlicka.suse.cz>
In-Reply-To: <20120618133012.GB2313@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/18 22:30), Michal Hocko wrote:
> On Mon 18-06-12 20:57:23, KAMEZAWA Hiroyuki wrote:
>> 2 follow-up patches for "memcg: move charges to root cgroup if use_hierarchy=0",
>> developped/tested onto memcg-devel tree. Maybe no HUNK with -next and -mm....
>> -Kame
>> ==
>> memcg: remove -EINTR at rmdir()
>>
>> By commit "memcg: move charges to root cgroup if use_hierarchy=0",
>> no memory reclaiming will occur at removing memory cgroup.
> 
> OK, so the there are only 2 reasons why move_parent could fail in this
> path. 1) it races with somebody else who is uncharging or moving the
> charge and 2) THP split.
> 1) works for us and 2) doens't seem to be serious enough to expect that
> it would stall rmdir on the group for unbound amount of time so the
> change is safe (can we make this into the changelog please?).
> 

Yes. But the failure of move_parent() (-EBUSY) will be retried.

Remaining problems are
 - attaching task while pre_destroy() is called.
 - creating child cgroup while pre_destroy() is called.

I think I need to make a patch for cgroup layer as I previously posted.
I'd like to try again.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
