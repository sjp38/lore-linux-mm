Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4AB76B0069
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:34:13 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so2343849wme.5
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:34:13 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id x5si959246wmx.163.2016.11.22.22.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 22:34:12 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so705472wmu.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:34:12 -0800 (PST)
Date: Wed, 23 Nov 2016 07:34:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161123063410.GB2864@dhcp22.suse.cz>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Marc MERLIN <marc@merlins.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue 22-11-16 11:38:47, Linus Torvalds wrote:
> On Tue, Nov 22, 2016 at 8:14 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> > Thanks a lot for the testing. So what do we do now about 4.8? (4.7 is
> > already EOL AFAICS).
> >
> > - send the patch [1] as 4.8-only stable.
> 
> I think that's the right thing to do. It's pretty small, and the
> argument that it changes the oom logic too much is pretty bogus, I
> think. The oom logic in 4.8 is simply broken. Let's get it fixed.
> Changing it is the point.

The point I've tried to make is that it is not should_reclaim_retry
which is broken. It's an overly optimistic reliance on the compaction
to do it's work which led to all those issues. My previous fix
31e49bfda184 ("mm, oom: protect !costly allocations some more for
!CONFIG_COMPACTION") tried to cope with that by checking the order-0
watermark which has proven to help most users. Now it didn't cover
everybody obviously. Rather than fiddling with fine tuning of these
heuristics I think it would be safer to simply admit that high order
OOM detection doesn't work in 4.8 kernel and so do not declare the OOM
killer for those requests at all. The risk of such a change is not big
because there usually are order-0 requests happening all the time so if
we are really OOM we would trigger the OOM eventually.

So I am proposing this for 4.8 stable tree instead
---
commit b2ccdcb731b666aa28f86483656c39c5e53828c7
Author: Michal Hocko <mhocko@suse.com>
Date:   Wed Nov 23 07:26:30 2016 +0100

    mm, oom: stop pre-mature high-order OOM killer invocations
    
    31e49bfda184 ("mm, oom: protect !costly allocations some more for
    !CONFIG_COMPACTION") was an attempt to reduce chances of pre-mature OOM
    killer invocation for high order requests. It seemed to work for most
    users just fine but it is far from bullet proof and obviously not
    sufficient for Marc who has reported pre-mature OOM killer invocations
    with 4.8 based kernels. 4.9 will all the compaction improvements seems
    to be behaving much better but that would be too intrusive to backport
    to 4.8 stable kernels. Instead this patch simply never declares OOM for
    !costly high order requests. We rely on order-0 requests to do that in
    case we are really out of memory. Order-0 requests are much more common
    and so a risk of a livelock without any way forward is highly unlikely.
    
    Reported-by: Marc MERLIN <marc@merlins.org>
    Signed-off-by: Michal Hocko <mhocko@suse.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c64ed3c..7401e996009a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3161,6 +3161,16 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 	if (!order || order > PAGE_ALLOC_COSTLY_ORDER)
 		return false;
 
+#ifdef CONFIG_COMPACTION
+	/*
+	 * This is a gross workaround to compensate a lack of reliable compaction
+	 * operation. We cannot simply go OOM with the current state of the compaction
+	 * code because this can lead to pre mature OOM declaration.
+	 */
+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
+		return true;
+#endif
+
 	/*
 	 * There are setups with compaction disabled which would prefer to loop
 	 * inside the allocator rather than hit the oom killer prematurely.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
