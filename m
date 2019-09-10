Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B95EAC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:11:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83C9F21019
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 12:11:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83C9F21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0370B6B0003; Tue, 10 Sep 2019 08:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F28E26B0006; Tue, 10 Sep 2019 08:11:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3EE76B0007; Tue, 10 Sep 2019 08:11:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id C39786B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:11:33 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 66589181AC9BA
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:11:33 +0000 (UTC)
X-FDA: 75918896466.20.deer34_47bee0eba7725
X-HE-Tag: deer34_47bee0eba7725
X-Filterd-Recvd-Size: 2996
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 12:11:32 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 668EEB150;
	Tue, 10 Sep 2019 12:11:31 +0000 (UTC)
Date: Tue, 10 Sep 2019 14:11:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: David Hildenbrand <david@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	mst@redhat.com, catalin.marinas@arm.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, willy@infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org,
	linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
	nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 1/8] mm: Add per-cpu logic to page shuffling
Message-ID: <20190910121130.GU2063@dhcp22.suse.cz>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172512.10910.74435.stgit@localhost.localdomain>
 <0df2e5d0-af92-04b4-aa7d-891387874039@redhat.com>
 <0ca58fea280b51b83e7b42e2087128789bc9448d.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ca58fea280b51b83e7b42e2087128789bc9448d.camel@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 08:11:36, Alexander Duyck wrote:
> On Mon, 2019-09-09 at 10:14 +0200, David Hildenbrand wrote:
> > On 07.09.19 19:25, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Change the logic used to generate randomness in the suffle path so that we
> > > can avoid cache line bouncing. The previous logic was sharing the offset
> > > and entropy word between all CPUs. As such this can result in cache line
> > > bouncing and will ultimately hurt performance when enabled.
> > 
> > So, usually we perform such changes if there is real evidence. Do you
> > have any such performance numbers to back your claims?
> 
> I'll have to go rerun the test to get the exact numbers. The reason this
> came up is that my original test was spanning NUMA nodes and that made
> this more expensive as a result since the memory was both not local to the
> CPU and was being updated by multiple sockets.

What was the pattern of page freeing in your testing? I am wondering
because order 0 pages should be prevailing and those usually go via pcp
lists so they do not get shuffled unless the batch is full IIRC.
-- 
Michal Hocko
SUSE Labs

