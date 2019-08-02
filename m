Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD414C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 18:34:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F2FA2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 18:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fGJG11C2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F2FA2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A20056B0003; Fri,  2 Aug 2019 14:34:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CF7C6B0005; Fri,  2 Aug 2019 14:34:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E57F6B0007; Fri,  2 Aug 2019 14:34:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4966B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 14:34:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e25so48815536pfn.5
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 11:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2kEy2KClG3alDj03YfM34b+mCKk6wTiisUQufFSVdlI=;
        b=nrRhpm65EGR3Ukh5+2KbCvGZmgNVRPPTask9obSNc54QGhkOQLukaQwXu70t7y61s5
         KCMD5alMyhnyF8lCGi9ssrvSi4yDijNYtv75iiVfJ95yWyabqvTpCqC5KgFzcGQJOX0M
         1tkaw+8uZSC79AAITSHoZDYJAQ7oQyr53iaMEPyHa79rVaF9hKY8cVz4u62lWHmBEiHs
         MF4FL8BdL1czp+CIcj1uot41sSsSx0P1FwlkosV2n0XWy9PP5MQSvIz7IIDZaDbChGei
         yE04r5i4lqwdo9CjCGhYo/3kuUws7p+D2pE4BcEOoa3mYW+0cnW2vv/MBMIySZVqTdz+
         fcWw==
X-Gm-Message-State: APjAAAWr7RrIR7lxu1CfRVjInFEyy9O7d2SbNDJnQtUQ9X4p9vwOGs6a
	/US7/MISe7hfGpyiQJLEuzEcryobkvZXsVG7OUYlWeUhSbkhAr2g7I/ckFFi2CDJDAdzFr47oBm
	nrMGbkFskkQxCohJ88o0XVmdpqpgJrD6H4oUwX+wE5CdDR+jjZlTVeJE+I/nmqvxISQ==
X-Received: by 2002:a17:902:e202:: with SMTP id ce2mr127542751plb.272.1564770863862;
        Fri, 02 Aug 2019 11:34:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhEMFy4cZ4LPBjxmeXKfzWWLzpz66Z0z11ydaC6oPiNKV/LaRyI8aO9wGiXg4p30k7eZFd
X-Received: by 2002:a17:902:e202:: with SMTP id ce2mr127542703plb.272.1564770863029;
        Fri, 02 Aug 2019 11:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564770863; cv=none;
        d=google.com; s=arc-20160816;
        b=BfQbYMy1OhTVk1W9oIV9pWNiHd1I4EcL/Q5AJqarBahXmP1tAlOyXW7jUABZVYjOp2
         nsqnvgLUhb2ia8TowwgsFs/wKK67DZ008HXQF2D8V4VlztTf6GOHDi8++vVLVteg0OL/
         B2NZ/66QxKmTYuT/y56Rvgm5/ths7XPnbaGk8zmKhceqCcMCLhRNG/a4QceOP6XhXVxz
         ca01diCeob/wwlhO15DivX8/1pHxN8DYlz1v5TaLWFm9E0XxL9Y0ZihHETX1gCtRrxRU
         FF/dtRdyFqa/gvWnBP2zIX5RZGDnMeXwTShJKfrxfq1Lhr/Am+N3ZHRX4OUzfoNAbOn3
         Gk5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2kEy2KClG3alDj03YfM34b+mCKk6wTiisUQufFSVdlI=;
        b=MBiiFKCMhn/dj7cKBP4/NOLPsihlqJhvxBdsWh52bJO29oei3zW+sJ7ENUE7sMDNy5
         TJB1Z9X3/kugqdedXNcoepQ+ouJnzZKbS5wUhY3H0D7dpxfe+MiDX/o1tX/njELPXsVu
         aS2S2dOPtsK9AI8J6DK22j+jjWXvJqKiji+zoa09YuCzzRcaT5GMkZDZjwEbfPwrgy57
         0R8PPYS8/8wzpxauDRECaRCWfr2OEYwJ3k+ljAKI3uhyjEQInTLJ9tLcvOO98ZaGo9jQ
         VsRnrQUmheyKfajNondcBWqRZ01jX4YKWNBf1zx5kQbJpT0Kwm3juAqY/OazCAyAtQQg
         wyPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fGJG11C2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r3si34590571plb.14.2019.08.02.11.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 11:34:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fGJG11C2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=2kEy2KClG3alDj03YfM34b+mCKk6wTiisUQufFSVdlI=; b=fGJG11C2pbKbbrqF3XBVAwW6q
	KxNlRGiE/D5EhURS1DioBlHhyjyk1M8FPn06HpEbQdOWUPT4Gs+mlHU0Af2k16yZRuf/cMIPY3n0r
	XK41cehqZldoz+EzicIdSIEaXJr//184sJwD7ES4euh7HNw15jUF+7w3gtjI253p7Y7QWYu858Vq3
	0dOzlAycnebIJB/vzWbG0pcCoMkKcNdbTEhMkE6iydjxtmLRsaRg4qDyYqwm3U0lBzR9rlFGUAH10
	YjzaL2L0nLNA/txU2Io+Jd1Wosp7Wa83n0s9XAak00CoTHlzAuj6+p99MMPhWN4Mh18utGNQ/A0We
	tqylaKRLw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htcNg-0006S8-2m; Fri, 02 Aug 2019 18:34:20 +0000
Date: Fri, 2 Aug 2019 11:34:19 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Chris Mason <clm@fb.com>
Cc: Dave Chinner <david@fromorbit.com>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 09/24] xfs: don't allow log IO to be throttled
Message-ID: <20190802183419.GC5597@bombadil.infradead.org>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-10-david@fromorbit.com>
 <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
 <20190801235849.GO7777@dread.disaster.area>
 <7093F5C3-53D2-4C49-9C0D-64B20C565D18@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7093F5C3-53D2-4C49-9C0D-64B20C565D18@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 02:11:53PM +0000, Chris Mason wrote:
> Yes and no.  At some point important FS threads have the potential to 
> wait on every single REQ_META IO on the box, so every single REQ_META IO 
> has the potential to create priority inversions.

[...]

> Tejun reminded me that in a lot of ways, swap is user IO and it's 
> actually fine to have it prioritized at the same level as user IO.  We 
> don't want to let a low prio app thrash the drive swapping things in and 
> out all the time, and it's actually fine to make them wait as long as 
> other higher priority processes aren't waiting for the memory.  This 
> depends on the cgroup config, so wrt your current patches it probably 
> sounds crazy, but we have a lot of data around this from the fleet.

swap is only user IO if we're doing the swapping in response to an
allocation done on behalf of a user thread.  If one of the above-mentioned
important FS threads does a memory allocation which causes swapping,
that priority needs to be inherited by the IO.

