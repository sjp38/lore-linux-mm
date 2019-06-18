Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63FEDC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:11:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DC40213F2
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:11:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nCh2sLXr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DC40213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE4266B0005; Tue, 18 Jun 2019 11:11:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC8238E0002; Tue, 18 Jun 2019 11:11:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D0E88E0001; Tue, 18 Jun 2019 11:11:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B53C6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:11:02 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so12570898qke.1
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:11:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pqCED5mYNInU5PAv2mesXGcqWFvLrmpHYJb9ulnVVgI=;
        b=JF6z/eq8Q662KsBOkr/Q/Bpvska3RfmPeMA7mNcWC8OIqjnxBkXRFg7xGETWNN13PA
         8+RFvB+LfrQs7xPkJJ2ru4e0PU01X8qY8/CYNU6ASrgcLSOq1eawTyH1nM1JpLtULehY
         kpfR9Wx1T8GeEFZKuqnKbF22KpB5EfTWiR/4PDzHvXEKaZtWonY8JB/9ihJ8nJeCanUo
         1xmxhhDQHjCrHe1gymh9e5EVbNgNCkX5fZIcUA7Vgixt9o4jgNLSi3euPhb95BD/SZo6
         SLI7z0lrjED8zlcjk25ACEQhkMfZPabywZKgmtQMat0+d654IywbiKwcpYIIgUJeYtzY
         agOA==
X-Gm-Message-State: APjAAAXXdZ0S2ZEPkzrUacV8DHDbC3qy89CrYgyO/+jCeoh+1k0/un0g
	YQP4dacADCRbovElWE5Crcwh6E6wWbcCvEsWoqX01U2RBCEpoJ8bqRF1HgT1ocaNV5nzpEnsRSl
	pr3E4han1KK6pK5a4kZ0jSJwRJRE/N0eVySJkqS8Tdv4T63WufuwC2yY2nLsCTcCA/w==
X-Received: by 2002:aed:2336:: with SMTP id h51mr44913193qtc.125.1560870662199;
        Tue, 18 Jun 2019 08:11:02 -0700 (PDT)
X-Received: by 2002:aed:2336:: with SMTP id h51mr44913142qtc.125.1560870661631;
        Tue, 18 Jun 2019 08:11:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560870661; cv=none;
        d=google.com; s=arc-20160816;
        b=WQUIEszuRJI/8P+ZgCYeroGPgOR60vxUqG2y6TNyaHZ2kk5XSMcIIYcq7MI61i4VA+
         Aob37fTCpbOQYpPmOWItuVteC/kUYmMcYfmQW+itqX4wJ/7Ly/PaFvEyNYxww0DatxkZ
         b+QkcacE0Sd9vmn/uuGGyTa61itoOpjApJE05q3vHpma6FQng3vOo8Dbh3VYSxQos5UC
         JrP0pwLCbxcSPCMGMdNsSP/Ec3Gm89lVyPMAmAfFFpBngMh/F0XSAM7PlxaA7whOhEwi
         LnXIiKiaX8QMw7pEbd4w7FL/Y6nujYKYbdQKQCCk2heOxQi7pcfrK0m/zvowi4+QXzqI
         8jzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pqCED5mYNInU5PAv2mesXGcqWFvLrmpHYJb9ulnVVgI=;
        b=qd8iSmOoiFOzRmlfDjA/MIsDzA8wlgAnbJZvz7p+EiZs9oht6TIhvXmpwJ+8yuvl7V
         78xeOHbdmHf1G8YqSUUw5xQoc3mTu6onBYRhLvubyEvTQhkxnrNb7/lVwOcGRNJAOefJ
         roof436R6Msx6wEJSOeQZVT7W2aTWW6KWUto2gSL0wF0RbVphHHmhjm7LUk6q3gfm9Jj
         TW1Yzzxx7rmVNM/+FpkJ2BiGFafCxpMMnZIoVXLUqwVzete0gnN6Z+N1LY5RYakW7Rnx
         rm47IhzzLDCE7XX8mDDoVcyy6OO6Lz22QlF0KHHHKG5nVeHpd0etPDlYk3umfxLjFNgi
         Ritg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nCh2sLXr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor9492494qkd.25.2019.06.18.08.11.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 08:11:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nCh2sLXr;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pqCED5mYNInU5PAv2mesXGcqWFvLrmpHYJb9ulnVVgI=;
        b=nCh2sLXrPktHy5XUJpjTlsCcshtqkRGZMfOua9pN5auRQe260AAMJlewmn5vXSTf2e
         Yc6POt9RnXEBOGGODqrP1rFPH7Cwm6+JhjPT5/rllkwaH/LtoXrRvluoAV6oe4NarBzt
         1k5+QybFYGGCga2ITf4dP/dJkwooOrYiCGgJL9cFPsdHIBZq5pdRYq1+Pz/XBNpoCt7E
         gS6VMSVDRqNygqmTx+TNLNkcy7/motNSfs4g6axRbb+X8ahuJ+lBfs2r0vK6Gb5qHpps
         EtDtwPMeiq+vcBcuwP536GU8VcFj8CLrVVuBc2x1aB7dl4PGOS5QoIPYqgsDjQ7l2cLm
         LZlg==
