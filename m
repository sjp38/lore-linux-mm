Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1E56B4925
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:49:48 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w18so20353708qts.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:49:48 -0800 (PST)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id h14si2475031qvc.2.2018.11.27.08.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Nov 2018 08:49:47 -0800 (PST)
Date: Tue, 27 Nov 2018 16:49:47 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
In-Reply-To: <20181127105602.GC16502@rapoport-lnx>
Message-ID: <010001675613a406-89de05df-ccf6-4bfa-ae3b-6f94148d514a-000000@email.amazonses.com>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils> <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com> <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils> <20181126205351.GM3065@bombadil.infradead.org>
 <20181127105602.GC16502@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Nov 2018, Mike Rapoport wrote:

> >  * @page: The page to wait for.
> >  *
> >  * The caller should hold a reference on @page.  They expect the page to
> >  * become unlocked relatively soon, but do not wish to hold up migration
> >  * (for example) by holding the reference while waiting for the page to
> >  * come unlocked.  After this function returns, the caller should not
> >  * dereference @page.
> >  */
>
> How about:
>
> They expect the page to become unlocked relatively soon, but they can wait
> for the page to come unlocked without holding the reference, to allow
> other users of the @page (for example migration) to continue.

All of this seems a bit strange and it seems unnecessary? Maybe we need a
better explanation?

A process has no refcount on a page struct and is waiting for it to become
unlocked? Why? Should it not simply ignore that page and continue? It
cannot possibly do anything with the page since it does not hold a
refcount.

In order to do anything with the page struct it would have to obtain a
refcount and possibly lock the page. That would already wait for the
page to become unlocked.
