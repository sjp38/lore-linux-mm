Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 10DA36B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 20:18:39 -0500 (EST)
Received: by dald2 with SMTP id d2so97068dal.9
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 17:18:38 -0800 (PST)
Date: Wed, 29 Feb 2012 17:18:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH next] memcg: fix deadlock by avoiding stat lock when
 anon
In-Reply-To: <20120229193517.GD1673@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1202291648340.11821@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils> <alpine.LSU.2.00.1202282125240.4875@eggly.anvils> <20120229193517.GD1673@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Feb 2012, Johannes Weiner wrote:
> 
> Saving the begin/end_update_page_stat() calls for the anon case where
> we know in advance we don't need them is one thing, but this also
> hides a dependencies that even eludes lockdep behind what looks like a
> minor optimization of the anon case.

Sounds like you'd appreciate a comment there: akpm has not put
this version in yet, so I'll send an updated version shortly.

> 
> Wouldn't this be more robust if we turned the ordering inside out in
> move_account instead?

I think we need more than the one user of this infrastructure before
that can be decided.

But I didn't actually consider that at all: perhaps prejudiced by the
way I had solved the race Konstantin pointed out in my patchset of 10
last week, by using the lruvec lock for move_lock_mem_cgroup too,
which fits with it being inside the page_cgroup lock.

Hmm, I notice move_lock_mem_cgroup is likewise spin_lock_irqsave:
if it needs to be (and I guess the idea is that it doesn't need to be
today, but for generality later on had better be), then it has to be
inside page_cgroup lock.

(If FILE_MAPPED were to be the only user of the infrastructure, I'd
actually prefer to remove the begin/end, and make move_account raise
the file page's mapcount temporarily, doing its own page_remove_rmap
after, to solve these races.  There's probably one or two VM_BUG_ONs
elsewhere that would need deleting to make that completely safe.
But I understand there may be more users to come - and mapcount
games might not fit your desire for robustness.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
