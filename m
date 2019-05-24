Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23E02C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D40792175B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:06:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jW1eyNNh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D40792175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84BD16B0271; Fri, 24 May 2019 13:06:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC486B0272; Fri, 24 May 2019 13:06:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C2C46B0273; Fri, 24 May 2019 13:06:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45DC56B0271
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:06:05 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id f138so8830837yba.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:06:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=XJk0dysE9wgKukvEat4C65gaJreFRWBYLCTM0Lx3FyI=;
        b=Y9+EE8K5C5xtjLdDC6XHqaND+hjjtCjOP+BG6NYC8g+oiNiwo2+YrefE3L5m9BANC+
         nwMMtpghFtcz6GYljw7SPVDPFFNNDo6vN3RYzEbKQtaV650y7w/eKoo68GvKzp77t2VT
         oEBm4E7FEl4ArRtJ+JEWUOJIH7vF6rASGr67sv8N75Qlh8b9e4K/eKH9i6sTAJMBXq6C
         whSAFbL10UAIry5T8a3FZHjdbbKBXjl9IFaZdenHs4lTTDHslkD8tsx3HV/rsxYwZkKT
         6oUHWUYCi2A4Hp4zWYbvTs15rOOWjoLENVqmM97PfN/PPJ8dkxZNcDU5ClumVDOHX2zL
         CGsw==
X-Gm-Message-State: APjAAAXYdm/iekxkdWiLvW/KNCnSAJbqagjaQd0ao4G2/hzgOl4E0iPo
	VbkOtTy3tScs6ARArQB4q+6QiKO5WUa804F3ueW34mhen9xnv6dszuY5+myo3/dJ8nn5KxCeKlM
	6+EskybNZYwefZguDZxhx2SjvDJuDXIo+iaRcJ4Ycf+4oMpMoPd1849m95yym85vqmw==
X-Received: by 2002:a25:be82:: with SMTP id i2mr46422822ybk.449.1558717564873;
        Fri, 24 May 2019 10:06:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySU+Hwyx/sEs15WH8FBdRVLDlYgp7IGDAtkg2X2k6DapQxersjXZDDlHyfI6KHx/6/iFBp
X-Received: by 2002:a25:be82:: with SMTP id i2mr46422762ybk.449.1558717564036;
        Fri, 24 May 2019 10:06:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558717564; cv=none;
        d=google.com; s=arc-20160816;
        b=i8vWxMSDKgrs+pFb8hzOWGVGa1XHHDsTaw79EAbQE4Z1AdA4rgXXHgUbeinUQqh0tU
         alZUjk9G9LX6vdPEpiQnbP6kvx3wZ2PU0CP44KEm2y5HmThM90J6m6uLGhFTTqnkWDW8
         tYqOnSbf9gI9TKcmdXrR/u64QlsGW5fg2LnG818EbCyGLJ/ITASGg2dlZsjUGXSTKDgr
         Mwt5QtYotGeG9VyxX2o9ZWy2Mg8mIosAMZ6tCp+9M2FtHsk3LQYbJ7JPsU7fEeB4uD2c
         vQffC/ckpjqKj5U57IGmDDepv/1HRt7TKsqi3ZLfybQozmBm5rUROE7DMK+5PsKvyd6c
         TQDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=XJk0dysE9wgKukvEat4C65gaJreFRWBYLCTM0Lx3FyI=;
        b=OPHmHwtRQ5qW85fYAktZ9GDyKOukXVJXMi4d/iiX+nOgpX/L0uWhzV2/jLTlFqIlCw
         dY+uVquAyugs6d9tfV4kiuhRW5hNrQVGURgqu/tFwPP9gQoRE2l47wPe6eMOjBUhrPrr
         4sbhdexZbeAif1+kSEuPSoVbo6nAm3cWNSRAcLU/3UENIUr1RN/OTiPnTd2b9nUAaG0K
         88Fv7AgEw5FN8myAozfTlBSMmPcKYLaa6u4vieViEluSFTQ2LIFGWjxOODnXyaQ0PdnN
         IzHHuYVjvFDbdzla4tAkCDBy8x011Z86QEe3vNttPVTdJng1owmPLhvIfcUxIeJ6I33J
         Hd/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jW1eyNNh;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id d64si930511ywa.459.2019.05.24.10.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 10:06:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jW1eyNNh;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce8247b0000>; Fri, 24 May 2019 10:06:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 24 May 2019 10:06:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 24 May 2019 10:06:02 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 24 May
 2019 17:06:02 +0000
Subject: Re: [RFC PATCH 04/11] mm/hmm: Simplify hmm_get_or_create and make it
 reliable
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Jerome Glisse
	<jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-5-jgg@ziepe.ca>
 <6945b6c9-338a-54e6-64df-2590d536910a@nvidia.com>
 <20190524012320.GA13614@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <2ce70e06-2c7c-db46-821c-bdf06825dc1d@nvidia.com>
