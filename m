Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31803C4CECE
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:41:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC1E720665
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:41:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="fflVkpkG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC1E720665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8275C6B02CC; Wed, 18 Sep 2019 10:41:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B4386B02CE; Wed, 18 Sep 2019 10:41:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 674C46B02CF; Wed, 18 Sep 2019 10:41:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB946B02CC
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:41:02 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9BF35181AC9B4
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:41:01 +0000 (UTC)
X-FDA: 75948303522.07.leaf19_603061cd16a0c
X-HE-Tag: leaf19_603061cd16a0c
X-Filterd-Recvd-Size: 6300
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:41:00 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id r9so191389edl.10
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 07:41:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=WbdKZkVaqIeYXFAePQEUm0K6Q0pnIntJd0Ufr5WX588=;
        b=fflVkpkGmtKJ99haJdbinaGgTE5566RU3Ym0c0y8xZgW/dkasHGT/Jm18khXW6sWj2
         JH7Lt2KLvkYOCBD02BJ7KKYBAK24/dZ90xwa9siV5DIpJKjgRDHtFezwPqi1WYOMesPT
         2c0IGzpi7BnmF+lFnm8npt+rD4ybvXsivPyksghyz07fYAWfeQyKWjrt3prFugMo+zb/
         F/Y61NpZ75Ji3+fCoK/L13w9dgTZRQgPIOEUOPjdxNmzxVvbZXsFPkucoY51nFizv044
         OK/99jaffqyHYTJmvF0gLWAJL0AMX7OTosCnFpiDtp4WfbUtvs4C/tuYjUOJBDIpycyY
         ZW9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=WbdKZkVaqIeYXFAePQEUm0K6Q0pnIntJd0Ufr5WX588=;
        b=mtvn4jfuGyPfCOBaAIkqvPMBuNcSQQlv0LlUJGlIyq7tN8+3c4K0T2cbMPnZByYlBo
         CVjIfi3y5GuUIKRuN5H4xuR3klnrWdWlKCKupn2BHf2hDXV4DTF15M7VW6aYR9X6h6hX
         1wbqYm3XltL+L2w2t/QskXkO5tky5Yw/QgCLquBShCoGOS8ORuPA/dZYYOwr/yNd/7HC
         WteQFpHDuoLTKnBmo8k6nONFMwvWdOm8KcQ0JBUoE9rkJqwz08i9GQQt8tC9yRrgzc+a
         0IX7y+QYM8I6vIxlAykPt18d1ub3IXW8Py/fUPOGlq5OZgP1wtFQYbriShAZXqyJ5Edn
         F8kQ==
X-Gm-Message-State: APjAAAUrPDRc/0Oicdyl8xzj4b5bsOal6ebIXsVfXJ5NIWKWL6SMFBJZ
	tBOn0AA5lpqr6pFVUqrPb84lwg==
X-Google-Smtp-Source: APXvYqxgmeVfhtDEtiJtgOKdVinAYjDvcBpPFWpBlvemIoPiWexeB0TF1pS1tIUsLeUKYzTg9rflAg==
X-Received: by 2002:a50:fd10:: with SMTP id i16mr8082111eds.239.1568817659723;
        Wed, 18 Sep 2019 07:40:59 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j1sm681317ejc.13.2019.09.18.07.40.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 07:40:59 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 55925101B27; Wed, 18 Sep 2019 17:41:02 +0300 (+03)
Date: Wed, 18 Sep 2019 17:41:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Thomas =?utf-8?Q?Hellstr=C3=B6m_=28VMware=29?= <thomas_os@shipmail.org>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, pv-drivers@vmware.com,
	linux-graphics-maintainer@vmware.com,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH 1/7] mm: Add write-protect and clean utilities for
 address space ranges
Message-ID: <20190918144102.jkukmhifmweagmwt@box>
References: <20190918125914.38497-1-thomas_os@shipmail.org>
 <20190918125914.38497-2-thomas_os@shipmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190918125914.38497-2-thomas_os@shipmail.org>
User-Agent: NeoMutt/20180716
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 18, 2019 at 02:59:08PM +0200, Thomas Hellstr=F6m (VMware) wro=
te:
> From: Thomas Hellstrom <thellstrom@vmware.com>
>=20
> Add two utilities to a) write-protect and b) clean all ptes pointing in=
to
> a range of an address space.
> The utilities are intended to aid in tracking dirty pages (either
> driver-allocated system memory or pci device memory).
> The write-protect utility should be used in conjunction with
> page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
> accesses. Typically one would want to use this on sparse accesses into
> large memory regions. The clean utility should be used to utilize
> hardware dirtying functionality and avoid the overhead of page-faults,
> typically on large accesses into small memory regions.
>=20
> The added file "as_dirty_helpers.c" is initially listed as maintained b=
y
> VMware under our DRM driver. If somebody would like it elsewhere,
> that's of course no problem.

After quick glance, it looks a lot as rmap code duplication. Why not
extend rmap_walk() interface instead to cover range of pages?

>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
>=20
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
> ---
>  MAINTAINERS           |   1 +
>  include/linux/mm.h    |  13 +-
>  mm/Kconfig            |   3 +
>  mm/Makefile           |   1 +
>  mm/as_dirty_helpers.c | 392 ++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 409 insertions(+), 1 deletion(-)
>  create mode 100644 mm/as_dirty_helpers.c
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c2d975da561f..b596c7cf4a85 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5287,6 +5287,7 @@ T:	git git://people.freedesktop.org/~thomash/linu=
x
>  S:	Supported
>  F:	drivers/gpu/drm/vmwgfx/
>  F:	include/uapi/drm/vmwgfx_drm.h
> +F:	mm/as_dirty_helpers.c

Emm.. No. Core MM functinality cannot belong to random driver.

--=20
 Kirill A. Shutemov

