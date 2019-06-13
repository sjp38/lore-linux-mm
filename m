Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5ED7C31E4B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:06:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FB272147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:06:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="k7gBpDBH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FB272147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF67D6B000C; Thu, 13 Jun 2019 19:06:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7FDF6B000D; Thu, 13 Jun 2019 19:06:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD36A6B000E; Thu, 13 Jun 2019 19:06:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 987356B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:06:55 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id e7so837945ybk.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:06:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=cGbQpSJeY7EVdecrn1B4tdD7hDPwyzG0O3MV1AM9XS8=;
        b=jxz0GttQofLZCL8kpL38PptujASSB13V1sRxvJnak1MCSl9+C+BTlGcaMl8XLhI5Yg
         gUDSQoEpcgA5JS9Fuu0V+BrATzIC5UPkkYqmuae7Po+fXhnUrTSXnbOOOd9tAcBWrewh
         8jGx8i79o3ocJ5FDkF9SLGXQhtGDwf5VOZndwQhjxL9Xz/2eiV49yVTHHtLsK6R9EXDF
         UbaUwxX7H62xjUmgw/8d2wfeCVytGjyeW0QehDxFXJ6l46YOF3MjF9ljaFKiseS79yA3
         9DoK3ube6SE4VIUBroaeAj/BmogfeAQMQiTnkRGLqRqI+HpyMvfYMu7M8PfRNmDVzJMW
         x/og==
X-Gm-Message-State: APjAAAWDxt6WbXYKUPFetUtfvyFE7meE7oRUwZsJeXA7FDmYIyRx8NBF
	i+6HFk9+h8lgl2f9HYht4dAesH6itDm2RCDv/Fr3GioKBaG722H3AuMK8ODZk8/Bb7L1yMtr3MY
	FU7SLP9baVeGf07bDrWFN2qEpoJzTQEI0aqe6Vv3bBlGlAGu/GTW/qxxUaaBzkDQ40A==
X-Received: by 2002:a81:34ca:: with SMTP id b193mr24290031ywa.329.1560467215326;
        Thu, 13 Jun 2019 16:06:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAKYVBiImPM5WU/A+G6nqGJhQhh4r/cVYsqerL9aRd5j7GW8cpSdtuOeH9tsMgrz6tXzyL
X-Received: by 2002:a81:34ca:: with SMTP id b193mr24289974ywa.329.1560467214287;
        Thu, 13 Jun 2019 16:06:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560467214; cv=none;
        d=google.com; s=arc-20160816;
        b=MDEeIsfcYGyE+hbzeNl8eMNrgRMu9aMNu6/T8DAf5fTseCwQUYrNvwwAGbw135DMaA
         MbIYVtEx2GjqBDQQjAFEz3h2W1pl2ljr5kzoKVWNKbTbzRpSm6mfsOd+tnjRKxBML4SX
         CK9+nfVS5piEwj7dwUJaYQBQjk/mWm/I33hCnticbQaG2+xZFawzkLJ2p9Elv53PG8dq
         DsBV3YMIAVklaQaazlP0ydPnVUsdo7gdT+bKopSrb9hFu1G5/sitxfC645MUcHrDsDs4
         MRBPFIl38nxe2QuYNRDzF/t7/0C+bSg3aSohP9VV92V51d+JVw3xXjYCRZ2dfUHexBUL
         phuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=cGbQpSJeY7EVdecrn1B4tdD7hDPwyzG0O3MV1AM9XS8=;
        b=k9O3WIHNQnRcQqnU3xij6UEyRAfRlFNg8G5NiXmTaF6mEE5Q6KeO4q+TJxKbu49w0m
         jvKcaBVK40FtkPhQt1Vj7YW4ZSOshYYlJ02X7zBzGKf5Y6iEre4qqq5nxyURqrV2rDHt
         62ZYbgDmS/stBO+lOPrk9rjkeNsNe/w8dj+w2/UV7gTtr11sTK6fS8rxQouXwtgWAbFD
         JSndl0eR9WJwsPQDH3iFypKFOiCBnLUaO2Lr1COrtYNL+fI4LdCUApAIBcOlWvaAMeZ+
         /Q6dskhJsI2q0DZgFFvR3etT1SMZ8tXPx9uqbVByS1H3Lx6yQU41CywdII1zYRb4PKSm
         TiVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=k7gBpDBH;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s62si481563ywb.29.2019.06.13.16.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:06:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=k7gBpDBH;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02d70d0000>; Thu, 13 Jun 2019 16:06:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 16:06:53 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 13 Jun 2019 16:06:53 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 13 Jun
 2019 23:06:48 +0000
Subject: Re: [Nouveau] [PATCH 02/22] mm: remove the struct hmm_device
 infrastructure
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
CC: <linux-nvdimm@lists.01.org>, <linux-pci@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-3-hch@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <5a11b5a1-cfb2-f9a1-493e-ed153de7f00b@nvidia.com>
Date: Thu, 13 Jun 2019 16:06:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613094326.24093-3-hch@lst.de>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560467213; bh=cGbQpSJeY7EVdecrn1B4tdD7hDPwyzG0O3MV1AM9XS8=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=k7gBpDBH28H0UPXm/LwiNKu0hTT0acLapve5cjM4dS/oE6ZVNYmwnPX6eZ1IBLBk5
	 FaGoLiYRcnAB14i7X74VljXHrRLRUzcvaMywNiBB41s9wEKQX/tEy3nCG/IGKVGiRl
	 AD/kzl4An8dw76LgLOSTpr6GRU+k7qjNEiiMvVCOWWDxfV2POtjYEN4x4fEQBVkt4s
	 w4fj3ThbmIEucaN47ISk4Wy4FipBObRrSm95UkSAAEnuZHlIoHv4MjV9u+xnt0TGcA
	 yAyoTlbvf9SebsSJFi4g4WQpsjzz4+CxSeUNYwWe+JCM2b7eq3Hz8n8DP45hXh+hWa
	 L//lTcvzR3KxQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 2:43 AM, Christoph Hellwig wrote:
