Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEBCDC4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9A6B218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:48:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9A6B218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30D6D8E0117; Mon, 11 Feb 2019 12:48:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BC438E0115; Mon, 11 Feb 2019 12:48:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D3308E0117; Mon, 11 Feb 2019 12:48:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA6678E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:48:44 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s65so12885437qke.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:48:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=QEi1EHIIELqWBsp0hkUVkZo55YiPgkhZYiMVZ0QI0Ds=;
        b=F/iVNPJyP3ZGlswdQr5Cg5Wc3zCMGJJqIjUGeWpY5gdkA5Z+0S+CxbOKLNr15e5iKR
         jMgHjQY51ufLqbXsaiunXgXGAKr5sZyir/iqCw46T4y4KoMFIbe2zpKX/YOJsG/I/WNM
         3ZD+8FsgyXF2xC6+93cfoG9lEnioBWinLs5cBS0ufJVwzByYzRjUEjsyeqmTKvkdUF1m
         4rY9Zmc/xUGH+AHZ6jN2sA9O6NBsOU+QiUohmKb5yZW8a075V6IfEv6Kx31bRQGy5/te
         hkRKJWkUP1YlnkCB3FlJImfSqKK7CZM0GiBLsuJRmK+oMJx7U1zNw+YvsegxwHZAojMS
         719g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZgaUscGWDEqS9Vb/IS8/XxBjIIqXbChIrxSiqhsYX5Sx0P0fWm
	g/kYqJLCrXRDvIksKjIbZyj4cVritFdbn5Lv+DvOaQmVwqN3B2w2ZqTnsNhtCArYOrnmC4jlx8r
	OCBsCnVYVaa/iucqX+p4KL3fb97zhCh4cMGPDXcyFf0txACcmVZRBk8sTF803UR22VA==
X-Received: by 2002:a0c:b126:: with SMTP id q35mr27502836qvc.156.1549907324719;
        Mon, 11 Feb 2019 09:48:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdV14tB9UGfxtOZhGwGWX+17141hiVuMiLwLch3xhAH3yoZ4idOr6KCLZ+uV7yO9Mg3roA
X-Received: by 2002:a0c:b126:: with SMTP id q35mr27502805qvc.156.1549907324326;
        Mon, 11 Feb 2019 09:48:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549907324; cv=none;
        d=google.com; s=arc-20160816;
        b=0XR7/D+BMINw2a3sEDyxg8qHTXBFSbyT9GfhZZatfUBtMKg6422aGWIlx9wglV+PAo
         30OIbaGe+0/U4GwYZlM4lmJdfQ9ywr9Znufe0YBAZ1U5QpPl7SesAw4k6wSjBtBJTlWJ
         TCCy0Hv6RfC/AImXFZvuM6peobHbwaaN8jv8tSJehhgwJmVBIK5XLWT81qz61e17y+5x
         kG1CPWsvDWJeHgMpKtSBWZLLf8vgPbsk1I8XQKccn9EOOf9afx77kcIcl1OArD6MZ3f1
         llU7pAK+7swjmL2mUmnYckyiTXQUDw5k4yO3haikVWGE/1t3uevYd8aHQgxR3XS9aXSQ
         Yz0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=QEi1EHIIELqWBsp0hkUVkZo55YiPgkhZYiMVZ0QI0Ds=;
        b=CaHkmkep3536LbKjz1r9j+E1BbOjMUm+o81pYFiaxmT7UxQfoAuM5e90K/U4dCX7sV
         hX+7NWPpSYXyVN08oOoB0d3KGv8lkSdakThTUrbIj/V1VXKuXUVKafl+abmvBb0XLeLj
         ma54wjOEBVE+kFji4OJpgAn/XktxmN1PpmVWDeoRs/302CyCGh9ywPWNXJZVouTLbRqL
         HTHMxybKS1xlS8wXkCvnYtdnLz3oAyHprUP0wLKmBgmBqehYtv2/c4L5pxzH02Uz+u62
         owLpKs38qIh0gUSoc2LXBstWbn3l6j7jB3WtmcmQCF0DOuEMNJAkLKgSv68cb0bCVG3Q
         Y+RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u135si5067781qka.242.2019.02.11.09.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:48:44 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5F53640229;
	Mon, 11 Feb 2019 17:48:43 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with SMTP id 161A95D736;
	Mon, 11 Feb 2019 17:48:40 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:48:35 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 2/4] kvm: Add host side support for free memory hints
Message-ID: <20190211124203-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181546.12095.81356.stgit@localhost.localdomain>
 <20190209194108-mutt-send-email-mst@kernel.org>
 <39c915a7-e317-db01-0286-579230f37da2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39c915a7-e317-db01-0286-579230f37da2@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 11 Feb 2019 17:48:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 09:41:19AM -0800, Dave Hansen wrote:
> On 2/9/19 4:44 PM, Michael S. Tsirkin wrote:
> > So the policy should not leak into host/guest interface.
> > Instead it is better to just keep the pages pinned and
> > ignore the hint for now.
> 
> It does seems a bit silly to have guests forever hinting about freed
> memory when the host never has a hope of doing anything about it.
> 
> Is that part fixable?


Yes just not with existing IOMMU APIs.

It's in the paragraph just above that you cut out:
	Yes right now assignment is not smart enough but generally
	you can protect the unused page in the IOMMU and that's it,
	it's safe.

So e.g.
	extern int iommu_remap(struct iommu_domain *domain, unsigned long iova,
				     phys_addr_t paddr, size_t size, int prot);


I can elaborate if you like but generally we would need an API that
allows you to atomically update a mapping for a specific page without
perturbing the mapping for other pages.

-- 
MST

