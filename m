Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6525C3A5A1
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 00:36:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67AD223401
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 00:36:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IPR34iXb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67AD223401
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00FD76B036E; Thu, 22 Aug 2019 20:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F020C6B036F; Thu, 22 Aug 2019 20:36:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19AE6B0370; Thu, 22 Aug 2019 20:36:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id BF1386B036E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:36:11 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5DA19180AD7C1
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:36:11 +0000 (UTC)
X-FDA: 75851825742.11.north18_52e40c8e0a60a
X-HE-Tag: north18_52e40c8e0a60a
X-Filterd-Recvd-Size: 4641
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com [216.228.121.143])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:36:09 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5f34f80000>; Thu, 22 Aug 2019 17:36:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 22 Aug 2019 17:36:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 22 Aug 2019 17:36:08 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 23 Aug
 2019 00:36:07 +0000
Subject: Re: [PATCH v2 0/3] mm/gup: introduce vaddr_pin_pages_remote(),
 FOLL_PIN
To: Ira Weiny <ira.weiny@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
References: <20190821040727.19650-1-jhubbard@nvidia.com>
 <20190823002443.GA19517@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <2f91e1a2-f82f-406a-600a-939bc07a0651@nvidia.com>
Date: Thu, 22 Aug 2019 17:36:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190823002443.GA19517@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566520568; bh=XTi8KewFAAPPdzH/kxXHq8AUlFdgw9TNIY7CgXtissQ=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=IPR34iXbP32VBS6NawFx8vHbWCUpISM/8+gLYDeZ6Kn8p2dNebgZFMMZM36L06l9/
	 D5C9xcsy+TfGK3CuFf2rQpMA+u8LhLeA4IdVY2ZiH8cmDVjox21UIx+hCfjQxwRbwP
	 CzRFrnCGWC7SWeskityM3OIPQ4agRt87OI4q7DhiQ/K9Br7m5Uq2L+oMLR2W6y7IUL
	 mET+mAaJIL5IP+a9iN+n1n9EebRhfqym+VuStBKaHcCphfqLFPM9uT/TUFg6cQEuT9
	 WF3YqJmEjk5vFi8XYhA13YoR2Wai7R7gpFagUrT5OfutwJCqbHP/JG8A1AaYO7VwcC
	 Y4ZtFg9tjzDiA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/22/19 5:24 PM, Ira Weiny wrote:
> On Tue, Aug 20, 2019 at 09:07:24PM -0700, John Hubbard wrote:
>> Hi Ira,
>>
>> This is for your tree. I'm dropping the RFC because this aspect is
>> starting to firm up pretty well.
>>
>> I've moved FOLL_PIN inside the vaddr_pin_*() routines, and moved
>> FOLL_LONGTERM outside, based on our recent discussions. This is
>> documented pretty well within the patches.
>>
>> Note that there are a lot of references in comments and commit
>> logs, to vaddr_pin_pages(). We'll want to catch all of those if
>> we rename that. I am pushing pretty hard to rename it to
>> vaddr_pin_user_pages().
>>
>> v1 of this may be found here:
>> https://lore.kernel.org/r/20190812015044.26176-1-jhubbard@nvidia.com
> 
> I am really sorry about this...
> 
> I think it is fine to pull these in...  There are some nits which are wrong but
> I think with the XDP complication and Daves' objection I think the vaddr_pin
> information is going to need reworking.  So the documentation there is probably
> wrong.  But until we know what it is going to be we should just take this.
> 

Sure, I was thinking the same thing: FOLL_PIN is clearing up, but vaddr_pin_pages() 
is still under heavy discussion.


> Do you have a branch with this on it?
> 

Yes, it's on: git@github.com:johnhubbard/linux.git , branch: vaddr_FOLL_PIN_next


> The patches don't seem to apply.  Looks like they got corrupted somewhere...
> 

Lately I'm trying out .nvidia.com outgoing servers for git-send-email, so I'm 
still nervous about potential email-based patch problems. I suspect, though,
that it's really just a "must be on exactly the right commit in order to apply"
situation. Please let me know, so I can make any corrections necessary on this end.


thanks,
-- 
John Hubbard
NVIDIA

