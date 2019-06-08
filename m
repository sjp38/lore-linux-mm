Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47A0DC2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:13:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D56DA208C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 01:13:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="SzYmAOHz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D56DA208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CD4D6B026C; Fri,  7 Jun 2019 21:13:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37D816B026D; Fri,  7 Jun 2019 21:13:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26C986B0276; Fri,  7 Jun 2019 21:13:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 026A96B026C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 21:13:50 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k142so3683393ywa.9
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 18:13:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=uiPsFTVMNBBi8QlzP+NhgiuB1J/ANB5gJR02GD6ywIc=;
        b=aoFn0jzzkCZzuntX45u5PS94fayYbicHRjI3OfTAmzrVn41nZjG19KtCk+G0M1MBBn
         sI4MUQC8qEwGGOusX65u6ulVH7oIYlsCZ6U/kYbzJjfAqiWdaSEHHJmSRCIvSX+WMEM2
         j+0ko2ZKdm4hSCMFDLsh2tT6FhTscTID10UVXn73SOgVQR2h1b0lu/Q86wpGuUybFRh3
         U9SWyOwQx5GrJf9WvR5lgyQ144BWgNx6NgwswOwPBpJi5HqUL5pt2F192/I32FTgz4+a
         6j48I9hEkD2U/4z0KpS1wBQh9SQvzUgHpYdnQ3vHIRrXLZQxigvZWADDgEO21Y9QlAG+
         az5A==
X-Gm-Message-State: APjAAAWYuEjKMyOUfHS5+sbv2F/VoSAOnHoiik89MfifuI/lv9ieZQ/N
	4eeSIRtLEk6JP7uhWQUQSiQuvRi/UgMav6CMFJGNlArZEygHIOA9kQHVggvl4E+ET9Ek9Kl9Zju
	eeZ+58fRQWNsRtMrnJURM+2izLFyKkqj8HBoH8qpsLPM/gDV5LXntY4/jAUD3p9XyQA==
X-Received: by 2002:a81:37c6:: with SMTP id e189mr13305986ywa.231.1559956429688;
        Fri, 07 Jun 2019 18:13:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymbGqgFxae6xkBEOW+ER+MrSx0uE1EXHnNoTvZqUH07N94fgrOVB4Zw2GOyZNpi1CO8qfX
X-Received: by 2002:a81:37c6:: with SMTP id e189mr13305950ywa.231.1559956428524;
        Fri, 07 Jun 2019 18:13:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559956428; cv=none;
        d=google.com; s=arc-20160816;
        b=Jd64gudgX8qcjhDZUu2QQb7rJL1O5w5qrvtuce5EOLXEZC5fPXWSWuYIc5no4Xxsmz
         ts0JVbuE88bvm99uUAD92TJMT+hncII8cl/cTx8K16K7pf//dVMlgQcFXl7omjAZND/B
         N6Pqd6vfs7eERQ2lOAnjXMuaoI9WnWotxKX5KF5OIF5zMrySqpdVGy2FWI7h04mvzbhL
         6epI7TJMST3wbEfCZ2klCrlRgKK7smi+iZoG8ysCi3qW+FIIxzF/bfd17daxFH4PVZuj
         9DE1X/R+Qe1z0tHLEV3E2mFvawFQpmDAp8tH0lydjvez8bEFMGfFHjxHNJtBhb9IOtQw
         Sd5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=uiPsFTVMNBBi8QlzP+NhgiuB1J/ANB5gJR02GD6ywIc=;
        b=or17BT/CkD9DOr+JpHrh6SnquGni7DPIC4XXYh9wRgmiQOoLbPoRs+1/u1jz8Rp+S5
         2FKcwi61O9Ixb1DCY+ZKzz472D+LPq8hra9PrEP6RNkKpn4JFZuR7s/fi2rtktsIy2La
         oS62zNst/hAAHg3XJRoJzRrYZKrOvMzeVwRQ8e0gbyrrGl09WmIlfPm1H5AVvjI+WDBj
         cvpKUE2PgpCXSndNxY14X+8Sx/e48K5c8bXckxfpiWtbLrFbSmoxnHwMklFmsuIG6AdI
         sInSScJY42dNCPBH8aDLcqSSOs29mGxBeixmmRMO6960npediilyLETyAxJRXOYcSN82
         aIzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SzYmAOHz;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 16si1101175ybl.0.2019.06.07.18.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 18:13:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SzYmAOHz;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfb0bc90000>; Fri, 07 Jun 2019 18:13:45 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 18:13:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 18:13:47 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 8 Jun
 2019 01:13:46 +0000
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	<Felix.Kuehling@amd.com>, <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
 <9c72d18d-2924-cb90-ea44-7cd4b10b5bc2@nvidia.com>
 <20190607123432.GB14802@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <1b3916b8-fcf0-3a11-1cd8-223fc8e60ac1@nvidia.com>
