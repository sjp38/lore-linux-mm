Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A835C4646D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53F27218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:46:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TSpRi0Z2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53F27218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA16A8E0021; Wed,  3 Jul 2019 16:46:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4FB88E0019; Wed,  3 Jul 2019 16:46:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF05B8E0021; Wed,  3 Jul 2019 16:46:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 996A08E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 16:46:05 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so4586543qtp.1
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 13:46:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=HwGmCz10Ci8GwJ1IjwMoUJAJeEMJSYtD2O20Ed/Ggn0=;
        b=M1vGCAKk0TFyaLaRc/WM7Vpgt3KzRVD5L5LzpkqI6oAJRzDiALkdWBdAOA2gvs8F50
         ODjkff2CFczJ4qk9eEGvkuZP3xikyywrfxEGe7lhTyjmJVyDuMQGBNG43n28YS9aGBJL
         jRZ8s4FsgIPv5FEHSKCCo3gmql+wYcAcq+e0SgC8JYhvmddpscca2DDTZH21jN8YBzqJ
         nR79oAQP3Ey70DbaWQ6Vvrg5qRMFxKz5RAh0nDuv0W08iDxTeOkhhYMf1tvtmlwuzTC6
         7HQeOXKnPgmT1MOUexhi155SwvrE6K5zmfhvguLAM43bMtcP66mZWROy/Hq5cGJvd9Sj
         NbbA==
X-Gm-Message-State: APjAAAWMjDVkcjvRcnRkDtCw5H+5Vg7wkvQuQdR72OejQ8DvaR3Gwl/d
	lCzFvdwlXTz4/vRMJj1qlJieGQ1a2JPsCdhGsPUJU8VpZ8YA+P+7zGZVIvkOytMJTehfSW7o5iH
	On9cNldMthKAvrLQadI6R7PSw21Q1JSS8GhrRD//Wv3dOJgrd147wLbSbqvDc0/iSxw==
X-Received: by 2002:a5b:48d:: with SMTP id n13mr24436163ybp.455.1562186765246;
        Wed, 03 Jul 2019 13:46:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxclNabxLPWeEAqjJaChw+Kz8GvTpL1g32W++T17pXHBBo4OHduLhoZiVcJnp3obx9wS/Kr
X-Received: by 2002:a5b:48d:: with SMTP id n13mr24436127ybp.455.1562186764568;
        Wed, 03 Jul 2019 13:46:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562186764; cv=none;
        d=google.com; s=arc-20160816;
        b=TH2woRfntLszgskFa94C7oVnE93FC5NkRyShUPFIP0iU55dN6opuwECCJ5hq6SarRY
         Of227KrMuermrJW6fhoJZC50kIxXIQrgjTOZd8rBpD5EQaHa4nuwqhW8Ut0tNI2taPQf
         ZnN3gnr9FJNeBbbk9SgfO0kfHUNirdODY37uH3/K5d2vB8b3b7cj14+IcipZr80pCb4u
         1UqwGU0sepmqK88XiyftODocCQI3VC4PXqpeRz1yUY+Rk0C8/i++kvhyfPryPxAVlALd
         DESyXT3RAALGMAjPXAPzfM7bmHUt23WJP0Ve0vPWzqWnZ7jY1gtWz+rhH7W/UnHUVe0i
         wpfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=HwGmCz10Ci8GwJ1IjwMoUJAJeEMJSYtD2O20Ed/Ggn0=;
        b=gxUMax+a+REQIJjW/MU8EfqMds50Z9tXP3OSyAw3dtHtRlRGOtqISjdX34h3fBpg8c
         aO643jSPTLrvM5ppToBfbXl88JFC8s5vOzmz7cbUbOK3C9ZQkPvbH8WjPPzjvDbmo7sT
         ZU/kfOanadkY1ZMIYjdzpr2yj/liZwFIIf4iYq4aE+/s/r8xAow9ik2NUb/6WzWqYLa4
         6Wh+1tRxCqtNMM7wDNewRwNwEE2E9opDlO4FvqTiHnZZ038C3k4P7kKqzDHU9Euqa8eF
         Er6BjOprq+997jWv4GuYwtMn2CgufH22Z29ZpxfFgeYxoJpCw7AnPlNzT5c9bI1CM0f4
         yTaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TSpRi0Z2;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 203si1561864ywc.190.2019.07.03.13.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 13:46:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TSpRi0Z2;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d1d140a0007>; Wed, 03 Jul 2019 13:46:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 03 Jul 2019 13:46:03 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 03 Jul 2019 13:46:03 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 3 Jul
 2019 20:46:02 +0000
