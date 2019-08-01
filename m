Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE36EC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:22:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA7B1206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 09:22:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA7B1206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51ECD8E0009; Thu,  1 Aug 2019 05:22:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CFA88E0001; Thu,  1 Aug 2019 05:22:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 397598E0009; Thu,  1 Aug 2019 05:22:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00DC68E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 05:22:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q11so39211897pll.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 02:22:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0GQZjpObIBtKLtQ7WAmj3uTVK4vP3i3j1F0MwGDWets=;
        b=WvVrVjf0FoO6vb2logHIjD899PD7I4fFuUOlDctmtDZ8sJEub3To6qmWxWny+xJoD8
         Bc0xfGfUW3z27ZXjjvwXszpWJYkdr3gOddJIJ8Ud/iWI8NGtzQcNouJawWG22JzWubmE
         j+dJwTv83Vr8X3j6faI55a95gUMowVHJzVoatGUHUdtcV89xtiVd/dl4+AFZMcisjIB+
         7jikXqplm8b1UNiUvcwNwFLkdJRSKGVLs8STRFp16ehGjtAii4RKNzmVv2E0BahXFD8/
         SIMV6Rf9rV/kzi8qooF9V63cx10xxw3mVjyGuULCSX2xr32dVYBPd1/ROXW4J/M+5ZyV
         BgLw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVyQODRsNQUyhqjDDxvewoUoBEWQKtsL2EgkOZ5LL7I7HoNUWNy
	UhXeUDIkD4N3SRcMbpf/xRN45ypseSBWesZ5vJADLEF1kUwvWCWv14XYTkXjJ4xeQBsjRKyaljo
	Zqqf3UlxCI+L3jUmFTWc4Pgy1hKbJSQujxp6EaTx6N5t0KV57w+fBR8Gb5NBE/Oc=
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr128014049plh.147.1564651364618;
        Thu, 01 Aug 2019 02:22:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4nQtUFZH94ga2Z1+1CAeliDk2EIYiP8eUfS8XnG5oxLCSjEPVWhdypG3p3WVedUbm9oER
X-Received: by 2002:a17:902:1566:: with SMTP id b35mr128013978plh.147.1564651363938;
        Thu, 01 Aug 2019 02:22:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564651363; cv=none;
        d=google.com; s=arc-20160816;
        b=IyJeoakgfNDQRFSZJAjXbCczBMcsUifjPN1qnPjvcNxuTTb1iR8uXMnkQFjGkrXC87
         Kqk8/lyFqah2yaeFkh7ieczIcYxNGOXdGxXJbRnZtC3GXbQ5THf8LkdxqufHlEPtlYVI
         hPwv9oBq+9bwTCtmsvqM3R/eH6iYAk7s9vY8OD2rMseZieM559WKm/Ekuaz7meqXCNyT
         Jm8p/ro76RczM/ytA4p+itJRij+luc4piGCXkZdRU6r8n2sd02yqyM3Ks4SAXTfbVa4n
         xKn+wEATIWX7/pwiLIuKhvMnkCOfkEBidtmcIt4q5+AxK8CZfTDyVSekW1AqEHCvCM8S
         r7jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0GQZjpObIBtKLtQ7WAmj3uTVK4vP3i3j1F0MwGDWets=;
        b=f0VoKokT+i05NHdxR5hC8hkBInuupjxAg9WEQp5NvpuVAkoBvCEj+HM56Qt0JHRYh7
         bMY9YLZVwH5pY0tXpT+GyRW+WK7E8F2nQU5fpfojpgtQObWM84Ulzp4GaYSdP31QQKX2
         vZSOhn7nEteaJ1Z5qIYvBMtNALq0ycjVdlrPfSCw4b+2w4MXyGnRrZdnBWKlKyuA2YJu
         rnOah691B/IIf6SpbjAim5OJC3ajoKiPZTvLr7/UOXRT9U+qMGwMxA70RQW6GA9NafGS
         35v9gw8rg4yaPVD8W8mWl4akZ6ciWHS5/5x/DUV7xCveWTS2+q3k+NSPaUpx1ckn1ot0
         ospw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id x18si3422863pjq.71.2019.08.01.02.22.43
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 02:22:43 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 0B0DB43DDF1;
	Thu,  1 Aug 2019 19:22:40 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht7HB-0006Bx-HP; Thu, 01 Aug 2019 19:21:33 +1000
Date: Thu, 1 Aug 2019 19:21:33 +1000
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 11/24] xfs:: account for memory freed from metadata
 buffers
Message-ID: <20190801092133.GK7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-12-david@fromorbit.com>
 <20190801081603.GA10600@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801081603.GA10600@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=D-H-fAKCpb68onX5N_cA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 01:16:03AM -0700, Christoph Hellwig wrote:
> > +
> > +		/*
> > +		 * Account for the buffer memory freed here so memory reclaim
> > +		 * sees this and not just the xfs_buf slab entry being freed.
> > +		 */
> > +		if (current->reclaim_state)
> > +			current->reclaim_state->reclaimed_pages += bp->b_page_count;
> > +
> 
> I think this wants a mm-layer helper ala:
> 
> static inline void shrinker_mark_pages_reclaimed(unsigned long nr_pages)
> {
> 	if (current->reclaim_state)
> 		current->reclaim_state->reclaimed_pages += nr_pages;
> }
> 
> plus good documentation on when to use it.

Sure, but that's something for patch 6, not this one :)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

