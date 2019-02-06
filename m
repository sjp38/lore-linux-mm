Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4B3BC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 598242081B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:30:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="QIuW9LI2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 598242081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB99F8E0003; Wed,  6 Feb 2019 18:30:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E689E8E0002; Wed,  6 Feb 2019 18:30:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7E538E0003; Wed,  6 Feb 2019 18:30:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA3428E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:30:41 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id z6so7686056otm.10
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:30:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=T3b2MLi3MjpOPd5FBKE6OQ6jKVHgNeTR55d4ovo7XUQ=;
        b=e6vtkdsMwdSQO+v1dpA9Fd6mgMHkBd37mJraLA5OrMJ8uaCXklibdw0zKj3IW9Yd26
         fwvF5wsTPtxSs4FHooZtqBBX6ht503tkyIic+uQac7WS39REquKLxcsaVsCdcofUamVh
         oPmLfqpXTEa165YDHMwg6v2CB3mhyPUlwXnUTQEtZtnOyZYotWawE+F1VzuuxJuGhQxp
         cMx5jD+qqJsUNk6v2L84tNqQftgqIdgtzNn3sgSj/ADpof1D5XGS0bgd0vWUTY/44yA3
         r0gDIpWNXO6BJYaggJTHVX5UjWoCgnWibFdjxOoOHHc01wfwd01qwCTeRYyR7UiYXE2F
         scsA==
X-Gm-Message-State: AHQUAuYptR5tntIptrwJAJ/TSM95yPhD8yyyLP0B3HDN+NP6jHeuompY
	+cyw/c1pvDvw5QTc9WISGIBJQsR99qzDCOvO2JfCNYYbPDofYUxYDz7eXYzSKJOg5ql+Y4DlU8O
	dVzzsAJCLI97rC79ChWSb4uPHSh2lpIT4QpDqcCj6r0P4JLllB5A7cz/PCsrAkYAJ+OIs8Shy3o
	u1EBa71oKtjstmeS6oLcaIzvWgA9HGOYXhngTT9obsDNlMcdi9A+830PxSxiF+f5/yaXEnWV5kA
	DhcC+q3yfc/3Fofb8J/zZDobG5H0N13JkFev3Z6/df80+xctybE/KMHr0zs5ex3cBI+ioH2zXTr
	pPYq15hUtirNPX6A9uBQXvcJwiobQv7jaDKT98t3FHZkaZwrFD6Jbeebzkf5iH9qYob4UT3zXbr
	c
X-Received: by 2002:aca:db85:: with SMTP id s127mr918148oig.165.1549495841380;
        Wed, 06 Feb 2019 15:30:41 -0800 (PST)
X-Received: by 2002:aca:db85:: with SMTP id s127mr918096oig.165.1549495839897;
        Wed, 06 Feb 2019 15:30:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549495839; cv=none;
        d=google.com; s=arc-20160816;
        b=iS5rVAh6+7t6ZmeoshHD0Cih59607RpdPqPr6LjHMTeEoSZYwI9B+iF50hOu+p/EWP
         T1lGBcQ7wi134gB778xJ273DZlcIjnrCB1lGl8fYASqUrUzEN+XH2ARyqvhUe1aNOj63
         GkYDzZUhfXXU4lOpYE8OzJxLhKgqEykKs2SNg0rnbrE1VEoMipBxZZDNAUOcPv0sJ5Cm
         q8uJ4FWO402jSVCHov4JYAKGzs1w7WtuY2PO9CR8LMn0/7y4zwrLNq6vhrKRANfS6CEf
         ewCnRGsMw3w36VPtRYEZPUDXNi6wt3Nxt7gMaxjHiZ4O20XHlwPAnmWs5P702tFpiKy4
         LFdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=T3b2MLi3MjpOPd5FBKE6OQ6jKVHgNeTR55d4ovo7XUQ=;
        b=vxoCMYXlZJi2zkIQfwflYaA7RyuwP/oR8kWOnQfn2Wk3C6pT16OXqI4O8CUJ9D8WGZ
         uBRXv1pHxFG8PU7gfqnq5HznVZ2hSjhw4EoS7J3+ianN6x0Z8WTYv1H2hLqCDlwTMEJ9
         jxu/fCLGnwxiBzedxmx13sCQu6phx6h7yoxAS9/eAFfWhDS8kRq3EvSCNkmnv4iSW4q1
         +BmenMja2bj3I76PaKrtcxo0wLFcI4dxSSg7xgCZai9kRD38VNfBY4fqDGJ1aRF+e7x5
         guffGFL6g/3lSyNiZZujZqtthE5E3XsbJbf9hoY6YCuxeCAG9NX0sbrPKiw3VZkItcbM
         hwCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=QIuW9LI2;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 61sor15059022otd.108.2019.02.06.15.30.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 15:30:39 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=QIuW9LI2;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T3b2MLi3MjpOPd5FBKE6OQ6jKVHgNeTR55d4ovo7XUQ=;
        b=QIuW9LI2AF2eWV3QLOhh/BbiJpeQBnZY6Fw1hbYkrfntghjEMg8J74FTfr3VGzkYwL
         tkBFB7QL04yqglF2EwKpiKRIkhgzqNXys8EkhZR3x1V7umOgeOCdkYq/dfIwVeCRf6TY
         GKWpOh6Jbw9MsTEcXtRuEybTalW8tangzSPI6EhzMHBbQdq+xRfdbTTRLFquF612HFCX
         Bu8KF7weUROBMdBc8JKyBoU91fhxlXg+DzUr5p2uBa+I6GyDLj5VgFHD0Iqkgeos1gX2
         GETWMRpFRGZQW0zS1OEBpZJwHuEDQXuNzHnUgHu9df5srbrJJDIGWqukdc9uVLMZ+bHM
         nu0Q==
