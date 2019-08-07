Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3C73C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:51:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54D6C22324
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:51:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54D6C22324
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xs4all.nl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEE4B6B0008; Wed,  7 Aug 2019 04:51:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D77C26B000A; Wed,  7 Aug 2019 04:51:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1A136B000C; Wed,  7 Aug 2019 04:51:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D08B6B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 04:51:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so55713453eda.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 01:51:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2OxrDQPAfwauhFuKeV7UkqdJcLMup2CsBtU+uh7V4DQ=;
        b=OwiuH6z5RDn3cHWFKv5IAKMbh0ifUpIuyvGLsnS/r/dhw5u+DFdmFLvlSpSqdZ/Wv/
         mjvx4OLlRKU7CryOXnxOO+nYpLitFDeZfw8QCU5mYNkIEFQDQSCRqtI7DBuBKanRqfZG
         2LyjHPty80G6NRc047qByIlkepeRrLX1YkPavt2ktXs2Cklg6pCA7fww7+NKywGgSPAk
         hkIXjf2JPBkybx8rA2tUUD/Ki8pTyQpSnOt8juReMLBR0Hs8lWkx9MdJeqh0I7CwLsiz
         wizBXb3vEEjCshQhRln5ptfQyxYe/lB56Xk3sM76LLm14HTbDo9H5pmWWXIwSe9Byw/5
         6mHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.26 as permitted sender) smtp.mailfrom=hverkuil-cisco@xs4all.nl
X-Gm-Message-State: APjAAAWvwDWf4FPMvvvRk0CLWmWF+IncI2KYy+PzGNo8YqLoEVfHb8Q5
	WtPP6zfpheHBeCXRnp9IesKaa3C7wPRDUfQVRMcAL/y4I+13J/ZHrpqY0VYHdBycn3tc+cGAGT7
	up2tWGGPqbF8GyAQ+vu+UGKMuiEN5MoXNOC614DOKsGDdJ4XWCUJaFa7cW+3YMfnwnA==
X-Received: by 2002:a17:906:a942:: with SMTP id hh2mr7501150ejb.253.1565167880982;
        Wed, 07 Aug 2019 01:51:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykM2WaomQHaZZAHf6ASEnLHgpCyPVpoK/nJuFsY2aGwathGFzIOL9qdqbsmSZJFnlc3NJx
X-Received: by 2002:a17:906:a942:: with SMTP id hh2mr7501115ejb.253.1565167880200;
        Wed, 07 Aug 2019 01:51:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565167880; cv=none;
        d=google.com; s=arc-20160816;
        b=VmuwtgR9hchkN1g23uTPkbBOBAIl/fXHf5lXJblQbddx66Fn4Tawd2wJG1FJ/Yrc7x
         R4LIcGW/vWNIMFR10Vlpg5lqGdjlsvuazUeMso5QMr4/PMSBbUf96EfAuvtO78ALlLcx
         9fO42mwpGCGXyzvoX4S3DuUgYsU/qz/eJReVIXWOFo3ZPC+NFGqAyakxogUFiKm30GRw
         anNLylRav9q4l+OjJPgg6bQ9wXc8sJcEZODfwgPrEmPG1LxXL+3Fz3vek94rXRoBPE+3
         BB5UOQhVw6U9E0NMA/20O083KjLJSSfpzlKNi20gbv7b5HKJN5TSHUqx1bPomj3IB/xp
         Armg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2OxrDQPAfwauhFuKeV7UkqdJcLMup2CsBtU+uh7V4DQ=;
        b=T++3l9wxWUmb5twk5pjLk7F62drLrtJHDOLfv1jo5faOvTQmfCXJIyHdK/Vnzbhjk8
         XjZ3aBw7FzzZ+T15lWXwEhpSvKCyk1jF/Ay7r+geu5FSw094idfFLRfcjaYaFFszv2Yo
         0BnLWYsoOMa5qgBIwJmtHdjtWj8XcduBpf6UnmcDIqF2qwT6NQIxGoPnXbABm4RAQeoA
         HtycdbPPJeocvqR1SOy1rPCZ4z5+XfEwOKSN+LJrVj8P/m1rGKR3iZNFk4+NFRer9G3P
         1YeV9IKp3XmbtyUBrgIBLSlK8RNP/+RMkEqep1CZLKQLLYIcsfQYUqxbJXl4I4YOd3Ud
         XHsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.26 as permitted sender) smtp.mailfrom=hverkuil-cisco@xs4all.nl
Received: from lb2-smtp-cloud9.xs4all.net (lb2-smtp-cloud9.xs4all.net. [194.109.24.26])
        by mx.google.com with ESMTPS id sd23si28937609ejb.182.2019.08.07.01.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 01:51:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.26 as permitted sender) client-ip=194.109.24.26;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.26 as permitted sender) smtp.mailfrom=hverkuil-cisco@xs4all.nl
