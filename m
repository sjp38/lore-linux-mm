Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5676C10F07
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:37:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9330E218FD
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:37:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9330E218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FE3C8E0050; Wed, 20 Feb 2019 19:37:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD268E0002; Wed, 20 Feb 2019 19:37:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29C838E0050; Wed, 20 Feb 2019 19:37:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 001AF8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:37:20 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 203so4020722qke.7
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:37:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2nBa+AB4OA1YDWlxbAuOxWE0aW8AnM+NeozjOtk/gzM=;
        b=U/ozu/ZKTyqRtBENGBN24ToCEdEmKsB2Cl3Jw8rZqeWHcr3JO5CoScWoWI88NnC+5p
         z6ZUDuy3btCGJ+e6dDHHbg2P3yjMNZ1FUdfD2+NUkc/uuM7BcAQNUD00/+y8tsJ8JmAJ
         kbv+6zqR422sTMGg5nSYIr5nqDtLRx1FZ4mzPZrmyp8w/YN6sGRHSV+lIFEmAGjRHm4m
         7gfyAuyenXv01JZ2bkOROe8+Hb+ydpPQnlkMKdorx7RwdY6iZoEHCL/r6D6tKMk6MnMn
         LJlBR17EuFkFTqOBwkHvUEN6PHSeFV6TGOu/5znEW8iCGgtCLyXVDvgMYjr5EoPu+5gF
         2dkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZu16GHfcQNuEeMvlQqcDGoGaaAF7YYpJdYmI/8YEJ2yGSM7jyh
	Y24y4Wy5zqEz8dswPYiopKeFp9OqbdNrVNP0uuH/kge8rrlezkoe9c9KzOZtU4Shrii1XgMZL7x
	hUfnJBKQWbN42h2BbaJbabfhmsIih2Zi8NhITVw07zXXt/sdrLdcGUkZmuUhpEdgdEQ==
X-Received: by 2002:a37:a0a:: with SMTP id 10mr21929749qkk.214.1550709440707;
        Wed, 20 Feb 2019 16:37:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYYtbs0sI1NOgIfy/xvT1wo4QjSIB0D4WR3tm2Wm4cU69limez0ek/uVT/yKIiNy5uT6EAi
X-Received: by 2002:a37:a0a:: with SMTP id 10mr21929722qkk.214.1550709440090;
        Wed, 20 Feb 2019 16:37:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550709440; cv=none;
        d=google.com; s=arc-20160816;
        b=vIZhBXcxVCiQ1CtWiR5H2NPGuv44sSYNRVuDkIcDy5n0dZUKki5D7U6XqI40bgYXfP
         LiQVJck9/PBd0xSBx/ByQGIOK/oQWt8ZKraE5qVStKsRIBtUnivfNCpFnL6nWmjEDoL0
         koG5UcxfLYuKYl1apYicvPVLsbjP8nampGvvGo0D4HO2L7PznxXxwuc/sKR63Lz9di8P
         3d0wYVagebq6dm5Gv+7sj6WAaV3WImGXhurlKzQcDkInCmJdSSPV9/vbvtVzrSq2ByBM
         SH+ogCok3fZONvvDKL5tSsrKBrPcNqJUhO4i1qeRuykxA7iLYi+N1Wg+xztkeKxuOEsS
         kA2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=2nBa+AB4OA1YDWlxbAuOxWE0aW8AnM+NeozjOtk/gzM=;
        b=NTrb+OAX1iFkrZ8zN3xkbwPDdLVq3lu5mVjxbcR9Mezrt2Rfy9ae/Yny0y14NQXCj1
         YzVCT/hOFskdfB+Ik7iw52bqUeKczZKPnDt8Of5DZsyQK6wSBeyE5hfArpKT6oHLKnuU
         ma0x8lYtDdxWsjYDd3x8bJFNw9RG1Eiph2fjAh1+zxGGGnjc0trYKOqlB4n1aQ/MZ07N
         pAzZ9BDcVsPT1xOdVnTdkqFFedgt3uidV6qNk5YeNKRUbxEP4IKJPDe0skdKmAt5Nbg2
         m3WAEk7m7OWBP//ilLHSyyXfHsjMLHYlIVQK/ccW4EtY/HoT4jgVy5NVE8xYDKVMH68R
         eq7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s30si8956872qtb.350.2019.02.20.16.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 16:37:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 47795307D90D;
	Thu, 21 Feb 2019 00:37:19 +0000 (UTC)
