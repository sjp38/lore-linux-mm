Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88559C43387
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 21:04:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B916218FE
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 21:04:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="RGXr9WLh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B916218FE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA5D88E000C; Thu, 20 Dec 2018 16:04:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B53208E0001; Thu, 20 Dec 2018 16:04:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1D468E000C; Thu, 20 Dec 2018 16:04:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7547D8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 16:04:49 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b185so3262813qkc.3
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:04:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=40o5Oy7hDwmt2u6+dlhmoS7n7OKNWc5BjZgibEpQDOg=;
        b=JKzuPTYTGbPrSgLFkuK5hBiv8D4sLROvCT/V3H4PChr9P/vig0MDVuKbdaIo/F+QOs
         Pz3lEoWllGDiy/tHvCbkScSzwYQ1yrxC1k3ltAsUhXxvB6RgDcWvXGpMfuJBQU+E03ef
         ZVaveA0Ss+mUQITQLi3aL8GZiHDCM1ZyqOExClpldt/4VvT7ePMZBgUbeytWC5F7uFES
         14lzNg+MhxtgKL2y1HAbK7fnvaqOVypPHOXy017gmai4HBz4Umkuf9sQ1oI+EOzBzfZK
         vB2vyyKj2Mxwst5HMLkt0hHGzG01y/VmowAFgK8ECdE5J7u20vbqwey3n1U+Z3DQ8dg1
         wICg==
X-Gm-Message-State: AA+aEWZe2GlygSLgI11QqlMRfGZ8MGgorEMF1HmaekBUHqSmY3GoSly0
	62ehBSZzjD3QnS9wZ/L6SsyhI58D1joufe4J9XQuFc+RyuHUD1GZZyzW1nsIxKg+mK0qHSKBx0V
	02j15BRSp1hcb1wl81oCGQYObpB0QbPZOKmFTOk3w/Fr0aWWywawi+1Y/a62ZG3xlKJx5v3GeFY
	uYnqHcnKxMEJPDBcafLIL+lQ7aOsd7dWmHShZlHyPMvNqtELxc2mW1tN+miNk3ak52mCMFGsZ3k
	vwML6B5fxMSbZ5dHaRJakXWHKz9oSb/3CfqUYSVvZ24ZNzzBtEb2+ITA9IiI1hq3m1oYSEQP9GK
	3EGXmyKSe4Ze/o273P+wWBBDVqUKnyxt0oKe9OC1bAaWd8geBjTshwvgBjpw1Q22DoY7um1e7Gk
	4
X-Received: by 2002:aed:31a3:: with SMTP id 32mr28357556qth.234.1545339889174;
        Thu, 20 Dec 2018 13:04:49 -0800 (PST)
X-Received: by 2002:aed:31a3:: with SMTP id 32mr28357530qth.234.1545339888690;
        Thu, 20 Dec 2018 13:04:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545339888; cv=none;
        d=google.com; s=arc-20160816;
        b=gJn5AqyGfhar6eUL5/nU6bjHBOrb+QgC3WAiMLRycq3xmK0SP+0ZuVeAxVCNtNEL5x
         M9ZIGh9QR4ly35LkVc9/BDJ3uPsTZawKeaTt2OGQHxhavvyUbt5ImbNqPa/AkPR3+MNa
         eWvvPYbFyVCEPKcUYnilTVFzNcsuB+QFnIPYWmBMuoSxX9GgvyWvdiKy8eK1kW4lQH8w
         e8pG5L6N6HsI6GrblqUb4ol6Po3ZfcoMAKidxfxu3/047jDIIacMDkBDWHrntu+qKcKv
         Rv7SYNdPWjf4XHcgRliexcQ6FbqLdWjTDIi4KgBhhx8mMz4gZOTpTwiSdrBtCT238NQv
         1HXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=40o5Oy7hDwmt2u6+dlhmoS7n7OKNWc5BjZgibEpQDOg=;
        b=IM48pYpW9eoSTVTgzFj5DZ8lXXKMyD0uGvB08DRPQJKkXdUNMZG5mao4rdzzQEGwOB
         BYFCPeLURP2DTKxSaGnXiDvZWN+qDttnjBmQ4HhGQkA6PalwxQ96Tl5CMRTmjJ6vfCJW
         Zbw11FrQYILzrZgrGuNsEUYxoiidqrIqMvFNtSK/rBavr7kQhRVSzOb+aSBIeWkvxy+K
         23ktRBdCk0xqHd4g9dzOaT6M5irVEF67jBJ0trftpPS+mYh/aiDMAzS4IzybqH2oOSNx
         HpJl6i0Yeg5VXqB2NHLc0BJ+y1srDgUJlcxqz8Ahe7gMTv29KYVj2rOBhKzQ79QmBOGB
         2ZSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=RGXr9WLh;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k34sor7986133qvf.44.2018.12.20.13.04.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 13:04:48 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=RGXr9WLh;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=40o5Oy7hDwmt2u6+dlhmoS7n7OKNWc5BjZgibEpQDOg=;
        b=RGXr9WLhK1buTTXJHJajtUgPlrUEOxrKtuQ4PrjbZMZmsvAN8c3rqfUUTgCy13uC/A
         WqfJItJU2+zXE2v2VFo1LxPRLhvY5uBDLhqFRCdeV23GQ3tW29tAfSIhY48FoUd9GlzE
         f2xGY0NBoFyKW5guhkvhjclikYP95/4ke2sov0QXpIuCWSgcn1rF4SbhlNNjAuV0YRjo
         ETlbCISSIgit7VjFS8ziKrNUe0Ep4+IzoxCj38tOtDt3o5BQb0Tl5w7Pf2AOkxAM7EXE
         9/kE2Biwtqjne10I1ST9Y9H8gtX3UTIe/LaxlNZKU0kg37eI0JIypd+fyAtn3Uht4IHv
         JysQ==
