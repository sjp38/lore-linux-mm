Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 540F66B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 19:06:31 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so3720688pac.38
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:06:30 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id i1si17617769pdf.193.2014.09.22.16.06.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 16:06:30 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id ey11so6040870pad.0
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 16:06:30 -0700 (PDT)
Date: Mon, 22 Sep 2014 16:04:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: NULL ptr deref in migrate_page_move_mapping
In-Reply-To: <5420407E.8040406@oracle.com>
Message-ID: <alpine.LSU.2.11.1409221531570.1244@eggly.anvils>
References: <5420407E.8040406@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>

On Mon, 22 Sep 2014, Sasha Levin wrote:
> 
> 	int migrate_page_move_mapping(struct address_space *mapping,
> 	                struct page *newpage, struct page *page,
> 	                struct buffer_head *head, enum migrate_mode mode,
> 	                int extra_count)
> 	{
> 	        int expected_count = 1 + extra_count;
> 	        void **pslot;
> 	
> 	        if (!mapping) {
> 	                /* Anonymous page without mapping */
> 	                if (page_count(page) != expected_count)
> 	                        return -EAGAIN;
> 	                return MIGRATEPAGE_SUCCESS;
> 	        }
> 	
> 	        spin_lock_irq(&mapping->tree_lock);
> 	
> 	        pslot = radix_tree_lookup_slot(&mapping->page_tree,
> 	                                        page_index(page));  <==== Returned NULL
> 	
> 	        expected_count += 1 + page_has_private(page);
> 	        if (page_count(page) != expected_count ||
> 	                radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) { <==== Dereferenced that NULL
> 	                spin_unlock_irq(&mapping->tree_lock);
> 	                return -EAGAIN;
> 	        }
> 
> I don't think it's just a missing '!= NULL' check

I agree: we have had this page locked since before the
mapping = page_mapping(page), so it ought to be in its radix_tree.

Though if we believe that argument, then am I not implying that the
"radix_blah() != page" check is redundant?  Hmm, perhaps someone can
see why it is needed, in which case that might give a hint on the crash.

But my suspicion is that it's just for safety: it corresponds to the
original "*radix_pointer != page" check in the first mm/migrate.c in
2.6.17, which may be there just so as not to rely so heavily on mm
locking protocols enforced elsewhere.

> but I'm not sure what went wrong.

Most likely would be a zeroing of the radix_tree node, just as you
were experiencing zeroing of other mm structures in earlier weeks.

Not that I've got any suggestions on where to take it from there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
