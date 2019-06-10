Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C130C4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:33:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 359ED2082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:33:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="xzuzhYxw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 359ED2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA8006B026B; Mon, 10 Jun 2019 16:33:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B59A86B026C; Mon, 10 Jun 2019 16:33:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46C86B026D; Mon, 10 Jun 2019 16:33:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B96E6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:33:53 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so6369854plb.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:33:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QntknNlUMZ8JI/1goGczbuHi72H8zQ1C3B8XCCIqc74=;
        b=cnwch7I//InxCCENyZQWjYudQYsU9GPGxGkaeN5nEJYE/VNhSB5lWHeIc7UM2Ofzh4
         3r9DS1oR18Azu91E01eSGNG4hZB0Ld/xiDT4jikm04yDl6lZguoBSUnCAhxCxligfJqK
         k/VCogG6OZ04J21SmrSb+c+JWEMkJ9X8vUZj51l5U+5EBvvQcJqezKibku1TJVumqiGO
         Fd/4DfRwOf/yV+YNNwyYtPI96jbe1NTTbF/7Ma8xoV0Vhi1dlEOEHcGJ0ZXjf8GNFidM
         1gpms2cl9VOs23HJ6pO4z9buDGLFgoNIVvIPgMiZVQd3pZkayFdXFq+js2aQQfuhcLHf
         3w2g==
X-Gm-Message-State: APjAAAVcPo9A9h8JUtf8kXX7okT7U9ow8EYG/PNP8d3xySTKNOIBlqE3
	JvEqgaO03wrjSobSfkwE6TV6C4rxt/CMlrUNpS5G7zyqqGWTSgLQSaFGdrCMxFjIIw9UytcvLyn
	iEfBa5MWaWjjkX4x2a/PlztPPEG0YbEs28EcpCodSHZVHxvz1vRky27eqyCUzgz7ltQ==
X-Received: by 2002:a62:1c92:: with SMTP id c140mr76249832pfc.258.1560198833053;
        Mon, 10 Jun 2019 13:33:53 -0700 (PDT)
X-Received: by 2002:a62:1c92:: with SMTP id c140mr76249767pfc.258.1560198832185;
        Mon, 10 Jun 2019 13:33:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560198832; cv=none;
        d=google.com; s=arc-20160816;
        b=WErVQpkeUQOk7rxMFPsIxm4qMSjtl6Y/xflE5wXk3xXJBzX/M95qSeh3D6huTIjHWc
         5L/hhVA2z+8gdLmGEsV/Wya55pCm1LOHaEvAD/Y0UjkymPkU8P10IYazB9wPjVqk668G
         1R4grjhKnhjPNQsBksVeHzkaY6aJeIKlEhob5vZCDx7EfVDVdQ5oSy2iqsDUvSlFmty6
         8wShRMPxEGgHuY4V18Ojbv29ImyFq3vru4cmU0VXLWAgxvEY8CecBqU62Ohyyd7QYYRN
         nJ1g+yh53lZpOiQLKCAoNPQkqi9eNaRTsn3Mv1PJ8hc5qPXs1sHRysz1rn/laE5pWL44
         QYag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QntknNlUMZ8JI/1goGczbuHi72H8zQ1C3B8XCCIqc74=;
        b=XGSERau+ATc6tztA7Jq1O+ZoIn/eda+e5B/ZW0u46e91ihkGH9rDok0Sa6PCl2iAo2
         6iAsSvjv1EbAXgFFpmRQhEezCG+na+DhkvY2vjiToDOkiHJSVAdeQd41n88ctg3geO5h
         q/a10XUnyC963zMSEpB4bP3O/ihsXeoNZ2iNEaqu62cpqoLj+Tgokb+/NH51kYEyEOfY
         Pvb2D+iwAsn1MaNHgFlsi1S8CS3fMSjUzoDPVDnAVlMf/RKpJ+FoIr3iYrK0N7YVoJOj
         Z945ocQwP8WoI3UIWgqMf4QwBqAvMfDUCJEAkSQpnwMuVTfglyKK3AhBeAWUherxR0fc
         TRqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=xzuzhYxw;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x189sor11067266pfx.37.2019.06.10.13.33.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 13:33:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=xzuzhYxw;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QntknNlUMZ8JI/1goGczbuHi72H8zQ1C3B8XCCIqc74=;
        b=xzuzhYxwoNBu8erHlLCrxSF6MyfWGF1hKTX+tKC7Hnyu/qw9Tj+eRX3C62ggnJnCN4
         tg1sy2avRP+ogUk9rkB6oxWVwW96l1plZ/wS2FgBg9ov5ZHfQD01osPiIMw9+s45gWyY
         GGXQZoJP/K2EQ4oq1dCL3nRh6zdkvZtN3sDwEjTz28wEzhHh0solkY3gANj5poClnBQT
         XSIBZ/r7EK9XzaDLWHwvHR99AFFP1HcBQWTc/qlpPiE93EVyQJHzrAVsG5nJX8onEPlp
         pOyyL1FTk0PCBlHw5ymm1gYsRTCXcT0eaXT0qFfdhfKjR67fqwACSYKwOZWVE2hRWy1F
         wgxg==
X-Google-Smtp-Source: APXvYqycry2VoGdYVSIQMIzoqz01wpBKdkO8o/o7K8OkM2VlKWAUhszB+cuq+ZnAXmc4MT74TSv4Yg==
X-Received: by 2002:a62:6145:: with SMTP id v66mr75694199pfb.144.1560198827276;
        Mon, 10 Jun 2019 13:33:47 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:8cbd])
        by smtp.gmail.com with ESMTPSA id v4sm14441747pff.45.2019.06.10.13.33.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 13:33:46 -0700 (PDT)
Date: Mon, 10 Jun 2019 16:33:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
Message-ID: <20190610203344.GA7789@cmpxchg.org>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-2-guro@fb.com>
 <20190609121052.kge3w3hv3t5u5bb3@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190609121052.kge3w3hv3t5u5bb3@esperanza>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 03:10:52PM +0300, Vladimir Davydov wrote:
> On Tue, Jun 04, 2019 at 07:44:45PM -0700, Roman Gushchin wrote:
> > Johannes noticed that reading the memcg kmem_cache pointer in
> > cache_from_memcg_idx() is performed using READ_ONCE() macro,
> > which doesn't implement a SMP barrier, which is required
> > by the logic.
> > 
> > Add a proper smp_rmb() to be paired with smp_wmb() in
> > memcg_create_kmem_cache().
> > 
> > The same applies to memcg_create_kmem_cache() itself,
> > which reads the same value without barriers and READ_ONCE().
> > 
> > Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > ---
> >  mm/slab.h        | 1 +
> >  mm/slab_common.c | 3 ++-
> >  2 files changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 739099af6cbb..1176b61bb8fc 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -260,6 +260,7 @@ cache_from_memcg_idx(struct kmem_cache *s, int idx)
> >  	 * memcg_caches issues a write barrier to match this (see
> >  	 * memcg_create_kmem_cache()).
> >  	 */
> > +	smp_rmb();
> >  	cachep = READ_ONCE(arr->entries[idx]);
> 
> Hmm, we used to have lockless_dereference() here, but it was replaced
> with READ_ONCE some time ago. The commit message claims that READ_ONCE
> has an implicit read barrier in it.

Thanks for catching this Vladimir. I wasn't aware of this change to
the memory model. Indeed, we don't need to change anything here.

