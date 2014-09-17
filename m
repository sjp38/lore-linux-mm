Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 016246B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 16:39:25 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so2827752pdj.30
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:39:25 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id o2si36090783pdf.1.2014.09.17.13.39.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 13:39:24 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so2965843pad.2
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 13:39:23 -0700 (PDT)
Date: Wed, 17 Sep 2014 13:37:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Best way to pin a page in ext4?
In-Reply-To: <20140917135719.GK2840@worktop.localdomain>
Message-ID: <alpine.LSU.2.11.1409171328002.7181@eggly.anvils>
References: <20140915185102.0944158037A@closure.thunk.org> <36321733-F488-49E3-8733-C6758F83DFA1@dilger.ca> <20140916180759.GI6205@thunk.org> <alpine.LSU.2.11.1409161555120.5144@eggly.anvils> <alpine.DEB.2.11.1409162230160.12769@gentwo.org>
 <20140917135719.GK2840@worktop.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger@dilger.ca>, linux-mm <linux-mm@kvack.org>, linux-ext4@vger.kernel.org

On Wed, 17 Sep 2014, Peter Zijlstra wrote:
> On Tue, Sep 16, 2014 at 10:31:24PM -0500, Christoph Lameter wrote:
> > On Tue, 16 Sep 2014, Hugh Dickins wrote:
> > 
> > > On the page migration issue: it's not quite as straightforward as
> > > Christoph suggests.  He and I agree completely that mlocked pages
> > > should be migratable, but some real-time-minded people disagree:
> > > so normal compaction is still forbidden to migrate mlocked pages in
> > > the vanilla kernel (though we in Google patch that prohibition out).
> > > So pinning by refcount is no worse for compaction than mlocking,
> > > in the vanilla kernel.
> > 
> > Note though that compaction is not the only mechanism that uses page
> > migration.

True: offhand, I think memory hotremove, and CMA, and explicit mempolicy
changes, are all (for good reason) allowed to migrate mlocked pages; but
the case which most interests many is migration for compaction.

> 
> Agreed, and not all migration paths check for mlocked iirc. ISTR it is
> very much possible for mlocked pages to get migrated in mainline.

I think all the checks are for unevictable; and certainly we permit
races whereby an mlocked page may miss the unevictable LRU, until
subsequent reclaim corrects the omission.  But I think that's the
extent to which mlocked pages might be migrated for compaction at
present.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
