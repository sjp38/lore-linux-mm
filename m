Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04856C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 23:24:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6C092147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 23:24:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6C092147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BFB98E0003; Tue, 12 Mar 2019 19:24:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 147FA8E0002; Tue, 12 Mar 2019 19:24:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2AB18E0003; Tue, 12 Mar 2019 19:24:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A977F8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 19:24:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n24so18405pgm.17
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:24:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+FO/aZAptqOuIx/FLxANaTDEsqif69hcVQygxSgbHdw=;
        b=Et/q7uH+XzsTkeryU1RL3r8XTxiqp+M2a7dAxqQvCf8GCRjzRq6Z9+6iUgWP9AJhz8
         qEAxLr6hI6hbx83XWgPVWZgE0LoaT6NjFh9zdfzXk7bGi/3HTN+U+64+ZtgxmHfe3mfq
         c+5Ei9zX1hnCn3d8MB5o/zNmEmmnYeRPxgF5DX4Sch4ScEMgtCf4tF/3KUAoZmWOOFlz
         CXP84l894sdF44sZPLoCSO1Oby7HqGOAGnPX12JfRuMLVbTPGtdfbsaXC7yvnA/Wp6cG
         P9mSUjR1NqbUzLKOm0JdSn5Hwsqw8smb2osUvPnIbopPcGksHFa1Pj0oF08cEBrOcR/V
         X60Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVGGkfUEZjRQtDUcpuq7mkOpmDNWpW2sk2J8Yg9EMY9KSuxQ4nl
	w4msZhS+c/+bzdAo7WDJFtro4G4MGLtGBxI9obDMi1z+ksD18fU+knHc7MFCI6U+2WD3gXMuJo4
	xSbpSFOifewhlr8eWuJEII5c+5nLzNIWwpKHcvMCJZWeSLBI4S1GOjjVtVe38sKaKgQ==
X-Received: by 2002:aa7:8516:: with SMTP id v22mr6048976pfn.23.1552433087291;
        Tue, 12 Mar 2019 16:24:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwx5iBCU2LKycQFZw2JQMmsYNYJPC+gyW0XyptnDka9ancqkM6P8zdcAImGuZfh8uag2JDT
X-Received: by 2002:aa7:8516:: with SMTP id v22mr6048931pfn.23.1552433086183;
        Tue, 12 Mar 2019 16:24:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552433086; cv=none;
        d=google.com; s=arc-20160816;
        b=q7HaOwYbTRzpRTZlGZeSIs2IM2++vkS8h8xppSe0XCv2vVOFgS3r+BxgK0S0M2CCKc
         92AaV6eZ3WP8ku61afwai22cEW1All6AfIA2+xqnrkhyuQGBPwwhNRMo2I4NHDjtY7Vd
         JC2upwlaptVGGgZgOC3Kpcy5uf2ntnBvz/EpoIxcemwakuA81ZMrRA8umpTZjb94HGuv
         YKElCUPTKxuB+uc7QUONkyXdGEGWiJn+eQnrt5Nr2UJYmi5l58FC/eZJ5nfWnTmIuQCD
         +Cb0sPJRZ7GnU4lis//2aIiuXETGPYw/FJ7aEmLQfG7D3bFzrEiFZlBUCOf1hJCeCIHx
         fqvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+FO/aZAptqOuIx/FLxANaTDEsqif69hcVQygxSgbHdw=;
        b=wToanrtdqbm2JnpFbawBDUXAgiyOZTjtfgu9fCdkn7BfgEt+YvgxV52lec0lDnbpWf
         s/y2zdvv9c9KVpmjLVmQ/EW2gClsKzPZTyx3P7R7+mM0TNb1GpAkhEXoWB2b0VsKg19I
         aoqFpZ4voHQFONkz1KsioFNP7KMPvo2bnF1s8+9HOIfi6019zefL0q9z1BlfmsWOXytN
         NmfIS4nUPvRjoNM6R0mO5rb8fc3BsU4ufjfHxumxOIURWsKzNMLArQtS6DZToP+zN2hy
         Oljtk6M2lXhuDxkLU2ZAm4Ru9OYuVO0y0keAEmpYPKGwShZjeHFct/Q/OlxRGsayDpOj
         JVMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a7si9174075plm.420.2019.03.12.16.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 16:24:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Mar 2019 16:24:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,472,1544515200"; 
   d="scan'208";a="131107170"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 12 Mar 2019 16:24:45 -0700
Date: Tue, 12 Mar 2019 08:23:16 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Christopher Lameter <cl@linux.com>, john.hubbard@gmail.com,
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
Message-ID: <20190312152316.GF1119@iweiny-DESK2.sc.intel.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190310224742.GK26298@dastard>
 <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
 <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
 <20190312221113.GF23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312221113.GF23020@dastard>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:11:13AM +1100, Dave Chinner wrote:
> On Tue, Mar 12, 2019 at 03:39:33AM -0700, Ira Weiny wrote:
> > IMHO I don't think that the copy_file_range() is going to carry us through the
> > next wave of user performance requirements.  RDMA, while the first, is not the
> > only technology which is looking to have direct access to files.  XDP is
> > another.[1]
> 
> Sure, all I doing here was demonstrating that people have been
> trying to get local direct access to file mappings to DMA directly
> into them for a long time. Direct Io games like these are now
> largely unnecessary because we now have much better APIs to do
> zero-copy data transfer between files (which can do hardware offload
> if it is available!).
> 
> It's the long term pins that RDMA does that are the problem here.
> I'm asssuming that for XDP, you're talking about userspace zero copy
> from files to the network hardware and vice versa? transmit is
> simple (read-only mapping), but receive probably requires bpf
> programs to ensure that data (minus headers) in the incoming packet
> stream is correctly placed into the UMEM region?

Yes, exactly.

> 
> XDP receive seems pretty much like the same problem as RDMA writes
> into the file. i.e.  the incoming write DMAs are going to have to
> trigger page faults if the UMEM is a long term pin so the filesystem
> behaves correctly with this remote data placement.  I'd suggest that
> RDMA, XDP and anything other hardware that is going to pin
> file-backed mappings for the long term need to use the same "inform
> the fs of a write operation into it's mapping" mechanisms...

Yes agreed.  I have a hack patch I'm testing right now which allows the user to
take a LAYOUT lease from user space and GUP triggers on that, either allowing
or rejecting the pin based on the lease.  I think this is the first step of
what Jan suggested.[1]  There is a lot more detail to work out with what
happens if that lease needs to be broken.

> 
> And if we start talking about wanting to do peer-to-peer DMA from
> network/GPU device to storage device without going through a
> file-backed CPU mapping, we still need to have the filesystem
> involved to translate file offsets to storage locations the
> filesystem has allocated for the data and to lock them down for as
> long as the peer-to-peer DMA offload is in place.  In effect, this
> is the same problem as RDMA+FS-DAXs - the filesystem owns the file
> offset to storage location mapping and manages storage access
> arbitration, not the mm/vma mapping presented to userspace....

I've only daydreamed about Peer-to-peer transfers.  But yes I think this is the
direction we need to go.  But The details of doing a

GPU -> RDMA -> {network } -> RDMA -> FS DAX

And back again... without CPU/OS involvement are only a twinkle in my eye...
If that.

Ira

[1] https://lore.kernel.org/lkml/20190212160707.GA19076@quack2.suse.cz/