Date: Fri, 24 May 2019 10:06:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190524012320.GA13614@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558717563; bh=XJk0dysE9wgKukvEat4C65gaJreFRWBYLCTM0Lx3FyI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=jW1eyNNhPjtEAO6FWqVl8EAxx2JBeH4GcdO9kGju1s7tCZab/gJgGjwLYDJ98lkXP
	 ksbObcsBdBy2SwkSl5hWajrj2gDQWp2/ZHigUmAZB9FPqZ5qwBeXFMA0Xo6oeVfsgw
	 KrkWYEzJrz/qFFNhYSxEU9ACDUFkF1VbeYWyUCMdnUioiLSTCdza46gjeit/WFII6M
	 vPcYBjaJY2codolpEZVWGWIz9lCsoYe2oAjoUmVpvFZMiksbBb+3Wes7dhaMbKrhuX
	 vNxUXTuonPjZqkVuBftnIHWggJ2lBKOZhHUAXIaZD0JrZuE2gCIANrXlnJCHNSZHxQ
	 gVDAQIRhFyd3g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/23/19 6:23 PM, Jason Gunthorpe wrote:
> On Thu, May 23, 2019 at 04:38:28PM -0700, Ralph Campbell wrote:
>>
>> On 5/23/19 8:34 AM, Jason Gunthorpe wrote:
>>> From: Jason Gunthorpe <jgg@mellanox.com>
>>>
>>> As coded this function can false-fail in various racy situations. Make it
>>> reliable by running only under the write side of the mmap_sem and avoiding
>>> the false-failing compare/exchange pattern.
>>>
>>> Also make the locking very easy to understand by only ever reading or
>>> writing mm->hmm while holding the write side of the mmap_sem.
>>>
>>> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>>>    mm/hmm.c | 75 ++++++++++++++++++++------------------------------------
>>>    1 file changed, 27 insertions(+), 48 deletions(-)
>>>
>>> diff --git a/mm/hmm.c b/mm/hmm.c
>>> index e27058e92508b9..ec54be54d81135 100644
>>> +++ b/mm/hmm.c
>>> @@ -40,16 +40,6 @@
>>>    #if IS_ENABLED(CONFIG_HMM_MIRROR)
>>>    static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>>> -static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>>> -{
>>> -	struct hmm *hmm = READ_ONCE(mm->hmm);
>>> -
>>> -	if (hmm && kref_get_unless_zero(&hmm->kref))
>>> -		return hmm;
>>> -
>>> -	return NULL;
>>> -}
>>> -
>>>    /**
>>>     * hmm_get_or_create - register HMM against an mm (HMM internal)
>>>     *
>>> @@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>>>     */
>>>    static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>>>    {
>>> -	struct hmm *hmm = mm_get_hmm(mm);
>>> -	bool cleanup = false;
>>> +	struct hmm *hmm;
>>> -	if (hmm)
>>> -		return hmm;
>>> +	lockdep_assert_held_exclusive(mm->mmap_sem);
>>> +
>>> +	if (mm->hmm) {
>>> +		if (kref_get_unless_zero(&mm->hmm->kref))
>>> +			return mm->hmm;
>>> +		/*
>>> +		 * The hmm is being freed by some other CPU and is pending a
>>> +		 * RCU grace period, but this CPU can NULL now it since we
>>> +		 * have the mmap_sem.
>>> +		 */
>>> +		mm->hmm = NULL;
>>
>> Shouldn't there be a "return NULL;" here so it doesn't fall through and
>> allocate a struct hmm below?
> 
> No, this function should only return NULL on memory allocation
> failure.
> 
> In this case another thread is busy freeing the hmm but wasn't able to
> update mm->hmm to null due to a locking constraint. So we make it null
> on behalf of the other thread and allocate a fresh new hmm that is
> valid. The freeing thread will complete the free and do nothing with
> mm->hmm.
> 
>>>    static void hmm_fee_rcu(struct rcu_head *rcu)
>>
>> I see Jerome already saw and named this hmm_free_rcu()
>> which I agree with.
> 
> I do love my typos :)
> 
>>>    {
>>> +	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
>>> +
>>> +	down_write(&hmm->mm->mmap_sem);
>>> +	if (hmm->mm->hmm == hmm)
>>> +		hmm->mm->hmm = NULL;
>>> +	up_write(&hmm->mm->mmap_sem);
>>> +	mmdrop(hmm->mm);
>>> +
>>>    	kfree(container_of(rcu, struct hmm, rcu));
>>>    }
>>>    static void hmm_free(struct kref *kref)
>>>    {
>>>    	struct hmm *hmm = container_of(kref, struct hmm, kref);
>>> -	struct mm_struct *mm = hmm->mm;
>>> -
>>> -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
>>> -	spin_lock(&mm->page_table_lock);
>>> -	if (mm->hmm == hmm)
>>> -		mm->hmm = NULL;
>>> -	spin_unlock(&mm->page_table_lock);
>>> -
>>> -	mmdrop(hmm->mm);
>>> +	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
>>>    	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
>>>    }
>>>
>>
>> This email message is for the sole use of the intended recipient(s) and may contain
>> confidential information.  Any unauthorized review, use, disclosure or distribution
>> is prohibited.  If you are not the intended recipient, please contact the sender by
>> reply email and destroy all copies of the original message.
> 
> Ah, you should not send this trailer to the public mailing lists.
> 
> Thanks,
> Jason
> 

Sorry, I have to apply the "magic" header to suppress this each time I
send email to a public list.

