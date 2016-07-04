Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 012BB6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 06:33:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c82so63806549wme.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 03:33:28 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id wn5si2405590wjb.116.2016.07.04.03.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 03:33:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 007671C1B0A
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 11:33:26 +0100 (IST)
Date: Mon, 4 Jul 2016 11:33:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160704103325.GD11498@techsingularity.net>
References: <009e01d1d5d8$fcf06440$f6d12cc0$@alibaba-inc.com>
 <00a301d1d5dc$02643ca0$072cb5e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00a301d1d5dc$02643ca0$072cb5e0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jul 04, 2016 at 06:08:27PM +0800, Hillf Danton wrote:
> > @@ -2561,17 +2580,23 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  	 * highmem pages could be pinning lowmem pages storing buffer_heads
> >  	 */
> >  	orig_mask = sc->gfp_mask;
> > -	if (buffer_heads_over_limit)
> > +	if (buffer_heads_over_limit) {
> >  		sc->gfp_mask |= __GFP_HIGHMEM;
> > +		sc->reclaim_idx = classzone_idx = gfp_zone(sc->gfp_mask);
> > +	}
> > 
> We need to push/pop ->reclaim_idx as ->gfp_mask handled?
> 

I saw no harm in having one full reclaim attempt reclaiming from all
zones if buffer_heads_over_limit was triggered. If it fails, the page
allocator will loop again and reset the reclaim_idx.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
