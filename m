Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 274C6C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:47:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCEB2218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:47:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="c/KEhwiF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCEB2218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=samsung.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 643FC8E0002; Thu, 31 Jan 2019 05:47:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F0108E0001; Thu, 31 Jan 2019 05:47:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46B2B8E0002; Thu, 31 Jan 2019 05:47:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F21148E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:47:08 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so2048828pll.23
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:47:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:cms-type:references;
        bh=psNr6P5d3KZD1xM7vBw/HsPsimHzAvavXSKrUjxnAEs=;
        b=qPT6YAhfgVx1L06xgtM9Q1I06REeYb4JnVpwyLDs7h+yI/ehQLknweFSDsyd0etaGM
         sRMjo8riNIa9S0UrBJOhn+mW1/I35M8Eo07uMhLJmOrSKOvdvJH76dr9JALskhdQb0b3
         CEbv/xEzLZKHTe/4dAKUHAXTDLkg5aAb4urVA4kB0WSlSXAYPcRkJC2Ii9xU+jGMRzun
         BlZX5Oqra/6dFD8j9S/wHKiyBuMBwwWYAkQqa/+zicemoRPiaGt4gv+wifTjd7pDd2kJ
         i2vYwQLNfeitslLVkcRKfcg1OiGa8UZ1+U72LokcH7fECaZGosMID8xQOjzlrdW+zCp/
         Z/IQ==
X-Gm-Message-State: AJcUukeWPv8xm6Vdg5LvckpBuexBeKbQuUshxcR/V3/V6NcTSquu8if5
	jKCoKFy9Iq3BnzedGHJBPIb626R8X0oQux1mqfRU0bxycOjcychuT/O3Mj7dekkhmSqjqA5XFCK
	uOTYRbEJ5Psgni2oc4FBeJ4N74NQGV5Igx2IwstoFsuDkPL7a26qkdYaMQlKbiM/3vg==
X-Received: by 2002:a62:34c6:: with SMTP id b189mr35133360pfa.229.1548931628652;
        Thu, 31 Jan 2019 02:47:08 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6bTSISzQ31qDLncVyqs8hk5vP3shOb6ugmUddOZi9TBXo7nmTEgf4eRzgmb8d/DgY8zbLC
