Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 296036B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:47:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so47389513wme.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 07:47:19 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id f194si4526863wmd.38.2016.06.14.07.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 07:47:18 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 90ED81C1C88
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:47:17 +0100 (IST)
Date: Tue, 14 Jun 2016 15:47:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20160614144716.GC1868@techsingularity.net>
References: <02ed01d1c47a$49fbfbc0$ddf3f340$@alibaba-inc.com>
 <02f101d1c47c$b4bae0f0$1e30a2d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <02f101d1c47c$b4bae0f0$1e30a2d0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, Jun 12, 2016 at 03:33:25PM +0800, Hillf Danton wrote:
> > @@ -3207,15 +3228,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> >  			sc.may_writepage = 1;
> > 
> >  		/*
> > -		 * Now scan the zone in the dma->highmem direction, stopping
> > -		 * at the last zone which needs scanning.
> > -		 *
> > -		 * We do this because the page allocator works in the opposite
> > -		 * direction.  This prevents the page allocator from allocating
> > -		 * pages behind kswapd's direction of progress, which would
> > -		 * cause too much scanning of the lower zones.
> > +		 * Continue scanning in the highmem->dma direction stopping at
> > +		 * the last zone which needs scanning. This may reclaim lowmem
> > +		 * pages that are not necessary for zone balancing but it
> > +		 * preserves LRU ordering. It is assumed that the bulk of
> > +		 * allocation requests can use arbitrary zones with the
> > +		 * possible exception of big highmem:lowmem configurations.
> >  		 */
> > -		for (i = 0; i <= end_zone; i++) {
> > +		for (i = end_zone; i >= end_zone; i--) {
> 
> s/i >= end_zone;/i >= 0;/ ?
> 

Yes although it's eliminated by "mm, vmscan: Make kswapd reclaim in
terms of nodes"

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
