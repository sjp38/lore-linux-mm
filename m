Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C46EC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:19:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A8AB2199C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:19:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A8AB2199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D216D6B0006; Wed,  7 Aug 2019 03:19:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD1B36B0007; Wed,  7 Aug 2019 03:19:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC0B66B0008; Wed,  7 Aug 2019 03:19:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87AB66B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:19:44 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 65so50251040plf.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:19:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HIQ2Ldk4Y33mnAwLK5xdyXBvLuWm8iKQ9XVUaldFNXY=;
        b=FhZDo/kMYD5Q4H98Q47oQAZbGEz646Yjmb5Wd2jaujUGHUXuKB4Iy5YH9/O3Fg7CQA
         Nna4rKShioda+vdZizRKLF5YKrn81IrK0b60zi4HudvqErwxFq7yOTWmmF7ZFj7wQEYP
         Q8bzwGY6KNM3XDytaS7ymouHUhPFCHcnGfzxD8kvvurVniFGEu2tUxoCAXeSV2tHkwIw
         XmW/cNiHdU3m8DzmTHM59bvyY0gaq+PSnYT0PRX1zDdnfmrUNLlp2AItZgU3ol3ElfK2
         h7V7ftmGeYDI8nSEUi40WHMH8VUxA0oTM5pQFy4zbpNwenP4+8uJPYLMTGktDU3G9zEm
         LZWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVFSAqTLqJoWCRODhzOIiZD63+VJSYrRrdA4vMeTWxDirLTMrl1
	RIR+C5IPS1njoTUmntnPIeRIFSXnUhTwVmboKfWrZ6BWwo4aiS1av7J3AMBohbxpd+hU4rhpo2K
	HS93bSjJh9iuDYzodDAm4jt9xcJSL2DgqM7sc5r88NT/OBrZs8qjNxsev6Vozavt6PQ==
X-Received: by 2002:a62:be04:: with SMTP id l4mr7642205pff.77.1565162384189;
        Wed, 07 Aug 2019 00:19:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0yXg1YDO/jpNSGz1h8XKdrQzcEAkhEXhehwNThfhijIip570zARkgEqKyQa8Tn/V+Gk5v
X-Received: by 2002:a62:be04:: with SMTP id l4mr7642165pff.77.1565162383557;
        Wed, 07 Aug 2019 00:19:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565162383; cv=none;
        d=google.com; s=arc-20160816;
        b=T1Haz621AI+tpSopTTZhELf3EQ0Kw1q54GRvTn6amvyNIQr1hLX6LB0tSvZQTV7DeN
         bTvFbj2pnNjcqDoEaUFFfIU9jldLu3RWDuJvBqlJD+/16iAfwE+jV0XT+0+u5bi7WW1B
         M90B3+o0FSIGfdEwMGufNjDNmaEBNITDRZ0YF2/LMfxIzQJb2U8Vw1J/VDujtbrNKqZ+
         l6ARdpk7JEQMq25lLTA7EyQmttoK1EATLQB44PyxnworUinn26ebO5GUZYSl45ORd1if
         BWA5osQDmGfVo5/XeNzeUMAdPW4SeOazJ/AscMaz3DICzIIpIPmIFJ9MdQWnOdr0KmN3
         95bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HIQ2Ldk4Y33mnAwLK5xdyXBvLuWm8iKQ9XVUaldFNXY=;
        b=f1ppI4InmiDDhbucU/2FztDcgQRfIQOlMXfRWrTWS2+jX2tUr6V+jzztzjNKPlhLgY
         CLHRIEHjecN+kQN6V7ggzETMgWHQ47+T8+O15zH6oPx32A7U3b55CrZTQMcJOjJGOz8b
         cdhRJhLbODwTuTfNSAX0mHbCnClgkiN36E9jY8RdwfmJwgm3/Nm2N6iZ7qKdHOjpfZTD
         cGpWbfKkZIpoJz6WbYjEhPb+dN2fZdXERsE2ca+X8qFb0T3pxF6kh6tjNsM/RS8v/r+X
         3jfz3ZyWQERL1fO+mnKt5A+TcTOyLotaOR9gF0BZaCM0p0BFpgM4h+w846h8hoDS7MRe
         0tKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id t29si51767162pfq.272.2019.08.07.00.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:19:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of sakari.ailus@linux.intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Aug 2019 00:19:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,356,1559545200"; 
   d="scan'208";a="176880179"
Received: from paasikivi.fi.intel.com ([10.237.72.42])
  by orsmga003.jf.intel.com with ESMTP; 07 Aug 2019 00:19:32 -0700
Received: by paasikivi.fi.intel.com (Postfix, from userid 1000)
	id 9980B202CC; Wed,  7 Aug 2019 10:20:07 +0300 (EEST)
Date: Wed, 7 Aug 2019 10:20:07 +0300
From: Sakari Ailus <sakari.ailus@linux.intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: Re: [PATCH v3 11/41] media/v4l2-core/mm: convert put_page() to
 put_user_page*()
Message-ID: <20190807072007.GG21370@paasikivi.fi.intel.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
 <20190807013340.9706-12-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190807013340.9706-12-jhubbard@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 06:33:10PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Hans Verkuil <hans.verkuil@cisco.com>
> Cc: Sakari Ailus <sakari.ailus@linux.intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: linux-media@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Sakari Ailus <sakari.ailus@linux.intel.com>

-- 
Sakari Ailus
sakari.ailus@linux.intel.com

