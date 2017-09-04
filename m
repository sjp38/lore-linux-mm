Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5C26B049B
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 04:47:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u26so8791968wma.3
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 01:47:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f15si4544769wmg.82.2017.09.04.01.47.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Sep 2017 01:47:17 -0700 (PDT)
Date: Mon, 4 Sep 2017 10:47:15 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: apply gfp_allowed_mask before the first
 allocation attempt.
Message-ID: <20170904084715.aeyckbfciif7g2z2@dhcp22.suse.cz>
References: <1504275091-4427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170901142845.nqcn2na4vy6giyhm@dhcp22.suse.cz>
 <201709020016.ADJ21342.OFLJHOOSMFVtFQ@I-love.SAKURA.ne.jp>
 <c03a89e8-e422-9fde-bb49-dac71a8fd7c6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c03a89e8-e422-9fde-bb49-dac71a8fd7c6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, brouer@redhat.com, mgorman@techsingularity.net

On Mon 04-09-17 10:22:59, Vlastimil Babka wrote:
> On 09/01/2017 05:16 PM, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> >> On Fri 01-09-17 23:11:31, Tetsuo Handa wrote:
> >>> We are by error initializing alloc_flags before gfp_allowed_mask is
> >>> applied. Apply gfp_allowed_mask before initializing alloc_flags so that
> >>> the first allocation attempt uses correct flags.
> >>
> >> It would be worth noting that this will not matter in most cases,
> >> actually when only the node reclaim is enabled we can misbehave because
> >> NOFS request for PM paths would be ignored.
> 
> Hmm don't we have the same problem with the god-damned node reclaim by
> applying current_gfp_context() also only after the first attempt? But
> that would be present since 21caf2fc1931b.
> Hm, actually no, because reclaim calls current_gfp_context() by itself.
> Good.

Yes.

> Maybe reclaim should also do the gfp_allowed_mask filtering?

I would rather not spread it more than it is really needed.

> I wonder how safe the pm_restrict_gfp_mask() update is when an
> allocation is already looping in __alloc_pages_slowpath()...

It will be broken

> What exactly are your ideas to get rid of gfp_allowed_mask, Michal?

Well I planned to actually examine why do we need it in the first place
and whether the original intention still applies and if yes then replace
it by memalloc_noio_save. It would still be proken in a similar way you
pointed out but something tells me that it is just obsolete.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
