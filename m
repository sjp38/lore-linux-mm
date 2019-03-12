Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDCA0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:41:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 884812077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:41:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 884812077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A9098E0003; Tue, 12 Mar 2019 14:41:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 157C18E0002; Tue, 12 Mar 2019 14:41:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020B88E0003; Tue, 12 Mar 2019 14:41:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B34208E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:41:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d2so4033194pfn.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:41:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ALsnwes5ankFWQd/y9xm0PV9fR/e70I0ltHr+DSdKPc=;
        b=mWs6eZT9/HMAiRjjWYyO4dPkYtScvGDsG2R3IBVDZjwWDrnQUp5fC9gdd6R56ViC7F
         /cY82Q6csV1TttNUGhh2DlePeRBJaGedl8r2EilMGQxK4IAbhUA3LLC03js4f+fMzwoz
         aT2BknVLLoVO9Q9szGgjlVHIbneyHkkXQ3fJB5KDus8ildhzWhka09xAeNUmLWj2/fSg
         5h+KW3CQP0wyFF1rDukCUV4yxUb4N9ld/hTuYpkwGs0baUK7aVTOznHhISuaG4rbEFFa
         vSlSTqmebEy0awHovJkooZ5XULMlX78h5ZFYTyEyoZb8LSaTC56CwjQ0i1FobH48G5N6
         cqiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVdCpD6B30I9iQgVhzvOQrQ2hF2L14LnrB2mduGKGbYCLuwim3G
	Kd6HowuNTT0jMFnqYXQFOty1zheaJG72KYRpceHfSDb0dMpFowbybeEwCjggh2X3nh+WKGF3Zyd
	3zNEcnB2+MKmY+YCNhkTW8bAJfzMxFVtENK56w0n4r6YBPQsKDNZ68yRwwM88wOmOLQ==
X-Received: by 2002:a63:2ad4:: with SMTP id q203mr37136227pgq.43.1552416065240;
        Tue, 12 Mar 2019 11:41:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPAehmLa4Bp5uYE5unx/gNHFp4i4y6/9qknOobQpPd5IWjnqJ5EorU7Nd+kIKpzkcJvDe0
X-Received: by 2002:a63:2ad4:: with SMTP id q203mr37136141pgq.43.1552416063965;
        Tue, 12 Mar 2019 11:41:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552416063; cv=none;
        d=google.com; s=arc-20160816;
        b=kvaI7mSvAhe3+vxwBaktRxFKevXfumdN19Bh5LyQnAzpH0S6s3vEm9vo8TLOPfZrms
         MyG/K2Kr5ZbHFblsbqGOAvECz76zGWHAoKRdZo+9lKYJ09OSrlyD84QRXWAwAiAn2pI1
         GEwsHk99METqaYhXdlhY+Je1Fk+diKkETHsswY0ry6jXp/BsH3vGiqKBors1Q+vy3MeZ
         2MhFLiR8ZmI7eN2vhJ++eWqt+PTb992peujaYDce7VRsbQVvcjtrxQOVML54dfMC9AW+
         iiy9Jo799HnpJfmsNshPQTfCjmommrdcaxi3R4v1LnHjImp7tp+MOXO2VKMQsB2meG2w
         cdgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ALsnwes5ankFWQd/y9xm0PV9fR/e70I0ltHr+DSdKPc=;
        b=NtO5wXyFlU0rOccPmzr4luErN/K7sxrl4fPQxsPr5hyC/ZsvbZbFLnhzrH1PE9nRuy
         IH1ADVhY3nEzbOEaC0aD2jyPS1Sk8b7XimUdiDIVEeNZBHtSfejAc6tAdt+twDDlPsm3
         J9/w1zGY+NBLmVY9K2Ja/iWEQ3OGCVPqReeYQsy8mM8rUbZQYnr7JZfJo2GV0Ls8zFOi
         ZIORr/HEFtMm824OMD8cWRD0/cLfLr6v+1kBuyNhpfbfVtN8g9zlkKbjZtOysr4aQc3r
         XTw8UQtajPpNvoKOxMrIp9Gg19iBp3yvXVloWHmoMFLI0Xh1QK4Kg/ckTnkgj7Kp7h3q
         Gl/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 8si8133679pgq.591.2019.03.12.11.41.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 11:41:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Mar 2019 11:41:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,471,1544515200"; 
   d="scan'208";a="306615952"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 12 Mar 2019 11:41:02 -0700
Date: Tue, 12 Mar 2019 03:39:33 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christopher Lameter <cl@linux.com>
Cc: Dave Chinner <david@fromorbit.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190310224742.GK26298@dastard>
 <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 05:23:21AM +0000, Christopher Lameter wrote:
> On Mon, 11 Mar 2019, Dave Chinner wrote:
> 
> > > Direct IO on a mmapped file backed page doesnt make any sense.
> >
> > People have used it for many, many years as zero-copy data movement
> > pattern. i.e. mmap the destination file, use direct IO to DMA direct
> > into the destination file page cache pages, fdatasync() to force
> > writeback of the destination file.
> 
> Well we could make that more safe through a special API that designates a
> range of pages in a file in the same way as for RDMA. This is inherently
> not reliable as we found out.

I'm not following.  What API was not reliable?  In[2] we had ideas on such an
API but AFAIK these have not been tried.

From what I have seen the above is racy and is prone to the issues John has
seen.  The difference is that Direct IO has a smaller window than RDMA.  (Or at
least I thought we already established that?)

	"And also remember that while RDMA might be the case at least some
	people care about here it really isn't different from any of the other
	gup + I/O cases, including doing direct I/O to a mmap area.  The only
	difference in the various cases is how long the area should be pinned
	down..."

		-- Christoph Hellwig : https://lkml.org/lkml/2018/10/1/591

> 
> > Now we have copy_file_range() to optimise this sort of data
> > movement, the need for games with mmap+direct IO largely goes away.
> > However, we still can't just remove that functionality as it will
> > break lots of random userspace stuff...
> 
> It is already broken and unreliable. Are there really "lots" of these
> things around? Can we test this by adding a warning in the kernel and see
> where it actually crops up?

IMHO I don't think that the copy_file_range() is going to carry us through the
next wave of user performance requirements.  RDMA, while the first, is not the
only technology which is looking to have direct access to files.  XDP is
another.[1]

Ira

[1] https://www.kernel.org/doc/html/v4.19-rc1/networking/af_xdp.html
[2] https://lore.kernel.org/lkml/20190205175059.GB21617@iweiny-DESK2.sc.intel.com/

