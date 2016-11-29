Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 989316B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 02:25:10 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so42204855wme.4
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 23:25:10 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id s9si1318659wmf.36.2016.11.28.23.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 23:25:09 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a20so22792357wme.2
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 23:25:09 -0800 (PST)
Date: Tue, 29 Nov 2016 08:25:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort
 allocations in blkcg
Message-ID: <20161129072507.GA31671@dhcp22.suse.cz>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161121230332.GA3767@htj.duckdns.org>
 <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz>
 <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz>
 <20161128171907.GA14754@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128171907.GA14754@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Mon 28-11-16 12:19:07, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 23, 2016 at 09:50:12AM +0100, Vlastimil Babka wrote:
> > > You'd certainly _hope_ that atomic allocations either have fallbacks
> > > or are harmless if they fail, but I'd still rather see that
> > > __GFP_NOWARN just to make that very much explicit.
> > 
> > A global change to GFP_NOWAIT would of course mean that we should audit its
> > users (there don't seem to be many), whether they are using it consciously
> > and should not rather be using GFP_ATOMIC.
> 
> A while ago, I thought about something like, say, GFP_MAYBE which is
> combination of NOWAIT and NOWARN but couldn't really come up with
> scenarios where one would want to use NOWAIT w/o NOWARN.  If an
> allocation is important enough to warn the user of its failure, it
> better be dipping into the atomic reserve pool; otherwise, it doesn't
> make sense to make noise.

I do not think we really need a new flag for that and fully agree that
GFP_NOWAIT warning about failure is rarely, if ever, useful.
Historically we didn't use to distinguish atomic (with access to
reserves) allocations from those which just do not want to trigger the
reclaim resp. to sleep (aka optimistic allocation requests). But this
has changed so I guess we can really do the following 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f8041f9de31e..a53b5187b4da 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -246,7 +246,7 @@ struct vm_area_struct;
 #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
 #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
 #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
-#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
+#define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM|__GFP_NOWARN)
 #define GFP_NOIO	(__GFP_RECLAIM)
 #define GFP_NOFS	(__GFP_RECLAIM | __GFP_IO)
 #define GFP_TEMPORARY	(__GFP_RECLAIM | __GFP_IO | __GFP_FS | \

this will not catch users who are doing gfp & ~__GFP_DIRECT_RECLAIM but
I would rather not make warn_alloc() even more cluttered with checks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
