Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 0FB4B6B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 19:39:37 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C83F53EE0BC
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:39:35 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70DBB45DEC0
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:39:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 39EED45DEBF
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:39:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AFF91DB8040
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:39:35 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D7E3C1DB803C
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:39:34 +0900 (JST)
Message-ID: <511AE0B5.4020502@jp.fujitsu.com>
Date: Wed, 13 Feb 2013 09:39:17 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Few things I would like to discuss
References: <20130205123515.GA26229@dhcp22.suse.cz>
In-Reply-To: <20130205123515.GA26229@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

(2013/02/05 21:35), Michal Hocko wrote:
> Hi,
> I would like to discuss the following topics:

I missed the deadline :(


> * memcg oom should be more sensitive to locked contexts because now
>    it is possible that a task is sitting in mem_cgroup_handle_oom holding
>    some other lock (e.g. i_mutex or mmap_sem) up the chain which might
>    block other task to terminate on OOM so we basically end up in a
>    deadlock. Almost all memcg charges happen from the page fault path
>    where we can retry but one class of them happen from
>    add_to_page_cache_locked and that is a bit more problematic.

Yes, this is a topic should be discussed.

> * memcg doesn't use PF_MEMALLOC for the targeted reclaim code paths
>    which asks for stack overflows (and we have already seen those -
>    e.g. from the xfs pageout paths). The primary problem to use the flag
>    is that there is no dirty pages throttling and writeback kicked out
>    for memcg so if we didn't writeback from the reclaim the caller could
>    be blocked for ever. Memcg dirty accounting is shaping slowly so we
>    should start thinking about the writeback as well.

Sure.

> * While we are at the memcg dirty pages accounting
>    (https://lkml.org/lkml/2012/12/25/95). It turned out that the locking
>    is really nasty (https://lkml.org/lkml/2013/1/2/48). The locking
>    should be reworked without incurring any penalty on the fast path.
>    This sounds really challenging.

I'd like to fix the locking problem.

> * I would really like to finally settle down on something wrt. soft
>    limit reclaim. I am pretty sure Ying would like to discuss this topic
>    as well so I will not go into details about it. I will post what I
>    have before the conference so that we can discuss her approach and
>    what was the primary disagreement the last time. I can go into more
>    ditails as a follow up if people are interested of course.
> * Finally I would like to collect feedback for the mm git tree.
>

Other points related to memcg is ...

+ kernel memory accounting + per-zone-per-memcg inode/dentry caching.
   Glaubler tries to account inode/dentry in kmem controller. To do that,
   I think inode and dentry should be hanldled per zone, at first. IIUC, there are
   ongoing work but not merged yet.

+ overheads by memcg
   Mel explained memcg's big overheads last year's MM summit. AFAIK, we have not
   made any progress with that. If someone have detailed data, please share again...

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