X-Received: by 2002:a62:34c6:: with SMTP id b189mr35133315pfa.229.1548931627827;
        Thu, 31 Jan 2019 02:47:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548931627; cv=none;
        d=google.com; s=arc-20160816;
        b=oOLg67cz+cX9NA+GqrlcMrj9Bam8EcPLZ0lM0wUYuIGfOkS53ZhQ1G6FeY7/+mMxG2
         vJQ8NY+aQWkzMWH/qL/g8P6q3zKR3nnRyBAxlC1lbWJFJdR1GlsIgAJb6nUps3GBW3NL
         JtUiAN6crM4ijvKHvcu5HHAFtnnI2/BrrNHvVGQ7jQGV+6+rpnPWtvqCbTGdvXfOnIjM
         tDYhnLKDW77bQJIlAYPTmlu+opDZBM28YK61t+1QHhdG7kjLW0InQcC9uyaPkFJveO0q
         vRGUTsLl09NJ1xXBfDIsX7jjoAbu3NgFmB8gMnpNsaZp0yR2uV3mXs3UQyWDEdYq9rTm
         OZxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:cms-type:content-language:content-transfer-encoding
         :in-reply-to:mime-version:user-agent:date:message-id:from:cc:to
         :subject:dkim-signature:dkim-filter;
        bh=psNr6P5d3KZD1xM7vBw/HsPsimHzAvavXSKrUjxnAEs=;
        b=AdLYHYO5aCYpa4t9IFKKAxi7q4vWhZmPvUhrI9NF4/jH/GyLgCIY9Mp34MreT1MwwG
         OJvjLPqLFg9hDD3qAQHcCd709DoJgeh3HNRYI8WLfeCT0x78FfOWhsUbYCh4Ub7OLEJV
         qMbASW2pJ0TPJWDn4NELPRPwGfoQg5rSy3k8WjGeajh2obwYjNfFJ8JfZ2qk5WBjl4GT
         z/9Tor9cnSaX6incZ62QX7Wzji3xa74th9WsVQMSg88mHSsyx/jNw2XLCjXlNMyl7zXE
         PwUireAhpWNuW/UXeRot7GsgtwdZ9Rn0ZGdSd5i/ecMictwadC7COuO2mJWhLI4P3T8Y
         RSxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b="c/KEhwiF";
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id v11si4144755plp.85.2019.01.31.02.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:47:07 -0800 (PST)
Received-SPF: pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) client-ip=210.118.77.12;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b="c/KEhwiF";
       spf=pass (google.com: domain of m.szyprowski@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=m.szyprowski@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20190131104703euoutp02393b677ae913e161c04a1bc48698dc5c~_6Rr9q7WA1392913929euoutp02k
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:47:03 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.w1.samsung.com 20190131104703euoutp02393b677ae913e161c04a1bc48698dc5c~_6Rr9q7WA1392913929euoutp02k
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1548931624;
	bh=psNr6P5d3KZD1xM7vBw/HsPsimHzAvavXSKrUjxnAEs=;
	h=Subject:To:Cc:From:Date:In-Reply-To:References:From;
	b=c/KEhwiFn1+/AACWW5CuRQQfajUtF8tj3j8rqk5mypU7dcprdGC6YhNH6oqR+E9hk
	 4GIKvCWgiZQbKDkuGmwYEcgxxm4eZUE0JY40lXPev1sbtlFZQDz6doYdctYCDCydR+
	 Rf4pBrBV3ys50vaG1UMbrscgnh++b3vOWxADwbdI=
Received: from eusmges3new.samsung.com (unknown [203.254.199.245]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTP id
	20190131104703eucas1p2bc8866d91e68d31b241e6a1b2efad557~_6Rrk-5t70151101511eucas1p2Y;
	Thu, 31 Jan 2019 10:47:03 +0000 (GMT)
Received: from eucas1p2.samsung.com ( [182.198.249.207]) by
	eusmges3new.samsung.com (EUCPMTA) with SMTP id 24.F1.04806.722D25C5; Thu, 31
	Jan 2019 10:47:03 +0000 (GMT)
Received: from eusmtrp2.samsung.com (unknown [182.198.249.139]) by
	eucas1p2.samsung.com (KnoxPortal) with ESMTPA id
	20190131104702eucas1p217179d3723a9e4ab8b356a53697dc90a~_6RqkkLrZ1630416304eucas1p2F;
	Thu, 31 Jan 2019 10:47:02 +0000 (GMT)
Received: from eusmgms1.samsung.com (unknown [182.198.249.179]) by
	eusmtrp2.samsung.com (KnoxPortal) with ESMTP id
	20190131104702eusmtrp2f7007b4bb8be9c081e9db09c18455154~_6RqV54SE2346723467eusmtrp2H;
	Thu, 31 Jan 2019 10:47:02 +0000 (GMT)
X-AuditID: cbfec7f5-367ff700000012c6-1b-5c52d22785b6
Received: from eusmtip1.samsung.com ( [203.254.199.221]) by
	eusmgms1.samsung.com (EUCPMTA) with SMTP id 0E.E6.04284.622D25C5; Thu, 31
	Jan 2019 10:47:02 +0000 (GMT)
Received: from [106.116.147.30] (unknown [106.116.147.30]) by
	eusmtip1.samsung.com (KnoxPortal) with ESMTPA id
	20190131104701eusmtip148e63e47938b8c65bcca73f0b42aa929~_6RpvChok1278112781eusmtip1Y;
	Thu, 31 Jan 2019 10:47:01 +0000 (GMT)
Subject: Re: [PATCHv2 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org,
	willy@infradead.org, mhocko@suse.com, pawel@osciak.com,
	kyungmin.park@samsung.com, mchehab@kernel.org, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-ID: <69e5a305-9d3b-b719-d1c6-8016e955b538@samsung.com>
Date: Thu, 31 Jan 2019 11:47:00 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
	Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190131031310.GA2372@jordon-HP-15-Notebook-PC>
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Brightmail-Tracker: H4sIAAAAAAAAA01SfSyUcRzv53n1cnoc5jeatttKmcj0x7MRamVPf9iKNVO31ckzb3foDqW2
	Zt6qm2RieLp5SSGEznlPHVlXi4RcZcjbNHGrvKzEkrtH5b/v5/P9fL+f7+e3H4kIxzFHMio2
	gZXHSqQi3AJtfrHaf8BlMEh8MGvShlbV1+K0fjgFoftSFwh6qF2F01kNTRg9XruB0d35nYCu
	UK+b0Z+y/ek8wypBd32bwei1nyrc34qpLa4FzJB+AGHauDGCaaxyZdTVN3FGvZhLMC8L11Bm
	+tcczmRrqgFTrxlGmSW180nLMxY+4aw0KomVe/iet4hcWFnC4icdL+frW9EUoLdXApKE1CFY
	URKpBBakkKoCsGxUS/BgGcBCffoWWNoEVeOYEpibJvpyRlC+UQngaNEz3NgQUl8BzHnsbVxr
	S4XC+21mRo0dNQHg+9kC1KhBqGBYyvURxhqnPKHSoDTNCihfWD41ZuJRag8cmB8x8faUGOa9
	6SF4jQ18VTSDGvebU4fhvbqd/MrdsMWgQvjaAY7MlJh8IZVBQu1yL8EffQxOdUxsBbCFX3Sa
	LX4X3Gj7O5AG4PVCjuBBFoBNqlacV3nD57oBzOiMUPthfbsHTx+BZS3tgH9Ha/jBYMMfYQ1z
	mwsQnhbAG5lCXr0Xcrq6f7ZdbweRHCDitiXjtsXhtsXh/vuWArQaOLCJClkEq/CKZS+5KyQy
	RWJshPuFOJkabP661791K63g6XpYN6BIILISTDw6JRZikiRFsqwbQBIR2QkWnwSJhYJwSfIV
	Vh53Tp4oZRXdwIlERQ6CqzsmzgqpCEkCG8Oy8az8b9eMNHdMAc4N2oBgt3kn//YAme+0tobq
	fVdRICies20MzlCqlPkXOy09OobGNGOzd4pHb/1ITyRP90TXeVm39J3I+ryRFtl7tESnyajp
	9Av0G9Zcc2msLP4eeNs6Rh3i1rwvsyYaK5QuVoekfixfmAtzbQjlnO6uEg8fGIasjrtk+7j3
	14tFqCJS4umKyBWSP1pOfyVxAwAA
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFvrAIsWRmVeSWpSXmKPExsVy+t/xu7pql4JiDKZd5LWYs34Nm8W1qw3M
	Fmeb3rBbXN41h82iZ8NWVot7a/6zWhyaupfRYtmmP0wW9/scLKa8/clucfDDE1aL3z/msDnw
	eKyZt4bR4/K1i8weO2fdZffYvELLY9OqTjaPTZ8msXucmPGbxePxr5dsHn1bVjF6rN9ylcXj
	8ya5AO4oPZui/NKSVIWM/OISW6VoQwsjPUNLCz0jE0s9Q2PzWCsjUyV9O5uU1JzMstQifbsE
	vYw3Xz+zFjyUqph6bQdLA+M10S5GTg4JAROJsxNusYDYQgJLGSUW3/aEiMtInJzWwAphC0v8
	udbF1sXIBVTzllHi0bb5QAkODmGBSIklO5lA4iICDxglZs3fzAbSwCwQLHFq9ytGiIYJjBKn
	ZjxmBEmwCRhKdL3tAiviFbCTWPzoLjuIzSKgKnHx9S02kKGiAjESV88xQpQISpyc+YQFJMwp
	YCuxaB0/xHh1iT/zLjFD2PIS29/OgbLFJW49mc80gVFoFpLuWUhaZiFpmYWkZQEjyypGkdTS
	4tz03GJDveLE3OLSvHS95PzcTYzA2N527OfmHYyXNgYfYhTgYFTi4X2wNjBGiDWxrLgy9xCj
	BAezkgjvpz1BMUK8KYmVValF+fFFpTmpxYcYTYFem8gsJZqcD0w7eSXxhqaG5haWhubG5sZm
	FkrivOcNKqOEBNITS1KzU1MLUotg+pg4OKUaGOMPRe56GtbslWa9su3TO7c/n+y/sMw6cn9W
	4yxDSc616nez7B0XRhrv+7qj3ObZWm75ENFDl94vs+Aoldv46Y7dtB9NpXyvK6rs98+Ycbww
	xT5kwaKcOq0ABvnCxLtlEluzU15cnPlHKfg8V8DEKDWP2A2L7gloczp4TW3f+eF0+WKnSV9e
	TVZiKc5INNRiLipOBACWwns2AwMAAA==
X-CMS-MailID: 20190131104702eucas1p217179d3723a9e4ab8b356a53697dc90a
X-Msg-Generator: CA
Content-Type: text/plain; charset="utf-8"
X-RootMTR: 20190131030925epcas1p4ffd8ed88bc8742d9ff2cabdaf6124383
X-EPHeader: CA
CMS-TYPE: 201P
X-CMS-RootMailID: 20190131030925epcas1p4ffd8ed88bc8742d9ff2cabdaf6124383
References: <CGME20190131030925epcas1p4ffd8ed88bc8742d9ff2cabdaf6124383@epcas1p4.samsung.com>
	<20190131031310.GA2372@jordon-HP-15-Notebook-PC>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Souptick,

On 2019-01-31 04:13, Souptick Joarder wrote:
> Convert to use vm_insert_range to map range of kernel memory
> to user vma.
>
> vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
> not as a in-buffer offset by design and it always want to mmap a
> whole buffer from its beginning.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Suggested-by: Marek Szyprowski <m.szyprowski@samsung.com>

Reviewed-by: Marek Szyprowski <m.szyprowski@samsung.com>

> ---
>  drivers/media/common/videobuf2/videobuf2-core.c    |  7 +++++++
>  .../media/common/videobuf2/videobuf2-dma-contig.c  |  6 ------
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c  | 22 ++++++----------------
>  3 files changed, 13 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/media/common/videobuf2/videobuf2-core.c b/drivers/media/common/videobuf2/videobuf2-core.c
> index 70e8c33..ca4577a 100644
> --- a/drivers/media/common/videobuf2/videobuf2-core.c
> +++ b/drivers/media/common/videobuf2/videobuf2-core.c
> @@ -2175,6 +2175,13 @@ int vb2_mmap(struct vb2_queue *q, struct vm_area_struct *vma)
>  		goto unlock;
>  	}
>  
> +	/*
> +	 * vm_pgoff is treated in V4L2 API as a 'cookie' to select a buffer,
> +	 * not as a in-buffer offset. We always want to mmap a whole buffer
> +	 * from its beginning.
> +	 */
> +	vma->vm_pgoff = 0;
> +
>  	ret = call_memop(vb, mmap, vb->planes[plane].mem_priv, vma);
>  
>  unlock:
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-contig.c b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> index aff0ab7..46245c5 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-contig.c
> @@ -186,12 +186,6 @@ static int vb2_dc_mmap(void *buf_priv, struct vm_area_struct *vma)
>  		return -EINVAL;
>  	}
>  
> -	/*
> -	 * dma_mmap_* uses vm_pgoff as in-buffer offset, but we want to
> -	 * map whole buffer
> -	 */
> -	vma->vm_pgoff = 0;
> -
>  	ret = dma_mmap_attrs(buf->dev, vma, buf->cookie,
>  		buf->dma_addr, buf->size, buf->attrs);
>  
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> index 015e737..a800200 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> @@ -328,28 +328,18 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
>  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
>  {
>  	struct vb2_dma_sg_buf *buf = buf_priv;
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned long usize = vma->vm_end - vma->vm_start;
> -	int i = 0;
> +	int err;
>  
>  	if (!buf) {
>  		printk(KERN_ERR "No memory to map\n");
>  		return -EINVAL;
>  	}
>  
> -	do {
> -		int ret;
> -
> -		ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> -		if (ret) {
> -			printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> -			return ret;
> -		}
> -
> -		uaddr += PAGE_SIZE;
> -		usize -= PAGE_SIZE;
> -	} while (usize > 0);
> -
> +	err = vm_insert_range(vma, buf->pages, buf->num_pages);
> +	if (err) {
> +		printk(KERN_ERR "Remapping memory, error: %d\n", err);
> +		return err;
> +	}
>  
>  	/*
>  	 * Use common vm_area operations to track buffer refcount.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

