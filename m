Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50AFFC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DAEC20879
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:51:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DAEC20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEA0E6B027F; Fri, 24 May 2019 13:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A99786B0280; Fri, 24 May 2019 13:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9895C6B0281; Fri, 24 May 2019 13:51:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 765796B027F
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:51:48 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id 3so2371253uag.14
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:51:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=p7qjPj6M5SddKRsQw9pfKShNUNckPJxKeQQcYCpQWgk=;
        b=ehVZrMmPfAG39xOOpVMFEw/4imRr/B3kLfiIhbd6D6fqBUkwtyXfF0OrUujVUgS8Ed
         hLnh6qO/Sub5zmty2L7ITgyUfeSTEHND5XBOeZ7Ge2vDG02Hnx0fqPMuMuCgxumziI1M
         xQlRQFKXDs0yWPoULgyZVApco41ncimPJWkutVHiAaPVsQvnhJ9uLd0Sy+9UjJ2pr4v5
         QJo7lM6b2y//Ji07t7nni899W25Jqi0qD4602jriWt3l0C0tOK/xT29gqNTn07iAEzym
         AjyiK7OhOrfXeJMlpCva4K06z7eOZWhHMgyBaHeFIeOMHH+9nG0Mxl4TKyQgiQKOpHQg
         WI5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWU/5tv89RCiEJ45OHdGpxbC/jicTlDYHnAhsZ8QezIZLiaEWHm
	ZS133UHJaXCtBasxYr5bMWUTgnIIPcm8G0WmpfPGseF6jHwfUc6FTIujs4hLShzIglTBjH2z7Jc
	8dAynvmWOOyz+bEez72ypOv+ydnVVQdzr5Jn9DeA0c/eFbDJEglr+ZL0f6C7CCwzNFw==
X-Received: by 2002:a1f:9ad1:: with SMTP id c200mr3701454vke.63.1558720308179;
        Fri, 24 May 2019 10:51:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM3r1X9LhzvSW0u8UwCK6HaXYlJqz2XbjDoI5zlbCZxzn86hP7uzePco6pyPuzjfqhlxKR
X-Received: by 2002:a1f:9ad1:: with SMTP id c200mr3701373vke.63.1558720307416;
        Fri, 24 May 2019 10:51:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558720307; cv=none;
        d=google.com; s=arc-20160816;
        b=nQrCfL8pTLnYWyQmtfjXZ+o2pq9O4A5WpdUUls4VCtaGVpEmrPGmiScZvd7gst+m8f
         N7YHNFH+k/uhM2ddCdr7wXmcscLrs8y47H1zyU75FlvGZMNQY7iYzHvujIZHfMz6IpTa
         HcGzAUBad/Rvy0nlPtgoLAJnILLkGa4aiD5YLIXob5roOLH7xh8wx9G6UlDLQ8u+DarW
         XbCPHAckdQpI65KmoTmZIrvcd4LhtTD26mc5ol2Rbj0yEgwJxDcce+qdGKNgdqWTPqxj
         Oo5ijQNBJnHdKAtyHf3dzPCjvgaAcBX7HKREOMmFi3uczvLFrbF5BLr0nl551vpO4OyW
         5R3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=p7qjPj6M5SddKRsQw9pfKShNUNckPJxKeQQcYCpQWgk=;
        b=1KVBYEsnAyMXmKrTLXcg0J6F+TIdjxfNH344V3ytxPBvnH2k6Nn2NIGsWL7gmxMhvn
         LVYQd9bxOvsA4eRXFiLltQUJqLoG7xAJ7MApjWLEcsB+o880v5euxhegTnPvJt3wXxrf
         4IUQT7uVyE6TdVoRTSFkAOBYic1l45Ji2q9lZFj0ttj7lWVI2WU/Wftxv4zYo4IS1GgT
         S0xxsVW7iP8BAWfrKC3AVwoNIE5Fd/h83+lRM9gUL+m5hC4B0SOEYGADvXpgHf1gZINr
         oxy1GoHPMfJkPTed5bX8b+Gw161UVy8qy/RtBXq6nDseTCjHo9/JUipg8v2yKIxezUjx
         y8oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l18si1054323vsj.246.2019.05.24.10.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 10:51:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 954453086246;
	Fri, 24 May 2019 17:51:46 +0000 (UTC)
Received: from redhat.com (ovpn-120-223.rdu2.redhat.com [10.10.120.223])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6188E6092D;
	Fri, 24 May 2019 17:51:45 +0000 (UTC)
Date: Fri, 24 May 2019 13:51:42 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524175142.GC3346@redhat.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
 <7f82b770-85a3-9b01-48b2-9e458191b8d6@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7f82b770-85a3-9b01-48b2-9e458191b8d6@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 24 May 2019 17:51:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 10:47:16AM -0700, Ralph Campbell wrote:
