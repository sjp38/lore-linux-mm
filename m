Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 498E36B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 06:09:53 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so70986336lfb.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 03:09:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d3si17789962wjv.169.2016.08.22.03.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 03:09:52 -0700 (PDT)
Date: Mon, 22 Aug 2016 06:05:28 -0400
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160822100528.GB11890@kroah.com>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822093707.GG13596@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 22, 2016 at 11:37:07AM +0200, Michal Hocko wrote:
> [ups, fixing up Greg's email]
> 
> On Mon 22-08-16 11:32:49, Michal Hocko wrote:
> > Hi, 
> > there have been multiple reports [1][2][3][4][5] about pre-mature OOM
> > killer invocations since 4.7 which contains oom detection rework. All of
> > them were for order-2 (kernel stack) alloaction requests failing because
> > of a high fragmentation and compaction failing to make any forward
> > progress. While investigating this we have found out that the compaction
> > just gives up too early. Vlastimil has been working on compaction
> > improvement for quite some time and his series [6] is already sitting
> > in mmotm tree. This already helps a lot because it drops some heuristics
> > which are more aimed at lower latencies for high orders rather than
> > reliability. Joonsoo has then identified further problem with too many
> > blocks being marked as unmovable [7] and Vlastimil has prepared a patch
> > on top of his series [8] which is also in the mmotm tree now.
> > 
> > That being said, the regression is real and should be fixed for 4.7
> > stable users. [6][8] was reported to help and ooms are no longer
> > reproducible. I know we are quite late (rc3) in 4.8 but I would vote
> > for mergeing those patches and have them in 4.8. For 4.7 I would go
> > with a partial revert of the detection rework for high order requests
> > (see patch below). This patch is really trivial. If those compaction
> > improvements are just too large for 4.8 then we can use the same patch
> > as for 4.7 stable for now and revert it in 4.9 after compaction changes
> > are merged.
> > 
> > Thoughts?
> > 
> > [1] http://lkml.kernel.org/r/20160731051121.GB307@x4
> > [2] http://lkml.kernel.org/r/201608120901.41463.a.miskiewicz@gmail.com
> > [3] http://lkml.kernel.org/r/20160801192620.GD31957@dhcp22.suse.cz
> > [4] https://lists.opensuse.org/opensuse-kernel/2016-08/msg00021.html
> > [5] https://bugzilla.opensuse.org/show_bug.cgi?id=994066
> > [6] http://lkml.kernel.org/r/20160810091226.6709-1-vbabka@suse.cz
> > [7] http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
> > [8] http://lkml.kernel.org/r/f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz
> > 
> > ---
> > From 899b738538de41295839dca2090a774bdd17acd2 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Mon, 22 Aug 2016 10:52:06 +0200
> > Subject: [PATCH] mm, oom: prevent pre-mature OOM killer invocation for high
> >  order request
> > 
> > There have been several reports about pre-mature OOM killer invocation
> > in 4.7 kernel when order-2 allocation request (for the kernel stack)
> > invoked OOM killer even during basic workloads (light IO or even kernel
> > compile on some filesystems). In all reported cases the memory is
> > fragmented and there are no order-2+ pages available. There is usually
> > a large amount of slab memory (usually dentries/inodes) and further
> > debugging has shown that there are way too many unmovable blocks which
> > are skipped during the compaction. Multiple reporters have confirmed that
> > the current linux-next which includes [1] and [2] helped and OOMs are
> > not reproducible anymore. A simpler fix for the stable is to simply
> > ignore the compaction feedback and retry as long as there is a reclaim
> > progress for high order requests which we used to do before. We already
> > do that for CONFING_COMPACTION=n so let's reuse the same code when
> > compaction is enabled as well.
> > 
> > [1] http://lkml.kernel.org/r/20160810091226.6709-1-vbabka@suse.cz
> > [2] http://lkml.kernel.org/r/f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz
> > 
> > Fixes: 0a0337e0d1d1 ("mm, oom: rework oom detection")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 50 ++------------------------------------------------
> >  1 file changed, 2 insertions(+), 48 deletions(-)

So, if this goes into Linus's tree, can you let stable@vger.kernel.org
know about it so we can add it to the 4.7-stable tree?  Otherwise
there's not much I can do here now, right?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
