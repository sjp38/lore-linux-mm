Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11BF3C46478
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D47C2218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:51:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D47C2218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ED848E0024; Wed,  3 Jul 2019 17:51:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99A818E0021; Wed,  3 Jul 2019 17:51:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 862BA8E0024; Wed,  3 Jul 2019 17:51:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A80B8E0021
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 17:51:29 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id i2so1610349wrp.12
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 14:51:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BQCLL5C2maXjuWUH1GMB4u+IF4n1j6/UYl1ONzdzHCU=;
        b=pOlkeTbkVKoy4T1WNzxChHjOgAfRUlLfcXH59qSrfZHhCfsHM/7fvQUb3Gf/BY3sym
         6bsVQ6qyHIjZQb/KOxz9g4vMCV13Rz2491+6NJyDVDMhrTO2yJV9JQtCY7meex868jZa
         vx1h//7SKjJk1iEV7cve3Dcj89iMtPTK9M3eQgz71s9taOpjJf4EHU3SM5snAEu+OaxQ
         jV1MXtBNDB/UXwJwqKFNGlCsJW2dZMbgmAhdTY2EuV+kXA+9md3lUKn/mfiMbJ+O9P7M
         zuNQIuwm7PAzT3p/SVFOJ9yY2oUtxb3rnE2mFTmpAoczDft6ZVnoXRlaSWIZX2/oW3MX
         xyqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUndTFwKugIAzRhJCZYCAm5S43iGMFgkqZfPlHP2xVmdTyN9STs
	psexhsSF/2KVnarJrxoQ6BHBJEULxPpFRDtyWDErMK8iiJCVs+hYkDeUoaizfxESo86rWy6PFkc
	buSIUPNP+/POE8OThM3Zjix4M6dGZuWILgxjOzT8EfJ6AywCbmSFxJzhxe2Kgms7ObQ==
X-Received: by 2002:a1c:7d8e:: with SMTP id y136mr9099630wmc.16.1562190688779;
        Wed, 03 Jul 2019 14:51:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdpRipHcdzjZESxIflYaaRQ/t0fYqQsxQu0aPKfmLFR+U7DYIFeU/y2uatllIu3Qn9rCEM
X-Received: by 2002:a1c:7d8e:: with SMTP id y136mr9099613wmc.16.1562190687939;
        Wed, 03 Jul 2019 14:51:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562190687; cv=none;
        d=google.com; s=arc-20160816;
        b=w58K88tIcLKf9apXw1c2z0y2K38MQrdkJVinNYzelvxioNYaLHo0BlCL6SbIKg7S7m
         4R3GO517fchZve9ia7wpn5K3CHC63rVKvzZ5ad84t7YfY+Oi0EZZqDQBoJkGDJ2WpEPk
         Oh8uvihTlCKNvYRnG2GobZ+ns8VECBhqPFKCQkxeL8mi4i34F0nRlXjSFW+0l1xax2/r
         v0OC2djHFYBo8N33xIokhujJRCtESRPPxJLJaD49mqJ9nsa5Q8HVGGFnVtMybatTu/IH
         20gZvHSEdCqPMJVpYvdMV+ou4FLguVfbkY+TI63/LuW0+6dm3cYRFs2R5TUGAHqzQBSO
         VtrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BQCLL5C2maXjuWUH1GMB4u+IF4n1j6/UYl1ONzdzHCU=;
        b=GVfU7nJYyObqCIfg3WCIySQR+msBf+cdW6qdDgpaQE2TcQm1V7AVZwUvy3cNi0kf8/
         6H5o1ZB1+Orh56eCggeZq/WrxYSfZ2yi7dO43A8eOlqsZdiT4WI/yF+73Bt4t6OlTMT/
         S44QeYX9MosiQ+lVdGPoL9NwDEVLBvgO8Jrovu9hSP4OVO0MzVG20y3fQr53ttcHMvE2
         TGG8RiQGouhk2NGSsYiDhqxL86HECkzcQEHTPGAuaHY43k55MY3mZhjvXxRTZpOzuu1r
         hTOJB4rDLKWrF3e2Tf7xzrz7UhYvVY+G1ZXodmeG8VVR632US+kpO92M8/RRhXYLEwHf
         O2vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id a17si2818876wrp.176.2019.07.03.14.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 14:51:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C562368B05; Wed,  3 Jul 2019 23:51:26 +0200 (CEST)
Date: Wed, 3 Jul 2019 23:51:26 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 4/5] nouveau: unlock mmap_sem on all errors from
 nouveau_range_fault
Message-ID: <20190703215126.GA17366@lst.de>
References: <20190703184502.16234-1-hch@lst.de> <20190703184502.16234-5-hch@lst.de> <ec5e86a4-4a60-0dd5-797c-41b21e3a091a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec5e86a4-4a60-0dd5-797c-41b21e3a091a@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 01:46:02PM -0700, Ralph Campbell wrote:
> You can delete the comment "With the old API the driver must ..."
> (not visible in the patch here).

Sure.

> I suggest moving the two assignments:
> 	range->default_flags = 0;
> 	range->pfn_flags_mask = -1UL;
> to just above the "again:" where the other range.xxx fields are
> initialized in nouveau_svm_fault().

For now I really just want to move the code around.  As Jason pointed
out the flow will need some major rework, and I'd rather not mess
with little things like this for now.  Especially as I assume Jerome
must have an update to the proper API ready given that he both
wrote that new API and the nouveau code.

> You can delete this comment (only the first line is visible here)
> since it is about the "old API".

Ok.

> Also, it should return -EBUSY not -EAGAIN since it means there was a
> range invalidation collision (similar to hmm_range_fault() if
> !range->valid).

Yes, probably.


>> @@ -515,15 +517,14 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
>>     	ret = hmm_range_fault(range, block);
>
> nouveau_range_fault() is only called with "block = true" so
> could eliminate the block parameter and pass true here.

Indeed.

>
>>   	if (ret <= 0) {
>> -		if (ret == -EBUSY || !ret) {
>> -			/* Same as above, drop mmap_sem to match old API. */
>> -			up_read(&range->vma->vm_mm->mmap_sem);
>> -			ret = -EBUSY;
>> -		} else if (ret == -EAGAIN)
>> +		if (ret == 0)
>>   			ret = -EBUSY;
>> +		if (ret != -EAGAIN)
>> +			up_read(&range->vma->vm_mm->mmap_sem);
>
> Can ret == -EAGAIN happen if "block = true"?

I don't think so, we can remove that.

> Generally, I prefer the read_down()/read_up() in the same function
> (i.e., nouveau_svm_fault()) but I can see why it should be here
> if hmm_range_fault() can return with mmap_sem unlocked.

Yes, in the long run this all needs a major cleanup..


>>   @@ -718,8 +719,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
>>   						NULL);
>>   			svmm->vmm->vmm.object.client->super = false;
>>   			mutex_unlock(&svmm->mutex);
>> +			up_read(&svmm->mm->mmap_sem);
>>   		}
>> -		up_read(&svmm->mm->mmap_sem);
>>   
>
> The "else" case should check for -EBUSY and goto again.

It should if I were trying to fix this.  But this is just code
inspection and I don't even have the hardware, so I'll have to leave
that for someone who can do real development on the driver.

