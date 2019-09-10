Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51329C5AE59
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 22:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CEE82171F
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 22:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CEE82171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA7EB6B0007; Tue, 10 Sep 2019 18:14:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A30BB6B0008; Tue, 10 Sep 2019 18:14:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F7756B000A; Tue, 10 Sep 2019 18:14:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0018.hostedemail.com [216.40.44.18])
	by kanga.kvack.org (Postfix) with ESMTP id 670F36B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 18:14:50 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F3EAC8243765
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:14:49 +0000 (UTC)
X-FDA: 75920416740.01.floor38_6453a9bcc0063
X-HE-Tag: floor38_6453a9bcc0063
X-Filterd-Recvd-Size: 4033
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:14:49 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Sep 2019 15:14:48 -0700
X-IronPort-AV: E=Sophos;i="5.64,490,1559545200"; 
   d="scan'208";a="178822353"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Sep 2019 15:14:48 -0700
Message-ID: <ac75ce0302faa234860a49cc965a6d342b3ca685.camel@linux.intel.com>
Subject: Re: [PATCH v9 1/8] mm: Add per-cpu logic to page shuffling
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, virtio-dev@lists.oasis-open.org, 
 kvm@vger.kernel.org, mst@redhat.com, catalin.marinas@arm.com, 
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, 
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org, 
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
 yang.zhang.wz@gmail.com,  pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com,  lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com,  ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,  fengguang.wu@intel.com,
 kirill.shutemov@linux.intel.com
Date: Tue, 10 Sep 2019 15:14:47 -0700
In-Reply-To: <20190910121130.GU2063@dhcp22.suse.cz>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172512.10910.74435.stgit@localhost.localdomain>
	 <0df2e5d0-af92-04b4-aa7d-891387874039@redhat.com>
	 <0ca58fea280b51b83e7b42e2087128789bc9448d.camel@linux.intel.com>
	 <20190910121130.GU2063@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-10 at 14:11 +0200, Michal Hocko wrote:
> On Mon 09-09-19 08:11:36, Alexander Duyck wrote:
> > On Mon, 2019-09-09 at 10:14 +0200, David Hildenbrand wrote:
> > > On 07.09.19 19:25, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Change the logic used to generate randomness in the suffle path so that we
> > > > can avoid cache line bouncing. The previous logic was sharing the offset
> > > > and entropy word between all CPUs. As such this can result in cache line
> > > > bouncing and will ultimately hurt performance when enabled.
> > > 
> > > So, usually we perform such changes if there is real evidence. Do you
> > > have any such performance numbers to back your claims?
> > 
> > I'll have to go rerun the test to get the exact numbers. The reason this
> > came up is that my original test was spanning NUMA nodes and that made
> > this more expensive as a result since the memory was both not local to the
> > CPU and was being updated by multiple sockets.
> 
> What was the pattern of page freeing in your testing? I am wondering
> because order 0 pages should be prevailing and those usually go via pcp
> lists so they do not get shuffled unless the batch is full IIRC.

So I am pretty sure my previous data was faulty. One side effect of the
page reporting is that it was evicting pages out of the guest and when the
pages were faulted back in they were coming from local page pools. This
was throwing off my early numbers and making tests look better than they
should have for the reported case.

I had this patch previously merged with another one so I wasn't testing it
on its own, it was instead a part of a bigger set. Now that I have tried
testing it on its own I can see that it has no significant impact on
performance. With that being the case I will probably just drop it.


