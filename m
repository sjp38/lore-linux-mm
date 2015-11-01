Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB6182F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 17:19:22 -0500 (EST)
Received: by qkcn129 with SMTP id n129so51939563qkc.1
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 14:19:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h35si15649407qgh.126.2015.11.01.14.19.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 14:19:21 -0800 (PST)
Date: Sun, 1 Nov 2015 23:19:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] ksm: add cond_resched() to the rmap_walks
Message-ID: <20151101221918.GR5390@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
 <1444925065-4841-3-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1510251634410.1923@eggly.anvils>
 <20151027003202.GG27292@linux-uzut.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027003202.GG27292@linux-uzut.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 26, 2015 at 05:32:02PM -0700, Davidlohr Bueso wrote:
> On Sun, 25 Oct 2015, Hugh Dickins wrote:
> 
> >On Thu, 15 Oct 2015, Andrea Arcangeli wrote:
> >
> >> While at it add it to the file and anon walks too.
> >>
> >> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> >
> >Subject really should be "mm: add cond_resched() to the rmap walks",
> >then body "Add cond_resched() to the ksm and anon and file rmap walks."
> >
> >Acked-by: Hugh Dickins <hughd@google.com>
> >but I think we need a blessing from Davidlohr too, if not more.
> 
> Perhaps I'm lost in the context, but by the changelog alone I cannot
> see the reasoning for the patch. Are latencies really that high? Maybe,
> at least the changelog needs some love.

Yes they can be that high. The rmap walk must reach every possible
mapping of the page, so if a page is heavily shared (no matter if it's
KSM, anon, pagecache) there will be tons of entries to walk
through. All optimizations with prio_tree, anon_vma chains, interval
tree, helps to find the right virtual mapping faster, but if there are
lots of virtual mappings, all mapping must still be walked through.

The biggest cost is for the IPIs and the IPIs can be optimized in a
variety of ways, but at least for KSM if each virtual mapping ends up
in a different mm and each mm runs in a different CPU and if there are
tons of CPUs, it's actually impossible to reduce the number of IPIs
during KSM page migration.

Regardless of the IPIs, it's generally safer to keep these
cond_resched() in all cases, as even if we massively reduce the number
of IPIs, the number of entries to walk IPI-less may still be large and
no entry can be possibly skipped in the page migration case. Plus we
leverage having made those locks sleepable.

Dropping 1/6 triggers a reject in a later patch, so I'll have to
resubmit. So while at it, I'll add more commentary to the commit.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
