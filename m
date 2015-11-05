Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9937182F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 13:18:49 -0500 (EST)
Received: by wijp11 with SMTP id p11so16001139wij.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 10:18:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v136si13093596wmd.15.2015.11.05.10.18.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 10:18:48 -0800 (PST)
Subject: Re: [PATCH 3/12] mm: page migration fix PageMlocked on migrated pages
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
 <alpine.LSU.2.11.1510182150590.2481@eggly.anvils>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B9D86.30608@suse.cz>
Date: Thu, 5 Nov 2015 19:18:46 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1510182150590.2481@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On 10/19/2015 06:52 AM, Hugh Dickins wrote:
> Commit e6c509f85455 ("mm: use clear_page_mlock() in page_remove_rmap()")
> in v3.7 inadvertently made mlock_migrate_page() impotent: page migration
> unmaps the page from userspace before migrating, and that commit clears
> PageMlocked on the final unmap, leaving mlock_migrate_page() with nothing
> to do.  Not a serious bug, the next attempt at reclaiming the page would
> fix it up; but a betrayal of page migration's intent - the new page ought
> to emerge as PageMlocked.
> 
> I don't see how to fix it for mlock_migrate_page() itself; but easily
> fixed in remove_migration_pte(), by calling mlock_vma_page() when the
> vma is VM_LOCKED - under pte lock as in try_to_unmap_one().
> 
> Delete mlock_migrate_page()?  Not quite, it does still serve a purpose
> for migrate_misplaced_transhuge_page(): where we could replace it by a
> test, clear_page_mlock(), mlock_vma_page() sequence; but would that be
> an improvement?  mlock_migrate_page() is fairly lean, and let's make
> it leaner by skipping the irq save/restore now clearly not needed.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
