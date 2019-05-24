Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 295D2C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD0BF2133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 18:03:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD0BF2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 477BB6B0283; Fri, 24 May 2019 14:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 428626B0284; Fri, 24 May 2019 14:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 316EE6B0285; Fri, 24 May 2019 14:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10D2B6B0283
	for <linux-mm@kvack.org>; Fri, 24 May 2019 14:03:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id w184so11098840qka.15
        for <linux-mm@kvack.org>; Fri, 24 May 2019 11:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=mwbUjE6hGtZEcIkunXjOCqT434dQeGecSimzxvO/V6Q=;
        b=b9q81HQQ/SxDDpDn1BQOAkaYui68EQNy5mTS+6b8ah2JQGiVoSFzG3h3mdHzX1XX2O
         DuWVSwhZPsJkQnpERVDiMXTjjR3Zn3tIh1WvMmz+DgyMXdFNn4WdNrGCxqhzknGOTjo8
         3inUMMu3M2i10KFo0lUD0MbTImPlgwrLlanPETPWwWrXqOu1oo+O4Le7tcxWkDwFkeAv
         r6mPTBykSatwgKYkZ0EA/bodo4FwA4V94Ts9v2FW9xCeSt62Sjhw2nS/mJv9l63XhjNi
         7Chd0qyvdzPdkFUBVABeMjd2Lt7eFbLY4ju4c0E3IYfs98BvZzb9MFaCnoeSM0QwHzyy
         iwMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU4JmwV+UpetRTLDR1wNnr8Ytj+e1/jBXZ7TI9sfWZG6IbjfqIa
	THOOYgEQmzmWWkaSczA+X86Hyf23r4RtAZQ9iId/NRtRW4ZvJN5gIJko3tF7+MfPlKt70t/48N+
	Ad/OMfNybwd6ZLd3PBmtM8bvxCt3xgBdkPNq1FRvH3LR+bs1fWgkX24xPt9DJbi8w0w==
X-Received: by 2002:a0c:affc:: with SMTP id t57mr32452485qvc.222.1558721006776;
        Fri, 24 May 2019 11:03:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzeh/VH92TOoul1P3jipuIhq4c4pblsDRnivA5ujVY6PXOT9s2xx6V83+wG1NaPbyl8y0W
X-Received: by 2002:a0c:affc:: with SMTP id t57mr32452443qvc.222.1558721006105;
        Fri, 24 May 2019 11:03:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558721006; cv=none;
        d=google.com; s=arc-20160816;
        b=AYKrssWRVZuENrGH0Li5I/wD7yc0Gdy30DuvTQe8raaGeAJGhcpiH6CeuSPadf8Jt6
         CK4HQeKyhX/tz9wBwoyE+pnI7FLmVdO6KY5HFY4n06K+SaVXJWjDr0j72ETJfS8Fzqxj
         PWXnqJiATOeMZWk1mLNFOqXepbWfuGk7KajLlqjk6ur4SVEobjx0/PzVZtV64KHVRHxB
         zaEhJXSbo+4G+nPQ4vvhLDxAqFtszsG0uJwaJDVSGJtKxMgqVYVOZfkOIlV8CoFpY65J
         p0rw6nbhVx3gdMyuEHLSw6O+8mSWtzgUfTP6vOwhZoRkm7NdrsYphLtpF5govz//kSKK
         +V8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=mwbUjE6hGtZEcIkunXjOCqT434dQeGecSimzxvO/V6Q=;
        b=cwDA36iPsPvyGrF14DWmJyo6wfD1LPBObEmE4XljBqDptANrD+zhi5M17LYD8VrnSF
         Wnb8KHCa31oj4OmGBrjEIa8YsXJjE8JrDmdfSBI2kV5dwcTAF8IzKOj/UBMjJrYJE3tm
         G7s6R1C3qcQ+WrOiiFchfMFzRtEX+tKdEXqAoDYYWmKxNDUM62pSOedywK6XISFCID4Y
         xmOXN6X3uC9sc/KozQOdNbexCiciaMlmy1hkZpEOPODsKMWd5c9Wkeh/KAoPUmK78jGj
         z2um2y0M5LRtYKQeKGzZiwWYHlPq9vdJUbh07CypTsQxuKmGXw+SDao2MFDTRbhv9S/P
         kW9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b8si1060698uan.6.2019.05.24.11.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 11:03:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4D1175F793;
	Fri, 24 May 2019 18:03:25 +0000 (UTC)
Received: from redhat.com (ovpn-120-223.rdu2.redhat.com [10.10.120.223])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4B3CC36FB;
	Fri, 24 May 2019 18:03:24 +0000 (UTC)
