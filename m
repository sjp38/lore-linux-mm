Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D2E6C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:42:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0759F2173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 22:42:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0759F2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CDF76B0003; Wed, 22 May 2019 18:42:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A5736B0006; Wed, 22 May 2019 18:42:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8947A6B0007; Wed, 22 May 2019 18:42:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68E7F6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 18:42:15 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n65so3705592qke.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 15:42:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4cmSsqPHZQLY+pWOSsOunO9s3Gp7MwmSxn+NLqvYXEI=;
        b=gE5GtGmqUTQk153kaEd7u34vjcwo3c+R7jMev22RWduIe6s/XoTrHq6gcMSXVh8qsY
         8z6/kIHIwTYETyksNE/XuNf+4tv/m5MOeV3qe53D9LocFDIl8SIDzzE0V/MxPCQPf4d8
         McAk2aG9UloEOFoUEe4yZ4o0feAVtJMqVv3esw7z92Fj0DNokF47tjJbTreV3ju44vmt
         C22+bd75zy8jF0uslxZfzheesg5dC6sSc0kWERpLI9dht8Xj4jB36u2ILgmXjDYAYAJq
         6DKtbMAmvXOL0JqRfjE3qFSEDstcHmnDU28sEesGnIySiEnJ+sxdI4A3Ybvnk0ybujoG
         H55A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWMRdOmFuhp3hhv2+aoG25M+u90ZHFD32eEW7/90eqrDGx2aLhw
	MB4MwhxV5wU9WogZYLl/WQjaSHP8PdtEiQEwzpPK18n/GAooAVNBfPwSGNRTwe5bZT8NoJEkSaG
	yeYkyvKzeKaI4KL7vxrL0ycedxE5iZ/BBPtOhDlMtZ8ObwwMTk3hoxZRGya9vQHtNHQ==
X-Received: by 2002:a37:8843:: with SMTP id k64mr70490068qkd.8.1558564935213;
        Wed, 22 May 2019 15:42:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh1NwKmZcb9+uw2VqHcnwenYU3jc/ktzeU0P7UlT0Dvh5kBqkbsd2zSh2J+OIKqn7RiKtL
X-Received: by 2002:a37:8843:: with SMTP id k64mr70490050qkd.8.1558564934754;
        Wed, 22 May 2019 15:42:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558564934; cv=none;
        d=google.com; s=arc-20160816;
        b=sDVO/48NiJikFUXVwRJsd4QSEueqeJduPHC4QNbttChK25bohxus7APf9tjEASOvc3
         0V7xiDhfXw9+TxS/oHtktMKwNwDOk+GtdV1y/LMSlBDgvIfqwnvpqyUL5RL6mj+9ZIpd
         ARwMdfyhFxM0Pow/p7V7L2iAsYdVQOzUsAx+c8pWYzsWcRjR8mzVbiRoYWDUu78Ov21G
         I4aM8Aq/QX5Hhqn1gbJ00UmdH091zbdjPHpzqt2af9TF/RaYPJFsw82XeieoeM1GXzxx
         9jwtAATzGcb8q4M+dHKYYD8AZGoJ6BszRrOIauoJfV2nSKBnt5OcOn7VwYAmpQy3SjLR
         juog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=4cmSsqPHZQLY+pWOSsOunO9s3Gp7MwmSxn+NLqvYXEI=;
        b=XZSxpTuRO2LilmPP7pGou8AZ7/Gpi0qw/GoxnBwzejOmzgJt7lzYcftdAki3vPcDLw
         a0WmIuWJPmBN8NqlrV4mLHBF5v8ZnW9OAeYOSkuMxaOFg59rGCHvu2WNZvkcxIymrFnR
         Nem3VU//pWhlwd8nZqhw8BK8j+Frrs9+zmx/MKTW5yPt6dceMa3xTPXiGOKxLhkm7CnO
         bdeamqYj1zY0qlO5ZXoV9TN0O2uAb9ming2IzKN6X1ReEdlJDCk9O8py1L7/BbEXkrE4
         IfkQyrdp6GWk1pkbZFy047epCrQ3YLQuBeCZiQblft90Pzr1fSxBJKdKz+fUBpcGrxzh
         a19w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n23si8094056qtn.188.2019.05.22.15.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 15:42:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E075A30001EB;
	Wed, 22 May 2019 22:42:13 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D720C62660;
	Wed, 22 May 2019 22:42:12 +0000 (UTC)
Date: Wed, 22 May 2019 18:42:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
Message-ID: <20190522224211.GF20179@redhat.com>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca>
 <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca>
 <20190522174852.GA23038@redhat.com>
 <20190522201247.GH6054@ziepe.ca>
 <20190522220419.GB20179@redhat.com>
 <20190522223906.GA15389@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190522223906.GA15389@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 22 May 2019 22:42:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 07:39:06PM -0300, Jason Gunthorpe wrote:
