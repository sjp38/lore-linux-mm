Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 73B366B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 09:02:34 -0400 (EDT)
Message-ID: <521F4666.20809@suse.cz>
Date: Thu, 29 Aug 2013 15:02:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 7/7] mm: munlock: manual pte walk in fast path instead
 of follow_page_mask()
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz> <1376915022-12741-8-git-send-email-vbabka@suse.cz> <20130827152421.4f546507364eb9da7fd5add0@linux-foundation.org>
In-Reply-To: <20130827152421.4f546507364eb9da7fd5add0@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 08/28/2013 12:24 AM, Andrew Morton wrote:
> On Mon, 19 Aug 2013 14:23:42 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>> Currently munlock_vma_pages_range() calls follow_page_mask() to obtain each
>> struct page. This entails repeated full page table translations and page table
>> lock taken for each page separately.
>>
>> This patch attempts to avoid the costly follow_page_mask() where possible, by
>> iterating over ptes within single pmd under single page table lock. The first
>> pte is obtained by get_locked_pte() for non-THP page acquired by the initial
>> follow_page_mask(). The latter function is also used as a fallback in case
>> simple pte_present() and vm_normal_page() are not sufficient to obtain the
>> struct page.
> 
> mm/mlock.c: In function 'munlock_vma_pages_range':
> mm/mlock.c:388: warning: 'pmd_end' may be used uninitialized in this function
> 
> As far as I can tell, this is notabug, but I'm not at all confident in
> that - the protocol for locals `pte' and `pmd_end' is bizarre.

I agree with both points.
 
> The function is fantastically hard to follow and deserves to be dragged
> outside, shot repeatedly then burned.

Aww, poor function, and it's all my fault. Let's put it on a diet instead...

> Could you please, as a matter of
> some urgency, take a look at rewriting the entire thing so that it is
> less than completely insane?

This patch replaces the following patch in the mm tree:
mm-munlock-manual-pte-walk-in-fast-path-instead-of-follow_page_mask.patch

Changelog since V2:
  o Split PTE walk to __munlock_pagevec_fill()
  o __munlock_pagevec() does not reinitialize the pagevec anymore
  o Use page_zone_id() for checking if pages are in the same zone (smaller
    overhead than page_zone())

The only small functional change is that previously failing the pte walk would
fall back to follow_page_mask() while continuing with the same partially filled
pagevec. Now, pagevec is munlocked immediately after pte walk fails. This means
that batching might be sometimes less effective, but it the gained simplicity
should be worth it.

--->8---
