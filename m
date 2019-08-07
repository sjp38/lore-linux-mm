Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E118C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:07:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADEE9229EB
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 08:07:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADEE9229EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xs4all.nl
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 425536B0003; Wed,  7 Aug 2019 04:07:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AE686B0006; Wed,  7 Aug 2019 04:07:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24EA76B0007; Wed,  7 Aug 2019 04:07:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7C1C6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 04:07:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so55581669edx.10
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 01:07:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fyvyPFY6LsAekD75jCm65WNNcXj/Gwv1GvIc/cgjq7g=;
        b=Bx90ibcJz0p9Jm3WxdkxFWc0NR/4VLMAtNH8FjlJ0bMg42P8/IhUVudMO1LTIET28K
         QIiZSTb1sUhnE2TeJ4Io0xNpeb0c9fI7Q71Xqwl3Pot4rYUCO5pRnC2byeo8a4G2a/zY
         ztkAciFK/0VbLUMQWGnxBsfYar+ODnvqTr29jZai4KQj2QBzUEuLKKBjgF0XYS3kcLEQ
         f8fuUBTyMiIyxzmGZloWas3JuNcNiHltzYwiloCNlWBQ/Xg3chUq2cw/U1fHg/GAHCle
         qpmBOcezZWbn8Icrv/CUhNRFO1o5fLXk5r+QK5nVcJDWkTgaF2UgxewZY5Esvyji5eK+
         +gUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.30 as permitted sender) smtp.mailfrom=hverkuil-cisco@xs4all.nl
X-Gm-Message-State: APjAAAWn+gyf+7YtILkg4yvki7sqtkvlt8niAcvNwlFd+8QRG/NQVZRF
	Wl+Q+w9CICD6LynV5Soc5UTTHQ8LRSyisWaO2wwQyYV2aHHscytEB3RRhicgGNKP2ayZ6swnJD2
	4xHATIXWsaPYANqCGQdHbgAHMdg8oEvzwpnka2wS3n2RiMGkb3UJJ7trAjfNQPSUlWg==
X-Received: by 2002:a50:886a:: with SMTP id c39mr8274196edc.214.1565165236382;
        Wed, 07 Aug 2019 01:07:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXd69R78AOkBNmg5nKBtbkO5ERdNH9068E03AdAzLLYpgm2qn3xNNITenzM85C4GCmV9p1
X-Received: by 2002:a50:886a:: with SMTP id c39mr8274153edc.214.1565165235738;
        Wed, 07 Aug 2019 01:07:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565165235; cv=none;
        d=google.com; s=arc-20160816;
        b=QdwvKT/XJ+4OQaNeT5BpdgcKDzornwvkTGAlGrIhC8msumnQERZLPQB0OpxvQyanvh
         EMOPMuRjxB4jZEJ29Dm4HQPO7cVJdsGbd0bE98IyFScI+L3xYiZeXKFNQdHpQ8gZG76Y
         jaYJg2HfA2hG0q/3cxt6e6QPop4xYtjD8yu9apzTnEGGXPc4Dkv35fZfRMSK0k2whUfz
         HhFBqnPItgB0eIaMrT6kQpZ8q1G3PdAOMdUIUS1r1zaG77ctNDDczfGVHIHdgyTAk7qb
         2O5ei5wIdkrf6H9nlAakwAkhiXYQZoTjpTRI7j56g4NCAGBBzvg4A2b6qREwsdkLD2Y0
         EEsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fyvyPFY6LsAekD75jCm65WNNcXj/Gwv1GvIc/cgjq7g=;
        b=fHLJqiw/ufn9NpGudfPdPCnWnlbvjSqTpVoGHAPzgNCT0dkNAEfcze3MFaVFgqVnpt
         rAmmfkckajVrNZHOTeGMPYyM8CSBxHi5gJLnhsa6N5EH6DLpk90MhBhDSu9slD2YCjN7
         yALgzkry2WXYpfVEgXP/oBa9QgjJCIIlz4US4bUNftSSFe+9eP328A0DOWKhMXalX23T
         L0Te8/LvF6mn0uYpwk6+Y99Nja/A6z+tgHb3TYwIfPeHHC5V4ZMjwa6+yZ7FC0G9sBrD
         n2Hx5JxKlEH2U384WfGPhiOmluJpWA4dWTNAG6XAbJJ3j/GlgD9zrRO9XM4aZIUddJLg
         GVNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.30 as permitted sender) smtp.mailfrom=hverkuil-cisco@xs4all.nl
Received: from lb3-smtp-cloud9.xs4all.net (lb3-smtp-cloud9.xs4all.net. [194.109.24.30])
        by mx.google.com with ESMTPS id k27si33328358edb.284.2019.08.07.01.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 01:07:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.30 as permitted sender) client-ip=194.109.24.30;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hverkuil-cisco@xs4all.nl designates 194.109.24.30 as permitted sender) smtp.mailfrom=hverkuil-cisco@xs4all.nl
Received: from [IPv6:2001:983:e9a7:1:8cc6:9015:1548:23f3] ([IPv6:2001:983:e9a7:1:8cc6:9015:1548:23f3])
	by smtp-cloud9.xs4all.net with ESMTPA
	id vGyNhjeHgAffAvGyOh7CoE; Wed, 07 Aug 2019 10:07:15 +0200
Subject: Re: [PATCH v3 11/41] media/v4l2-core/mm: convert put_page() to
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
 John Hubbard <jhubbard@nvidia.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>, Kees Cook
 <keescook@chromium.org>, Hans Verkuil <hans.verkuil@cisco.com>,
 Sakari Ailus <sakari.ailus@linux.intel.com>,
 Robin Murphy <robin.murphy@arm.com>, Souptick Joarder <jrdr.linux@gmail.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
 <20190807013340.9706-12-jhubbard@nvidia.com>
