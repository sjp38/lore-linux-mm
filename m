Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3F93C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C11D121773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:49:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C11D121773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FD206B0006; Fri, 24 May 2019 12:49:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AD766B000A; Fri, 24 May 2019 12:49:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39B336B000C; Fri, 24 May 2019 12:49:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FED66B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:49:15 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id p9so2287900uad.23
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:49:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=b5geToT0Cp46LxH6LAjFsyERvRjevTHwaxxxxZIu/T0=;
        b=f5n7B9nzPW+JPPD/c+JZeQSzdxIIJdQD89QufErQvAJrGByCFBT/INXrbGwK9KS3At
         +YLEz1w1WmFew4d5ttENSnMP1SWAAfoizIY4SuI7FvE5Azoy7Ykj3Blavs4gp4NuoGl/
         Y9gnVxW1FEwW/G3FnXu99OnvorcHCODcIZRs/TK/rSTvWCFB2O/pmKy13IwuJL1Jt2mS
         6Clg+67GL5vJd/uIyuc9nilANXS7hL5D0qOf0dhkv9FHHsy3EvZKJiZGUSlLG4F3HXbE
         W9Eo1pZPBJ/QXGJH3ZtIHi2JqsPTvx1voikSuibVf0DKQMu5mLf/oJYrAo/dwzAflFD6
         BzfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4z+psb3O/WKfOxgmJh+NWwVxgudEu8uQ7hKyWX0mkv4xRNG6u
	VatZGm9rtAn2Zy4+zsd51eUD/RrJqjlli5L4mGuc2WANoJ5VNz2z1JQAC0XmpGT17QZdl7UZPv2
	g1QPuzTsHKn4pcaAHeYjsVuXKphyUUMugFbOMV746NJufHtpKCOnBz/RPqoyeULGnCw==
X-Received: by 2002:a67:f489:: with SMTP id o9mr42292641vsn.118.1558716554682;
        Fri, 24 May 2019 09:49:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwKY3X5OpWC38aWpUV2lEQJTP2fxabR2+yYuH+S+K9N190XR7WnFzId6zJZAqM6Y+hXxte
X-Received: by 2002:a67:f489:: with SMTP id o9mr42292531vsn.118.1558716553788;
        Fri, 24 May 2019 09:49:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558716553; cv=none;
        d=google.com; s=arc-20160816;
        b=yB5zrVLDeuUHFOurUTjw//IztgWPU+5M+I8a3kYWOrNG2+sMvLX/4v0Az7vYEuyIVO
         jnlq1jgzNu42eQt27Vgylv6F2lEOZ9MEySmu1pJH1SKLmvrOnuvmWCqYc5panDEPCc3b
         uAduarAsOH6KFWppe0l4+Z1wOLtisZ6lyDYItiT9c7AAaCW7FxW5F6MyBOX1OObiIcx8
         gF2IgNB+EbPowLkFLf3WqP5A1tttrluAShbrcU7Uka+ONcuj2kD/+xdT4eN+VeGiy1zV
         QY3dG7EYEiTTIGEjjslRJGD89et2gSWPFyYtd6W1OQAzKN2hSrPbhWRLGwgMiV3JJYt3
         /blQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=b5geToT0Cp46LxH6LAjFsyERvRjevTHwaxxxxZIu/T0=;
        b=y+2heWNi+is8RmyyrBb/iny6P92i6BnGzRlRbiBWwQu9ky8CU/DWGmrbV9JVbcSHJF
         QT9gUGjMKWAPqRC18gZPd7xVWkhEeY5qlQPWnCnDK5dBXb9eYLhfr0IK/MNcVJ72m5z7
         W3w1XXWJuW2rqaLPOAjJYIpJizG8eQhfxM8j4EuSuoJtM/R9JIo9B5Fq2hanL7BY4ts5
         0GVSKlar4SCSlY9qisOKlTfUvnp18bzxsBbjDasIoLHHTKH0HP1nfd69SZl8jRSzgD71
         K+z4YGAlb7PcSzFz0IO846QssAVYroddPTXMlEkkZURHxdQBH3wRld2izRq6Q7FJcZZT
         JlTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v22si186925uap.48.2019.05.24.09.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 09:49:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 400CF300413F;
	Fri, 24 May 2019 16:49:06 +0000 (UTC)
Received: from redhat.com (ovpn-120-223.rdu2.redhat.com [10.10.120.223])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1D4F310027B6;
	Fri, 24 May 2019 16:49:04 +0000 (UTC)
Date: Fri, 24 May 2019 12:49:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524164902.GA3346@redhat.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190524143649.GA14258@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 24 May 2019 16:49:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > This patch series arised out of discussions with Jerome when looking at the
> > ODP changes, particularly informed by use after free races we have already
> > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> 
> So the last big difference with ODP's flow is how 'range->valid'
> works.
> 
> In ODP this was done using the rwsem umem->umem_rwsem which is
> obtained for read in invalidate_start and released in invalidate_end.
> 
> Then any other threads that wish to only work on a umem which is not
> undergoing invalidation will obtain the write side of the lock, and
> within that lock's critical section the virtual address range is known
> to not be invalidating.
> 
> I cannot understand how hmm gets to the same approach. It has
> range->valid, but it is not locked by anything that I can see, so when
> we test it in places like hmm_range_fault it seems useless..
> 
> Jerome, how does this work?
> 
> I have a feeling we should copy the approach from ODP and use an
> actual lock here.

range->valid is use as bail early if invalidation is happening in
hmm_range_fault() to avoid doing useless work. The synchronization
is explained in the documentation:


Locking within the sync_cpu_device_pagetables() callback is the most important
aspect the driver must respect in order to keep things properly synchronized.
The usage pattern is::

 int driver_populate_range(...)
 {
      struct hmm_range range;
      ...

      range.start = ...;
      range.end = ...;
      range.pfns = ...;
      range.flags = ...;
      range.values = ...;
      range.pfn_shift = ...;
      hmm_range_register(&range);

      /*
       * Just wait for range to be valid, safe to ignore return value as we
       * will use the return value of hmm_range_snapshot() below under the
       * mmap_sem to ascertain the validity of the range.
       */
      hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);

 again:
      down_read(&mm->mmap_sem);
      ret = hmm_range_snapshot(&range);
      if (ret) {
          up_read(&mm->mmap_sem);
          if (ret == -EAGAIN) {
            /*
             * No need to check hmm_range_wait_until_valid() return value
             * on retry we will get proper error with hmm_range_snapshot()
             */
            hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
            goto again;
          }
          hmm_range_unregister(&range);
          return ret;
      }
      take_lock(driver->update);
      if (!hmm_range_valid(&range)) {
          release_lock(driver->update);
          up_read(&mm->mmap_sem);
          goto again;
      }

      // Use pfns array content to update device page table

      hmm_range_unregister(&range);
      release_lock(driver->update);
      up_read(&mm->mmap_sem);
      return 0;
 }

The driver->update lock is the same lock that the driver takes inside its
sync_cpu_device_pagetables() callback. That lock must be held before calling
hmm_range_valid() to avoid any race with a concurrent CPU page table update.


Cheers,
Jérôme

