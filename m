Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 950DBC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C1702067B
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 12:06:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C1702067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97BAD6B0005; Mon,  9 Sep 2019 08:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92BBA6B0006; Mon,  9 Sep 2019 08:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CB536B0007; Mon,  9 Sep 2019 08:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id 568196B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:06:12 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 037B9180AD801
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:06:12 +0000 (UTC)
X-FDA: 75915254184.25.limit72_703caee6e1818
X-HE-Tag: limit72_703caee6e1818
X-Filterd-Recvd-Size: 8894
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:06:11 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 08A3A8980EF;
	Mon,  9 Sep 2019 12:06:10 +0000 (UTC)
Received: from [10.36.116.173] (ovpn-116-173.ams2.redhat.com [10.36.116.173])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C189B6061E;
	Mon,  9 Sep 2019 12:06:00 +0000 (UTC)
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
To: Dan Williams <dan.j.williams@intel.com>
Cc: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "mhocko@kernel.org" <mhocko@kernel.org>,
 "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
 "longman@redhat.com" <longman@redhat.com>,
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
 <f9b10653-949b-64a6-6539-a32bd980edb9@redhat.com>
 <CAPcyv4gA4mcDEPeCFokn_jy5gX62cK0U40EzL7M8c0iDO7U7bg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c6198acd-8ff7-c40c-cb4e-f0f12f841b38@redhat.com>
Date: Mon, 9 Sep 2019 14:05:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gA4mcDEPeCFokn_jy5gX62cK0U40EzL7M8c0iDO7U7bg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.67]); Mon, 09 Sep 2019 12:06:10 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.09.19 13:53, Dan Williams wrote:
> On Mon, Sep 9, 2019 at 1:11 AM David Hildenbrand <david@redhat.com> wro=
te:
> [..]
>>>> It seems that SECTION_IS_ONLINE and SECTION_MARKED_PRESENT can be us=
ed to
>>>> distinguish uninitialized struct pages if we can apply them to ZONE_=
DEVICE,
>>>> but that is no longer necessary with this approach.
>>>
>>> Let's take a step back here to understand the issues I am aware of. I
>>> think we should solve this for good now:
>>>
>>> A PFN walker takes a look at a random PFN at a random point in time. =
It
>>> finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
>>> options are:
>>>
>>> 1. It is buddy memory (add_memory()) that has not been online yet. Th=
e
>>> memmap contains garbage. Don't access.
>>>
>>> 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
>>>
>>> 3. It is ZONE_DEVICE memory with an invalid memmap, because the secti=
on
>>> is only partially present: E.g., device starts at offset 64MB within =
a
>>> section or the device ends at offset 64MB within a section. Don't acc=
ess it.
>>>
>>> 4. It is ZONE_DEVICE memory with an invalid memmap, because the memma=
p
>>> was not initialized yet. memmap_init_zone_device() did not yet succee=
d
>>> after dropping the mem_hotplug lock in mm/memremap.c. Don't access it=
.
>>>
>>> 5. It is reserved ZONE_DEVICE memory ("pages mapped, but reserved for
>>> driver") with an invalid memmap. Don't access it.
>>>
>>> I can see that your patch tries to make #5 vanish by initializing the
>>> memmap, fair enough. #3 and #4 can't be detected. The PFN walker coul=
d
>>> still stumble over uninitialized memmaps.
>>>
>>
>> FWIW, I thinkg having something like pfn_zone_device(), similarly
>> implemented like pfn_zone_device_reserved() could be one solution to
>> most issues.
>=20
> I've been thinking of a replacement for PTE_DEVMAP with section-level,
> or sub-section level flags. The section-level flag would still require
> a call to get_dev_pagemap() to validate that the pfn is not section in
> the subsection case which seems to be entirely too much overhead. If
> ZONE_DEVICE is to be a first class citizen in pfn walkers I think it
> would be worth the cost to double the size of subsection_map and to
> identify whether a sub-section is ZONE_DEVICE, or not.
>=20
> Thoughts?
>=20

I thought about this last week and came up with something like

1. Convert SECTION_IS_ONLINE to SECTION IS_ACTIVE

2. Make pfn_to_online_page() also check that it's not ZONE_DEVICE.
Online pfns are limited to !ZONE_DEVICE.

3. Extend subsection_map to an additional active_map

4. Set SECTION IS_ACTIVE *iff* the whole active_map is set. This keeps
most accesses of pfn_to_online_page() fast. If !SECTION IS_ACTIVE, check
the active_map.

5. Set sub-sections active/unactive in
move_pfn_range_to_zone()/remove_pfn_range_from_zone() - see "[PATCH v4
0/8] mm/memory_hotplug: Shrink zones before removing memory=E2=80=8B" for=
 the
latter.

6. Set boot memory properly active (this is a tricky bit :/ ).

However, it turned out too complex for my taste (and limited time to
spend on this), so I abandoned that idea for now. If somebody wants to
pick that up, fine.

--=20

Thanks,

David / dhildenb

