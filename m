Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1C26C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 22:11:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71E50216F4
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 22:11:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71E50216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6DC96B0005; Tue, 10 Sep 2019 18:11:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1C7C6B0006; Tue, 10 Sep 2019 18:11:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A347F6B0007; Tue, 10 Sep 2019 18:11:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0196.hostedemail.com [216.40.44.196])
	by kanga.kvack.org (Postfix) with ESMTP id 825C06B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 18:11:54 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2E81562E9
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:11:54 +0000 (UTC)
X-FDA: 75920409348.07.use87_4abdb31229f5b
X-HE-Tag: use87_4abdb31229f5b
X-Filterd-Recvd-Size: 2959
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 22:11:53 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Sep 2019 15:11:51 -0700
X-IronPort-AV: E=Sophos;i="5.64,490,1559545200"; 
   d="scan'208";a="268551180"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Sep 2019 15:11:50 -0700
Message-ID: <3de2409415b20440d5c8f3016ed78fde3d106dc8.camel@linux.intel.com>
Subject: Re: [PATCH v9 1/8] mm: Add per-cpu logic to page shuffling
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: David Hildenbrand <david@redhat.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, virtio-dev@lists.oasis-open.org, 
 kvm@vger.kernel.org, mst@redhat.com, catalin.marinas@arm.com, 
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, 
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 will@kernel.org,  linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com, 
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com,  aarcange@redhat.com, ying.huang@intel.com,
 pbonzini@redhat.com,  dan.j.williams@intel.com, fengguang.wu@intel.com, 
 kirill.shutemov@linux.intel.com
Date: Tue, 10 Sep 2019 15:11:50 -0700
In-Reply-To: <0df2e5d0-af92-04b4-aa7d-891387874039@redhat.com>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172512.10910.74435.stgit@localhost.localdomain>
	 <0df2e5d0-af92-04b4-aa7d-891387874039@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 10:14 +0200, David Hildenbrand wrote:
> On 07.09.19 19:25, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Change the logic used to generate randomness in the suffle path so that we
> > can avoid cache line bouncing. The previous logic was sharing the offset
> > and entropy word between all CPUs. As such this can result in cache line
> > bouncing and will ultimately hurt performance when enabled.
> 
> So, usually we perform such changes if there is real evidence. Do you
> have any such performance numbers to back your claims?

I don't have any numbers. From what I can tell the impact is small enough
that this doesn't really have much impact.

With that being the case I can probably just drop this patch. I will
instead just use "rand & 1" in the 2nd patch to generate the return value
which was what was previously done in add_to_free_area_random.