X-Google-Smtp-Source: APXvYqzNqG1TNcSVdITe8C3fCMJFkUWykHx0vaCyd8hF7H/75BSskda+UeSXCPEKbmE+kRdajwWEsQ==
X-Received: by 2002:a37:7847:: with SMTP id t68mr91753295qkc.128.1560870661341;
        Tue, 18 Jun 2019 08:11:01 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 15sm8515948qtf.2.2019.06.18.08.11.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 08:11:00 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdFlE-0008OK-D5; Tue, 18 Jun 2019 12:11:00 -0300
Date: Tue, 18 Jun 2019 12:11:00 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 06/12] mm/hmm: Hold on to the mmget for the
 lifetime of the range
Message-ID: <20190618151100.GI6961@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-7-jgg@ziepe.ca>
 <20190615141435.GF17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615141435.GF17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:14:35AM -0700, Christoph Hellwig wrote:
> >  	mutex_lock(&hmm->lock);
> > -	list_for_each_entry(range, &hmm->ranges, list)
> > -		range->valid = false;
> > -	wake_up_all(&hmm->wq);
> > +	/*
> > +	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
> > +	 * prevented as long as a range exists.
> > +	 */
> > +	WARN_ON(!list_empty(&hmm->ranges));
> >  	mutex_unlock(&hmm->lock);
> 
> This can just use list_empty_careful and avoid the lock entirely.

Sure, it is just a debugging helper and the mmput should serialize
thinigs enough to be reliable. I had to move the RCU patch ahead of
this. Thanks

diff --git a/mm/hmm.c b/mm/hmm.c
index a9ace28984ea42..1eddda45cefae7 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -124,13 +124,11 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
 	if (!kref_get_unless_zero(&hmm->kref))
 		return;
 
-	mutex_lock(&hmm->lock);
 	/*
 	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
 	 * prevented as long as a range exists.
 	 */
-	WARN_ON(!list_empty(&hmm->ranges));
-	mutex_unlock(&hmm->lock);
+	WARN_ON(!list_empty_careful(&hmm->ranges));
 
 	down_write(&hmm->mirrors_sem);
 	mirror = list_first_entry_or_null(&hmm->mirrors, struct hmm_mirror,
@@ -938,7 +936,7 @@ void hmm_range_unregister(struct hmm_range *range)
 		return;
 
 	mutex_lock(&hmm->lock);
-	list_del(&range->list);
+	list_del_init(&range->list);
 	mutex_unlock(&hmm->lock);
 
 	/* Drop reference taken by hmm_range_register() */

