Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1336B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:07:26 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so3574920wev.40
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:07:25 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id hl12si4282198wib.101.2014.07.18.08.07.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 08:07:24 -0700 (PDT)
Date: Fri, 18 Jul 2014 11:07:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: use page lists for uncharge batching
Message-ID: <20140718150719.GH29639@cmpxchg.org>
References: <1404759358-29331-1-git-send-email-hannes@cmpxchg.org>
 <20140717152936.GF8011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140717152936.GF8011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 17, 2014 at 05:29:36PM +0200, Michal Hocko wrote:
> On Mon 07-07-14 14:55:58, Johannes Weiner wrote:
> > Pages are now uncharged at release time, and all sources of batched
> > uncharges operate on lists of pages.  Directly use those lists, and
> > get rid of the per-task batching state.
> > 
> > This also batches statistics accounting, in addition to the res
> > counter charges, to reduce IRQ-disabling and re-enabling.
> 
> It is probably worth noticing that there is a higher chance of missing
> threshold events now when we can accumulate huge number of uncharges
> during munmaps. I do not think this is earth shattering and the overall
> improvement is worth it but changelog should mention it.

Does this actually matter, though?  We might deliver events a few
pages later than before, but as I read the threshold code, once
invoked it catches up from the last delivered threshold to the new
usage.  So we shouldn't *miss* any events.

> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> With the follow up fix from
> http://marc.info/?l=linux-mm&m=140552814228135&w=2
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> > +static void uncharge_list(struct list_head *page_list)
> > +{
> > +	struct mem_cgroup *memcg = NULL;
> > +	unsigned long nr_memsw = 0;
> > +	unsigned long nr_anon = 0;
> > +	unsigned long nr_file = 0;
> > +	unsigned long nr_huge = 0;
> > +	unsigned long pgpgout = 0;
> > +	unsigned long nr_mem = 0;
> > +	struct list_head *next;
> > +	struct page *page;
> > +
> > +	next = page_list->next;
> > +	do {
> 
> I would use list_for_each_entry here which would also save list_empty
> check in mem_cgroup_uncharge_list

list_for_each_entry() wouldn't work for the singleton list where we
pass in page->lru.  That's why it's a do-while that always does the
first page before checking whether it looped back to the list head.

Do we need a comment for that?  I'm not convinced, there are only two
callsites, and the one that passes the singleton page->lru is right
below this function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
