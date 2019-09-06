Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C0BDC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 10:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 606DB2082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 10:03:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 606DB2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 086726B0006; Fri,  6 Sep 2019 06:03:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00F8E6B0007; Fri,  6 Sep 2019 06:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18C16B0008; Fri,  6 Sep 2019 06:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0139.hostedemail.com [216.40.44.139])
	by kanga.kvack.org (Postfix) with ESMTP id B89546B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 06:03:34 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 445FB180AD7C3
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:03:34 +0000 (UTC)
X-FDA: 75904058748.07.snow22_1ee7e575d4a20
X-HE-Tag: snow22_1ee7e575d4a20
X-Filterd-Recvd-Size: 8167
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 10:03:32 +0000 (UTC)
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x86A3G8q000676
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 6 Sep 2019 19:03:16 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x86A3G6V019248;
	Fri, 6 Sep 2019 19:03:16 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x86A3FRQ009995;
	Fri, 6 Sep 2019 19:03:16 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-813918; Fri, 6 Sep 2019 19:02:17 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0439.000; Fri, 6
 Sep 2019 19:02:16 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: David Hildenbrand <david@redhat.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>
CC: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
        "longman@redhat.com" <longman@redhat.com>,
        "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
        "mst@redhat.com" <mst@redhat.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Re: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
Thread-Topic: [RFC PATCH v2] mm: initialize struct pages reserved by
 ZONE_DEVICE driver.
Thread-Index: AQHVZIp2xk1cU6nEkk+ez7kL5reVFKcdvuyAgAAVnwA=
Date: Fri, 6 Sep 2019 10:02:15 +0000
Message-ID: <e762ee45-43e3-975a-ad19-065f07d1440f@vx.jp.nec.com>
References: <20190906081027.15477-1-t-fukasawa@vx.jp.nec.com>
 <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
In-Reply-To: <b7732a55-4a10-2c1d-c2f5-ca38ee60964d@redhat.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1386AA92981A614395BFC086033E6288@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you for your feedback.

On 2019/09/06 17:45, David Hildenbrand wrote:
> On 06.09.19 10:09, Toshiki Fukasawa wrote:
>> A kernel panic is observed during reading
>> /proc/kpage{cgroup,count,flags} for first few pfns allocated by
>> pmem namespace:
>>
>> BUG: unable to handle page fault for address: fffffffffffffffe
>> [  114.495280] #PF: supervisor read access in kernel mode
>> [  114.495738] #PF: error_code(0x0000) - not-present page
>> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
>> [  114.496713] Oops: 0000 [#1] SMP PTI
>> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1
>> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BI=
OS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
>> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
>> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 =
41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 =
<48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
>> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
>> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 00000000=
00000000
>> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd074=
89000000
>> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 00000000=
00000000
>> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000=
00240000
>> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e6=
01a0ff08
>> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knl=
GS:0000000000000000
>> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000=
000006e0
>> [  114.506401] Call Trace:
>> [  114.506660]  kpageflags_read+0xb1/0x130
>> [  114.507051]  proc_reg_read+0x39/0x60
>> [  114.507387]  vfs_read+0x8a/0x140
>> [  114.507686]  ksys_pread64+0x61/0xa0
>> [  114.508021]  do_syscall_64+0x5f/0x1a0
>> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>> [  114.508844] RIP: 0033:0x7f0266ba426b
>>
>> The first few pages of ZONE_DEVICE expressed as the range
>> (altmap->base_pfn) to (altmap->base_pfn + altmap->reserve) are
>> skipped by struct page initialization. Some pfn walkers like
>> /proc/kpage{cgroup, count, flags} can't handle these uninitialized
>> struct pages, which causes the error.
>>
>> In previous discussion, Dan seemed to have concern that the struct
>> page area of some pages indicated by vmem_altmap->reserve may not
>> be allocated. (See https://lore.kernel.org/lkml/CAPcyv4i5FjTOnPbXNcTzvt+=
e6RQYow0JRQwSFuxaa62LSuvzHQ@mail.gmail.com/)
>> However, arch_add_memory() called by devm_memremap_pages() allocates
>> struct page area for pages containing addresses in the range
>> (res.start) to (res.start + resource_size(res)), which include the
>> pages indicated by vmem_altmap->reserve. If I read correctly, it is
>> allocated as requested at least on x86_64. Also, memmap_init_zone()
>> initializes struct pages in the same range.
>> So I think the struct pages should be initialized.>
>=20
> For !ZONE_DEVICE memory, the memmap is valid with SECTION_IS_ONLINE -
> for the whole section. For ZONE_DEVICE memory we have no such
> indication. In any section that is !SECTION_IS_ONLINE and
> SECTION_MARKED_PRESENT, we could have any subsections initialized. >
> The only indication I am aware of is pfn_zone_device_reserved() - which
> seems to check exactly what you are trying to skip here.
>=20
> Can't you somehow use pfn_zone_device_reserved() ? Or if you considered
> that already, why did you decide against it?

No, in current approach this function is no longer needed.
The reason why we change the approach is that all pfn walkers
have to be aware of the uninitialized struct pages.

As for SECTION_IS_ONLINE, I'm not sure now.
I will look into it next week.

Thanks,
Toshiki Fukasawa

>=20
>> Signed-off-by: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
>> Cc: stable@vger.kernel.org
>> ---
>> Changes since rev 1:
>>   Instead of avoiding uninitialized pages on the pfn walker side,
>>   we initialize struct pages.
>>
>> mm/page_alloc.c | 5 +----
>>   1 file changed, 1 insertion(+), 4 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 9c91949..6d180ae 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5846,8 +5846,7 @@ void __meminit memmap_init_zone(unsigned long size=
, int nid, unsigned long zone,
>>  =20
>>   #ifdef CONFIG_ZONE_DEVICE
>>   	/*
>> -	 * Honor reservation requested by the driver for this ZONE_DEVICE
>> -	 * memory. We limit the total number of pages to initialize to just
>> +	 * We limit the total number of pages to initialize to just
>>   	 * those that might contain the memory mapping. We will defer the
>>   	 * ZONE_DEVICE page initialization until after we have released
>>   	 * the hotplug lock.
>> @@ -5856,8 +5855,6 @@ void __meminit memmap_init_zone(unsigned long size=
, int nid, unsigned long zone,
>>   		if (!altmap)
>>   			return;
>>  =20
>> -		if (start_pfn =3D=3D altmap->base_pfn)
>> -			start_pfn +=3D altmap->reserve;
>>   		end_pfn =3D altmap->base_pfn + vmem_altmap_offset(altmap);
>>   	}
>>   #endif
>>
>=20
> =