Received: from redhat.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6B08C19C58;
	Thu, 21 Feb 2019 00:37:18 +0000 (UTC)
Date: Wed, 20 Feb 2019 19:37:16 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/10] mm/hmm: use reference counting for HMM struct
Message-ID: <20190221003716.GD24489@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-2-jglisse@redhat.com>
 <1373673d-721e-a7a2-166f-244c16f236a3@nvidia.com>
 <20190220235933.GD11325@redhat.com>
 <dd448c6f-5ed7-ceb4-ca5e-c7650473a47c@nvidia.com>
 <20190221001557.GA24489@redhat.com>
 <58ab7c36-36dd-700a-6a66-8c9abbf4076a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <58ab7c36-36dd-700a-6a66-8c9abbf4076a@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 21 Feb 2019 00:37:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 04:32:09PM -0800, John Hubbard wrote:
> On 2/20/19 4:15 PM, Jerome Glisse wrote:
> > On Wed, Feb 20, 2019 at 04:06:50PM -0800, John Hubbard wrote:
> > > On 2/20/19 3:59 PM, Jerome Glisse wrote:
> > > > On Wed, Feb 20, 2019 at 03:47:50PM -0800, John Hubbard wrote:
> > > > > On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > > > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > > > 
> > > > > > Every time i read the code to check that the HMM structure does not
> > > > > > vanish before it should thanks to the many lock protecting its removal
> > > > > > i get a headache. Switch to reference counting instead it is much
> > > > > > easier to follow and harder to break. This also remove some code that
> > > > > > is no longer needed with refcounting.
> > > > > 
> > > > > Hi Jerome,
> > > > > 
> > > > > That is an excellent idea. Some review comments below:
> > > > > 
> > > > > [snip]
> > > > > 
> > > > > >     static int hmm_invalidate_range_start(struct mmu_notifier *mn,
> > > > > >     			const struct mmu_notifier_range *range)
> > > > > >     {
> > > > > >     	struct hmm_update update;
> > > > > > -	struct hmm *hmm = range->mm->hmm;
> > > > > > +	struct hmm *hmm = hmm_get(range->mm);
> > > > > > +	int ret;
> > > > > >     	VM_BUG_ON(!hmm);
> > > > > > +	/* Check if hmm_mm_destroy() was call. */
> > > > > > +	if (hmm->mm == NULL)
> > > > > > +		return 0;
> > > > > 
> > > > > Let's delete that NULL check. It can't provide true protection. If there
> > > > > is a way for that to race, we need to take another look at refcounting.
> > > > 
> > > > I will do a patch to delete the NULL check so that it is easier for
> > > > Andrew. No need to respin.
> > > 
> > > (Did you miss my request to make hmm_get/hmm_put symmetric, though?)
> > 
> > Went over my mail i do not see anything about symmetric, what do you
> > mean ?
> > 
> > Cheers,
> > Jérôme
> 
> I meant the comment that I accidentally deleted, before sending the email!
> doh. Sorry about that. :) Here is the recreated comment:
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index a04e4b810610..b9f384ea15e9 100644
> 
> --- a/mm/hmm.c
> 
> +++ b/mm/hmm.c
> 
> @@ -50,6 +50,7 @@
> 
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
> 
>   */
>  struct hmm {
>  	struct mm_struct	*mm;
> +	struct kref		kref;
>  	spinlock_t		lock;
>  	struct list_head	ranges;
>  	struct list_head	mirrors;
> 
> @@ -57,6 +58,16 @@
> 
>  struct hmm {
> 
>  	struct rw_semaphore	mirrors_sem;
>  };
> 
> +static inline struct hmm *hmm_get(struct mm_struct *mm)
> +{
> +	struct hmm *hmm = READ_ONCE(mm->hmm);
> +
> +	if (hmm && kref_get_unless_zero(&hmm->kref))
> +		return hmm;
> +
> +	return NULL;
> +}
> +
> 
> So for this, hmm_get() really ought to be symmetric with
> hmm_put(), by taking a struct hmm*. And the null check is
> not helping here, so let's just go with this smaller version:
> 
> static inline struct hmm *hmm_get(struct hmm *hmm)
> {
> 	if (kref_get_unless_zero(&hmm->kref))
> 		return hmm;
> 
> 	return NULL;
> }
> 
> ...and change the few callers accordingly.
> 

What about renaning hmm_get() to mm_get_hmm() instead ?

Cheers,
Jérôme

