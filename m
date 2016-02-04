Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD444403D8
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 20:39:20 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id o185so25879896pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 17:39:20 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id af6si12822583pad.226.2016.02.03.17.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 17:39:19 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id w123so26014409pfb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 17:39:19 -0800 (PST)
Date: Wed, 3 Feb 2016 17:39:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/3] mm: migrate: do not touch page->mem_cgroup of live
 pages
In-Reply-To: <20160203183547.GA4007@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1602031648050.1497@eggly.anvils>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org> <1454109573-29235-2-git-send-email-hannes@cmpxchg.org> <20160203131748.GB15520@mguzik> <20160203140824.GJ21016@esperanza> <20160203183547.GA4007@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Mateusz Guzik <mguzik@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Wed, 3 Feb 2016, Johannes Weiner wrote:

> CCing Hugh and Greg, they have worked on the memcg migration code most
> recently. AFAIK the only reason newpage->mem_cgroup had to be set up
> that early in migration was because of the way dirty accounting used
> to work. But Hugh took memcg out of the equation there, so moving
> mem_cgroup_migrate() to the end should be safe, as long as the pages
> are still locked and off the LRU.

Yes, that should be safe now: Vladimir's patch looks okay to me,
fixing the immediate irq issue.

But it would be nicer, if mem_cgroup_migrate() were called solely
from migrate_page_copy() - deleting the other calls in mm/migrate.c,
including that from migrate_misplaced_transhuge_page() (which does
some rewinding on error after its migrate_page_copy(): but just as
you now let a successfully migrated old page be uncharged when it's
freed, so you can leave a failed new_page to be uncharged when it's
freed, no extra code needed).

And (even more off-topic), I'm slightly sad to see that the lrucare
arg which mem_cgroup_migrate() used to have (before I renamed it and
you renamed it back!) has gone, so mem_cgroup_migrate() now always
demands lrucare of commit_charge().  I'd hoped that with your
separation of new from old charge, mem_cgroup_migrate() would never
need lrucare; but that's not true for the fuse case, though true
for everyone else.  Maybe just not worth bothering about?  Or the
reintroduction of some unnecessary zone->lru_lock-ing in page
migration, which we ought to try to avoid?

Or am I wrong, and even fuse doesn't need it?  That early return
"if (newpage->mem_cgroup)": isn't mem_cgroup_migrate() a no-op for
fuse, or is there some corner case by which newpage can be on LRU
but its mem_cgroup unset?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
