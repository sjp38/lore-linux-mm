Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4107E6B0037
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:24:24 -0400 (EDT)
Date: Tue, 27 Aug 2013 15:24:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 7/7] mm: munlock: manual pte walk in fast path
 instead of follow_page_mask()
Message-Id: <20130827152421.4f546507364eb9da7fd5add0@linux-foundation.org>
In-Reply-To: <1376915022-12741-8-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
	<1376915022-12741-8-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, 19 Aug 2013 14:23:42 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> Currently munlock_vma_pages_range() calls follow_page_mask() to obtain each
> struct page. This entails repeated full page table translations and page table
> lock taken for each page separately.
> 
> This patch attempts to avoid the costly follow_page_mask() where possible, by
> iterating over ptes within single pmd under single page table lock. The first
> pte is obtained by get_locked_pte() for non-THP page acquired by the initial
> follow_page_mask(). The latter function is also used as a fallback in case
> simple pte_present() and vm_normal_page() are not sufficient to obtain the
> struct page.

mm/mlock.c: In function 'munlock_vma_pages_range':
mm/mlock.c:388: warning: 'pmd_end' may be used uninitialized in this function

As far as I can tell, this is notabug, but I'm not at all confident in
that - the protocol for locals `pte' and `pmd_end' is bizarre.

The function is fantastically hard to follow and deserves to be dragged
outside, shot repeatedly then burned.  Could you please, as a matter of
some urgency, take a look at rewriting the entire thing so that it is
less than completely insane?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
