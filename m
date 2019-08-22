Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9908DC3A5A2
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:33:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55EAE233FD
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:33:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55EAE233FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E03A76B0330; Thu, 22 Aug 2019 11:33:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDA746B0331; Thu, 22 Aug 2019 11:33:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D18466B0332; Thu, 22 Aug 2019 11:33:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE9236B0330
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:33:18 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4A2C78248AA4
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:33:18 +0000 (UTC)
X-FDA: 75850457676.07.end79_912efb7cb7631
X-HE-Tag: end79_912efb7cb7631
X-Filterd-Recvd-Size: 6698
Received: from mga09.intel.com (mga09.intel.com [134.134.136.24])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:33:17 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Aug 2019 08:33:16 -0700
X-IronPort-AV: E=Sophos;i="5.64,417,1559545200"; 
   d="scan'208";a="330425538"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Aug 2019 08:33:15 -0700
Message-ID: <31b75078d004a1ccf77b710b35b8f847f404de9a.camel@linux.intel.com>
Subject: Re: [PATCH v6 0/6] mm / virtio: Provide support for unused page
 reporting
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Pankaj Gupta <pagupta@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com,
 david@redhat.com,  dave hansen <dave.hansen@intel.com>,
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org, 
 linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org,  osalvador@suse.de, yang zhang wz
 <yang.zhang.wz@gmail.com>, riel@surriel.com,  konrad wilk
 <konrad.wilk@oracle.com>, lcapitulino@redhat.com, wei w wang
 <wei.w.wang@intel.com>,  aarcange@redhat.com, pbonzini@redhat.com, dan j
 williams <dan.j.williams@intel.com>
Date: Thu, 22 Aug 2019 08:32:59 -0700
In-Reply-To: <1297409377.9866813.1566470593223.JavaMail.zimbra@redhat.com>
References: <20190821145806.20926.22448.stgit@localhost.localdomain>
	 <1297409377.9866813.1566470593223.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-08-22 at 06:43 -0400, Pankaj Gupta wrote:
> > This series provides an asynchronous means of reporting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as unused page reporting
> > 
> > The functionality for this is fairly simple. When enabled it will allocate
> > statistics to track the number of reported pages in a given free area.
> > When the number of free pages exceeds this value plus a high water value,
> > currently 32, it will begin performing page reporting which consists of
> > pulling pages off of free list and placing them into a scatter list. The
> > scatterlist is then given to the page reporting device and it will perform
> > the required action to make the pages "reported", in the case of
> > virtio-balloon this results in the pages being madvised as MADV_DONTNEED
> > and as such they are forced out of the guest. After this they are placed
> > back on the free list, and an additional bit is added if they are not
> > merged indicating that they are a reported buddy page instead of a
> > standard buddy page. The cycle then repeats with additional non-reported
> > pages being pulled until the free areas all consist of reported pages.
> > 
> > I am leaving a number of things hard-coded such as limiting the lowest
> > order processed to PAGEBLOCK_ORDER, and have left it up to the guest to
> > determine what the limit is on how many pages it wants to allocate to
> > process the hints. The upper limit for this is based on the size of the
> > queue used to store the scattergather list.
> > 
> > My primary testing has just been to verify the memory is being freed after
> > allocation by running memhog 40g on a 40g guest and watching the total
> > free memory via /proc/meminfo on the host. With this I have verified most
> > of the memory is freed after each iteration. 
> 
> I tried to go through the entire patch series. I can see you reported a
> -3.27 drop from the baseline. If its because of re-faulting the page after
> host has freed them? Can we avoid freeing all the pages from the guest free_area
> and keep some pages(maybe some mixed order), so that next allocation is done from
> the guest itself than faulting to host. This will work with real workload where
> allocation and deallocation happen at regular intervals. 
> 
> This can be further optimized based on other factors like host memory pressure etc.
> 
> Thanks,
> Pankaj  

When I originally started implementing and testing this code I was seeing
less than a 1% regression. I didn't feel like that was really an accurate
result since it wasn't putting much stress on the changed code so I have
modified my tests and kernel so that I have memory shuffting and THP
enabled. In addition I have gone out of my way to lock things down to a
single NUMA node on my host system as the code I had would sometimes
perform better than baseline when running the test due to the fact that
memory was being freed back to the hose and then reallocated which
actually allowed for better NUMA locality.

The general idea was I wanted to know what the worst case penalty would be
for running this code, and it turns out most of that is just the cost of
faulting back in the pages. By enabling memory shuffling I am forcing the
memory to churn as pages are added to both the head and tail of the
free_list. The test itself was modified so that it didn't allocate order 0
pages and instead was allocating transparent huge pages so the effects
were as visible as possible. Without that the page faulting overhead would
mostly fall into the noise of having to allocate the memory as order 0
pages, that is what I had essentially seen earlier when I was running the
stock page_fault1 test.

This code does no hinting on anything smaller than either MAX_ORDER - 1 or
HUGETLB_PAGE_ORDER pages, and it only starts when there are at least 32 of
them available to hint on. This results in us not starting to perform the
hinting until there is 64MB to 128MB of memory sitting in the higher order
regions of the zone.

The hinting itself stops as soon as we run out of unhinted pages to pull
from. When this occurs we let any pages that are freed after that
accumulate until we get back to 32 pages being free in a given order.
During this time we should build up the cache of warm pages that you
mentioned, assuming that shuffling is not enabled.

As far as further optimizations I don't think there is anything here that
prevents us from doing that. For now I am focused on just getting the
basics in place so we have a foundation to start from.

Thanks.

- Alex


