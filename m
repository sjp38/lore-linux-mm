Return-Path: <SRS0=krm6=SB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC17EC43381
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 14:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49973218A3
	for <linux-mm@archiver.kernel.org>; Sat, 30 Mar 2019 14:10:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="t70YCJRO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49973218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B607A6B0006; Sat, 30 Mar 2019 10:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0FD46B0008; Sat, 30 Mar 2019 10:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FFFC6B000A; Sat, 30 Mar 2019 10:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 694C96B0006
	for <linux-mm@kvack.org>; Sat, 30 Mar 2019 10:10:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q7so3727632plr.7
        for <linux-mm@kvack.org>; Sat, 30 Mar 2019 07:10:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k8fOrwtV5wK7JdWjG3iRBUCyiViueX8wWfndBnk3Jq4=;
        b=OTL0Z5rH9ElmzDZbNnetq4cv8WJ2c49Z8Tv9jz4/ogIe+vfO9aatq118aAo9pUpckU
         K8zN1jhdLaCJIGpXQCMSSOgH3HPolhMB2MbHydY+iCgJVWvGQNDbRc8nkk6wLLjcDKok
         B/jDJw6sTDw+jsmKSE7oLFJpYZsotvYETl0eevYOPrLCAsQeiMeJnqqw/pPvbndrWepJ
         dTawvCS/pAMGP0n/YKxBCRu8a9bQiYFyZh8mXJJEgbB5B+JtVzJj9nWVuKlCxtkrr5+g
         FSwIY7pg7PuHVqtDsxBEtT+/aFLXe4rzdUZ0BmAUJnRAMIm20tBrwRAB0QX+TdAfyv8q
         eCSQ==
X-Gm-Message-State: APjAAAXHPBmK01JJdwCCqVsK+mE4kqjiY0EY1h5MIJM4aBr84hd++bHw
	J65m1WhyYZakWAojrtA1MqlFo5ijRHEgi3gXoIMjHr+O6upjsjAcapu2+QGo449ID53n2ciJUuy
	JSDCdWkEnS66zBpfNNeLpC78KJo3Frp+U9PVSZVW4PwOtz7GBAdB774fiGbjdkRQcuQ==
X-Received: by 2002:a17:902:1:: with SMTP id 1mr53274981pla.226.1553955054519;
        Sat, 30 Mar 2019 07:10:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz16xZtlhR/QQfgkgDsJd7dsmQmTu3AiOH72xDK07I5RhGrE1s2m2GxT6iGV0QeWbUbm9Hr
X-Received: by 2002:a17:902:1:: with SMTP id 1mr53274905pla.226.1553955053560;
        Sat, 30 Mar 2019 07:10:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553955053; cv=none;
        d=google.com; s=arc-20160816;
        b=fvqI7+WMftjnfMFCJH3rc5FTUsS5EkLq9g4u68JmsqSRvRQUTe7mX913VYYm+s26Gc
         9YPWy7bLkDabTF9vcZDBCwsJkV4JKWkU0AEimXAH1Ch7OIYX36JksunskwhTsqqfqUE0
         hAcaOOxqUhDrBVrEQn37WLfBq8d+GjAMehSMlI8OY+oqtJI+EjfuKSumgsg3hC2iFyud
         2CixSHzmMK9lj8OIEXMEzbt3HeC5Ip4ibAgANTBlw/sQK/GKOftgeNPfWl0bn9bimLRG
         IznA/dRCp/EbDNalt70h4mIRijm70cVPW3nuG9D+32HZTmqadLtz/Ddshfm2H2/1eHX/
         GhWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k8fOrwtV5wK7JdWjG3iRBUCyiViueX8wWfndBnk3Jq4=;
        b=yBDfexorW16kYIZWGgrBZnsTDg6P0Il+MmT2NZ7GLYz0Lf9JkmZCZgDeZebFzuI+r5
         YxeLJWHkvPJdWuKYdk7I5qaSkFV1mb4DG3oBNlkKLnHylZEJSttOi6dws2JdQANTN1Wf
         r5kIqY+LVgPzCD2Q5ewS7lpQSX8JxnVj1sw7AMtd/J6ysyJPfODEZaWfwoeKlWHc8wTM
         PDjlPE7vPYXUDn2m8xWiN5b28m/r0R4GI5Xnfy+IPUCaStwZuVf8zR+kqTf2R73q0ZqY
         +dWarWs3W11JyIEZYIVcKtFHWYbpqbB7kbdHrDj9x4epx6kg5I3yhySv9brUJIhOizP8
         eHrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=t70YCJRO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q3si4809021pfc.151.2019.03.30.07.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 30 Mar 2019 07:10:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=t70YCJRO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=k8fOrwtV5wK7JdWjG3iRBUCyiViueX8wWfndBnk3Jq4=; b=t70YCJROpL6uXChzulRKsjdi2
	RjsKzUzNp+zTTpU9bbsPFzQeVN19ikY4y474Q3o4HzEyP06kJ3RymWHSvtkWFDQWjUal9F4nbycnM
	N2GdAFFKJr84H5u2RH9bndJobY57786MzDG4vB5AQ7vgNaAI0mHE4XD45h+dV+FBkA1AIcbL8dbPV
	bJgAI5AI+TycokZxHdg8OGOjo3jswH4caIdVGPzVcp/qf1WfkoYBkAIRjkpHvg6a3JHCclVd4aX/8
	7Jd/QFPAX72tdAF8mAKC5AMc+AW5Jd9eCEfw25trScKoEYGMekjNoQuqFDuKNovxL3qCnJA8T8FYr
	GjBj4JLAA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hAEhA-0007RE-6Y; Sat, 30 Mar 2019 14:10:52 +0000
Date: Sat, 30 Mar 2019 07:10:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page cache: Store only head pages in i_pages
Message-ID: <20190330141052.GZ10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
 <20190323033852.GC10344@bombadil.infradead.org>
 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
 <20190324020614.GD10344@bombadil.infradead.org>
 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
 <20190324030422.GE10344@bombadil.infradead.org>
 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
 <20190329195941.GW10344@bombadil.infradead.org>
 <1553894734.26196.30.camel@lca.pw>
 <20190330030431.GX10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190330030431.GX10344@bombadil.infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 08:04:32PM -0700, Matthew Wilcox wrote:
> Excellent!  I'm not comfortable with the rule that you have to be holding
> the i_pages lock in order to call find_get_page() on a swap address_space.
> How does this look to the various smart people who know far more about the
> MM than I do?
> 
> The idea is to ensure that if this race does happen, the page will be
> handled the same way as a pagecache page.  If __delete_from_swap_cache()
> can be called while the page is still part of a VMA, then this patch
> will break page_to_pgoff().  But I don't think that can happen ... ?

Oh, blah, that can totally happen.  reuse_swap_page() calls
delete_from_swap_cache().  Need a new plan.

