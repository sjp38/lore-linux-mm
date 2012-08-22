Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 42A7B6B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 17:23:17 -0400 (EDT)
Received: by iahk25 with SMTP id k25so48642iah.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 14:23:16 -0700 (PDT)
Date: Wed, 22 Aug 2012 14:22:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 19/36] autonuma: memory follows CPU algorithm and
 task/mm_autonuma stats collection
In-Reply-To: <m2sjbe7k93.fsf@firstfloor.org>
Message-ID: <alpine.LSU.2.00.1208221414450.2114@eggly.anvils>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com> <1345647560-30387-20-git-send-email-aarcange@redhat.com> <m2sjbe7k93.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 22 Aug 2012, Andi Kleen wrote:
> Andrea Arcangeli <aarcange@redhat.com> writes:
> > +		/*
> > +		 * Take the lock with irqs disabled to avoid a lock
> > +		 * inversion with the lru_lock. The lru_lock is taken
> > +		 * before the autonuma_migrate_lock in
> > +		 * split_huge_page. If we didn't disable irqs, the
> > +		 * lru_lock could be taken by interrupts after we have
> > +		 * obtained the autonuma_migrate_lock here.
> > +		 */
> 
> Which interrupt code takes the lru_lock? That sounds like a bug.

Not a bug: the clearest example is end_page_writeback() calling
rotate_reclaimable_page(); but I think once you probe deeper, you
find some other mm/swap.c pagevec operations which may get called
from interrupt, and end up freeing unrelated PageLRU pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
