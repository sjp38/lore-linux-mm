Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 145396B0068
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 12:59:08 -0500 (EST)
Date: Wed, 19 Dec 2012 12:58:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/7] mm: reduce rmap overhead for ex-KSM page copies
 created on swap faults
Message-ID: <20121219175811.GD7147@cmpxchg.org>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
 <1355767957-4913-8-git-send-email-hannes@cmpxchg.org>
 <1355900479.1381.1.camel@kernel-VirtualBox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355900479.1381.1.camel@kernel-VirtualBox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 19, 2012 at 02:01:19AM -0500, Simon Jeons wrote:
> On Mon, 2012-12-17 at 13:12 -0500, Johannes Weiner wrote:
> > When ex-KSM pages are faulted from swap cache, the fault handler is
> > not capable of re-establishing anon_vma-spanning KSM pages.  In this
> > case, a copy of the page is created instead, just like during a COW
> > break.
> > 
> > These freshly made copies are known to be exclusive to the faulting
> > VMA and there is no reason to go look for this page in parent and
> > sibling processes during rmap operations.
> > 
> > Use page_add_new_anon_rmap() for these copies.  This also puts them on
> > the proper LRU lists and marks them SwapBacked, so we can get rid of
> > doing this ad-hoc in the KSM copy code.
> 
> Is it just a code cleanup instead of reduce rmap overhead?

Both.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
