Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23781C4CECE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 17:04:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4B60214AF
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 17:04:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4B60214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AA146B0003; Tue, 17 Sep 2019 13:04:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781656B0005; Tue, 17 Sep 2019 13:04:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BEB86B0006; Tue, 17 Sep 2019 13:04:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0252.hostedemail.com [216.40.44.252])
	by kanga.kvack.org (Postfix) with ESMTP id 498126B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:04:39 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id AAF8A81C5
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:04:38 +0000 (UTC)
X-FDA: 75945036636.20.name92_7fc07faf7ab01
X-HE-Tag: name92_7fc07faf7ab01
X-Filterd-Recvd-Size: 4825
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:04:37 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 79063369D3;
	Tue, 17 Sep 2019 17:04:36 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6C2F560126;
	Tue, 17 Sep 2019 17:04:29 +0000 (UTC)
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
To: Qian Cai <cai@lca.pw>, David Hildenbrand <david@redhat.com>,
 Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "dan.j.williams@intel.com" <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "mhocko@kernel.org" <mhocko@kernel.org>,
 "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
 "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
 "mst@redhat.com" <mst@redhat.com>,
 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Junichi Nomura <j-nomura@ce.jp.nec.com>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
 <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
 <40a1ce2e-1384-b869-97d0-7195b5b47de0@redhat.com>
 <6a99e003-e1ab-b9e8-7b25-bc5605ab0eb2@vx.jp.nec.com>
 <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com>
 <31fd3c86-5852-1863-93bd-8df9da9f95b4@vx.jp.nec.com>
 <38e58d23-c20b-4e68-5f56-20bba2be2d6c@redhat.com>
 <59c946f8-843d-c017-f342-d007a5e14a85@redhat.com>
 <1568737304.5576.162.camel@lca.pw>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <bd6ea535-b228-8de0-1454-e512ccbfb4fa@redhat.com>
Date: Tue, 17 Sep 2019 13:04:28 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1568737304.5576.162.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 17 Sep 2019 17:04:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/17/19 12:21 PM, Qian Cai wrote:
> On Tue, 2019-09-17 at 11:49 -0400, Waiman Long wrote:
>> On 9/17/19 3:13 AM, David Hildenbrand wrote:
>>> On 17.09.19 04:34, Toshiki Fukasawa wrote:
>>>> On 2019/09/09 16:46, David Hildenbrand wrote:
>>>>> Let's take a step back here to understand the issues I am aware of. I
>>>>> think we should solve this for good now:
>>>>>
>>>>> A PFN walker takes a look at a random PFN at a random point in time. It
>>>>> finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
>>>>> options are:
>>>>>
>>>>> 1. It is buddy memory (add_memory()) that has not been online yet. The
>>>>> memmap contains garbage. Don't access.
>>>>>
>>>>> 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
>>>>>
>>>>> 3. It is ZONE_DEVICE memory with an invalid memmap, because the section
>>>>> is only partially present: E.g., device starts at offset 64MB within a
>>>>> section or the device ends at offset 64MB within a section. Don't access it.
>>>> I don't agree with case #3. In the case, struct page area is not allocated on
>>>> ZONE_DEVICE, but is allocated on system memory. So I think we can access the
>>>> struct pages. What do you mean "invalid memmap"?
>>> No, that's not the case. There is no memory, especially not system
>>> memory. We only allow partially present sections (sub-section memory
>>> hotplug) for ZONE_DEVICE.
>>>
>>> invalid memmap == memmap was not initialized == struct pages contains
>>> garbage. There is a memmap, but accessing it (e.g., pfn_to_nid()) will
>>> trigger a BUG.
>>>
>> As long as the page structures exist, they should be initialized to some
>> known state. We could set PagePoison for those invalid memmap. It is the
> Sounds like you want to run page_init_poison() by default.

Yes for those pages that are not initialized otherwise. I don't want to
run page_init_poison() for the whole ZONE_DEVICE memory range as it can
take a while if we are talking about TBs of persistent memory. Also most
of the pages will be reinitialized anyway in the init process. So it is
mostly a wasted effort. However, for those reserved pages that are not
being exported to the memory management layer, having them initialized
to a known state will cause less problem down the road.

Cheers,
Longman


