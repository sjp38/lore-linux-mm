Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5347DC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:21:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E36621850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:21:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E36621850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A00F46B0288; Thu, 28 Mar 2019 17:21:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AFD56B028A; Thu, 28 Mar 2019 17:21:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 877456B028B; Thu, 28 Mar 2019 17:21:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66ABA6B0288
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:21:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g25so14200520qkm.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:21:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=9jZkFNiQttSurNEbrkWU2SNfRubCfXj0hGVydY5gnr4=;
        b=eHA7zWJdK9bjbwz7D5Ezcwp7IXgCfLBQmZHETdGFYCYo6fQXhqZ1VVFOQiia4NCAl3
         gCKGFtpHWVg2w7jYv8GHOKC9tROvrbxx5wRfU704RgFMfF0b/v6a/MOB8bQc/hpg3y1d
         dfE+hucIQOv7pc6zCMU6Z0Fq8ipTl86rwAYVOjVV3Xduara/hzD3fFXVkvrCneV66FeL
         Kq4W47yq9lGwcsOwYgWvgEDpwhwzaXw4vhXAH8450+1msZcfU8d6oyggZlgy/vAbDwUU
         wPIp0Wjzwtx2Jf4cW52cP9jBIuxb0cKMd6ScJPyV6aU5mFDTMw8K5+S3LB4she52aLID
         k2GA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXWRQ6c4bIfCAEG76erCMbviP3xwJ/5pyX4upYPHdGooC4F4bVc
	k5BaYyI4sVvstElsfD5myOJ5zM8dA60pjEnjsGnankOg2K8YJJX8MwzQc1rCJxRFui9Ix7Qr8IJ
	3S5dpkw3HCtWjq2/n9EwcNPkR1m4EDRIGtLXDm5ZHDMTPr8hm39xGzawcSgnZsFVRQw==
X-Received: by 2002:a0c:b8a8:: with SMTP id y40mr31536899qvf.27.1553808111165;
        Thu, 28 Mar 2019 14:21:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqsdywGpC1G4FJZaPQcoHVQcShYiunXa/8Z8oKOnrF7pDErWrNGWPXEkWcL2KBlfolPlwb
X-Received: by 2002:a0c:b8a8:: with SMTP id y40mr31536847qvf.27.1553808110279;
        Thu, 28 Mar 2019 14:21:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553808110; cv=none;
        d=google.com; s=arc-20160816;
        b=n+jtUqnuLyHus3DSBiaT46gqPi3e1XPxcem0a+1Yf6UgFrX7+waP0qCL1MpZfGIEDA
         gXa/9OZu/A469N3kYd4Or11LSWp5NuyIrM+XQ0fXjZDceEy6JJswthCRtqNcjf23kwZ4
         rdE4RwURXeOEjbjC3HNPqxQcMwtrG5ZVKJzh7spdA4Ptj4PBLHS6XmFfMwupZZpRyrSQ
         ruegGqzgx9OvYssQcBRzudBV7SbJtbzC/xDT1QZMPAwn8MlgwmxjCehyJTSV/GrwU7lK
         N0tfddNlPQYwg3TYFoJ8Bw26tAbwihmf9VovefixjMO96It4xF+ugfjFuKMEoei7xytV
         LyMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=9jZkFNiQttSurNEbrkWU2SNfRubCfXj0hGVydY5gnr4=;
        b=tP8JZJp4XFSB4i4LY3y7yt1CRj0iGnV9otqHAICNOf1QHVb8NlWyoNdNQRJLX2aVp+
         ir4ZYTDRANTvVeIDJtZCBFiW5f7JJYaCxS1MQ34hc0wX6uofAscBLyLk4OOx3+ma2xOp
         YdqxyhsSv+W9R8okaEnvBeUMg17EaY1IqfCloEX36w/UGsb1kXJkOV5GPK/vhsb5qyyX
         Y/ExQl/lqYQZLkFlFanX3MPl4o+Fy0UXGFTrMd9yWQCYwl7Nlqud0XHaVBST1WWKZ6jd
         KWNI9fJunh8y1315zRfuVYakoWvF41jKJ/ziM0KtdqqvniKvOK0pt54UVScJhJdzxnSo
         wN9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si64018qtb.285.2019.03.28.14.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:21:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6F9B58046F;
	Thu, 28 Mar 2019 21:21:49 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 518825C226;
	Thu, 28 Mar 2019 21:21:48 +0000 (UTC)
