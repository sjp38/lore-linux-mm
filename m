Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29389C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB75C205F4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:17:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="m+QpA48G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB75C205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 847BF8E0003; Mon, 11 Mar 2019 13:17:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8278F8E0002; Mon, 11 Mar 2019 13:17:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734FB8E0003; Mon, 11 Mar 2019 13:17:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C55A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:17:51 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id w130so7159027yww.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:17:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=coypjIdy1AhrlMMPmLcrE133h5i+xJ7VOPTW+kFU1II=;
        b=SeTu9jOpOqI3nl9l6131hOgKmWSV3iXeTxlWqSQv5hXtSnK7zHj5PjlRXfPPkObycG
         3fQpZqL2oEToIba5It/7uiL53qjpU69D60JyQ5B+lGapHnFDKwZvdLg4bL549D0eJI36
         nY7oEj8XpK7Av3XnXbU6w7+/GCuKzMHWKRfXfO0k2S+VmLYrtx9dxRSF9wDOjioaxcM9
         l2GHIZyuQxJDdi02S/TOHbsM3XN4r8Xhg3HYmCefobXiSSRkAtls5gnPj/S+Akh962d4
         KmmzDedHBKtwUF+PLIf3mhd6bcbUIeyTFlImmixDSWD2b7TAVbV9deu/XZxWQsUybuJZ
         ml1w==
X-Gm-Message-State: APjAAAU57qYwGRBgka+7GdIL/l4x7XYGrW0c2xB9prInaUg5+hPCE5Rb
	IgeeOhMJMuKAAfz+YsqQ1YFhFzQMrM3XeD5hYLKreHT6ufaGkX8JbB4oqrM894jTFge9Ppj3WiG
	mKorNyTCbgmumkWZhq+ZADmjwIfRm49msfI1PNnumBn2mvEA89/s4fTBE9BjN9v3iA2iHNzMgvS
	uoiUWagXuFZMfaTzSUAKhcUnEJeWkmIKTTyF2KWgO3m7FE77r1fFOt+HDwhixn8vlExa+TLkMps
	0rOUs+200e6PfqSEOx/v+InXWjmImrq1I1UOyaB8Zs0g9fN33VV7JsfWpZlEmkLXbCIuP+CADtA
	E3817iR2HU+i1OJ6htvCIqr2MPkB1AnOYK7FHlzoNvSSAyj2vZRk7dlspXZ8GDOgOYCQzwLEgs7
	x
X-Received: by 2002:a25:e016:: with SMTP id x22mr27295769ybg.297.1552324671086;
        Mon, 11 Mar 2019 10:17:51 -0700 (PDT)
X-Received: by 2002:a25:e016:: with SMTP id x22mr27295720ybg.297.1552324670300;
        Mon, 11 Mar 2019 10:17:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552324670; cv=none;
        d=google.com; s=arc-20160816;
        b=CUPzBF1YqQry4AeF1S3BKLUt6HyEvjG2tMsKuYHFGWA0bA8HRT82jvSDSvPlX32D0d
         DXW+3S1FYmR+y48h5FafkzcQ07gtPpKaY32g85GEiSSMypwHMBtTFQs7epBqvg+7lsQ6
         nvnKprfzIsT2mwa5Ko+Ze1Nih86kxgJZrhNX7vbtKSbCbiLbXFNOmB1zoIn1LTgNwnUB
         G95H5mbHewFoUB025K5F4PoGbFQ+2mwpHUK2VjTvD191Xuk7SYRYrHCF87DZRm4uRmNn
         vIbplIcJ4XTOWB/XoMY+8vcGJQeWajM74s6sLqI9lHV4fUm9wB2c4orWKuN4JEfSs8mf
         9Tag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=coypjIdy1AhrlMMPmLcrE133h5i+xJ7VOPTW+kFU1II=;
        b=YLquR9BUo38jdmVKA0nqN5XqSuRupQP3NLUW5ZkmnZFSNi5OuDu+qXarcLr+G/mQWD
         6qOWO44OTDYn0+Jk21xjZ41jF4qCVp8kHWYGLsXCvU8kP1Pt63nM5OSUg94Q9Ao6si97
         bpobyeIk0IRC/th3leR8qYSOCzdZUF+YkEaHDTqtVUwvjWEBH20sH4eMEtRwUvzZeOtZ
         gWZHTHTLyP0CPI3g0VBAK8Ef23SPR40Gp+r4/rGIRebfZ+m4GaCFPtm/iQE2NlWcMX6e
         1/inr7kmBS6Wh0mFnntAo/oxYgTHHBwU+aT6YOYRZ51mRoP84O/K2GimbQszU9DXOxgD
         k2Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=m+QpA48G;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q23sor783363ywg.97.2019.03.11.10.17.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:17:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=m+QpA48G;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=coypjIdy1AhrlMMPmLcrE133h5i+xJ7VOPTW+kFU1II=;
        b=m+QpA48GMQIe1hT9fTznaJRkf3YbE8aOm/OOlEg2dVAcY/KWKLhrNJpy/aWney039N
         qDjBNNH9fkjedCBvxSKRUca9GoV1Ip6SIJ0j6lgOCN+nW0Uni6wl4ukR9ATuTEQX+7C+
         hjx1tEKy2bhfp6DSkOiegI9EFQZPn9Mc7btFHTquFFoa1U0DBfIPDA9mDDBr03Pc+/AW
         7EKklnSR2t+Y4HjbQkE0wRYsm+fLx2ywt9P7B+kmDnzqIvB92JERjJ2Z2VvYdHECNhri
         i+s4JB46px05c6oIiZI1wzjitv0h+ZVq6h5pYiycMaWG4UaWYmdmHz/b4aF3WVZYJhhi
         66QA==
X-Google-Smtp-Source: APXvYqzdSvWmEohVstdTHunGgf8/GkwwFsOaHjn4qRw+SGWZ56Y0Yk/SdJ2gfe7XAxj0V7d5Qz7SrA==
X-Received: by 2002:a81:12d6:: with SMTP id 205mr27213496yws.338.1552324669939;
        Mon, 11 Mar 2019 10:17:49 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::1:3c60])
        by smtp.gmail.com with ESMTPSA id f131sm3096720ywf.93.2019.03.11.10.17.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 10:17:49 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:17:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 2/5] mm: prepare to premature release of per-node
 lruvec_stat_cpu
Message-ID: <20190311171748.GB10823@cmpxchg.org>
References: <20190307230033.31975-1-guro@fb.com>
 <20190307230033.31975-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307230033.31975-3-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 03:00:30PM -0800, Roman Gushchin wrote:
> Similar to the memcg's vmstats_percpu, per-memcg per-node stats
> consists of percpu- and atomic counterparts, and we do expect
> that both coexist during the whole life-cycle of the memcg.
> 
> To prepare for a premature release of percpu per-node data,
> let's pretend that lruvec_stat_cpu is a rcu-protected pointer,
> which can be NULL. This patch adds corresponding checks whenever
> required.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> @@ -4430,7 +4436,8 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>  	if (!pn)
>  		return 1;
>  
> -	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
> +	rcu_assign_pointer(pn->lruvec_stat_cpu,
> +			   alloc_percpu(struct lruvec_stat));
>  	if (!pn->lruvec_stat_cpu) {

Nitpick: wouldn't this have to use rcu_dereference()? Might be cleaner
to use an intermediate variable and only assign after the NULL check.