> This code is a trivial wrapper around device model helpers, which
> should have been integrated into the driver device model usage from
> the start.  Assuming it actually had users, which it never had since
> the code was added more than 1 1/2 years ago.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/hmm.h | 20 ------------
>  mm/hmm.c            | 80 ---------------------------------------------
>  2 files changed, 100 deletions(-)
> 

Yes. This code is definitely unnecessary, and it's a good housecleaning here.

(As to the history: I know that there was some early "HMM dummy device" 
testing when the HMM code was much younger, but such testing has long since
been superseded by more elaborate testing with real drivers.)


Reviewed-by: John Hubbard <jhubbard@nvidia.com> 


thanks,
-- 
John Hubbard
NVIDIA

> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 0fa8ea34ccef..4867b9da1b6c 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -717,26 +717,6 @@ static inline unsigned long hmm_devmem_page_get_drvdata(const struct page *page)
>  {
>  	return page->hmm_data;
>  }
> -
> -
> -/*
> - * struct hmm_device - fake device to hang device memory onto
> - *
> - * @device: device struct
> - * @minor: device minor number
> - */
> -struct hmm_device {
> -	struct device		device;
> -	unsigned int		minor;
> -};
> -
> -/*
> - * A device driver that wants to handle multiple devices memory through a
> - * single fake device can use hmm_device to do so. This is purely a helper and
> - * it is not strictly needed, in order to make use of any HMM functionality.
> - */
> -struct hmm_device *hmm_device_new(void *drvdata);
> -void hmm_device_put(struct hmm_device *hmm_device);
>  #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
>  #else /* IS_ENABLED(CONFIG_HMM) */
>  static inline void hmm_mm_destroy(struct mm_struct *mm) {}
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 886b18695b97..ff2598eb7377 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1499,84 +1499,4 @@ struct hmm_devmem *hmm_devmem_add_resource(const struct hmm_devmem_ops *ops,
>  	return devmem;
>  }
>  EXPORT_SYMBOL_GPL(hmm_devmem_add_resource);
> -
> -/*
> - * A device driver that wants to handle multiple devices memory through a
> - * single fake device can use hmm_device to do so. This is purely a helper
> - * and it is not needed to make use of any HMM functionality.
> - */
> -#define HMM_DEVICE_MAX 256
> -
> -static DECLARE_BITMAP(hmm_device_mask, HMM_DEVICE_MAX);
> -static DEFINE_SPINLOCK(hmm_device_lock);
> -static struct class *hmm_device_class;
> -static dev_t hmm_device_devt;
> -
> -static void hmm_device_release(struct device *device)
> -{
> -	struct hmm_device *hmm_device;
> -
> -	hmm_device = container_of(device, struct hmm_device, device);
> -	spin_lock(&hmm_device_lock);
> -	clear_bit(hmm_device->minor, hmm_device_mask);
> -	spin_unlock(&hmm_device_lock);
> -
> -	kfree(hmm_device);
> -}
> -
> -struct hmm_device *hmm_device_new(void *drvdata)
> -{
> -	struct hmm_device *hmm_device;
> -
> -	hmm_device = kzalloc(sizeof(*hmm_device), GFP_KERNEL);
> -	if (!hmm_device)
> -		return ERR_PTR(-ENOMEM);
> -
> -	spin_lock(&hmm_device_lock);
> -	hmm_device->minor = find_first_zero_bit(hmm_device_mask, HMM_DEVICE_MAX);
> -	if (hmm_device->minor >= HMM_DEVICE_MAX) {
> -		spin_unlock(&hmm_device_lock);
> -		kfree(hmm_device);
> -		return ERR_PTR(-EBUSY);
> -	}
> -	set_bit(hmm_device->minor, hmm_device_mask);
> -	spin_unlock(&hmm_device_lock);
> -
> -	dev_set_name(&hmm_device->device, "hmm_device%d", hmm_device->minor);
> -	hmm_device->device.devt = MKDEV(MAJOR(hmm_device_devt),
> -					hmm_device->minor);
> -	hmm_device->device.release = hmm_device_release;
> -	dev_set_drvdata(&hmm_device->device, drvdata);
> -	hmm_device->device.class = hmm_device_class;
> -	device_initialize(&hmm_device->device);
> -
> -	return hmm_device;
> -}
> -EXPORT_SYMBOL(hmm_device_new);
> -
> -void hmm_device_put(struct hmm_device *hmm_device)
> -{
> -	put_device(&hmm_device->device);
> -}
> -EXPORT_SYMBOL(hmm_device_put);
> -
> -static int __init hmm_init(void)
> -{
> -	int ret;
> -
> -	ret = alloc_chrdev_region(&hmm_device_devt, 0,
> -				  HMM_DEVICE_MAX,
> -				  "hmm_device");
> -	if (ret)
> -		return ret;
> -
> -	hmm_device_class = class_create(THIS_MODULE, "hmm_device");
> -	if (IS_ERR(hmm_device_class)) {
> -		unregister_chrdev_region(hmm_device_devt, HMM_DEVICE_MAX);
> -		return PTR_ERR(hmm_device_class);
> -	}
> -	return 0;
> -}
> -
> -device_initcall(hmm_init);
>  #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> 

