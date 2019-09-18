Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30D5FC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:44:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFD7C21920
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:44:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=shipmail.org header.i=@shipmail.org header.b="msZ9svm4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFD7C21920
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shipmail.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 242DB6B02DD; Wed, 18 Sep 2019 13:44:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CCF36B02DE; Wed, 18 Sep 2019 13:44:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 093716B02DF; Wed, 18 Sep 2019 13:44:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id D510E6B02DD
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:44:18 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8027D181AC9AE
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:44:18 +0000 (UTC)
X-FDA: 75948765396.25.juice76_5f8cec008fd4b
X-HE-Tag: juice76_5f8cec008fd4b
X-Filterd-Recvd-Size: 7195
Received: from pio-pvt-msa2.bahnhof.se (pio-pvt-msa2.bahnhof.se [79.136.2.41])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:44:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 87B663F712;
	Wed, 18 Sep 2019 19:44:09 +0200 (CEST)
Authentication-Results: pio-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=shipmail.org header.i=@shipmail.org header.b=msZ9svm4;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bGAvdWARNseX; Wed, 18 Sep 2019 19:44:05 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id 8D1B63F3BA;
	Wed, 18 Sep 2019 19:44:03 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id D789636020A;
	Wed, 18 Sep 2019 19:44:02 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=shipmail.org; s=mail;
	t=1568828642; bh=GJRbag8de5OLyDKo8HWyVkbRJublreoNXwx3gXTOWdM=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=msZ9svm4xkJZX+qV+94dYAuQRk1LlAJIYDeI17uYtpNt8JMLrQwI7n109FFlIW4BG
	 fI+HNrYUbUA8iZJ313W6y2HYjGi3Md8g/Exh2KQzd9nyvwFFQbfhgPOnUfeJof6Syx
	 IxmSAE+DNQB/TcE07nLEFbjFi7wDUUEDYkeLD7x4=
Subject: Re: [PATCH 1/7] mm: Add write-protect and clean utilities for address
 space ranges
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, pv-drivers@vmware.com,
 linux-graphics-maintainer@vmware.com,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ralph Campbell <rcampbell@nvidia.com>
References: <20190918125914.38497-1-thomas_os@shipmail.org>
 <20190918125914.38497-2-thomas_os@shipmail.org>
 <20190918144102.jkukmhifmweagmwt@box>
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?= <thomas_os@shipmail.org>
Organization: VMware Inc.
Message-ID: <8b710686-af78-d85a-d8a9-e4d92be4be57@shipmail.org>
Date: Wed, 18 Sep 2019 19:44:02 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190918144102.jkukmhifmweagmwt@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/18/19 4:41 PM, Kirill A. Shutemov wrote:
> On Wed, Sep 18, 2019 at 02:59:08PM +0200, Thomas Hellstr=C3=B6m (VMware=
) wrote:
>> From: Thomas Hellstrom <thellstrom@vmware.com>
>>
>> Add two utilities to a) write-protect and b) clean all ptes pointing i=
nto
>> a range of an address space.
>> The utilities are intended to aid in tracking dirty pages (either
>> driver-allocated system memory or pci device memory).
>> The write-protect utility should be used in conjunction with
>> page_mkwrite() and pfn_mkwrite() to trigger write page-faults on page
>> accesses. Typically one would want to use this on sparse accesses into
>> large memory regions. The clean utility should be used to utilize
>> hardware dirtying functionality and avoid the overhead of page-faults,
>> typically on large accesses into small memory regions.
>>
>> The added file "as_dirty_helpers.c" is initially listed as maintained =
by
>> VMware under our DRM driver. If somebody would like it elsewhere,
>> that's of course no problem.
> After quick glance, it looks a lot as rmap code duplication. Why not
> extend rmap_walk() interface instead to cover range of pages?

There appears to exist quite a few pagetable walks in the mm code. "Take=20
1" of this patch series modified the "apply_to_page_range" interface and=20
used that. But the interface modification was actually what eventually=20
caused Linus to reject the code. While it is entirely possible to do a=20
proper modification following Linus' and Christoph's guidelines, that=20
code doesn't allow for huge pages and populates all page table levels.=20
We will soon probably want to support huge pages and do not want to=20
populate. The number of altered code-paths itself IMO motivates yet=20
another pagetable walk implementation.

The walk code currently resembling the present patch the most is the=20
unmap_mapping_range() implementation.

The rmap_walk() is not very well suited since it operates on a struct=20
page and the code of this patch has no notion of struct pages.

So my thoughts on this is that the interface should in time move towards=20
the code in mm/pagewalk.c. If we eventually have more users of an=20
address-space pagewalk or want to re-implement unmap_mapping_range()=20
using a generic pagewalk, we should move the walk to pagewalk.c and=20
reuse its structures, but implement separate code for the walk since we=20
can't split huge pages and we can't take the mmap_sem. Meanwhile we=20
should keep the code separate in as_dirty_helpers.c

>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Rik van Riel <riel@surriel.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Huang Ying <ying.huang@intel.com>
>> Cc: Souptick Joarder <jrdr.linux@gmail.com>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
>>
>> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com> #v1
>> ---
>>   MAINTAINERS           |   1 +
>>   include/linux/mm.h    |  13 +-
>>   mm/Kconfig            |   3 +
>>   mm/Makefile           |   1 +
>>   mm/as_dirty_helpers.c | 392 ++++++++++++++++++++++++++++++++++++++++=
++
>>   5 files changed, 409 insertions(+), 1 deletion(-)
>>   create mode 100644 mm/as_dirty_helpers.c
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index c2d975da561f..b596c7cf4a85 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -5287,6 +5287,7 @@ T:	git git://people.freedesktop.org/~thomash/lin=
ux
>>   S:	Supported
>>   F:	drivers/gpu/drm/vmwgfx/
>>   F:	include/uapi/drm/vmwgfx_drm.h
>> +F:	mm/as_dirty_helpers.c
> Emm.. No. Core MM functinality cannot belong to random driver.

OK. I'll put it under core MM.

/Thomas




