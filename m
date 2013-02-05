Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id F13AB6B0029
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 07:35:19 -0500 (EST)
Date: Tue, 5 Feb 2013 13:35:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [LSF/MM TOPIC] Few things I would like to discuss
Message-ID: <20130205123515.GA26229@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hi,
I would like to discuss the following topics:
* memcg oom should be more sensitive to locked contexts because now
  it is possible that a task is sitting in mem_cgroup_handle_oom holding
  some other lock (e.g. i_mutex or mmap_sem) up the chain which might
  block other task to terminate on OOM so we basically end up in a
  deadlock. Almost all memcg charges happen from the page fault path
  where we can retry but one class of them happen from
  add_to_page_cache_locked and that is a bit more problematic.
* memcg doesn't use PF_MEMALLOC for the targeted reclaim code paths
  which asks for stack overflows (and we have already seen those -
  e.g. from the xfs pageout paths). The primary problem to use the flag
  is that there is no dirty pages throttling and writeback kicked out
  for memcg so if we didn't writeback from the reclaim the caller could
  be blocked for ever. Memcg dirty accounting is shaping slowly so we
  should start thinking about the writeback as well.
* While we are at the memcg dirty pages accounting 
  (https://lkml.org/lkml/2012/12/25/95). It turned out that the locking
  is really nasty (https://lkml.org/lkml/2013/1/2/48). The locking
  should be reworked without incurring any penalty on the fast path.
  This sounds really challenging.
* I would really like to finally settle down on something wrt. soft
  limit reclaim. I am pretty sure Ying would like to discuss this topic
  as well so I will not go into details about it. I will post what I
  have before the conference so that we can discuss her approach and
  what was the primary disagreement the last time. I can go into more
  ditails as a follow up if people are interested of course.
* Finally I would like to collect feedback for the mm git tree.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
