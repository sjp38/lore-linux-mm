Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 98A4A82F6D
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:06:10 -0400 (EDT)
Received: by pasz6 with SMTP id z6so63655747pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:06:10 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id kz10si15573758pab.59.2015.10.21.13.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:06:09 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so63767032pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:06:09 -0700 (PDT)
Date: Wed, 21 Oct 2015 13:05:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX
 increase
In-Reply-To: <20151021193852.GA13511@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1510211303240.3467@eggly.anvils>
References: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org> <20151021193852.GA13511@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 21 Oct 2015, Johannes Weiner wrote:
> On Mon, Oct 19, 2015 at 02:13:01PM -0400, Johannes Weiner wrote:
> > mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
> > SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
> > the scan window for vmpressure detection from 2MB to 16MB. Revert.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/vmpressure.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> > index c5afd57..74f206b 100644
> > --- a/mm/vmpressure.c
> > +++ b/mm/vmpressure.c
> > @@ -38,7 +38,7 @@
> >   * TODO: Make the window size depend on machine size, as we do for vmstat
> >   * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
> >   */
> > -static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
> > +static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX;
> 
> Argh, Mel's patch sets SWAP_CLUSTER_MAX to 256, so this should be
> SWAP_CLUSTER_MAX * 2 to retain the 512 pages scan window.
> 
> Andrew could you please update this fix in-place? Otherwise I'll
> resend a corrected version.
> 
> Thanks, and sorry about that.

I don't understand why "SWAP_CLUSTER_MAX * 2" is thought better than "512".
Retaining a level of obscurity, that just bit us twice, is a good thing?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
