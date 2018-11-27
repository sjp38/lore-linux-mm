Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 971EB6B496D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:57:03 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so11120206edz.15
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:57:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2-v6si1991413eji.21.2018.11.27.08.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 08:57:01 -0800 (PST)
Date: Tue, 27 Nov 2018 17:56:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
Message-ID: <20181127165659.GC6923@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
 <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <20181126205351.GM3065@bombadil.infradead.org>
 <20181127105602.GC16502@rapoport-lnx>
 <010001675613a406-89de05df-ccf6-4bfa-ae3b-6f94148d514a-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001675613a406-89de05df-ccf6-4bfa-ae3b-6f94148d514a-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 27-11-18 16:49:47, Cristopher Lameter wrote:
> On Tue, 27 Nov 2018, Mike Rapoport wrote:
> 
> > >  * @page: The page to wait for.
> > >  *
> > >  * The caller should hold a reference on @page.  They expect the page to
> > >  * become unlocked relatively soon, but do not wish to hold up migration
> > >  * (for example) by holding the reference while waiting for the page to
> > >  * come unlocked.  After this function returns, the caller should not
> > >  * dereference @page.
> > >  */
> >
> > How about:
> >
> > They expect the page to become unlocked relatively soon, but they can wait
> > for the page to come unlocked without holding the reference, to allow
> > other users of the @page (for example migration) to continue.
> 
> All of this seems a bit strange and it seems unnecessary? Maybe we need a
> better explanation?
> 
> A process has no refcount on a page struct and is waiting for it to become
> unlocked? Why? Should it not simply ignore that page and continue? It
> cannot possibly do anything with the page since it does not hold a
> refcount.

So do you suggest busy waiting on the page under migration?
-- 
Michal Hocko
SUSE Labs