X-Google-Smtp-Source: AHgI3IayjFYRZY3pSXkyZVgC3dGVYY9+g7blthD7FrC9+B+OiT/qR4rquAdDecTZD2PeFpTHuQXbZDc47JNrCDAjntk=
X-Received: by 2002:a9d:7dd5:: with SMTP id k21mr7268168otn.214.1549495839552;
 Wed, 06 Feb 2019 15:30:39 -0800 (PST)
MIME-Version: 1.0
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com> <20190206232130.GK12227@ziepe.ca>
In-Reply-To: <20190206232130.GK12227@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 15:30:27 -0800
Message-ID: <CAPcyv4g2r=L3jfSDoRPt4VG7D_2CxCgv3s+JLu4FQRUSRWg+4Q@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Doug Ledford <dledford@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 3:21 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Feb 06, 2019 at 02:44:45PM -0800, Dan Williams wrote:
>
> > > Do they need to stick with xfs?
> >
> > Can you clarify the motivation for that question? This problem exists
> > for any filesystem that implements an mmap that where the physical
> > page backing the mapping is identical to the physical storage location
> > for the file data.
>
> .. and needs to dynamicaly change that mapping. Which is not really
> something inherent to the general idea of a filesystem. A file system
> that had *strictly static* block assignments would work fine.
>
> Not all filesystem even implement hole punch.
>
> Not all filesystem implement reflink.
>
> ftruncate doesn't *have* to instantly return the free blocks to
> allocation pool.
>
> ie this is not a DAX & RDMA issue but a XFS & RDMA issue.
>
> Replacing XFS is probably not be reasonable, but I wonder if a XFS--
> operating mode could exist that had enough features removed to be
> safe?

You're describing the current situation, i.e. Linux already implements
this, it's called Device-DAX and some users of RDMA find it
insufficient. The choices are to continue to tell them "no", or say
"yes, but you need to submit to lease coordination".

> Ie turn off REFLINK. Change the semantic of ftruncate to be more like
> ETXTBUSY. Turn off hole punch.
>
> > > Are they really trying to do COW backed mappings for the RDMA
> > > targets?  Or do they want a COW backed FS but are perfectly happy
> > > if the specific RDMA targets are *not* COW and are statically
> > > allocated?
> >
> > I would expect the COW to be broken at registration time. Only ODP
> > could possibly support reflink + RDMA. So I think this devolves the
> > problem back to just the "what to do about truncate/punch-hole"
> > problem in the specific case of non-ODP hardware combined with the
> > Filesystem-DAX facility.
>
> Usually the problem with COW is that you make a READ RDMA MR and on a
> COW'd file, and some other thread breaks the COW..
>
> This probably becomes a problem if the same process that has the MR
> triggers a COW break (ie by writing to the CPU mmap). This would cause
> the page to be reassigned but the MR would not be updated, which is
> not what the app expects.
>
> WRITE is simpler, once the COW is broken during GUP, the pages cannot
> be COW'd again until the DMA pin is released. So new reflinks would be
> blocked during the DMA pin period.
>
> To fix READ you'd have to treat it like WRITE and break the COW at GPU.

Right, that's what I'm proposing that any longterm-GUP break COW as if
it were a write.