Date: Fri, 7 Jun 2019 18:13:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190607123432.GB14802@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559956425; bh=uiPsFTVMNBBi8QlzP+NhgiuB1J/ANB5gJR02GD6ywIc=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=SzYmAOHzQcQHZcZQepC2C4sEoMsTl8f1jPKE1PnsyZJ/ap9CeBbaoX8p4Uqwe7fjw
	 iL8f8FtsIZMdEtfURvHBm68zj3tCm+12mMLKimRtnuE4YhAitzFOU5MKDwXRyjCeYO
	 5deRY3zjyiX3Ix5CKxv9aSy7KMe+7ccCCysTafCkZ4U1HBhk4PPIWSgCSrdZB6YXq1
	 IDqqkAglq+MdtTdF0Ow6aPH2DHxVbL8zqacY9v6JH+nR8KPh5yDkgmGKO2SHsst6Cz
	 aVmO18nZ4ypXY18hqKo0R9gDDhJ/FscYVwyWlur4hC5L38VcU2aI3sq/un5/chhvEL
	 vIvvlsKGNdDuQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 5:34 AM, Jason Gunthorpe wrote:
> On Thu, Jun 06, 2019 at 07:29:08PM -0700, John Hubbard wrote:
>> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
>>> From: Jason Gunthorpe <jgg@mellanox.com>
>> ...
>>> diff --git a/mm/hmm.c b/mm/hmm.c
>>> index 8e7403f081f44a..547002f56a163d 100644
>>> +++ b/mm/hmm.c
>> ...
>>> @@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
>>>  		mm->hmm = NULL;
>>>  	spin_unlock(&mm->page_table_lock);
>>>  
>>> -	kfree(hmm);
>>> +	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>>
>>
>> It occurred to me to wonder if it is best to use the MMU notifier's
>> instance of srcu, instead of creating a separate instance for HMM.
> 
> It *has* to be the MMU notifier SRCU because we are synchornizing
> against the read side of that SRU inside the mmu notifier code, ie:
> 
> int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>         id = srcu_read_lock(&srcu);
>         hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
>                 if (mn->ops->invalidate_range_start) {
>                    ^^^^^
> 
> Here 'mn' is really hmm (hmm = container_of(mn, struct hmm,
> mmu_notifier)), so we must protect the memory against free for the mmu
> notifier core.
> 
> Thus we have no choice but to use its SRCU.

Ah right. It's embarassingly obvious when you say it out loud. :) 
Thanks for explaining.

> 
> CH also pointed out a more elegant solution, which is to get the write
> side of the mmap_sem during hmm_mirror_unregister - no notifier
> callback can be running in this case. Then we delete the kref, srcu
> and so forth.
> 
> This is much clearer/saner/better, but.. requries the callers of
> hmm_mirror_unregister to be safe to get the mmap_sem write side.
> 
> I think this is true, so maybe this patch should be switched, what do
> you think?

OK, your follow-up notes that we'll leave it as is, got it.


thanks,
-- 
John Hubbard
NVIDIA

