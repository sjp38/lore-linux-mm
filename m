Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93D09C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:49:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48A2E20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TOSu9Iw1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48A2E20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F08546B000D; Thu, 13 Jun 2019 20:49:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB9DC6B000E; Thu, 13 Jun 2019 20:49:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD0856B0266; Thu, 13 Jun 2019 20:49:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE2F76B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:49:09 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id t203so794324ywe.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:49:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=BjedhBHdC+dcOh91aticrwFWw8MgD0WBJkzQKnUq81E=;
        b=cxWGkqpihL3DGGeg+e5btvbEZleA7Pcmd2CyU8Ve48d++fy+50t3x1JXUj8kMJYJLR
         qXKIYbBc1dvxjJYekDs8HMlGyU6Mi1g/Wt5ZDLgJk22wYG29YEIjmkjTziB8Ok0IZQwr
         kH6jSk9d58OF1H6oViev9NMhuEJFLHi7cB1MYm5rGX7PSqgQu21M9dUhP84xZqCytXgQ
         qyvv5Sdd53skktun0LUla5OzhGPAixyyaNaYh5r/xn9xQtzLGP/vHYJtVu1BOfvcmiUq
         1tEk3PHRbchTiAralbo3c4iaBN8+vjnLj4czsMG6fIUCWY7ZHxL7MsGhrOokI+ooOmwj
         897g==
X-Gm-Message-State: APjAAAWyIBActyvmK2sWo7rzv30EqxkYtD93C4ZAqxzyqYweQy0Ke0NX
	uNsBHyuxwYLfVhMQAzLy4Y/Gvf7vQGiy8qBkZFZrIoMYxM6iFpIP1ZIbdlsNx1njnuKWZ05DptS
	gwRYM4XoZU91aKRbFgTbfa4yHJVWXAuX6NQmiVbrDdpuES1IbcbqG+IG3DxNrPlrRlA==
X-Received: by 2002:a0d:ddc8:: with SMTP id g191mr39801647ywe.334.1560473349475;
        Thu, 13 Jun 2019 17:49:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVWusnfl3rdjnYZ0HJz/8OFBOi0MThbOgUFXsULKKLsUxLbQoSzIpcHx6aSCVWUKmMCxZn
X-Received: by 2002:a0d:ddc8:: with SMTP id g191mr39801632ywe.334.1560473348895;
        Thu, 13 Jun 2019 17:49:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560473348; cv=none;
        d=google.com; s=arc-20160816;
        b=kVinhtQ972DMQUyCzGJabkKe2vtYALX8iVx8ilIh41kKPGzQOJ27odUdJXB+vLZcVk
         8UFz1h5KxZAHjgVJtQ9USUpTHkL1tiUYafaWSmsCObuBU4ci7AswSz0NkhMeSd2tptAW
         CWfiPm9HaGDc4klqLD21kGWFqewEnMJO+9uHzRJ4W1P6b9WsxH32lyOpEpiqHoliV4yd
         sGQZQwlpzYkudmFehSTtyPYFoZI53Z5FiJKj+AYCkfxcDb5gvXifMhr7TA74vMkyWDZN
         wjI8+vwnV3sf/M1wUbOkQ8AVTomf5KnDboDV/Iq6l3YkCYtxlh0FJfnHB5iyuaJz1I7i
         gbQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=BjedhBHdC+dcOh91aticrwFWw8MgD0WBJkzQKnUq81E=;
        b=a0M+3tcQk+6zTduicRc4REmt5A/6wg1hPgohGDttotGbOtGZDc2mqISEuGBSC6qGCb
         2CB8uyxG4c3IT5dyBG98PhHF/1lJvCwel0i+8yv9oPoDc/QxkpYbWQ/ufGaYIsFENMjv
         V8bMLkXQt3YhyNfIGjiHotNH08N8mgRdY90nVpgGF+AsjSaS35sCt7onfXr7GtlNx1zH
         SeIbCOPQ1nGGROwVa7Acp5DARhQOhIPJX1ebsWm4dCD2iHGN31BG063b2v0+6g8+0x7v
         dWCBGP+HKWs5u7hBGpE1JxSd5fodRITSNFCH40BCC3l9TNiia4gOuYBgFDiMSogMGZZm
         E6jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TOSu9Iw1;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v5si486266ywc.263.2019.06.13.17.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 17:49:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TOSu9Iw1;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02eeff0000>; Thu, 13 Jun 2019 17:49:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 17:49:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 13 Jun 2019 17:49:02 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 00:49:00 +0000
Subject: Re: [PATCH] drm/nouveau/dmem: missing mutex_lock in error path
To: Ralph Campbell <rcampbell@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	David Airlie <airlied@linux.ie>, Ben Skeggs <bskeggs@redhat.com>, "Jason
 Gunthorpe" <jgg@mellanox.com>
CC: <nouveau@lists.freedesktop.org>, <linux-mm@kvack.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>
References: <20190614001121.23950-1-rcampbell@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <1fc63655-985a-0d60-523f-00a51648dc38@nvidia.com>
Date: Thu, 13 Jun 2019 17:49:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614001121.23950-1-rcampbell@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560473343; bh=BjedhBHdC+dcOh91aticrwFWw8MgD0WBJkzQKnUq81E=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TOSu9Iw1C1DyRb5jRymBzYQAVGIJGrsxVJQIolENnFKOatN3JUmcw1Cu7lBtGtE3X
	 cc+8Hc1/d7iGZDZFhLxpWRvLO2EQqM/XPuM/S7T68j1IMK3V62F6/Gu/we7U2KMrQH
	 TzSpxb5+WvPQsxgC5pSPQYT/yRLTWzMGeZg5F23F2WZiFp6OJSPuZm8DEQAuvOyfgH
	 83pDBVFmfiNeFA3osDju1F4Wbw1zBq/ovn9iTiBWwe8XdP86mKRIhfcUwBSb8PDBcM
	 FTNPwt4TervNTABgwRII5KXJ/FclnbDfCQfZZWdNIlPs0Rg0xcdClB5AUmpfBYvWgH
	 xZac448fVDEKA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 5:11 PM, Ralph Campbell wrote:
> In nouveau_dmem_pages_alloc(), the drm->dmem->mutex is unlocked before
> calling nouveau_dmem_chunk_alloc().
> Reacquire the lock before continuing to the next page.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
> 
> I found this while testing Jason Gunthorpe's hmm tree but this is
> independant of those changes. I guess it could go through
> David Airlie's tree for nouveau or Jason's tree.
> 

Hi Ralph,

btw, was this the fix for the crash you were seeing? It might be nice to
mention in the commit description, if you are seeing real symptoms.


>  drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 27aa4e72abe9..00f7236af1b9 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -379,9 +379,10 @@ nouveau_dmem_pages_alloc(struct nouveau_drm *drm,
>  			ret = nouveau_dmem_chunk_alloc(drm);
>  			if (ret) {
>  				if (c)
> -					break;

Actually, the pre-existing code is a little concerning. Your change preserves
the behavior, but it seems questionable to be doing a "return 0" (whether
via the above break, or your change) when it's in this partially allocated
state. It's reporting success when it only allocates part of what was requested,
and it doesn't fill in the pages array either.



> +					return 0;
>  				return ret;
>  			}
> +			mutex_lock(&drm->dmem->mutex);
>  			continue;
>  		}
>  
> 

The above comment is about pre-existing potential problems, but your patch itself
looks correct, so:

Reviewed-by: John Hubbard <jhubbard@nvidia.com> 


thanks,
-- 
John Hubbard
NVIDIA