Date: Thu, 28 Mar 2019 17:21:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190328212145.GA13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 28 Mar 2019 21:21:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 01:43:13PM -0700, John Hubbard wrote:
> On 3/28/19 12:11 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
> >> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
> >>> From: Jérôme Glisse <jglisse@redhat.com>
> >>>
> >>> Every time i read the code to check that the HMM structure does not
> >>> vanish before it should thanks to the many lock protecting its removal
> >>> i get a headache. Switch to reference counting instead it is much
> >>> easier to follow and harder to break. This also remove some code that
> >>> is no longer needed with refcounting.
> >>>
> >>> Changes since v1:
> >>>     - removed bunch of useless check (if API is use with bogus argument
> >>>       better to fail loudly so user fix their code)
> >>>     - s/hmm_get/mm_get_hmm/
> >>>
> >>> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> >>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> >>> Cc: John Hubbard <jhubbard@nvidia.com>
> >>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>> ---
> >>>  include/linux/hmm.h |   2 +
> >>>  mm/hmm.c            | 170 ++++++++++++++++++++++++++++----------------
> >>>  2 files changed, 112 insertions(+), 60 deletions(-)
> >>>
> >>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> >>> index ad50b7b4f141..716fc61fa6d4 100644
> >>> --- a/include/linux/hmm.h
> >>> +++ b/include/linux/hmm.h
> >>> @@ -131,6 +131,7 @@ enum hmm_pfn_value_e {
> >>>  /*
> >>>   * struct hmm_range - track invalidation lock on virtual address range
> >>>   *
> >>> + * @hmm: the core HMM structure this range is active against
> >>>   * @vma: the vm area struct for the range
> >>>   * @list: all range lock are on a list
> >>>   * @start: range virtual start address (inclusive)
> >>> @@ -142,6 +143,7 @@ enum hmm_pfn_value_e {
> >>>   * @valid: pfns array did not change since it has been fill by an HMM function
> >>>   */
> >>>  struct hmm_range {
> >>> +	struct hmm		*hmm;
> >>>  	struct vm_area_struct	*vma;
> >>>  	struct list_head	list;
> >>>  	unsigned long		start;
> >>> diff --git a/mm/hmm.c b/mm/hmm.c
> >>> index fe1cd87e49ac..306e57f7cded 100644
> >>> --- a/mm/hmm.c
> >>> +++ b/mm/hmm.c
> >>> @@ -50,6 +50,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
> >>>   */
> >>>  struct hmm {
> >>>  	struct mm_struct	*mm;
> >>> +	struct kref		kref;
> >>>  	spinlock_t		lock;
> >>>  	struct list_head	ranges;
> >>>  	struct list_head	mirrors;
> >>> @@ -57,6 +58,16 @@ struct hmm {
> >>>  	struct rw_semaphore	mirrors_sem;
> >>>  };
> >>>  
> >>> +static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> >>> +{
> >>> +	struct hmm *hmm = READ_ONCE(mm->hmm);
> >>> +
> >>> +	if (hmm && kref_get_unless_zero(&hmm->kref))
> >>> +		return hmm;
> >>> +
> >>> +	return NULL;
> >>> +}
> >>> +
> >>>  /*
> >>>   * hmm_register - register HMM against an mm (HMM internal)
> >>>   *
> >>> @@ -67,14 +78,9 @@ struct hmm {
> >>>   */
> >>>  static struct hmm *hmm_register(struct mm_struct *mm)
> >>>  {
> >>> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> >>> +	struct hmm *hmm = mm_get_hmm(mm);
> >>
> >> FWIW: having hmm_register == "hmm get" is a bit confusing...
> > 
> > The thing is that you want only one hmm struct per process and thus
> > if there is already one and it is not being destroy then you want to
> > reuse it.
> > 
> > Also this is all internal to HMM code and so it should not confuse
> > anyone.
> > 
> 
> Well, it has repeatedly come up, and I'd claim that it is quite 
> counter-intuitive. So if there is an easy way to make this internal 
> HMM code clearer or better named, I would really love that to happen.
> 
> And we shouldn't ever dismiss feedback based on "this is just internal
> xxx subsystem code, no need for it to be as clear as other parts of the
> kernel", right?

Yes but i have not seen any better alternative that present code. If
there is please submit patch.

Cheers,
Jérôme

