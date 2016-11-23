Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57D356B0261
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 02:00:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so2547311wms.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:00:05 -0800 (PST)
Received: from mail-wj0-f177.google.com (mail-wj0-f177.google.com. [209.85.210.177])
        by mx.google.com with ESMTPS id w206si1077862wmb.82.2016.11.22.23.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 23:00:04 -0800 (PST)
Received: by mail-wj0-f177.google.com with SMTP id v7so3430314wjy.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:00:03 -0800 (PST)
Date: Wed, 23 Nov 2016 08:00:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Message-ID: <20161123070002.GC2864@dhcp22.suse.cz>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
 <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <01a101d24556$4262a230$c727e690$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01a101d24556$4262a230$c727e690$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Marc MERLIN' <marc@merlins.org>, 'linux-mm' <linux-mm@kvack.org>, 'LKML' <linux-kernel@vger.kernel.org>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, 'Tejun Heo' <tj@kernel.org>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>

On Wed 23-11-16 14:53:12, Hillf Danton wrote:
> On Wednesday, November 23, 2016 2:34 PM Michal Hocko wrote:
> > @@ -3161,6 +3161,16 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> >  	if (!order || order > PAGE_ALLOC_COSTLY_ORDER)
> >  		return false;
> > 
> > +#ifdef CONFIG_COMPACTION
> > +	/*
> > +	 * This is a gross workaround to compensate a lack of reliable compaction
> > +	 * operation. We cannot simply go OOM with the current state of the compaction
> > +	 * code because this can lead to pre mature OOM declaration.
> > +	 */
> > +	if (order <= PAGE_ALLOC_COSTLY_ORDER)
> 
> No need to check order once more.

yes simple return true would be sufficient but I wanted the code to be
more obvious.

> Plus can we retry without CONFIG_COMPACTION enabled?

Yes checking the order-0 watermark was the original implementation of
the high order retry without compaction enabled. I do not rememeber any
reports for that so I didn't want to touch that path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
