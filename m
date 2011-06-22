Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 62604900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 08:32:11 -0400 (EDT)
Date: Wed, 22 Jun 2011 14:32:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH V2] mm: Do not keep page locked during page fault while
 charging it for memcg
Message-ID: <20110622123204.GC14343@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
 <20110622121516.GA28359@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110622121516.GA28359@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>

On Wed 22-06-11 08:15:16, Christoph Hellwig wrote:
> > +
> > +			/* We have to drop the page lock here because memcg
> > +			 * charging might block for unbound time if memcg oom
> > +			 * killer is disabled.
> > +			 */
> > +			unlock_page(vmf.page);
> > +			ret = mem_cgroup_newpage_charge(page, mm, GFP_KERNEL);
> > +			lock_page(vmf.page);
> 
> This introduces a completely poinless unlock/lock cycle for non-memcg
> pagefaults.  Please make sure it only happens when actually needed.

Fair point. Thanks!
What about the following?
I realize that pushing more memcg logic into mm/memory.c is not nice but
I found it better than pushing the old page into mem_cgroup_newpage_charge.
We could also check whether the old page is in the root cgroup because
memcg oom killer is not active there but that would add more code into
this hot path so I guess it is not worth it.

Changes since v1
- do not unlock page when memory controller is disabled.

8<------
