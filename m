Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF9C66B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 02:28:23 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so10621659pad.10
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 23:28:23 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id it5si27342763pbc.230.2014.11.30.23.28.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 23:28:20 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so10558857pab.4
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 23:28:20 -0800 (PST)
Date: Sun, 30 Nov 2014 23:28:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: unmapped page migration avoid unmap+remap overhead
In-Reply-To: <547C0E4E.4020605@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.11.1411302302280.6613@eggly.anvils>
References: <alpine.LSU.2.11.1411302046420.5335@eggly.anvils> <547C0E4E.4020605@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 1 Dec 2014, Yasuaki Ishimatsu wrote:
> (2014/12/01 13:52), Hugh Dickins wrote:
> > @@ -798,7 +798,7 @@ static int __unmap_and_move(struct page
> >   				int force, enum migrate_mode mode)
> >   {
> >   	int rc = -EAGAIN;
> > -	int remap_swapcache = 1;
> > +	int page_was_mapped = 0;
> >   	struct anon_vma *anon_vma = NULL;
> > 
> >   	if (!trylock_page(page)) {
> > @@ -870,7 +870,6 @@ static int __unmap_and_move(struct page
> >   			 * migrated but are not remapped when migration
> >   			 * completes
> >   			 */
> > -			remap_swapcache = 0;
> >   		} else {
> >   			goto out_unlock;
> >   		}
> > @@ -910,13 +909,17 @@ static int __unmap_and_move(struct page
> >   	}
> > 
> >   	/* Establish migration ptes or remove ptes */
> 
> > -	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> > +	if (page_mapped(page)) {
> > +		try_to_unmap(page,
> > +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> > +		page_was_mapped = 1;
> > +	}
> 
> Is there no possibility that page is swap cache? If page is swap cache,
> this code changes behavior of move_to_new_page(). Is it O.K.?

Certainly the page may be swap cache, but I don't see how the behavior
of move_to_new_page() is changed.

Do you mean how I removed that "remap_swapcache = 0;" line above, so that
it now looks as if move_to_new_page() may be called with page_was_mapped
1, where before it was called with remap_swapcache 0?

No: although it cannot be seen from the patch context, that reset
of remap_swapcache was in a block where we have a PageAnon page, but
page_get_anon_vma() failed to "get" the anon_vma for it: that means
that the page was not mapped, so page_was_mapped will be 0 too.

(I was going to add that the page might be faulted back in again by
the time we reach the page_mapped() test above try_to_unmap(), and
that yes I'd would be making a change in that case, but it does not
matter at all to diverge in racy cases.  But actually even that cannot
happen, since faulting back swap needs page lock which we hold here.)

There is an argument that move_to_new_page() behavior should be
changed in the case of swap cache: since try_to_unmap() then uses
the ordinary swap instead of a migration entry, there's not much
point in going to remove swap entries afterwards; though it would
be good to make those pages present again.  But I didn't try to
change that in this patch: this was just a lock contention thing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
