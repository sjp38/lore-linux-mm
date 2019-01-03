Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67EF6C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 334142070D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:59:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 334142070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFD598E007E; Thu,  3 Jan 2019 09:59:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED4698E0002; Thu,  3 Jan 2019 09:59:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEA6C8E007E; Thu,  3 Jan 2019 09:59:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B10068E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:59:56 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n95so42014679qte.16
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:59:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=VweWDkJOSVGMqBH2PuFLGiJb4jAbCwFK7OrOk4xEjcY=;
        b=DpwXfFkcBX2xOAIUbzJNpyrP6gAjaGReVNdcVIG6mrlDnGM9pGAuU0PbpL877ttsmN
         QjPKMgILR6TupGEdOLrBGlF8cehq8tBwIUX0fwji76WaSa+dljs9FpZKJwUqycSb71Cq
         CP2iVQwUPC5o2kH863knUKNmv+HebTfoO3E6mVA30rsEBup3i4dCMAe7I/G2j1An5mn+
         m8/gsB9ZtupKh+5PcDxTwWMb2IK4K+0ItNGW5AlZOuGxnjhFCdMBpox8ay+iXbxnLsl9
         6HJhhHsDXJ3kXT9Fi4OipGWhB2xXVVaP6h8q4YuRiMQx7G5GEajlXd9CdhnYlvFHA0es
         g0AA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcQXi1WIov3C2Qkl8vLR9vCmnon/H/cjAu5HcREKyURXu/PYlq8
	oUjL+1DVlRq3QxewZBC1+Sjb6tBiNygX+1UAs6xk0cnHDuCvD4uqsWqnd/mn/qd4ag0NzxlMohz
	Xod8feZJjeXU8rb4N9cHMhNa6ZmIPf1PT7czcubWVqhuCbBfm4KuhdXwwl5ArL3uwTw==
X-Received: by 2002:a37:a483:: with SMTP id n125mr42990073qke.184.1546527596499;
        Thu, 03 Jan 2019 06:59:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5+p5gPMmsWdcAZWX4Jyft+UVcQyEnQORrPhRvEHP2JaeeFH5bDoCkwBSq8KS6iVcZ+efoS
X-Received: by 2002:a37:a483:: with SMTP id n125mr42990036qke.184.1546527595943;
        Thu, 03 Jan 2019 06:59:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546527595; cv=none;
        d=google.com; s=arc-20160816;
        b=DS+vSSteOI4fF0Hm/fvXUc0g1ErENYr8qShod+NtfDIR9MHe+KCMw2WA1q/mOlyONw
         mbkCsKERoZLQw9oZun+FFM2udEPwXJmWnbBO8JuHseJi6OOg8PamGN+oLYmNvATCJJ41
         ewr3SoCjF4vtorSqZU54KWpXp87RBapCu1gY0oFoxztfkHUNJbxR1a8r/PweYN6W7TkU
         2qr1MCrkiUePxV6FqufhmZNjF4aGLNlGWI865PtkgZxXey4whLIXp78gbY57GqhhAFOU
         UJL72C1fxYmvawuMFGMloXxvmdqiqor0B3XFEsrpUJVtSbdhm4WtVHy5V6GqWY2AwUqc
         sifA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=VweWDkJOSVGMqBH2PuFLGiJb4jAbCwFK7OrOk4xEjcY=;
        b=aH1CmcKOTcuIOzQAEIK1tOOPhx80CNc7VBB+25y3WWfMH39NO74lkYNoLecvUlHPi9
         Gytx4S/tAMZGXQHQYC1aVBWneJNtqEUQWFiEIDo1oXYwyt/h/ORKeWVrkTyw3dkDaevI
         oEIIlHmbCqU2e0m5oTAzURnwdCeYxFOJ+kGlRC4Awa+C0QFWz32WpqUO3R+aiqZElZWa
         buN8pelSDbcjQxtlqWwWVcmNrxaPhKx01GkGuPDemQOmSy3nNSL2fd4JbJrNZz6OMDdV
         o2csfI9dw5YodM0UtyOpSNZ3iblsAv252ZR4morZ9pJP17DB32gkuoTod4w/CpvCddc6
         BqOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y22si1106748qtc.39.2019.01.03.06.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:59:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D01B14D4DD;
	Thu,  3 Jan 2019 14:59:54 +0000 (UTC)
