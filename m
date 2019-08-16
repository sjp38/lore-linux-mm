Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D387CC3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A4D6206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:59:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A4D6206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369146B0007; Fri, 16 Aug 2019 17:59:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 318B86B000A; Fri, 16 Aug 2019 17:59:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22EA06B000C; Fri, 16 Aug 2019 17:59:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id 018E96B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:59:57 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AAACA8248AD2
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:59:57 +0000 (UTC)
X-FDA: 75829659234.26.dog35_73e9806d1953d
X-HE-Tag: dog35_73e9806d1953d
X-Filterd-Recvd-Size: 4033
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:59:56 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Aug 2019 14:59:54 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,394,1559545200"; 
   d="scan'208";a="201663215"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga004.fm.intel.com with ESMTP; 16 Aug 2019 14:59:54 -0700
Date: Fri, 16 Aug 2019 14:59:54 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190816215954.GA19549@iweiny-DESK2.sc.intel.com>
References: <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <20190815173237.GA30924@iweiny-DESK2.sc.intel.com>
 <b378a363-f523-518d-9864-e2f8e5bd0c34@nvidia.com>
 <58b75fa9-1272-b683-cb9f-722cc316bf8f@nvidia.com>
 <20190816154108.GE3041@quack2.suse.cz>
 <20190816183337.GA371@iweiny-DESK2.sc.intel.com>
 <a584cfbd-b458-dce9-4144-3b542bcf163d@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a584cfbd-b458-dce9-4144-3b542bcf163d@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 11:50:09AM -0700, John Hubbard wrote:
> On 8/16/19 11:33 AM, Ira Weiny wrote:
> > On Fri, Aug 16, 2019 at 05:41:08PM +0200, Jan Kara wrote:
> > > On Thu 15-08-19 19:14:08, John Hubbard wrote:
> > > > On 8/15/19 10:41 AM, John Hubbard wrote:
> > > > > On 8/15/19 10:32 AM, Ira Weiny wrote:
> > > > > > On Thu, Aug 15, 2019 at 03:35:10PM +0200, Jan Kara wrote:
> > > > > > > On Thu 15-08-19 15:26:22, Jan Kara wrote:
> > > > > > > > On Wed 14-08-19 20:01:07, John Hubbard wrote:
> > > > > > > > > On 8/14/19 5:02 PM, John Hubbard wrote:
> > > > ...
> > > > 
> > > > OK, there was only process_vm_access.c, plus (sort of) Bharath's sgi-gru
> > > > patch, maybe eventually [1].  But looking at process_vm_access.c, I think
> > > > it is one of the patches that is no longer applicable, and I can just
> > > > drop it entirely...I'd welcome a second opinion on that...
> > > 
> > > I don't think you can drop the patch. process_vm_rw_pages() clearly touches
> > > page contents and does not synchronize with page_mkclean(). So it is case
> > > 1) and needs FOLL_PIN semantics.
> > 
> > John could you send a formal patch using vaddr_pin* and I'll add it to the
> > tree?
> > 
> 
> Yes...hints about which struct file to use here are very welcome, btw. This part
> of mm is fairly new to me.

I'm still working out the final semantics of vaddr_pin*.  But right now you
don't need a vaddr_pin if you don't specify FOLL_LONGTERM.

Since case 1, this case, does not need FOLL_LONGTERM I think it is safe to
simply pass NULL here.

OTOH we could just track this against the mm_struct.  But I don't think we need
to because this pin should be transient.

And this is why I keep leaning toward _not_ putting these flags in the
vaddr_pin*() calls.  I know this is what I did but I think I'm wrong.  It should
be the caller specifying what they want and the vaddr_pin*() calls check that
what they are asking for is correct.

Ira

> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

