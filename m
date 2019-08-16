Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 175ECC3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5AE32063F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 08:47:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5AE32063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CEB76B0005; Fri, 16 Aug 2019 04:47:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47F956B0006; Fri, 16 Aug 2019 04:47:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36F2F6B0007; Fri, 16 Aug 2019 04:47:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0171.hostedemail.com [216.40.44.171])
	by kanga.kvack.org (Postfix) with ESMTP id 168CD6B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:47:26 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B91786D75
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:47:25 +0000 (UTC)
X-FDA: 75827662050.19.chain67_23aedc17e7651
X-HE-Tag: chain67_23aedc17e7651
X-Filterd-Recvd-Size: 3634
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:47:25 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8416CB06B;
	Fri, 16 Aug 2019 08:47:23 +0000 (UTC)
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
To: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
References: <20190812015044.26176-3-jhubbard@nvidia.com>
 <20190812234950.GA6455@iweiny-DESK2.sc.intel.com>
 <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
 <20190813210857.GB12695@iweiny-DESK2.sc.intel.com>
 <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0d6797d8-1e04-1ebe-80a7-3d6895fe71b0@suse.cz>
Date: Fri, 16 Aug 2019 10:47:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190815133510.GA21302@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/15/19 3:35 PM, Jan Kara wrote:
>> 
>> So when the GUP user uses MMU notifiers to stop writing to pages whenever
>> they are writeprotected with page_mkclean(), they don't really need page
>> pin - their access is then fully equivalent to any other mmap userspace
>> access and filesystem knows how to deal with those. I forgot out this case
>> when I wrote the above sentence.
>> 
>> So to sum up there are three cases:
>> 1) DIO case - GUP references to pages serving as DIO buffers are needed for
>>    relatively short time, no special synchronization with page_mkclean() or
>>    munmap() => needs FOLL_PIN
>> 2) RDMA case - GUP references to pages serving as DMA buffers needed for a
>>    long time, no special synchronization with page_mkclean() or munmap()
>>    => needs FOLL_PIN | FOLL_LONGTERM
>>    This case has also a special case when the pages are actually DAX. Then
>>    the caller additionally needs file lease and additional file_pin
>>    structure is used for tracking this usage.
>> 3) ODP case - GUP references to pages serving as DMA buffers, MMU notifiers
>>    used to synchronize with page_mkclean() and munmap() => normal page
>>    references are fine.

IMHO the munlock lesson told us about another one, that's in the end equivalent
to 3)

4) pinning for struct page manipulation only => normal page references are fine

> I want to add that I'd like to convert users in cases 1) and 2) from using
> GUP to using differently named function. Users in case 3) can stay as they
> are for now although ultimately I'd like to denote such use cases in a
> special way as well...

So after 1/2/3 is renamed/specially denoted, only 4) keeps the current interface?

> 								Honza
> 


