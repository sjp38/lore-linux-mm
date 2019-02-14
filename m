Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5A0DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:39:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A33D2147C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A33D2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 196D98E0002; Thu, 14 Feb 2019 16:39:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 148B68E0001; Thu, 14 Feb 2019 16:39:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 037658E0002; Thu, 14 Feb 2019 16:39:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA0938E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:39:27 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id e31so6941106qtb.22
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:39:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=s35jh3LllDPkRpPyieU7vUJCfrRoayTstsbDUCPNZ3M=;
        b=Hy099vG+YqWNmLP1+kRJZhxjaKyla/JgyIveQq0qHb9whR/2iHzpZsSl8PSv61ULZ3
         xEC48olYK/18r0tr0ELo6NZRom1kUPRbMfQqwx2bWWA0yiJ1VoQlsdCq/bGKy9Qm1mvM
         aRi9GO1xc46V2tKTdezlFG2HYiJKRUH68lpKViofGGTL6n3M96mV1nt5v6VY9tk2qt7r
         +MiTh23ivNNxsMAJq3667G88jbR4Y0ElYreLqAGvEfUfggLYgWis0pbGyOUuRXI+3GJI
         IKm6/Tcn8ivWX4VJgV/m4OYuNUPYW4QVpkib3cFL5dejzK0MCNge4Wle11GGEup3xQ2A
         C5aQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaZXU+cc6ubKkAhWQCc9a9zDCBe5HKFneX30aHkPbf1KbEDCCmF
	Qh4g0T8Ou0tFTijSavwl5b4YdNXH69nItVzK2M/6SHUCAlvyn66km8DnRo6pNyI9bXKNyJ8mRlH
	/ZC6jJhno8S8EKAVCLD7/fHnI/aOkngy6U3ud4lvhFu6tdYTS2fx6SpgaU7QyzSnLGA==
X-Received: by 2002:ac8:285c:: with SMTP id 28mr4800403qtr.54.1550180367579;
        Thu, 14 Feb 2019 13:39:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7/MKCEVL9UCxAFrF918tOiLSHB+XnPl7cuv+PujeUStEZcFd7U5emarf3OGV5Bg6b41kL
X-Received: by 2002:ac8:285c:: with SMTP id 28mr4800378qtr.54.1550180366962;
        Thu, 14 Feb 2019 13:39:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550180366; cv=none;
        d=google.com; s=arc-20160816;
        b=daITP89sZQDZkbDs4ldz63qTca+W5vc6/zw++3JxRLGv71oG62T8xTYg43Crg8AQ0q
         23oTHIEluv6nWqGTQzCRiqOsHcfBWfCwGhVEYGxlXxSddJWKPBbzu4jRaX3T3ivoimIn
         T/DnTbtLfsQnmKdjkOuN3txo5IlTpr1636JwxVD5RHRyKNgymzSwuxeRorT50Lrbj0kG
         2l8yuvSWi7bETQY/wDZ1E1wDMaAc7V79bSvmzL7PvlYAXmn2Czlp5UTFvQ/SIW3xTWh4
         9eAQDJ/ZzQ9BsqUT9Xkgoy3Z5LLl/wbYOTRnw45t7woeilRapf5qaNcNTUO0F5rIfdbx
         WtCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=s35jh3LllDPkRpPyieU7vUJCfrRoayTstsbDUCPNZ3M=;
        b=QEzetrJCIP34lc6QoRKbNN9i1mKQRpvaVvstW6s9hAcK80jMSEHca3i3hj27ue9fog
         nzHWsHBmg1Y9wCsJm2Sdscwr/B6vZLrQYfP53Odr+VWRpPaf3xTyN5KBuN/NGP5uJu/y
         Row4PXyDHlJ+MzB4nr1hvMgnY5s/v9nXiVqT0YqdgabAD/p0WSFQWCOchLcsRlk1t1co
         fDiqhF+gkVZVghnrPcY02L07jlJQOhRK/PW0j99+KwVcZqtdtcbs0RRBcdnr+LyAQTvj
         m/nIRmTPwCObN9/Hfsis7Q4JCRLy4uUQsq4QtRam8BRTxtKObawBHxjxe1veqjSl4vOm
         YSVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b203si1343740qka.144.2019.02.14.13.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 13:39:26 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1AD2A7A48C;
	Thu, 14 Feb 2019 21:39:26 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8A9535ED22;
	Thu, 14 Feb 2019 21:39:24 +0000 (UTC)
Date: Thu, 14 Feb 2019 16:39:22 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190214213922.GD3420@redhat.com>
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
 <20190214205049.GC12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190214205049.GC12668@bombadil.infradead.org>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 14 Feb 2019 21:39:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 12:50:49PM -0800, Matthew Wilcox wrote:
> On Thu, Feb 14, 2019 at 03:26:22PM -0500, Jerome Glisse wrote:
> > On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
> > > But it also doesnt' trucate/create a hole. Another thread wrote to it
> > > right away and the 'hole' was essentially instantly reallocated. This
> > > is an inherent, pre-existing, race in the ftrucate/etc APIs.
> > 
> > So it is kind of a // point to this, but direct I/O do "truncate" pages
> > or more exactly after a write direct I/O invalidate_inode_pages2_range()
> > is call and it will try to unmap and remove from page cache all pages
> > that have been written too.
> 
> Hang on.  Pages are tossed out of the page cache _before_ an O_DIRECT
> write starts.  The only way what you're describing can happen is if
> there's a race between an O_DIRECT writer and an mmap.  Which is either
> an incredibly badly written application or someone trying an exploit.

I believe they are tossed after O_DIRECT starts (dio_complete). But
regardless the issues is that an RDMA can have pin the page long
before the DIO in which case the page can not be toss from the page
cache and what ever is written to the block device will be discarded
once the RDMA unpin the pages. So we would end up in the code path
that spit out big error message in the kernel log.

Cheers,
Jérôme