X-Google-Smtp-Source: AFSGD/XbSTAr4I1DC+05jTpum05aDzoBFdNVh04bS9bxA1o3YaoP3QrygbYxrtJc8MyOKkPxD8jymQ==
X-Received: by 2002:a0c:9531:: with SMTP id l46mr27092597qvl.175.1545339888399;
        Thu, 20 Dec 2018 13:04:48 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id x5sm4557736qtc.43.2018.12.20.13.04.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 13:04:47 -0800 (PST)
Message-ID: <1545339886.18411.31.camel@lca.pw>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
From: Qian Cai <cai@lca.pw>
To: William Kucharski <william.kucharski@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com,
 Pavel.Tatashin@microsoft.com,  mingo@kernel.org, hpa@zytor.com,
 mgorman@techsingularity.net,  iamjoonsoo.kim@lge.com, tglx@linutronix.de,
 linux-mm@kvack.org,  linux-kernel@vger.kernel.org
Date: Thu, 20 Dec 2018 16:04:46 -0500
In-Reply-To: <E084FF0A-88CD-4E61-88F2-7D542D67DDF1@oracle.com>
References: <20181220185031.43146-1-cai@lca.pw>
	 <20181220203156.43441-1-cai@lca.pw>
	 <E084FF0A-88CD-4E61-88F2-7D542D67DDF1@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220210446.DCiiL77Y8bk8K8De4gaLbswXtLOLUeqkFzDv4r7DLG8@z>

On Thu, 2018-12-20 at 14:00 -0700, William Kucharski wrote:
> > On Dec 20, 2018, at 1:31 PM, Qian Cai <cai@lca.pw> wrote:
> > 
> > diff --git a/mm/page_ext.c b/mm/page_ext.c
> > index ae44f7adbe07..d76fd51e312a 100644
> > --- a/mm/page_ext.c
> > +++ b/mm/page_ext.c
> > @@ -399,9 +399,8 @@ void __init page_ext_init(void)
> > 			 * -------------pfn-------------->
> > 			 * N0 | N1 | N2 | N0 | N1 | N2|....
> > 			 *
> > -			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
> > 			 */
> > -			if (early_pfn_to_nid(pfn) != nid)
> > +			if (pfn_to_nid(pfn) != nid)
> > 				continue;
> > 			if (init_section_page_ext(pfn, nid))
> > 				goto oom;
> > -- 
> > 2.17.2 (Apple Git-113)
> > 
> 
> Is there any danger in the fact that in the CONFIG_NUMA case in mmzone.h
> (around line 1261), pfn_to_nid() calls page_to_nid(), possibly causing the
> same issue seen in v2?
> 

No. If CONFIG_DEFERRED_STRUCT_PAGE_INIT=y, page_ext_init() is called after
page_alloc_init_late() where all the memory has already been initialized,
so page_to_nid() will work then.