Received: from [IPv6:2001:983:e9a7:1:9c05:4bbc:890e:7747] ([IPv6:2001:983:e9a7:1:9c05:4bbc:890e:7747])
	by smtp-cloud9.xs4all.net with ESMTPA
	id vHfBhjvBuAffAvHfDh7OBy; Wed, 07 Aug 2019 10:51:20 +0200
Subject: Re: [PATCH v3 10/41] media/ivtv: convert put_page() to
 put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>,
 Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
 ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
 devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
 linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org,
 netdev@vger.kernel.org, rds-devel@oss.oracle.com,
 sparclinux@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org,
 John Hubbard <jhubbard@nvidia.com>, Andy Walls <awalls@md.metrocast.net>,
 Mauro Carvalho Chehab <mchehab@kernel.org>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
 <20190807013340.9706-11-jhubbard@nvidia.com>
From: Hans Verkuil <hverkuil-cisco@xs4all.nl>
Message-ID: <6fd38719-b5d3-f981-732f-da904e029546@xs4all.nl>
Date: Wed, 7 Aug 2019 10:51:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190807013340.9706-11-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfMJxwy/aLQOuQbf06fYFW7+YfWl4BADGtFuQE6wXUrTjdGOxgky6uB//ESvSCh+yVYUjsu+P3ALVGvunyB2+4QNbiR9U1sMYhv33IEL6pdyKQiMVj8T1
 W1Qkt4/A8zg1aaKiXQLOb9cAEBeGuXUGjP0ApW7QHZ9+dJcj1rZJOG9kuRWyqdkLdl0Xfd+YU4Sk6qze6hklKEmlvnGPBahaqqNlqtFrPY2VYZgE8xlevbPK
 VYzwfyBnV0qB7sk2HJHbwtjw82ezllVmshbYtU2bjc7wM9hsKDG6EcPPmsd9lrPWAB9FBL1Y3g8hvBHaWnOx4q3kfDEr6Y3kC/4CbXRQ20FpJPAzV81+yAGi
 +cKudbAsX3yt4NQHLMq6NA6K0kBILjc1co+39hFkrrZIcUvJwiKdy8NMve+H6E2GJnEUUv4nGFbjKuVZLLH5y+b+1vAe1RnVhiytR5yxpsF6hz0tRaR6dO/m
 bKPKNqsFsYXDJ5W59C6b3zicjNWHQZiEn7R8u8OkVB9sGerU7xu4rh8uGzZcq6amwD2COMghZJgTrNiun/ifaDQhmzzN53FDOAKM+vszwSUJENplETndDo8y
 lmjjtBHkM72XNJj8RdBdJI0SZn59/rf//zMIHHt6NgU9mNPP3mXofWS+FI78JEBQKLhYLHJa0ha02bP8S2wsCqhiBYGCYfLM5YjnglwHdz5MRKNNPyE0/oCr
 dZ1pq2UTafijHXzLpcISRXLWw9AZnmu/wF9aLzcClow1YFgj8I4CVeEQWdBw+L0MQjl3rEanK6AEfKDCQJnJLHrgYCJZzK8lNhtogle+zBwwTVUbelovesg0
 2Z/LL+E2WfZzXhib9FscV/8Rh9ToBgNbNMhdUU+hlXoQnZWmFz4spOz6uc44jjnJMhTqUTTg5hrVWn9mTUsqOLeTtpY8kW/K2cuWdgF0wrxh68Tha0mbWKIT
 h1eKpvM3yCzq6DBvt+4fyEiX9NjhFQCa7MNabjtWGhlXyk0ZjWF4ffIi9wV7oklEl1VYZUg79U6dELOAAE9vul6NRqDojlMJCqNaHjnuq3fjMxzEn5uV49mz
 FPD7znLfhbE8FWiYTDTLLH+F8vVBTzJTBgpIxygp14Fz2rP8/IvLLQTaYZiAs1yls952pasjas0Q53pSxIQVarur6cT2MqxBbc5Dkh7+Kfq7Y91uNNAg04iu
 d3+RJ+RCE2l1cbWqQWuXhu2j3C3rQr6dROpJhXRRXQP1J97AvtdCiS7dL9s6gULkooJ1lyTBk0aSFxIoqVYcIP0df/i5MmVLM4jFetRz5G+ThUJC0Gc1KTni
 J8I2ou/BC1bOXOJ9lSOzAqFgDoYHvEZlRb2SvXzzXkDYqMgFYolGY5VKp9uCTVWd2PQmaBlbu1lHchM+NnqdfZ7YxkxIhSoqPdSqtG27MX0XBSfBp4v/ADsP
 H7xofpTtcDVeVERyWqD+q5UMM2Wpkx8uIf59scuWLYExFj2E6FLh/6DxVIE2D4OhS9udVr+503DGAmvegA+vJlyXKbNabKFcW5bmXYY95PEPyy1wNsxvcmw6
 BPLri27Pq99nmIRm69PM0/43YEDR6U4lfeDpNuOtu7XhL7tzHXBogR/ytIhLuavtudk3kQ1Nk50AAQdwvvIdGe/4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 3:33 AM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Andy Walls <awalls@md.metrocast.net>
> Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
> Cc: linux-media@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Hans Verkuil <hverkuil-cisco@xs4all.nl>

Regards,

	Hans

> ---
>  drivers/media/pci/ivtv/ivtv-udma.c | 14 ++++----------
>  drivers/media/pci/ivtv/ivtv-yuv.c  | 11 +++--------
>  2 files changed, 7 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/media/pci/ivtv/ivtv-udma.c b/drivers/media/pci/ivtv/ivtv-udma.c
> index 5f8883031c9c..7c7f33c2412b 100644
> --- a/drivers/media/pci/ivtv/ivtv-udma.c
> +++ b/drivers/media/pci/ivtv/ivtv-udma.c
> @@ -92,7 +92,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
>  {
>  	struct ivtv_dma_page_info user_dma;
>  	struct ivtv_user_dma *dma = &itv->udma;
> -	int i, err;
> +	int err;
>  
>  	IVTV_DEBUG_DMA("ivtv_udma_setup, dst: 0x%08x\n", (unsigned int)ivtv_dest_addr);
>  
> @@ -119,8 +119,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
>  		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
>  			   err, user_dma.page_count);
>  		if (err >= 0) {
> -			for (i = 0; i < err; i++)
> -				put_page(dma->map[i]);
> +			put_user_pages(dma->map, err);
>  			return -EINVAL;
>  		}
>  		return err;
> @@ -130,9 +129,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
>  
>  	/* Fill SG List with new values */
>  	if (ivtv_udma_fill_sg_list(dma, &user_dma, 0) < 0) {
> -		for (i = 0; i < dma->page_count; i++) {
> -			put_page(dma->map[i]);
> -		}
> +		put_user_pages(dma->map, dma->page_count);
>  		dma->page_count = 0;
>  		return -ENOMEM;
>  	}
> @@ -153,7 +150,6 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
>  void ivtv_udma_unmap(struct ivtv *itv)
>  {
>  	struct ivtv_user_dma *dma = &itv->udma;
> -	int i;
>  
>  	IVTV_DEBUG_INFO("ivtv_unmap_user_dma\n");
>  
> @@ -170,9 +166,7 @@ void ivtv_udma_unmap(struct ivtv *itv)
>  	ivtv_udma_sync_for_cpu(itv);
>  
>  	/* Release User Pages */
> -	for (i = 0; i < dma->page_count; i++) {
> -		put_page(dma->map[i]);
> -	}
> +	put_user_pages(dma->map, dma->page_count);
>  	dma->page_count = 0;
>  }
>  
> diff --git a/drivers/media/pci/ivtv/ivtv-yuv.c b/drivers/media/pci/ivtv/ivtv-yuv.c
> index cd2fe2d444c0..2c61a11d391d 100644
> --- a/drivers/media/pci/ivtv/ivtv-yuv.c
> +++ b/drivers/media/pci/ivtv/ivtv-yuv.c
> @@ -30,7 +30,6 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
>  	struct yuv_playback_info *yi = &itv->yuv_info;
>  	u8 frame = yi->draw_frame;
>  	struct yuv_frame_info *f = &yi->new_frame_info[frame];
> -	int i;
>  	int y_pages, uv_pages;
>  	unsigned long y_buffer_offset, uv_buffer_offset;
>  	int y_decode_height, uv_decode_height, y_size;
> @@ -81,8 +80,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
>  				 uv_pages, uv_dma.page_count);
>  
>  			if (uv_pages >= 0) {
> -				for (i = 0; i < uv_pages; i++)
> -					put_page(dma->map[y_pages + i]);
> +				put_user_pages(&dma->map[y_pages], uv_pages);
>  				rc = -EFAULT;
>  			} else {
>  				rc = uv_pages;
> @@ -93,8 +91,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
>  				 y_pages, y_dma.page_count);
>  		}
>  		if (y_pages >= 0) {
> -			for (i = 0; i < y_pages; i++)
> -				put_page(dma->map[i]);
> +			put_user_pages(dma->map, y_pages);
>  			/*
>  			 * Inherit the -EFAULT from rc's
>  			 * initialization, but allow it to be
> @@ -112,9 +109,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
>  	/* Fill & map SG List */
>  	if (ivtv_udma_fill_sg_list (dma, &uv_dma, ivtv_udma_fill_sg_list (dma, &y_dma, 0)) < 0) {
>  		IVTV_DEBUG_WARN("could not allocate bounce buffers for highmem userspace buffers\n");
> -		for (i = 0; i < dma->page_count; i++) {
> -			put_page(dma->map[i]);
> -		}
> +		put_user_pages(dma->map, dma->page_count);
>  		dma->page_count = 0;
>  		return -ENOMEM;
>  	}
> 