> 
> On 5/24/19 9:49 AM, Jerome Glisse wrote:
> > On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> > > On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > > 
> > > > This patch series arised out of discussions with Jerome when looking at the
> > > > ODP changes, particularly informed by use after free races we have already
> > > > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > > > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > > 
> > > So the last big difference with ODP's flow is how 'range->valid'
> > > works.
> > > 
> > > In ODP this was done using the rwsem umem->umem_rwsem which is
> > > obtained for read in invalidate_start and released in invalidate_end.
> > > 
> > > Then any other threads that wish to only work on a umem which is not
> > > undergoing invalidation will obtain the write side of the lock, and
> > > within that lock's critical section the virtual address range is known
> > > to not be invalidating.
> > > 
> > > I cannot understand how hmm gets to the same approach. It has
> > > range->valid, but it is not locked by anything that I can see, so when
> > > we test it in places like hmm_range_fault it seems useless..
> > > 
> > > Jerome, how does this work?
> > > 
> > > I have a feeling we should copy the approach from ODP and use an
> > > actual lock here.
> > 
> > range->valid is use as bail early if invalidation is happening in
> > hmm_range_fault() to avoid doing useless work. The synchronization
> > is explained in the documentation:
> > 
> > 
> > Locking within the sync_cpu_device_pagetables() callback is the most important
> > aspect the driver must respect in order to keep things properly synchronized.
> > The usage pattern is::
> > 
> >   int driver_populate_range(...)
> >   {
> >        struct hmm_range range;
> >        ...
> > 
> >        range.start = ...;
> >        range.end = ...;
> >        range.pfns = ...;
> >        range.flags = ...;
> >        range.values = ...;
> >        range.pfn_shift = ...;
> >        hmm_range_register(&range);
> > 
> >        /*
> >         * Just wait for range to be valid, safe to ignore return value as we
> >         * will use the return value of hmm_range_snapshot() below under the
> >         * mmap_sem to ascertain the validity of the range.
> >         */
> >        hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
> > 
> >   again:
> >        down_read(&mm->mmap_sem);
> >        ret = hmm_range_snapshot(&range);
> >        if (ret) {
> >            up_read(&mm->mmap_sem);
> >            if (ret == -EAGAIN) {
> >              /*
> >               * No need to check hmm_range_wait_until_valid() return value
> >               * on retry we will get proper error with hmm_range_snapshot()
> >               */
> >              hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
> >              goto again;
> >            }
> >            hmm_range_unregister(&range);
> >            return ret;
> >        }
> >        take_lock(driver->update);
> >        if (!hmm_range_valid(&range)) {
> >            release_lock(driver->update);
> >            up_read(&mm->mmap_sem);
> >            goto again;
> >        }
> > 
> >        // Use pfns array content to update device page table
> > 
> >        hmm_range_unregister(&range);
> >        release_lock(driver->update);
> >        up_read(&mm->mmap_sem);
> >        return 0;
> >   }
> > 
> > The driver->update lock is the same lock that the driver takes inside its
> > sync_cpu_device_pagetables() callback. That lock must be held before calling
> > hmm_range_valid() to avoid any race with a concurrent CPU page table update.
> > 
> > 
> > Cheers,
> > Jérôme
> 
> 
> Given the above, the following patch looks necessary to me.
> Also, looking at drivers/gpu/drm/nouveau/nouveau_svm.c, it
> doesn't check the return value to avoid calling up_read(&mm->mmap_sem).
> Besides, it's better to keep the mmap_sem lock/unlock in the caller.

No, nouveau use the old API so check hmm_vma_fault() within hmm.h, i have
patch to convert it to new API for 5.3


> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 836adf613f81..8b6ef97a8d71 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -1092,10 +1092,8 @@ long hmm_range_fault(struct hmm_range *range, bool
> block)
> 
>  	do {
>  		/* If range is no longer valid force retry. */
> -		if (!range->valid) {
> -			up_read(&hmm->mm->mmap_sem);
> +		if (!range->valid)
>  			return -EAGAIN;
> -		}
> 
>  		vma = find_vma(hmm->mm, start);
>  		if (vma == NULL || (vma->vm_flags & device_vma))
> 
> -----------------------------------------------------------------------------------
> This email message is for the sole use of the intended recipient(s) and may contain
> confidential information.  Any unauthorized review, use, disclosure or distribution
> is prohibited.  If you are not the intended recipient, please contact the sender by
> reply email and destroy all copies of the original message.
> -----------------------------------------------------------------------------------

