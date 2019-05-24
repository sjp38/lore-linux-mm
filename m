Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CD25C282DD
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 01:23:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D95142168B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 01:23:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KLYYYyhf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D95142168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 654306B0007; Thu, 23 May 2019 21:23:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 603C86B0008; Thu, 23 May 2019 21:23:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CD106B000A; Thu, 23 May 2019 21:23:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A02A6B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 21:23:24 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id f25so7113071qkk.22
        for <linux-mm@kvack.org>; Thu, 23 May 2019 18:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ob1haUFm9FIqRuYLZIZ42lM0yuIKUzBg3HV4kFfNrOY=;
        b=I5rsoVZNRxPOSCPYwDM2Ld2Irj4qRwHIHuLCeREzYK6ACJlTCUtXTAFhxWVJLI5W/q
         X9ilpQX+/npe88n428/MjaZBFe163DrQ5g0iMo3XAwjp3wqYTjb4Hjqg7FrOyTp4znV1
         yU3TkCRl9r4eCBDJceapUUCBgCoZ5YdLLAj/yvq6Eg+k/RJ3qFrVQL0GDyLY8ey3BvqL
         c0mzYgeWAdg5OtfsHEBBki7Ahq8MqzLu1GklxGUMKuwmZImOXnnhIpXMzHhgZJ8dKBWb
         zgfdwoAmFkrgZ2q+dJ373SEq8iwULIDXBLS6arZ10gcQtrVZKkBo7OZNI5dUCJ2ASFjY
         +lXQ==
X-Gm-Message-State: APjAAAW4kHD3vPueWP+W07C8HqjrH1mWCusgTqduG6Eomaya7H1rRhx3
	QeH+mIlYCbQLqrG8ErCT3hKcoqASWOPifPFMI32OJtdv//4XQUla89HumlvA8XYaaP6kPd0cGS7
	Iqnzx3Y5rIfnHlJeeRPLWpVX4dDy14H4JV7+o0mqVJOOc7iE1A4unPWo9UE+n8L76Aw==
X-Received: by 2002:aed:3f72:: with SMTP id q47mr83835748qtf.268.1558661003898;
        Thu, 23 May 2019 18:23:23 -0700 (PDT)
X-Received: by 2002:aed:3f72:: with SMTP id q47mr83835706qtf.268.1558661003181;
        Thu, 23 May 2019 18:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558661003; cv=none;
        d=google.com; s=arc-20160816;
        b=ACriY+X0oPl7YavN6g9I5j/47v9mcxvfZl1CCWBo3fsIPbal8KDnVId7ZJ7ThNLyUy
         i5z8dHVP0ncgKvcfmDQIGJnNbTYG6+aSkPcjj89UDeO9hQ+KTgZpSQ70anMMqqvhMBvN
         93CKN/ZwbdZy22KNPWQkRGnTohRjslmZSkvOAXqO8mxLsJVcZ3IaoSI3uLTVW0+zTeDt
         JPBldBFnQfV869qACnlg5PrlAH76bbambctD6YUDdBism8DacdTXDhbW+Gz3FoH5a1S3
         xfUaqJUPQukkP28pALP+y5aePODu/pib1D68mzX/dKaC1kw2jneKvVuCBGcQv7qdeACh
         EfqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ob1haUFm9FIqRuYLZIZ42lM0yuIKUzBg3HV4kFfNrOY=;
        b=qa1UTP7PyltV7RxEVcxdo99PqYGV53puuTOY20qYQ4L8p9orIOpedjY7BIv4AcnxiQ
         0AUaX4CvZk0A/ypk1BCe/6e5gfN5/BZxA4adpvgtJfm/aXIGhUP+YhS/T+lZF/OrAP6q
         Ky5h8R5PQWlPbV7dFaRg1bL2QcsrdT+vMGMwcJWNx3gPd3IluzIET69Z5yn2WZXNhcED
         KAoblGh0TOq8v+U+nh8YZ9DUqj1stEYlYxR0b4A551dxo8+mUpfMdsB92gq4cJO7BMNu
         keUW2CVoZqdksI2Os2YNMskFqk5TifRG8eGA/G9uRyWsTfFZc/ah/ywwtczE8N4x0+nx
         9NCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KLYYYyhf;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h52sor1079546qta.66.2019.05.23.18.23.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 18:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KLYYYyhf;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ob1haUFm9FIqRuYLZIZ42lM0yuIKUzBg3HV4kFfNrOY=;
        b=KLYYYyhfR7qLmYFT7PD/6mbnTSqoa5EKCxrWbEJljTnUQGQzjmXq0/IE4iv/pV5tD+
         kV90GBjIM2Ex+gNXJsl8+DLghIGsZp0eyO36a7M9uJCwTwz1EDXCTwLzXHv2jqHbWs3b
         mxaFuu0KU/naSa1V4DBVXwbnqPaUZQ9eZb9qTQ9SUqxg1Pd1X6YWj4JNmyLmctFvLjcB
         jOt27076LQFHlY//bHsfmB5Qj7Z20kguVEUwen4NQ6Uxxq10xnVB7JoVwramPLyEO6IZ
         Nu7979o6iWuxKxSllKta16tysjzPYGoaCQsSw0iPpivVUHu3cOXoo2x3QIlb+DkG4KwQ
         Uy+A==
