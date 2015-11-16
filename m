Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEF46B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 15:23:08 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so95806489lbb.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 12:23:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p194si15239174lfe.43.2015.11.16.12.23.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 12:23:06 -0800 (PST)
Date: Mon, 16 Nov 2015 15:22:54 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: vmpressure: fix scan window after SWAP_CLUSTER_MAX
 increase
Message-ID: <20151116202254.GA6996@cmpxchg.org>
References: <1445278381-21033-1-git-send-email-hannes@cmpxchg.org>
 <20151021193852.GA13511@cmpxchg.org>
 <alpine.LSU.2.11.1510211303240.3467@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510211303240.3467@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Dear Hugh,

[ sorry, I just noticed this email now ]

On Wed, Oct 21, 2015 at 01:05:53PM -0700, Hugh Dickins wrote:
> On Wed, 21 Oct 2015, Johannes Weiner wrote:
> > On Mon, Oct 19, 2015 at 02:13:01PM -0400, Johannes Weiner wrote:
> > > mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch changed
> > > SWAP_CLUSTER_MAX from 32 pages to 256 pages, inadvertantly switching
> > > the scan window for vmpressure detection from 2MB to 16MB. Revert.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/vmpressure.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> > > index c5afd57..74f206b 100644
> > > --- a/mm/vmpressure.c
> > > +++ b/mm/vmpressure.c
> > > @@ -38,7 +38,7 @@
> > >   * TODO: Make the window size depend on machine size, as we do for vmstat
> > >   * thresholds. Currently we set it to 512 pages (2MB for 4KB pages).
> > >   */
> > > -static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
> > > +static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX;
> > 
> > Argh, Mel's patch sets SWAP_CLUSTER_MAX to 256, so this should be
> > SWAP_CLUSTER_MAX * 2 to retain the 512 pages scan window.
> > 
> > Andrew could you please update this fix in-place? Otherwise I'll
> > resend a corrected version.
> > 
> > Thanks, and sorry about that.
> 
> I don't understand why "SWAP_CLUSTER_MAX * 2" is thought better than "512".
> Retaining a level of obscurity, that just bit us twice, is a good thing?

I'm not sure it is. But it doesn't seem entirely wrong to link it to
the reclaim scan window, either--at least be a multiple of it so that
the vmpressure reporting happens cleanly at the end of a scan cycle?

I don't mind changing it to 512, but it doesn't feel like an obvious
improvement, either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
