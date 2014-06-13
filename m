Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F0C716B0087
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 01:21:44 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so2147455wgh.18
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:21:44 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id em6si261100wib.48.2014.06.12.22.21.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 22:21:43 -0700 (PDT)
Date: Fri, 13 Jun 2014 01:21:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm/vmscan.c: wrap five parameters into shrink_result
 for reducing the stack consumption
Message-ID: <20140613052138.GN2878@cmpxchg.org>
References: <1402634191-3442-1-git-send-email-slaoub@gmail.com>
 <CALYGNiMENJ014dELVS8Ej+RP=WVkt8rF0=bxs5yDXO4+hr6B_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiMENJ014dELVS8Ej+RP=WVkt8rF0=bxs5yDXO4+hr6B_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Chen Yucong <slaoub@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, mhocko@suse.cz, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jun 13, 2014 at 08:52:22AM +0400, Konstantin Khlebnikov wrote:
> On Fri, Jun 13, 2014 at 8:36 AM, Chen Yucong <slaoub@gmail.com> wrote:
> > shrink_page_list() has too many arguments that have already reached ten.
> > Some of those arguments and temporary variables introduces extra 80 bytes
> > on the stack. This patch wraps five parameters into shrink_result and removes
> > some temporary variables, thus making the relative functions to consume fewer
> > stack space.
> 
> I think it's better to put them into struct scan_control.
> Reset them before calling shrinker or take a snapshot to get delta.

scan_control applies to the whole reclaim invocation*, it would be
confusing as hell to have things in there that only apply to certain
sublevels.  Please don't do that.

If you on the other hand take snapshots and accumulate them over the
whole run, it might actually make sense to move sc->nr_scanned and
sc->nr_reclaimed into shrink_results instead.  But I'm not sure it's
worth the extra snapshotting code, given that we don't actually need
the accumulated numbers at the outer levels right now.

* sc->swappiness being the recent exception, I'll send a fix for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