From: Hans Verkuil <hverkuil-cisco@xs4all.nl>
Message-ID: <8a02b10a-507b-2eb3-19aa-1cb498c1a4af@xs4all.nl>
Date: Wed, 7 Aug 2019 10:07:02 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190807013340.9706-12-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CMAE-Envelope: MS4wfLtFI4ThDBFuoSwFqT380PxkcC6q3XCYC9HO7bxya62SPesHUoWCzd0ksBMTGkppOn75d+WBKCLiUJL1JCKKzueS8vA20zMfsb357SuvaUy4TtJTFapt
 x/bWCTcScAJNoSAViYa6NSlEx2FKBMG1ub01wuczTnbJurUSOB+vxv+m9yWKJM94dHdvARuWMkXZdmUldHpi22HuFtGEBhfQsDY52cLv9SRNbWMy30DrEJ0t
 IZpNWziFzZ3evJ7mzLCVhbiK2kiOOXAk37J1rrkYGH2YtOIVmpGPTJw+iPQnS41ERf+BCjbaTp9dtSr4qdKvpCtCTPfnpCYMb9QEG7YIv4Bkl6jCBTx7G7/4
 E+/Gcs1gOswCkbsVZkXHiYav454A3NZryrYeXwugbZcaQXzdLwQKX8vixuVBgbqFmyjLnuKfL1+c17HvE7YGvrxNLgEJHTveu7qGFUgiDp8Kxm2qaSU6Ln+T
 ElUIz8bygLmP/ZaLM0W02XHdcvoF3n3t59CNY87n3tR3oXUf8LBXliPMUlUaTsd4sTe3FnbfHAUNwVeklfrjO7mwx/ZtuvdypniGohclf+1bp5fAUTyCCCrQ
 2HyNedUvC2lDdYTRuhJr04fafwrpC9JLhSLKJeMRBVwa4n0gqjUnzFBrEoDnP692PfkgpqcUzLJ3ou9bn9SXymgnoZ/su+Qto3UpDDWJiMsSJM83gtLeDDPU
 2LAMy4jSsugrfD7VC1dmYwzG8OWIPHuvJ7Tu8XU7oActSpAZS3c9skTdMjLehhV+5MHeC8g3tQLGrW2WL0nM2XSwHbo4mwTDcXTASOqE5niPTgs0jd+PPxdD
 6xGBJo3u/QbyQ3ajYSHTR7/iYO7MKvqve0YwbtTNR57pWM38fmVObjBWJ2Qb5+GQ3v2MdIxvVfz42j69SfAzoN+qm5pqDcKBwXhfBdG1NM3xlepenmsR9xg5
 62RVbClfekDh1mdFfuyj4KBmVBX0v1np3JjJ4vNebVx2IyoyHonzCgI/VeK3Xg6+xvyxhVW0lz7O9WmdlxWKcql5t0Yb5f0zsKtS1NvNqjdoMQPPDLlgqBkJ
 zSwzmxMfYBhUca00uKQBlssFsG5QNKIC7fFgqtDFBmNtn6ipJvZKRC79Cw4QS6qRNMXKSaUQOSPYCvM4KmrZVW9w5s8hot0TfDYbj+oHiuzjCO1jmdtzXAbt
 gWocxcFwf55hNfAhTODtYnIcQTTBxC/fmKLTijSmU3lfUSSSsnl8ef0xn1zUtoXXnyzz6mcZVljhvITEJx0jnOlTUGnl6EnAeCVrfPoD4WCRmPS4tIKMb0Sn
 DjxDBO/HszoKfvVJZYTfTvPxU+6WAyaIoLGRNQX6ew6/T19LTZ7M+CVC1zczygV1hOTQJzIdJnWdrI7AWTB8dFsFHEUTylMp921VegrittBprwtssRQSETDt
 w+WAy7sK++9/GONtwbizNl49IwU+D0GMpL0NbybeY6J7lGNNM2UtsFttBraN5pO3M9SU3xDoE5SqJiulL8VfDzJKyah60WIfPdhLbN00mLGEveLuRT0YQNVO
 Ve41rvqKpgWWp9HPZO7QwGGi4muzZFJs6F8sgGua1ktJvh99nm3LVZHEV++X5Bous3oUMbzF6ihXBdgtubshPp+ElhOLvWLff7DQNQVzst9h3eqqPREvSJlB
 0+CfDkY+tvaCm6YXmIbg/FxzMGySzi98TfrQYNsvylv4MWX8pxKCyY/xfBN6o8zPRNMJNc0PX0kAdkxIJbJSRls4hOcOInlZ
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

Acked-by: Hans Verkuil <hverkuil-cisco@xs4all.nl>

> ---
>  drivers/media/v4l2-core/videobuf-dma-sg.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
> index 66a6c6c236a7..d6eeb437ec19 100644
> --- a/drivers/media/v4l2-core/videobuf-dma-sg.c
> +++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
> @@ -349,8 +349,7 @@ int videobuf_dma_free(struct videobuf_dmabuf *dma)
>  	BUG_ON(dma->sglen);
>  
>  	if (dma->pages) {
> -		for (i = 0; i < dma->nr_pages; i++)
> -			put_page(dma->pages[i]);
> +		put_user_pages(dma->pages, dma->nr_pages);
>  		kfree(dma->pages);
>  		dma->pages = NULL;
>  	}
> 