Date: Fri, 24 May 2019 14:03:22 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524180321.GD3346@redhat.com>
References: <20190523153436.19102-1-jgg@ziepe.ca>
 <20190524143649.GA14258@ziepe.ca>
 <20190524164902.GA3346@redhat.com>
 <20190524165931.GF16845@ziepe.ca>
 <20190524170148.GB3346@redhat.com>
 <20190524175203.GG16845@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190524175203.GG16845@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 24 May 2019 18:03:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 02:52:03PM -0300, Jason Gunthorpe wrote:
> On Fri, May 24, 2019 at 01:01:49PM -0400, Jerome Glisse wrote:
> > On Fri, May 24, 2019 at 01:59:31PM -0300, Jason Gunthorpe wrote:
> > > On Fri, May 24, 2019 at 12:49:02PM -0400, Jerome Glisse wrote:
> > > > On Fri, May 24, 2019 at 11:36:49AM -0300, Jason Gunthorpe wrote:
> > > > > On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> > > > > > From: Jason Gunthorpe <jgg@mellanox.com>
> > > > > > 
> > > > > > This patch series arised out of discussions with Jerome when looking at the
> > > > > > ODP changes, particularly informed by use after free races we have already
> > > > > > found and fixed in the ODP code (thanks to syzkaller) working with mmu
> > > > > > notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> > > > > 
> > > > > So the last big difference with ODP's flow is how 'range->valid'
> > > > > works.
> > > > > 
> > > > > In ODP this was done using the rwsem umem->umem_rwsem which is
> > > > > obtained for read in invalidate_start and released in invalidate_end.
> > > > > 
> > > > > Then any other threads that wish to only work on a umem which is not
> > > > > undergoing invalidation will obtain the write side of the lock, and
> > > > > within that lock's critical section the virtual address range is known
> > > > > to not be invalidating.
> > > > > 
> > > > > I cannot understand how hmm gets to the same approach. It has
> > > > > range->valid, but it is not locked by anything that I can see, so when
> > > > > we test it in places like hmm_range_fault it seems useless..
> > > > > 
> > > > > Jerome, how does this work?
> > > > > 
> > > > > I have a feeling we should copy the approach from ODP and use an
> > > > > actual lock here.
> > > > 
> > > > range->valid is use as bail early if invalidation is happening in
> > > > hmm_range_fault() to avoid doing useless work. The synchronization
> > > > is explained in the documentation:
> > > 
> > > That just says the hmm APIs handle locking. I asked how the apis
> > > implement that locking internally.
> > > 
> > > Are you trying to say that if I do this, hmm will still work completely
> > > correctly?
> > 
> > Yes it will keep working correctly. You would just be doing potentialy
> > useless work.
> 
> I don't see how it works correctly.
> 
> Apply the comment out patch I showed and this trivially happens:
> 
>       CPU0                                               CPU1
>   hmm_invalidate_start()
>     ops->sync_cpu_device_pagetables()
>       device_lock()
>        // Wipe out page tables in device, enable faulting
>       device_unlock()
> 
>                                                        DEVICE PAGE FAULT
>                                                        device_lock()
>                                                        hmm_range_register()
>                                                        hmm_range_dma_map()
>                                                        device_unlock()
>   hmm_invalidate_end()

No in the above scenario hmm_range_register() will not mark the range
as valid thus the driver will bailout after taking its lock and checking
the range->valid value.

> 
> The mmu notifier spec says:
> 
>  	 * Invalidation of multiple concurrent ranges may be
> 	 * optionally permitted by the driver. Either way the
> 	 * establishment of sptes is forbidden in the range passed to
> 	 * invalidate_range_begin/end for the whole duration of the
> 	 * invalidate_range_begin/end critical section.
> 
> And I understand "establishment of sptes is forbidden" means
> "hmm_range_dmap_map() must fail with EAGAIN". 

No it means that secondary page table entry (SPTE) must not materialize
thus what hmm_range_dmap_map() is doing if fine and safe as long as the
driver do not use the result to populate the device page table if there
was an invalidation for the range.

> 
> This is why ODP uses an actual lock held across the critical region
> which completely prohibits reading the CPU pages tables, or
> establishing new mappings.
> 
> So, I still think we need a true lock, not a 'maybe valid' flag.

The rational in HMM is to never block mm so that mm can always make
progress as whatever mm is doing will take precedence and thus it
would be useless to block mm while we do something if what we are
doing is about to become invalid.

Cheers,
Jérôme

