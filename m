Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BCA0C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AAA42183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AAA42183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6382F6B0008; Thu, 18 Apr 2019 08:45:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E6E26B000A; Thu, 18 Apr 2019 08:45:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D7D26B000C; Thu, 18 Apr 2019 08:45:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29DF96B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:45:28 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n1so1878534qte.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:45:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=V6+AwqFlWgmo/f1d5Sr1wG1FplZRlRHmIy7RCmGRmNA=;
        b=iH8wJ9dbWje1aQWep1zlDY+aZi2a+cwrsvOQGnwdQfNW+7SHtuyTRddhRfkMEfYl2G
         LTfwr86jzCyBqEpqy+NsmXKCHZhVTmLC73AUNDwgUHC3YweeuLpGh3OOz1kUxXssNrVC
         NwSCq1xuJJ/ZW8k/eBZAg3TkO9qhRPwiGKVDgrE13XLrHzA8a2Wuon1zMd79l2vjcHjS
         THvxpJ8hVcmZNJV7EF6aYjlqKNMFMaYc9wGRGESNeVC/iVylCxkxgPcCUJiJRfxVoxkB
         1pZhLb1eyhEA0HkTyWVTaoHUBPzPkNib3c0EKU7W4XL0S+ARJ3DwKD8xq9kSloKmZPBO
         9SWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUfE0s5gKpL/BYOtiqBsb+gpl9g0rYPlKPiWq8r0F7iHEbn9fb1
	Tp5PO4LY2sS8p+bsnQRJlpWBmnjpSlUsRuejprwejuikyoAcFCRH5N7Tz820BbxmoiIYGoNPyXk
	PXONDuCASDikRzmDi8jzWN/tJOdgIDsSCml2oa2xyh9poxpw8BIl+thoiwTmrYGv8ww==
X-Received: by 2002:a37:7c87:: with SMTP id x129mr8174161qkc.311.1555591527838;
        Thu, 18 Apr 2019 05:45:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7K6Gco0E4zKGW+yYKZ34b7XbKRYvnc1grFSL0JUUy7jG2y5Z6t/pqt/6+IGzm+rp1JIJJ
X-Received: by 2002:a37:7c87:: with SMTP id x129mr8174120qkc.311.1555591527070;
        Thu, 18 Apr 2019 05:45:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555591527; cv=none;
        d=google.com; s=arc-20160816;
        b=lINbMtjMds0f4jh/SPrTkylBYNA6PTA9KIzMVAxqxNd7BuhAiH5cZPcYkS6dDTrPwj
         dADtWe8yaNL2W+IAsrUsBsbVP8Tjudya4hN8wg7jHGl5Pdk6i1atTX0LhlELOOuRsHAZ
         YhjZwuKZiSsVWPbrmEvRhwdrCjKPA3jjVsxGvcNtm16yj7txXZuAHXE5kjRY2k5STnLQ
         +9g5XiJaSaCkbvcYKWWqv58wryLAIHUxyulec2ewDNaaO+lhvL2XnDLBirR+8KDEbS8n
         s85q0CLf8W301jngavkmOBE8c/1PxRl5MKQ24TpPPhtvzMTE6nvNUWT4zqKT1+ErXdJo
         SFfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=V6+AwqFlWgmo/f1d5Sr1wG1FplZRlRHmIy7RCmGRmNA=;
        b=imklo8SfPTBVlKO9TA58VA0vHWb7NS5kuczIe6UFlP/+eEASmetN4MmKFeqncjyZYL
         BJ1tIeW0vZFte+3mV5RIl2GAje8qhnDWJH3+ehUUrYZDPgPJ8k2CSH329zg7GrnbNfcs
         bA3cXfGSPMFM+ozaWHwQrO3YVAgvv5jVv3v3sdRMpo5Jpmbrh2wkBL5AxKKoR78fNgJu
         GoWEqRCpklel+MjM0EWL4qpqMC+6XCTceeXePM+9GO37yA+Bd+qTtVtm0jmp7a5cFNfj
         dZkVM9le3Ew5f2nciCmYjGXCIoG/RqfofeK0KwCGoITs0PQs45YEcEaSK0tOjyPb97Ij
         C/yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e33si1516500qvh.73.2019.04.18.05.45.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 05:45:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 83FA681129;
	Thu, 18 Apr 2019 12:45:25 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6CC6519C65;
	Thu, 18 Apr 2019 12:45:11 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  David Hildenbrand
 <david@redhat.com>,  =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
  Logan Gunthorpe <logang@deltatee.com>,  Toshi Kani <toshi.kani@hpe.com>,
  Michal Hocko <mhocko@suse.com>,  Vlastimil Babka <vbabka@suse.cz>,
  stable <stable@vger.kernel.org>,  Linux MM <linux-mm@kvack.org>,
  linux-nvdimm <linux-nvdimm@lists.01.org>,  Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>,  osalvador@suse.de
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
	<CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
	<CAPcyv4iW=xhhUQbg0bt=xCgVaR_jUvATeLxSoCfvzG5gTEAX6A@mail.gmail.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Thu, 18 Apr 2019 08:45:10 -0400
In-Reply-To: <CAPcyv4iW=xhhUQbg0bt=xCgVaR_jUvATeLxSoCfvzG5gTEAX6A@mail.gmail.com>
	(Dan Williams's message of "Wed, 17 Apr 2019 19:09:12 -0700")
Message-ID: <x49lg07eb3d.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 18 Apr 2019 12:45:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

>> On Wed, Apr 17, 2019 at 3:59 PM Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> On Wed, Apr 17, 2019 at 3:04 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>> >
>> > On Wed, 17 Apr 2019 11:38:55 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>> >
>> > > The memory hotplug section is an arbitrary / convenient unit for memory
>> > > hotplug. 'Section-size' units have bled into the user interface
>> > > ('memblock' sysfs) and can not be changed without breaking existing
>> > > userspace. The section-size constraint, while mostly benign for typical
>> > > memory hotplug, has and continues to wreak havoc with 'device-memory'
>> > > use cases, persistent memory (pmem) in particular. Recall that pmem uses
>> > > devm_memremap_pages(), and subsequently arch_add_memory(), to allocate a
>> > > 'struct page' memmap for pmem. However, it does not use the 'bottom
>> > > half' of memory hotplug, i.e. never marks pmem pages online and never
>> > > exposes the userspace memblock interface for pmem. This leaves an
>> > > opening to redress the section-size constraint.
>> >
>> > v6 and we're not showing any review activity.  Who would be suitable
>> > people to help out here?
>>
>> There was quite a bit of review of the cover letter from Michal and
>> David, but you're right the details not so much as of yet. I'd like to
>> call out other people where I can reciprocate with some review of my
>> own. Oscar's altmap work looks like a good candidate for that.
>
> I'm also hoping Jeff can give a tested-by for the customer scenarios
> that fall over with the current implementation.

Sure.  I'll also have a look over the patches.

-Jeff

