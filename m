Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE5BC6B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 03:47:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p80so33160694lfp.6
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 00:47:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv8si13834231wjc.92.2016.10.10.00.47.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Oct 2016 00:47:15 -0700 (PDT)
Date: Mon, 10 Oct 2016 09:47:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
Message-ID: <20161010074712.GB24081@quack2.suse.cz>
References: <20160911225425.10388-1-lstoakes@gmail.com>
 <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com>
 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <20161007100720.GA14859@lucifer>
 <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com>
 <20161007162240.GA14350@lucifer>
 <alpine.LSU.2.11.1610071101410.7822@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1610071101410.7822@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri 07-10-16 11:16:26, Hugh Dickins wrote:
> On Fri, 7 Oct 2016, Lorenzo Stoakes wrote:
> > On Fri, Oct 07, 2016 at 08:34:15AM -0700, Linus Torvalds wrote:
> > > Would you be willing to look at doing that kind of purely syntactic,
> > > non-semantic cleanup first?
> > 
> > Sure, more than happy to do that! I'll work on a patch for this.
> > 
> > > I think that if we end up having the FOLL_FORCE semantics, we're
> > > actually better off having an explicit FOLL_FORCE flag, and *not* do
> > > some kind of implicit "under these magical circumstances we'll force
> > > it anyway". The implicit thing is what we used to do long long ago, we
> > > definitely don't want to.
> > 
> > That's a good point, it would definitely be considerably more 'magical', and
> > expanding the conditions to include uprobes etc. would only add to that.
> > 
> > I wondered about an alternative parameter/flag but it felt like it was
> > more-or-less FOLL_FORCE in a different form, at which point it may as well
> > remain FOLL_FORCE :)
> 
> Adding Jan Kara (and Dave Hansen) to the Cc list: I think they were
> pursuing get_user_pages() cleanups last year (which would remove the
> force option from most callers anyway), and I've lost track of where
> that all got to.  Lorenzo, please don't expend a lot of effort before
> checking with Jan.

Yeah, so my cleanups where mostly concerned about mmap_sem locking and
reducing number of places which cared about those. Regarding flags for
get_user_pages() / get_vaddr_frames(), I agree that using flags argument
as Linus suggests will make it easier to see what the callers actually
want. So I'm for that.

Regarding the FOLL_FORCE I've had a discussion about its use in Infiniband
drivers in 2013 with Roland Dreier. He referenced me to discussion
https://lkml.org/lkml/2012/1/26/7 and summarized that they use FOLL_FORCE
to trigger possible COW early. That avoids the situation when the process
triggers COW of the pages later after DMA buffers are set up which results
in the DMA result to not be visible where the process expects it... I'll
defer to others whether that is a sane or intended use of FOLL_FORCE flag
but I suppose that is the reason why most drivers use it when setting up
DMA buffers in memory passed from userspace.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