Subject: Re: [PATCH 4/5] nouveau: unlock mmap_sem on all errors from
 nouveau_range_fault
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>
References: <20190703184502.16234-1-hch@lst.de>
 <20190703184502.16234-5-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <ec5e86a4-4a60-0dd5-797c-41b21e3a091a@nvidia.com>
Date: Wed, 3 Jul 2019 13:46:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190703184502.16234-5-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1562186762; bh=HwGmCz10Ci8GwJ1IjwMoUJAJeEMJSYtD2O20Ed/Ggn0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TSpRi0Z2SY1PHzP7KqCWwxKUB7G7m2aHuiHMaA+9zP4+plxdtT8gQdk4j/bAX75jR
	 ie5dx3Vb3i48qambjEboni/xwCBSBYFfWIVo7DXI/FiT8Ul+vFRdVDMeGda752Ju2A
	 /faZi69iPodzzziBC24xask8p2w8tOrV67rfXnwmepxxW9gqMmKv8bpJ2kHbtImsld
	 paeawUfZJ1OaKL7ImUmpDFGnWOkmofheb70vsKR3CJ1F3qa7X4zWMBap07oQfA7/l1
	 edHl7WUUACR964z3YaQirWTw8Cyvej6xdanAN7TJ3NW3ryuhpXhblUsxTU4iuod6sZ
	 CFn2uVwfp3Juw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/3/19 11:45 AM, Christoph Hellwig wrote:
> Currently nouveau_svm_fault expects nouveau_range_fault to never unlock
> mmap_sem, but the latter unlocks it for a random selection of error
> codes. Fix this up by always unlocking mmap_sem for non-zero return
> values in nouveau_range_fault, and only unlocking it in the caller
> for successful returns.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_svm.c | 15 ++++++++-------
>   1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
> index e831f4184a17..c0cf7aeaefb3 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_svm.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
> @@ -500,8 +500,10 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,

You can delete the comment "With the old API the driver must ..."
(not visible in the patch here).
I suggest moving the two assignments:
	range->default_flags = 0;
	range->pfn_flags_mask = -1UL;
to just above the "again:" where the other range.xxx fields are
initialized in nouveau_svm_fault().

>   	ret = hmm_range_register(range, mirror,
>   				 range->start, range->end,
>   				 PAGE_SHIFT);
> -	if (ret)
> +	if (ret) {
> +		up_read(&range->vma->vm_mm->mmap_sem; >   		return (int)ret;
> +	}
>   
>   	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
>   		/*

You can delete this comment (only the first line is visible here)
since it is about the "old API".
Also, it should return -EBUSY not -EAGAIN since it means there was a
range invalidation collision (similar to hmm_range_fault() if
!range->valid).

> @@ -515,15 +517,14 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
>   
>   	ret = hmm_range_fault(range, block);

nouveau_range_fault() is only called with "block = true" so
could eliminate the block parameter and pass true here.

>   	if (ret <= 0) {
> -		if (ret == -EBUSY || !ret) {
> -			/* Same as above, drop mmap_sem to match old API. */
> -			up_read(&range->vma->vm_mm->mmap_sem);
> -			ret = -EBUSY;
> -		} else if (ret == -EAGAIN)
> +		if (ret == 0)
>   			ret = -EBUSY;
> +		if (ret != -EAGAIN)
> +			up_read(&range->vma->vm_mm->mmap_sem);

Can ret == -EAGAIN happen if "block = true"?
Generally, I prefer the read_down()/read_up() in the same function
(i.e., nouveau_svm_fault()) but I can see why it should be here
if hmm_range_fault() can return with mmap_sem unlocked.

>   		hmm_range_unregister(range);
>   		return ret;
>   	}
> +
>   	return 0;
>   }
>   
> @@ -718,8 +719,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
>   						NULL);
>   			svmm->vmm->vmm.object.client->super = false;
>   			mutex_unlock(&svmm->mutex);
> +			up_read(&svmm->mm->mmap_sem);
>   		}
> -		up_read(&svmm->mm->mmap_sem);
>   

The "else" case should check for -EBUSY and goto again.

>   		/* Cancel any faults in the window whose pages didn't manage
>   		 * to keep their valid bit, or stay writeable when required.
> 