> On Wed, May 22, 2019 at 06:04:20PM -0400, Jerome Glisse wrote:
> > On Wed, May 22, 2019 at 05:12:47PM -0300, Jason Gunthorpe wrote:
> > > On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:
> > > 
> > > >  static void put_per_mm(struct ib_umem_odp *umem_odp)
> > > >  {
> > > >  	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
> > > > @@ -325,9 +283,10 @@ static void put_per_mm(struct ib_umem_odp *umem_odp)
> > > >  	up_write(&per_mm->umem_rwsem);
> > > >  
> > > >  	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> > > > -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> > > > +	hmm_mirror_unregister(&per_mm->mirror);
> > > >  	put_pid(per_mm->tgid);
> > > > -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> > > > +
> > > > +	kfree(per_mm);
> > > 
> > > Notice that mmu_notifier only uses SRCU to fence in-progress ops
> > > callbacks, so I think hmm internally has the bug that this ODP
> > > approach prevents.
> > > 
> > > hmm should follow the same pattern ODP has and 'kfree_srcu' the hmm
> > > struct, use container_of in the mmu_notifier callbacks, and use the
> > > otherwise vestigal kref_get_unless_zero() to bail:
> > > 
> > > From 0cb536dc0150ba964a1d655151d7b7a84d0f915a Mon Sep 17 00:00:00 2001
> > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > Date: Wed, 22 May 2019 16:52:52 -0300
> > > Subject: [PATCH] hmm: Fix use after free with struct hmm in the mmu notifiers
> > > 
> > > mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
> > > system will continue to reference hmm->mn until the srcu grace period
> > > expires.
> > > 
> > >          CPU0                                     CPU1
> > >                                                __mmu_notifier_invalidate_range_start()
> > >                                                  srcu_read_lock
> > >                                                  hlist_for_each ()
> > >                                                    // mn == hmm->mn
> > > hmm_mirror_unregister()
> > >   hmm_put()
> > >     hmm_free()
> > >       mmu_notifier_unregister_no_release()
> > >          hlist_del_init_rcu(hmm-mn->list)
> > > 			                           mn->ops->invalidate_range_start(mn, range);
> > > 					             mm_get_hmm()
> > >       mm->hmm = NULL;
> > >       kfree(hmm)
> > >                                                      mutex_lock(&hmm->lock);
> > > 
> > > Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
> > > existing. Get the now-safe hmm struct through container_of and directly
> > > check kref_get_unless_zero to lock it against free.
> > 
> > It is already badly handled with BUG_ON()
> 
> You can't crash the kernel because userspace forced a race, and no it
> isn't handled today because there is no RCU locking in mm_get_hmm nor
> is there a kfree_rcu for the struct hmm to make the
> kref_get_unless_zero work without use-after-free.
> 
> > i just need to convert those to return and to use
> > mmu_notifier_call_srcu() to free hmm struct.
> 
> Isn't that what this patch does?

Yes but other chunk just need to replace BUG_ON with return

> 
> > The way race is avoided is because mm->hmm will either be NULL or
> > point to another hmm struct before an existing hmm is free. 
> 
> There is no locking on mm->hmm so it is useless to prevent races.

There is locking on mm->hmm

> 
> > Also if range_start/range_end use kref_get_unless_zero() but right
> > now this is BUG_ON if it turn out to be NULL, it should just return
> > on NULL.
> 
> Still needs rcu.
> 
> Also the container_of is necessary to avoid some race where you could
> be doing:
> 
>                   CPU0                                     CPU1                         CPU2
>                                                        hlist_for_each ()
>        mmu_notifier_unregister_no_release(hmm1)             
>        spin_lock(&mm->page_table_lock);                                
>        mm->hmm = NULL
>        spin_unlock(&mm->page_table_lock);                                                                                      
>                                                       				 hmm2 = hmm_get_or_create()
>                                                         mn == hmm1->mn
>                                                         mn->ops->invalidate_range_start(mn, range)
> 							  mm_get_mm() == hmm2
>                                                       hist_for_each con't
>                                                         mn == hmm2->mn
>                                                         mn->ops->invalidate_range_start(mn, range)
> 							  mm_get_mm() == hmm2
> 
> Now we called the same notifier twice on hmm2. Ooops.
> 
> There is no reason to risk this confusion just to avoid container_of.
> 
> So we agree this patch is necessary? Can you test it an ack it please?

A slightly different patch than this one is necessary i will work on
it tomorrow.

Cheers,
Jérôme

