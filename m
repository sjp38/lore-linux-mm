Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18346C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:08:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1CDD21B1C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:08:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1CDD21B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 665658E0162; Mon, 11 Feb 2019 16:08:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 613E88E0155; Mon, 11 Feb 2019 16:08:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52A518E0162; Mon, 11 Feb 2019 16:08:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A21B8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:08:32 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id m34so372529qtb.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:08:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=uYu8fhGrCPe5ORQZnf2SfiOVoXmG+qDHSpTQJMH4p34=;
        b=KCKgFjJgLBnlA6oeC/kjjb3HiuPeKu67FF7YgdbEWBxwtqyYD4AJDnFJEyFVUwpoua
         F3nuC8FZw+9DG1ED7ThVIs9XCFNx3crJ5Wbu7Q4QEJbj9p4PzGJHvU5vGuvyI9oQXm5D
         KJmfLelgFvCEgTnHWNFkQo+Y4U+1h0iOKiJ9+45FFppESyh65UPenqkN1qLz7iWloRao
         47ZVayJqDupW/ETqfrROHcxuk8YDU5n5678+2l+GzBxcD/otE9fy2FFvWrtfMzYPi6nh
         fiKNWLD8onQsv1R/uqtKGHEibzgP45OsAEU5J5onzcrZkN7staras9NBv3qxzU2u5HMm
         W9uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYfcEhQjXqusDysyntxDh2KSo6tHpLFp4T4FAw4qheeOK6tkuQS
	Gv1DP8urlTBlWUcCB9lWFdPMuKOjQn5+zGmei2Jkdk9a85p99I/bTpD4GVmMwHpzkxiDWruO7cf
	nV1cwuavdH/C7FuP+1fCmMOsJ4wRTR/3gd7b/y85T4oo6FiVG/dk/7+mKFw31H8n5Mg==
X-Received: by 2002:ac8:dc5:: with SMTP id t5mr187348qti.80.1549919311906;
        Mon, 11 Feb 2019 13:08:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZRGp9Za3j553SAAirnFfFB0YaxEM/AK2MPDgEcCJ/kWfHfHXXOf2LV1aKOvjZ747k+Mmv4
X-Received: by 2002:ac8:dc5:: with SMTP id t5mr187312qti.80.1549919311211;
        Mon, 11 Feb 2019 13:08:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549919311; cv=none;
        d=google.com; s=arc-20160816;
        b=PK3WG4NWZJLLtOpnuFM5xy7AY6GTQXf2wz+mPIXp8SSZUGoTWAoOTe9PvWVjazUpfp
         GR3LeO9Tzr9/+fagzg7fp540UaDvykjUPmhVSrLh55qEc/j6zChiLgfTzf5B4DF7zHCK
         Ix2uLExfTweziH8qqMfqv+3wSB/femrWbFwkLwMbkPlpSzxzvJs7RYWNyjdaucAS+rIO
         hma+837f5a44reg8pHE+4wJhNIXihMHj66luf1l72JxMdHIQ/NXUU+i2JXShq1XLJZP9
         kkimRAOZMzfox7r9IojTW9mBJO14m9A1G+HSMAchD+lB8QM5dNl1FF5NrxYFEzywlXCX
         rTRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=uYu8fhGrCPe5ORQZnf2SfiOVoXmG+qDHSpTQJMH4p34=;
        b=aJzJHAdnrQrgcUgPcP7nDatA4pAOfHbS45R/eT8Hs5HCMVTortpwviy693QIsr8Vs4
         31pZgXXV6wjVgL6XOTpNn22xpn3IGVATcQgQTsxLzfbvdUqTzXRmyFql05LLGJCanMEQ
         jtUwHIgia2hD2ret3stoCWGzCIUV/jzIoxl+NqducZ3WkOL/3wIlvMrvXmRDVJ9lzBlN
         B0hCuFur4SF8cR7bS5mD4zHjkZ7+vy2KhmZqd4dIYdUsiUBKeFtM6jdma3G+7ByvcxHf
         DTO5GjJ9gWu6SLayWIvs+F55/AfW6+MiB2MPZhY5eEtEkkHd0+GiJC2y04B87mbh1NvF
         Z4+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p18si646768qkg.40.2019.02.11.13.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:08:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 092C65D61C;
	Mon, 11 Feb 2019 21:08:30 +0000 (UTC)
Received: from redhat.com (ovpn-123-21.rdu2.redhat.com [10.10.123.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8DE6A60A9A;
	Mon, 11 Feb 2019 21:08:27 +0000 (UTC)
Date: Mon, 11 Feb 2019 16:08:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211210824.GH3908@redhat.com>
References: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 11 Feb 2019 21:08:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:19:22AM -0800, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 09:22:58AM -0800, Dan Williams wrote:
> > 
> > > I honestly don't like the idea that random subsystems can pin down
> > > file blocks as a side effect of gup on the result of mmap. Recall that
> > > it's not just RDMA that wants this guarantee. It seems safer to have
> > > the file be in an explicit block-allocation-immutable-mode so that the
> > > fallocate man page can describe this error case. Otherwise how would
> > > you describe the scenarios under which FALLOC_FL_PUNCH_HOLE fails?
> > 
> > I rather liked CL's version of this - ftruncate/etc is simply racing
> > with a parallel pwrite - and it doesn't fail.
> > 
> > But it also doesnt' trucate/create a hole. Another thread wrote to it
> > right away and the 'hole' was essentially instantly reallocated. This
> > is an inherent, pre-existing, race in the ftrucate/etc APIs.
> 
> I kind of like it as well, except Christopher did not answer my question:
> 
> What if user space then writes to the end of the file with a regular write?
> Does that write end up at the point they truncated to or off the end of the
> mmaped area (old length)?
> 
> To make this work I think it has to be the later.  And as you say the semantic
> is as if another thread wrote to the file first (but in this case the other
> thread is the RDMA device).
> 
> In addition I'm not sure what the overall work is for this case?
> 
> John's patches will indicate to the FS that the page is gup pinned.  But they
> will not indicate longterm vs not "shorterm".  A shortterm pin could be handled
> as a "real truncate".  So, are we back to needing a longterm "bit" in struct
> page to indicate a longterm pin and allow the FS to perform this "virtual
> write" after truncate?
> 
> Or is it safe to consider all gup pinned pages this way?

So i have been working on several patchset to convert all user that can
abide to mmu notifier to HMM mirror which does not pin pages ie does not
take reference on the page. So all the left over GUP users would be the
long term problematic one with few exceptions: direct I/O, KVM (i
think xen too but i am less familiar with that), virtio.

For direct I/O i believe the ignore the truncate solution would work too.
For KVM and virtio i think it only does GUP on anonymous memory.

So the answer would be that it is safe to consider all pin pages as being
longterm pin.

Cheers,
Jérôme

