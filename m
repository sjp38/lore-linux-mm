Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84382C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:35:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45AB6217F9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 13:35:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kT6wAqKt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45AB6217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D08BD6B0003; Fri, 24 May 2019 09:35:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C92476B0005; Fri, 24 May 2019 09:35:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B32D36B0006; Fri, 24 May 2019 09:35:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5766B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 09:35:39 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id o62so6991964qkb.4
        for <linux-mm@kvack.org>; Fri, 24 May 2019 06:35:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=IcqaDeuGJCGa5ZggdGNAYSqFQEnHs8MfUQiHhXABBMk=;
        b=ABmbnGgf/clmXeOpYP4iRXguVHdy9zhD4kd0TPaISVQI1QGyFkGVZlGvnT36CVU0W1
         6AzjeJ+DnNpQOQZ00auqyHkB9jklqbXilxYx+CIDOHR9jN+2KxUryWTBRP+yNQLSQVte
         kgNYEz781R2Mro6uDUfV8vK30IL40mssLKxaY0iMYvBzaYwp8C6hvmocjIqSEjHphYuc
         iUHzY7TgLhM3aRfSAzm0WDJWDxptfkx/XQlYzBAXvs2VapVKU7y8ydaa01YF+lJiiG5d
         UOBPEfCRRGd5Qe4GSSI/rzJiGFAZNu2QoJL6uqEnSmlVDBFbrHNYDup2/SkmHda2ZZhR
         /eLQ==
X-Gm-Message-State: APjAAAUBODJs3TTAYqFzE3z8vlR8Jbd3OcMBfOODgXsh93VKDWd0Ho5w
	Apz3K2T4UdpmofBgMRqNgFuBz5Vvk9qxlUL7EKKD8P7zNA2bISavFxvxK3Bc1XW04Vh3f1xHLlf
	7rd97IQV9JTzinBjNDxz6lwrDMPj1SFJ/bPXM+IPP1+C5gAIO0jnYa/M2nksIp9WEdg==
X-Received: by 2002:ac8:1ad3:: with SMTP id h19mr74089348qtk.47.1558704939167;
        Fri, 24 May 2019 06:35:39 -0700 (PDT)
X-Received: by 2002:ac8:1ad3:: with SMTP id h19mr74089281qtk.47.1558704938275;
        Fri, 24 May 2019 06:35:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558704938; cv=none;
        d=google.com; s=arc-20160816;
        b=S6ULRZzc7ijwuZ5PO1UFfEwjUjq3kAPw3lYx9DwDAVilQ/zVatnJqlsiXT3u/y/8U5
         zz6/ZoNe3UNhDGRLUFnbLN5nvSNX8gw9QN/G4fx5/hM4MeMd1K6xebEgdz2isAOAJVMB
         MkEs2Mf9nMbZYBNZbVCwla3pGva3mSWsqZH1kAUcjPxCtFZKIxghNCzoftItufmKf8O7
         ZjjGWEdC1T+5LK0+I8T/t+sIptK8YER9/dbQfVBnxawthQyHw6jJE2qVJRJb1J/rDF0T
         3I1U2hnWNuGOT9lrO/ul9+Ih1XBkbTNC/mAr43jRTaH/wPLqZiXw+nnAs6g5og3VMc8i
         ZOuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=IcqaDeuGJCGa5ZggdGNAYSqFQEnHs8MfUQiHhXABBMk=;
        b=eWY58kgnj8VRpperpfMtE/+tGtHkH8VDLVCwPSxAoqF/dn1STVebUohPPt0UcuC9WX
         lsIfQkw+Ljw7wVTBWwZi6NJbZHY8xtp6yvbfAMsa19aSePl8rV+D675PFklYT6l+rEBc
         Y+NUq6N4zlBzua0FTBQdW6+7h6d91YKpx+C1wKtfK2KzIE/mJKOroWq0lPF9YNv+UtQQ
         pjcpxiBfLdEflt028AW7GYfN21i2k7c8hyEtGQ+rTRS1aDJahHpExolBZi9GA9uHdosa
         /vdKOcI9lVEM1bXOf3z6eo2CPlBETL7WZVAY7ukcUS4xLz7A5a1AnSwFYw86HCVkGeWG
         fTXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kT6wAqKt;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l10sor1272934uap.10.2019.05.24.06.35.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 06:35:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kT6wAqKt;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IcqaDeuGJCGa5ZggdGNAYSqFQEnHs8MfUQiHhXABBMk=;
        b=kT6wAqKtAnkGgx9v0S5iMBX5PaiLPotndmiXT1nSNY9JkqPTYWp7A/iyFvybPJh8lp
         6fvGORU6bU9+iKBWjnR/LQcEwu5lBvNu68V94RAb+y6RZW0AwsiOBgIQheR6rtQ4Zd2g
         gR7y0LwWGp1cKWn2n1rsa1Na1N0NqaV89eAZsDyNbrQZb0CxTA4vDx/LWbDVG+DIgvbk
         8E8kuzBfWLz9C7iv2GILGg8qdGMBNgctKYWpscbJ2irgE9XMPm0RJmzA/3hJZ2JRF3vs
         D5OWvsg6hDAq43E7IKvTVtxBBLIx5E4CyvDBEHD4hHqJooOC7TmKHVlHhgNUsGi+XxMP
         3Pkw==
