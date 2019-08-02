Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 746A3C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:22:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3816D2173E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:22:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3816D2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5F226B000A; Fri,  2 Aug 2019 10:22:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE88F6B000C; Fri,  2 Aug 2019 10:22:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C62646B000D; Fri,  2 Aug 2019 10:22:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7CC6B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:22:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i27so48347964pfk.12
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:22:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RMk/kiFyFZnRWtcRnl7bfSeKR/UZ4JlY5lTJe8BObXU=;
        b=lL4qE7SRL74UBRNtTdJvcvQcZB1B2ExvhGEulMgZ9pF5uzub5pHDQydwEJR5vMnl+p
         lILU+FFoXb9Yle94zCmJ5W08gLI1aXpDS4ZAtwb05cry50U57d2EOrH4j/51Bxf4P2I+
         w/u/w2XaH4nTHVegM3wHm6U/TynT09EEynLIKfc8Umy7dguwZJFq/8nWh7duZ/s+H9Qp
         W9cn3HBC5kxLB/ySr31yGgH6kRMkSFBQdW5sHp1HMS+4Ej+KhC4ic9JX+eCPGW4arlCF
         9IG3qsWArmUUDH6AAL1EH1/gBS+jpPAkJNuCmWUYxNwlj2XQEa67aXcEhBz/8iDQzD9P
         jIaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUINevCvwMz/AwshFTUICqv3o9Dza4Q09qpiS+XiLQxG4dtYGJE
	vFSZgWKWe1S7QCgJ6JvWaPyH1L+Dbi7RGfqMSJtUlZB/5VKOfaqJ6tRQew3BEO1Qwxipg5DFx69
	RiQF/uDHs7wNGRCRNtYwS3r81rSZusZe5iTv9WAQeMNLFZOhv3Vyu4aryRyYRJNL/9g==
X-Received: by 2002:a17:90a:350c:: with SMTP id q12mr4655806pjb.46.1564755754114;
        Fri, 02 Aug 2019 07:22:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvVKgDkFjwm7w6MQrtfxAIQKvpgyvS96tjG+6JERzm60vqN60xA0Wl7uVu4Ce706ZKJmlm
X-Received: by 2002:a17:90a:350c:: with SMTP id q12mr4655740pjb.46.1564755753275;
        Fri, 02 Aug 2019 07:22:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564755753; cv=none;
        d=google.com; s=arc-20160816;
        b=VKbRMgdSD/ZJtLl7NWBuVDXVs+mS6lU9cRJHp6W7nBXJ43ay/6nN9zbUMhOyfXnohk
         vKYyVHHrcd+2jeUnKgqcW4YO3rNEllDZ4Iqt3Zo+u/9aTUtRvu+HsQeX6alLULrSekPL
         M1sCRsho/veF61J9m/97k9H/cxtArx7Hwg5QduFtg3heX7qQtxV41V9MwuCh0A60rM6v
         FIUvw3Z/B2OLjds5wu0VzB4PAqUwCpx5sefXVJ6kIUMQ2h3F5v67Y37cmcHrF/tAAsKU
         h8korV+iWHAbJCK0TvSH5AqETe1PGE4TemfM/+JSFzLwulhsTaQFcA6TVpus2ybRdqRX
         gJdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RMk/kiFyFZnRWtcRnl7bfSeKR/UZ4JlY5lTJe8BObXU=;
        b=iUQvUKNtLmKhkOj62yi9sqoTm7BMnOwcGrWxxzvrzxtTCPWr/ee94SIEzwBUz3/bd3
         b0wSXAdWqIgATU7AMmMCYTlwbfuIEqs3z40NBiV/HQZaVIdiNL2TFBHe0OfRh3Dw5tqW
         14GmyXL4CIYgdR4Y4pTk540Cq9geJUnoSlSmmI8iQy73I9SxPcEalolc0y0lQSzs2nDv
         6lQQIvaf7rTDECpxTxeaL+tg4TUcFXf/8UGbH2rG8DRnu2OW+K2qSGzJk8qTtDSIUhA1
         himtvIAhdlyYkOt2X4vI1pWqRGC6A5ZA0KZByebXSogNglSqAPq/oh6jifo68FdegLsE
         EXVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y6si38330245pfl.288.2019.08.02.07.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 07:22:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Aug 2019 07:22:32 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,338,1559545200"; 
   d="scan'208";a="167245949"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 02 Aug 2019 07:22:29 -0700
Date: Fri, 2 Aug 2019 08:19:52 -0600
From: Keith Busch <keith.busch@intel.com>
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
	Dan Carpenter <dan.carpenter@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	YueHaibing <yuehaibing@huawei.com>
Subject: Re: [PATCH 26/34] mm/gup_benchmark.c: convert put_page() to
 put_user_page*()
Message-ID: <20190802141952.GA18214@localhost.localdomain>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-27-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802022005.5117-27-jhubbard@nvidia.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 07:19:57PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: YueHaibing <yuehaibing@huawei.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Looks fine.

Reviewed-by: Keith Busch <keith.busch@intel.com>

>  mm/gup_benchmark.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> index 7dd602d7f8db..515ac8eeb6ee 100644
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -79,7 +79,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
>  	for (i = 0; i < nr_pages; i++) {
>  		if (!pages[i])
>  			break;
> -		put_page(pages[i]);
> +		put_user_page(pages[i]);
>  	}
>  	end_time = ktime_get();
>  	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
> -- 