Received: from redhat.com (ovpn-123-124.rdu2.redhat.com [10.10.123.124])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 67C435C223;
	Thu,  3 Jan 2019 14:59:53 +0000 (UTC)
Date: Thu, 3 Jan 2019 09:59:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103145950.GE3395@redhat.com>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103015654.GB15619@redhat.com>
 <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
 <20190103041833.GN6310@bombadil.infradead.org>
 <20190103142959.GA3395@redhat.com>
 <20190103143908.GQ6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103143908.GQ6310@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 03 Jan 2019 14:59:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103145951.qRKrMb1HV2wDhEniqvnFFlLl-euH73zm-H95mV11oKM@z>

On Thu, Jan 03, 2019 at 06:39:08AM -0800, Matthew Wilcox wrote:
> On Thu, Jan 03, 2019 at 09:29:59AM -0500, Jerome Glisse wrote:
> > On Wed, Jan 02, 2019 at 08:18:33PM -0800, Matthew Wilcox wrote:
> > > On Wed, Jan 02, 2019 at 07:32:08PM -0800, John Hubbard wrote:
> > > > Having the range struct declared in separate places from the mmu_notifier_range_init()
> > > > calls is not great. But I'm not sure I see a way to make it significantly cleaner, given
> > > > that __follow_pte_pmd uses the range pointer as a way to decide to issue the mmn calls.
> > > 
> > > Yeah, I don't think there's anything we can do.  But I started reviewing
> > > the comments, and they don't make sense together:
> > > 
> > >                 /*
> > >                  * Note because we provide range to follow_pte_pmd it will
> > >                  * call mmu_notifier_invalidate_range_start() on our behalf
> > >                  * before taking any lock.
> > >                  */
> > >                 if (follow_pte_pmd(vma->vm_mm, address, &range,
> > >                                    &ptep, &pmdp, &ptl))
> > >                         continue;
> > > 
> > >                 /*
> > >                  * No need to call mmu_notifier_invalidate_range() as we are
> > >                  * downgrading page table protection not changing it to point
> > >                  * to a new page.
> > >                  *
> > >                  * See Documentation/vm/mmu_notifier.rst
> > >                  */
> > > 
> > > So if we don't call mmu_notifier_invalidate_range, why are we calling
> > > mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_end?
> > > ie, why not this ...
> > 
> > Thus comments looks wrong to me ... we need to call
> > mmu_notifier_invalidate_range() those are use by
> > IOMMU. I might be to blame for those comments thought.
> 
> Yes, you're to blame for both of them.
> 
> a4d1a88525138 (Jérôme Glisse     2017-08-31 17:17:26 -0400  791)                 * Note because we provide start/end to follow_pte_pmd it will
> a4d1a88525138 (Jérôme Glisse     2017-08-31 17:17:26 -0400  792)                 * call mmu_notifier_invalidate_range_start() on our behalf
> a4d1a88525138 (Jérôme Glisse     2017-08-31 17:17:26 -0400  793)                 * before taking any lock.
> 
> 0f10851ea475e (Jérôme Glisse     2017-11-15 17:34:07 -0800  794)                 * No need to call mmu_notifier_invalidate_range() as we are
> 0f10851ea475e (Jérôme Glisse     2017-11-15 17:34:07 -0800  795)                 * downgrading page table protection not changing it to point
> 0f10851ea475e (Jérôme Glisse     2017-11-15 17:34:07 -0800  796)                 * to a new page.
> 

I remember now we do not need to call invalidate range because
invalidate_range_end() does call invalidate_range so it is fine.
Comments should be better thought. So existing code is fine.

Cheers,
Jérôme