X-Google-Smtp-Source: APXvYqwS/i6+HbsdCX5+s2T6q31qtlvAXYqPjnfVPNdoqlWYS5H7qKCjFxh3N6+BqekbFs052a88ew==
X-Received: by 2002:ab0:688b:: with SMTP id t11mr15080209uar.70.1558704937753;
        Fri, 24 May 2019 06:35:37 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id a123sm1060434vka.22.2019.05.24.06.35.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 06:35:37 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUAMC-0003DA-Dx; Fri, 24 May 2019 10:35:36 -0300
Date: Fri, 24 May 2019 10:35:36 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524133536.GA12259@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This patch series arised out of discussions with Jerome when looking at the
> ODP changes, particularly informed by use after free races we have already
> found and fixed in the ODP code (thanks to syzkaller) working with mmu
> notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> 
> Overall this brings in a simplified locking scheme and easy to explain
> lifetime model:
> 
>  If a hmm_range is valid, then the hmm is valid, if a hmm is valid then the mm
>  is allocated memory.
> 
>  If the mm needs to still be alive (ie to lock the mmap_sem, find a vma, etc)
>  then the mmget must be obtained via mmget_not_zero().
> 
> Locking of mm->hmm is shifted to use the mmap_sem consistently for all
> read/write and unlocked accesses are removed.
> 
> The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
> standard mmget() locking to prevent the mm from being released. Many of the
> debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
> which is much clearer as to the lifetime intent.
> 
> The trailing patches are just some random cleanups I noticed when reviewing
> this code.
> 
> I expect Jerome & Ralph will have some design notes so this is just RFC, and
> it still needs a matching edit to nouveau. It is only compile tested.
> 
> Regards,
> Jason
> 
> Jason Gunthorpe (11):
>   mm/hmm: Fix use after free with struct hmm in the mmu notifiers
>   mm/hmm: Use hmm_mirror not mm as an argument for hmm_register_range
>   mm/hmm: Hold a mmgrab from hmm to mm
>   mm/hmm: Simplify hmm_get_or_create and make it reliable
>   mm/hmm: Improve locking around hmm->dead
>   mm/hmm: Remove duplicate condition test before wait_event_timeout
>   mm/hmm: Delete hmm_mirror_mm_is_alive()
>   mm/hmm: Use lockdep instead of comments
>   mm/hmm: Remove racy protection against double-unregistration
>   mm/hmm: Poison hmm_range during unregister
>   mm/hmm: Do not use list*_rcu() for hmm->ranges
> 
>  include/linux/hmm.h |  50 ++----------
>  kernel/fork.c       |   1 -
>  mm/hmm.c            | 184 +++++++++++++++++++-------------------------
>  3 files changed, 88 insertions(+), 147 deletions(-)

Jerome, I was doing some more checking of this and noticed lockdep
doesn't compile test if it is turned off, since you took and revised
the series can you please fold in these hunks to fix compile failures
with lockdep on. Thanks

commit f0653c4d4c1dadeaf58d49f1c949ab1d2fda05d3
diff --git a/mm/hmm.c b/mm/hmm.c
index 836adf613f81c8..2a08b78550b90d 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -56,7 +56,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
 	struct hmm *hmm;
 
-	lockdep_assert_held_exclusive(mm->mmap_sem);
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
 
 	if (mm->hmm) {
 		if (kref_get_unless_zero(&mm->hmm->kref))
@@ -262,7 +262,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
  */
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 {
-	lockdep_assert_held_exclusive(mm->mmap_sem);
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
 
 	/* Sanity check */
 	if (!mm || !mirror || !mirror->ops)
@@ -987,7 +987,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 	struct mm_walk mm_walk;
 
 	/* Caller must hold the mmap_sem, and range hold a reference on mm. */
-	lockdep_assert_held(hmm->mm->mmap_sem);
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 	if (WARN_ON(!atomic_read(&hmm->mm->mm_users)))
 		return -EINVAL;
 
@@ -1086,7 +1086,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
 	int ret;
 
 	/* Caller must hold the mmap_sem, and range hold a reference on mm. */
-	lockdep_assert_held(hmm->mm->mmap_sem);
+	lockdep_assert_held(&hmm->mm->mmap_sem);
 	if (WARN_ON(!atomic_read(&hmm->mm->mm_users)))
 		return -EINVAL;
 

