Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 19193440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:03:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n9so1526136wra.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:03:24 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id p123si3461054wmp.21.2017.08.24.09.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:03:18 -0700 (PDT)
Date: Wed, 23 Aug 2017 19:57:09 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170823175709.GA22743@xo-6d-61-c0.localdomain>
References: <20170728091904.14627-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170728091904.14627-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hi!

> From: Michal Hocko <mhocko@suse.com>
> 
> GFP_TEMPORARY has been introduced by e12ba74d8ff3 ("Group short-lived
> and reclaimable kernel allocations") along with __GFP_RECLAIMABLE. It's
> primary motivation was to allow users to tell that an allocation is
> short lived and so the allocator can try to place such allocations close
> together and prevent long term fragmentation. As much as this sounds
> like a reasonable semantic it becomes much less clear when to use the
> highlevel GFP_TEMPORARY allocation flag. How long is temporary? Can
> the context holding that memory sleep? Can it take locks? It seems
> there is no good answer for those questions.
> 
> The current implementation of GFP_TEMPORARY is basically
> GFP_KERNEL | __GFP_RECLAIMABLE which in itself is tricky because
> basically none of the existing caller provide a way to reclaim the
> allocated memory. So this is rather misleading and hard to evaluate for
> any benefits.
> 
> I have checked some random users and none of them has added the flag
> with a specific justification. I suspect most of them just copied from
> other existing users and others just thought it might be a good idea
> to use without any measuring. This suggests that GFP_TEMPORARY just
> motivates for cargo cult usage without any reasoning.
> 
> I believe that our gfp flags are quite complex already and especially
> those with highlevel semantic should be clearly defined to prevent from
> confusion and abuse. Therefore I propose dropping GFP_TEMPORARY and
> replace all existing users to simply use GFP_KERNEL. Please note that
> SLAB users with shrinkers will still get __GFP_RECLAIMABLE heuristic
> and so they will be placed properly for memory fragmentation prevention.
> 
> I can see reasons we might want some gfp flag to reflect shorterm
> allocations but I propose starting from a clear semantic definition and
> only then add users with proper justification.

Dunno. < 1msec probably is temporary, 1 hour probably is not. If it causes
problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide replace,
and then starting again goes not look attractive to me.

									Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
