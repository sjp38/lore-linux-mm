Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C789C433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:11:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2F8A21920
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 08:11:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2F8A21920
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 598C66B0006; Mon,  9 Sep 2019 04:11:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 549426B000C; Mon,  9 Sep 2019 04:11:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4109E6B000D; Mon,  9 Sep 2019 04:11:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD3D6B0006
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 04:11:01 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id CE1E26135
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:11:00 +0000 (UTC)
X-FDA: 75914661480.02.neck61_600bdc4b19e18
X-HE-Tag: neck61_600bdc4b19e18
X-Filterd-Recvd-Size: 12179
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 08:10:59 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E056C300D1C8;
	Mon,  9 Sep 2019 08:10:58 +0000 (UTC)
Received: from [10.36.116.173] (ovpn-116-173.ams2.redhat.com [10.36.116.173])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CFA27100194E;
	Mon,  9 Sep 2019 08:10:48 +0000 (UTC)
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
From: David Hildenbrand <david@redhat.com>
To: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "dan.j.williams@intel.com" <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
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
Message-ID: <f9b10653-949b-64a6-6539-a32bd980edb9@redhat.com>
Date: Mon, 9 Sep 2019 10:10:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <e4e54258-e83b-cf0b-b66e-9874be6b5122@redhat.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 09 Sep 2019 08:10:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.09.19 09:46, David Hildenbrand wrote:
> On 09.09.19 07:48, Toshiki Fukasawa wrote:
>> On 2019/09/06 19:35, David Hildenbrand wrote:
>>> On 06.09.19 12:02, Toshiki Fukasawa wrote:
>>>> Thank you for your feedback.
>>>>
>>>> On 2019/09/06 17:45, David Hildenbrand wrote:
>>>>> On 06.09.19 10:09, Toshiki Fukasawa wrote:
>>>>>> A kernel panic is observed during reading
>>>>>> /proc/kpage{cgroup,count,flags} for first few pfns allocated by
>>>>>> pmem namespace:
>>>>>>
>>>>>> BUG: unable to handle page fault for address: fffffffffffffffe
>>>>>> [  114.495280] #PF: supervisor read access in kernel mode
>>>>>> [  114.495738] #PF: error_code(0x0000) - not-present page
>>>>>> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
>>>>>> [  114.496713] Oops: 0000 [#1] SMP PTI
>>>>>> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1
>>>>>> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
>>>>>> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
>>>>>> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
>>>>>> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
>>>>>> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 0000000000000000
>>>>>> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd07489000000
>>>>>> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 0000000000000000
>>>>>> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000240000
>>>>>> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e601a0ff08
>>>>>> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knlGS:0000000000000000
>>>>>> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>>>> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000000006e0
>>>>>> [  114.506401] Call Trace:
>>>>>> [  114.506660]  kpageflags_read+0xb1/0x130
>>>>>> [  114.507051]  proc_reg_read+0x39/0x60
>>>>>> [  114.507387]  vfs_read+0x8a/0x140
>>>>>> [  114.507686]  ksys_pread64+0x61/0xa0
>>>>>> [  114.508021]  do_syscall_64+0x5f/0x1a0
>>>>>> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>>>>> [  114.508844] RIP: 0033:0x7f0266ba426b
>>>>>>
>>>>>> The first few pages of ZONE_DEVICE expressed as the range
>>>>>> (altmap->base_pfn) to (altmap->base_pfn + altmap->reserve) are
>>>>>> skipped by struct page initialization. Some pfn walkers like
>>>>>> /proc/kpage{cgroup, count, flags} can't handle these uninitialized
>>>>>> struct pages, which causes the error.
>>>>>>
>>>>>> In previous discussion, Dan seemed to have concern that the struct
>>>>>> page area of some pages indicated by vmem_altmap->reserve may not
>>>>>> be allocated. (See https://lore.kernel.org/lkml/CAPcyv4i5FjTOnPbXNcTzvt+e6RQYow0JRQwSFuxaa62LSuvzHQ@mail.gmail.com/)
>>>>>> However, arch_add_memory() called by devm_memremap_pages() allocates
>>>>>> struct page area for pages containing addresses in the range
>>>>>> (res.start) to (res.start + resource_size(res)), which include the
>>>>>> pages indicated by vmem_altmap->reserve. If I read correctly, it is
>>>>>> allocated as requested at least on x86_64. Also, memmap_init_zone()
>>>>>> initializes struct pages in the same range.
>>>>>> So I think the struct pages should be initialized.>
>>>>>
>>>>> For !ZONE_DEVICE memory, the memmap is valid with SECTION_IS_ONLINE -
>>>>> for the whole section. For ZONE_DEVICE memory we have no such
>>>>> indication. In any section that is !SECTION_IS_ONLINE and
>>>>> SECTION_MARKED_PRESENT, we could have any subsections initialized. >
>>>>> The only indication I am aware of is pfn_zone_device_reserved() - which
>>>>> seems to check exactly what you are trying to skip here.
>>>>>
>>>>> Can't you somehow use pfn_zone_device_reserved() ? Or if you considered
>>>>> that already, why did you decide against it?
>>>>
>>>> No, in current approach this function is no longer needed.
>>>> The reason why we change the approach is that all pfn walkers
>>>> have to be aware of the uninitialized struct pages.
>>>
>>> We should use the same strategy for all pfn walkers then (effectively
>>> get rid of pfn_zone_device_reserved() if that's what we want).
>>
>> True, but this patch replaces "/proc/kpageflags: do not use uninitialized
>> struct pages". If we initialize the uninitialized struct pages, no pfn walker
>> will need to be aware of them.
> 
> So the function should go.
> 
>>
>>>
>>>>
>>>> As for SECTION_IS_ONLINE, I'm not sure now.
>>>> I will look into it next week.
>>>
>>> SECTION_IS_ONLINE does currently not apply to ZONE_DEVICE and due to
>>> sub-section support for ZONE_DEVICE, it cannot easily be reused.
>>>
>> It seems that SECTION_IS_ONLINE and SECTION_MARKED_PRESENT can be used to
>> distinguish uninitialized struct pages if we can apply them to ZONE_DEVICE,
>> but that is no longer necessary with this approach.
> 
> Let's take a step back here to understand the issues I am aware of. I
> think we should solve this for good now:
> 
> A PFN walker takes a look at a random PFN at a random point in time. It
> finds a PFN with SECTION_MARKED_PRESENT && !SECTION_IS_ONLINE. The
> options are:
> 
> 1. It is buddy memory (add_memory()) that has not been online yet. The
> memmap contains garbage. Don't access.
> 
> 2. It is ZONE_DEVICE memory with a valid memmap. Access it.
> 
> 3. It is ZONE_DEVICE memory with an invalid memmap, because the section
> is only partially present: E.g., device starts at offset 64MB within a
> section or the device ends at offset 64MB within a section. Don't access it.
> 
> 4. It is ZONE_DEVICE memory with an invalid memmap, because the memmap
> was not initialized yet. memmap_init_zone_device() did not yet succeed
> after dropping the mem_hotplug lock in mm/memremap.c. Don't access it.
> 
> 5. It is reserved ZONE_DEVICE memory ("pages mapped, but reserved for
> driver") with an invalid memmap. Don't access it.
> 
> I can see that your patch tries to make #5 vanish by initializing the
> memmap, fair enough. #3 and #4 can't be detected. The PFN walker could
> still stumble over uninitialized memmaps.
> 

FWIW, I thinkg having something like pfn_zone_device(), similarly
implemented like pfn_zone_device_reserved() could be one solution to
most issues.

-- 

Thanks,

David / dhildenb