X-Google-Smtp-Source: APXvYqwsxMpcSzONxYLiLCOcNY8OkbIwVOP7XkNW4vjUWReqycLJjAvzE6AKOyHvlwsEdD3dsyM4VA==
X-Received: by 2002:ac8:2bb3:: with SMTP id m48mr30921288qtm.218.1558661002696;
        Thu, 23 May 2019 18:23:22 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id d23sm821597qta.26.2019.05.23.18.23.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 18:23:21 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTyvY-0003c5-PL; Thu, 23 May 2019 22:23:20 -0300
Date: Thu, 23 May 2019 22:23:20 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 04/11] mm/hmm: Simplify hmm_get_or_create and make it
 reliable
Message-ID: <20190524012320.GA13614@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190523153436.19102-5-jgg@ziepe.ca>
 <6945b6c9-338a-54e6-64df-2590d536910a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6945b6c9-338a-54e6-64df-2590d536910a@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 04:38:28PM -0700, Ralph Campbell wrote:
> 
> On 5/23/19 8:34 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > As coded this function can false-fail in various racy situations. Make it
> > reliable by running only under the write side of the mmap_sem and avoiding
> > the false-failing compare/exchange pattern.
> > 
> > Also make the locking very easy to understand by only ever reading or
> > writing mm->hmm while holding the write side of the mmap_sem.
> > 
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> >   mm/hmm.c | 75 ++++++++++++++++++++------------------------------------
> >   1 file changed, 27 insertions(+), 48 deletions(-)
> > 
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index e27058e92508b9..ec54be54d81135 100644
> > +++ b/mm/hmm.c
> > @@ -40,16 +40,6 @@
> >   #if IS_ENABLED(CONFIG_HMM_MIRROR)
> >   static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
> > -static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> > -{
> > -	struct hmm *hmm = READ_ONCE(mm->hmm);
> > -
> > -	if (hmm && kref_get_unless_zero(&hmm->kref))
> > -		return hmm;
> > -
> > -	return NULL;
> > -}
> > -
> >   /**
> >    * hmm_get_or_create - register HMM against an mm (HMM internal)
> >    *
> > @@ -64,11 +54,20 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
> >    */
> >   static struct hmm *hmm_get_or_create(struct mm_struct *mm)
> >   {
> > -	struct hmm *hmm = mm_get_hmm(mm);
> > -	bool cleanup = false;
> > +	struct hmm *hmm;
> > -	if (hmm)
> > -		return hmm;
> > +	lockdep_assert_held_exclusive(mm->mmap_sem);
> > +
> > +	if (mm->hmm) {
> > +		if (kref_get_unless_zero(&mm->hmm->kref))
> > +			return mm->hmm;
> > +		/*
> > +		 * The hmm is being freed by some other CPU and is pending a
> > +		 * RCU grace period, but this CPU can NULL now it since we
> > +		 * have the mmap_sem.
> > +		 */
> > +		mm->hmm = NULL;
> 
> Shouldn't there be a "return NULL;" here so it doesn't fall through and
> allocate a struct hmm below?

No, this function should only return NULL on memory allocation
failure.

In this case another thread is busy freeing the hmm but wasn't able to
update mm->hmm to null due to a locking constraint. So we make it null
on behalf of the other thread and allocate a fresh new hmm that is
valid. The freeing thread will complete the free and do nothing with
mm->hmm.

> >   static void hmm_fee_rcu(struct rcu_head *rcu)
> 
> I see Jerome already saw and named this hmm_free_rcu()
> which I agree with.

I do love my typos :)

> >   {
> > +	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
> > +
> > +	down_write(&hmm->mm->mmap_sem);
> > +	if (hmm->mm->hmm == hmm)
> > +		hmm->mm->hmm = NULL;
> > +	up_write(&hmm->mm->mmap_sem);
> > +	mmdrop(hmm->mm);
> > +
> >   	kfree(container_of(rcu, struct hmm, rcu));
> >   }
> >   static void hmm_free(struct kref *kref)
> >   {
> >   	struct hmm *hmm = container_of(kref, struct hmm, kref);
> > -	struct mm_struct *mm = hmm->mm;
> > -
> > -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
> > -	spin_lock(&mm->page_table_lock);
> > -	if (mm->hmm == hmm)
> > -		mm->hmm = NULL;
> > -	spin_unlock(&mm->page_table_lock);
> > -
> > -	mmdrop(hmm->mm);
> > +	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
> >   	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
> >   }
> > 
> 
> This email message is for the sole use of the intended recipient(s) and may contain
> confidential information.  Any unauthorized review, use, disclosure or distribution
> is prohibited.  If you are not the intended recipient, please contact the sender by
> reply email and destroy all copies of the original message.

Ah, you should not send this trailer to the public mailing lists.

Thanks,
Jason

