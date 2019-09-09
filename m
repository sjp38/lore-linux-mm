Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2277C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:11:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70D4920863
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 15:11:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70D4920863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C61C6B0008; Mon,  9 Sep 2019 11:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 176436B000A; Mon,  9 Sep 2019 11:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08B386B000C; Mon,  9 Sep 2019 11:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0227.hostedemail.com [216.40.44.227])
	by kanga.kvack.org (Postfix) with ESMTP id D77FC6B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 11:11:39 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 82AE5181AC9BF
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:11:39 +0000 (UTC)
X-FDA: 75915721518.03.rain81_82ce8dc3dd109
X-HE-Tag: rain81_82ce8dc3dd109
X-Filterd-Recvd-Size: 3062
Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 15:11:38 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 08:11:36 -0700
X-IronPort-AV: E=Sophos;i="5.64,486,1559545200"; 
   d="scan'208";a="175007390"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 08:11:36 -0700
Message-ID: <0ca58fea280b51b83e7b42e2087128789bc9448d.camel@linux.intel.com>
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
Date: Mon, 09 Sep 2019 08:11:36 -0700
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

I'll have to go rerun the test to get the exact numbers. The reason this
came up is that my original test was spanning NUMA nodes and that made
this more expensive as a result since the memory was both not local to the
CPU and was being updated by multiple sockets.

I will try building a pair of host kernels with shuffling enabled and this
patch applied to one and can add that data to the patch description.

- Alex



