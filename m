Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3FE6B0255
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 09:47:26 -0400 (EDT)
Received: by oihq81 with SMTP id q81so69382726oih.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 06:47:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id by1si1077353pab.92.2015.07.28.06.47.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 06:47:25 -0700 (PDT)
Date: Tue, 28 Jul 2015 15:47:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 05/10] mm, page_alloc: Remove unnecessary updating of GFP
 flags during normal operation
Message-ID: <20150728134712.GB19282@twins.programming.kicks-ass.net>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-6-git-send-email-mgorman@suse.com>
 <55B78545.8000906@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55B78545.8000906@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Jul 28, 2015 at 03:36:05PM +0200, Vlastimil Babka wrote:
> >+static inline gfp_t gfp_allowed_mask(gfp_t gfp_mask)
> >+{
> >+	if (static_key_false(&gfp_restricted_key))
> 
> This is where it uses static_key_false()...

> >+struct static_key gfp_restricted_key __read_mostly = STATIC_KEY_INIT_TRUE;
> 
> ... and here it's combined with STATIC_KEY_INIT_TRUE. I've suspected that
> this is not allowed, which Peter confirmed on IRC.
> 
> It's however true that the big comment at the top of
> include/linux/jump_label.h only explicitly talks about combining
> static_key_false() and static_key_true().
> 
> I'm not sure what's the correct idiom for a default-false static key which
> however has to start as true on boot (Peter said such cases do exist)...

There currently isn't one. But see the patchset I just send to address
this:

  lkml.kernel.org/r/20150728132313.164884020@infradead.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
