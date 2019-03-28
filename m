Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D855DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:11:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9902720811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 19:11:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9902720811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AD1C6B0271; Thu, 28 Mar 2019 15:11:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35D0B6B0272; Thu, 28 Mar 2019 15:11:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 225F36B0273; Thu, 28 Mar 2019 15:11:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F366E6B0271
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:11:26 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n13so21227268qtn.6
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:11:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hM0v6Z9vU97QJB0zhiOeTElSQxAdDvJbsTGJn9ulqzI=;
        b=IcqK2u8CS3ogi6hyOuc8PS11up+zGIhKd4mGcpha44NOT59mjHmnrbdLDbDd+h8vbL
         V102pkZ1S87Nn9rq8Ck2hS324mSqtsxQkj2fZqftRrD8q47MhCxmwSHfbgshBWYZiXSY
         tetymETjE4i/3i+ehiuB2Awlnn6LuJvCAUsftYzPI1XbyXAx7UzW5kxeFREuA9KQOj5j
         RzH/y0xNJO7oQeNzGVxG4jyJ07/NnrkwB8ZO7XN57lX1K1GQp8FZn0MheDtn1VZi5CPl
         NNlPg2VurSOYUZBQ4OLx7LWHzDm06Es3isR9+0TNM2VsgFZcjmM4IlUXW47xC+2aPnSJ
         IuOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvIdnCsP9nU8yz9ROkxKsUpNqt2XKkxzVNElRZTTPBJqYoqtrp
	Z/iMBKX7+RpT/yJnaJTaB1YQCFakVTObgKut6jRRsRXX9HJU/TKhUq5rGdo5viuUKWB1UBZ/SAI
	dpi6F2eMXphfsNy1eo8vrBWndScqhfE+z+ovx5jyvUAuBhyZU4oHlgkfgQIJAw9tECg==
X-Received: by 2002:a37:5905:: with SMTP id n5mr12803247qkb.181.1553800286726;
        Thu, 28 Mar 2019 12:11:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8gQ42YSge2JlU1+PZ/hEv8IJfXTX4pnYH256vNCgoq2Lm05dni8BFPzGPVBNoYoAa7/AU
X-Received: by 2002:a37:5905:: with SMTP id n5mr12803200qkb.181.1553800286068;
        Thu, 28 Mar 2019 12:11:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553800286; cv=none;
        d=google.com; s=arc-20160816;
        b=Em48bsqQ1iJjzgCw6PEwp4ycD5RLO2f52S+sOeLXLKk4eP467UWX9Z+n5/qbEyX1JN
         w1SZgM6TRyBba41Vs3lOmOwBX48Pj4eH5a+R6i5TCI1lSeZJbiWDa2jf4vDHlCzYCl+h
         lpgGcBDAkfVkL7SGrZTrtVU3lHy12HLksRVpzr6gBaHzjSY61SOu5qgDOcWXsqbIzYkH
         KgLFHeG2ut7KEfvXAT/e1B5m5PnSZoRFjY4GaJ0wpdlbJ7sBf8AVC2V0fTu6w8AG13hY
         B6E9e1Sl1Uhw6zZJ0O9UnLqMHRoRXB4QCq//OPvGojJb9BnSVrU9FdPHf1kYCJ8Pn+MW
         0XWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hM0v6Z9vU97QJB0zhiOeTElSQxAdDvJbsTGJn9ulqzI=;
        b=s4wosVYCHUmesK7CQR2zGSNCoss/59GcqNo8xHFL5oy9/yfnlKMRdYD2F8QEBa0ib2
         WoqB+ZKD2j9A1SCDzq+nTcnl3SBa5S9VZB+o9hQHTCDb2yOAFRLJfljCmU+GJ+aUppbx
         trf9IvLYLpVNsGNZFeVwAGlHcHgB54QZxZUgjctUIBcH2aCpUrdJrk344vOhwtela9Gy
         MAbxHmL8b16oClcT6eBtPfqUlrCZq3h8NlwexqXqVHlNU2IMP7YuHHXOs6VhCZJbe6Uo
         ceDEpUK29P1IGyCi4ocDfNta+yCBeX/Icl4fE7/120wJaBRyF/+2eVha64S3bSlMdqcx
         JuNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u17si1695982qvm.77.2019.03.28.12.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 12:11:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16B1C59445;
	Thu, 28 Mar 2019 19:11:25 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 62AAE1DB;
	Thu, 28 Mar 2019 19:11:24 +0000 (UTC)
Date: Thu, 28 Mar 2019 15:11:22 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190328191122.GA5740@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 28 Mar 2019 19:11:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > Every time i read the code to check that the HMM structure does not
> > vanish before it should thanks to the many lock protecting its removal
> > i get a headache. Switch to reference counting instead it is much
> > easier to follow and harder to break. This also remove some code that
> > is no longer needed with refcounting.
> > 
> > Changes since v1:
> >     - removed bunch of useless check (if API is use with bogus argument
> >       better to fail loudly so user fix their code)
> >     - s/hmm_get/mm_get_hmm/
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/hmm.h |   2 +
> >  mm/hmm.c            | 170 ++++++++++++++++++++++++++++----------------
> >  2 files changed, 112 insertions(+), 60 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index ad50b7b4f141..716fc61fa6d4 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -131,6 +131,7 @@ enum hmm_pfn_value_e {
> >  /*
> >   * struct hmm_range - track invalidation lock on virtual address range
> >   *
> > + * @hmm: the core HMM structure this range is active against
> >   * @vma: the vm area struct for the range
> >   * @list: all range lock are on a list
> >   * @start: range virtual start address (inclusive)
> > @@ -142,6 +143,7 @@ enum hmm_pfn_value_e {
> >   * @valid: pfns array did not change since it has been fill by an HMM function
> >   */
> >  struct hmm_range {
> > +	struct hmm		*hmm;
> >  	struct vm_area_struct	*vma;
> >  	struct list_head	list;
> >  	unsigned long		start;
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index fe1cd87e49ac..306e57f7cded 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -50,6 +50,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
> >   */
> >  struct hmm {
> >  	struct mm_struct	*mm;
> > +	struct kref		kref;
> >  	spinlock_t		lock;
> >  	struct list_head	ranges;
> >  	struct list_head	mirrors;
> > @@ -57,6 +58,16 @@ struct hmm {
> >  	struct rw_semaphore	mirrors_sem;
> >  };
> >  
> > +static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> > +{
> > +	struct hmm *hmm = READ_ONCE(mm->hmm);
> > +
> > +	if (hmm && kref_get_unless_zero(&hmm->kref))
> > +		return hmm;
> > +
> > +	return NULL;
> > +}
> > +
> >  /*
> >   * hmm_register - register HMM against an mm (HMM internal)
> >   *
> > @@ -67,14 +78,9 @@ struct hmm {
> >   */
> >  static struct hmm *hmm_register(struct mm_struct *mm)
> >  {
> > -	struct hmm *hmm = READ_ONCE(mm->hmm);
> > +	struct hmm *hmm = mm_get_hmm(mm);
> 
> FWIW: having hmm_register == "hmm get" is a bit confusing...

The thing is that you want only one hmm struct per process and thus
if there is already one and it is not being destroy then you want to
reuse it.

Also this is all internal to HMM code and so it should not confuse
anyone.

Cheers,
Jérôme

