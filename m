Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F5BC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:28:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3807D2077B
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:28:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3807D2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C45B76B0266; Thu, 29 Aug 2019 11:28:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCC336B026D; Thu, 29 Aug 2019 11:28:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46176B026E; Thu, 29 Aug 2019 11:28:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0178.hostedemail.com [216.40.44.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAC76B0266
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:28:53 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 26D2C180AD7C3
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:28:53 +0000 (UTC)
X-FDA: 75875848146.25.fork42_4d677fb005329
X-HE-Tag: fork42_4d677fb005329
X-Filterd-Recvd-Size: 12413
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:28:51 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 452BA2BFDD;
	Thu, 29 Aug 2019 15:28:49 +0000 (UTC)
Received: from [10.36.117.243] (ovpn-117-243.ams2.redhat.com [10.36.117.243])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 346E6179ED;
	Thu, 29 Aug 2019 15:28:35 +0000 (UTC)
Subject: Re: [PATCH v3 00/11] mm/memory_hotplug: Shrink zones before removing
 memory
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexander Potapenko <glider@google.com>,
 Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Arun KS <arunks@codeaurora.org>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>, Dave Airlie
 <airlied@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Halil Pasic <pasic@linux.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>,
 Jun Yao <yaojun8558363@gmail.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Logan Gunthorpe <logang@deltatee.com>, Mark Rutland <mark.rutland@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Mel Gorman <mgorman@techsingularity.net>,
 Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Oscar Salvador
 <osalvador@suse.com>, Oscar Salvador <osalvador@suse.de>,
 Paul Mackerras <paulus@samba.org>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
 Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
 Souptick Joarder <jrdr.linux@gmail.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Steve Capper
 <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Tom Lendacky <thomas.lendacky@amd.com>, Tony Luck <tony.luck@intel.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Vlastimil Babka <vbabka@suse.cz>,
 Wei Yang <richard.weiyang@gmail.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Will Deacon <will@kernel.org>,
 Yang Shi <yang.shi@linux.alibaba.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Yu Zhao <yuzhao@google.com>
References: <20190829070019.12714-1-david@redhat.com>
 <20190829082323.GT28313@dhcp22.suse.cz>
 <ff42b158-11bb-5dd6-7c3b-0394b6b919bc@redhat.com>
 <ef4a4973-3df9-4368-cf50-463e2970348f@redhat.com>
 <90313ec8-a13e-5353-cc25-1c8993d5269c@redhat.com>
 <20190829121515.GE28313@dhcp22.suse.cz>
 <ac7f1b53-f30d-35d0-375f-18fa6262b059@redhat.com>
 <20190829151950.GI28313@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <387a85db-c639-eb08-72a1-6fb5a2aca324@redhat.com>
Date: Thu, 29 Aug 2019 17:28:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190829151950.GI28313@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 29 Aug 2019 15:28:50 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.08.19 17:19, Michal Hocko wrote:
> On Thu 29-08-19 14:29:22, David Hildenbrand wrote:
>> On 29.08.19 14:15, Michal Hocko wrote:
>>> On Thu 29-08-19 14:08:48, David Hildenbrand wrote:
>>>> On 29.08.19 13:43, David Hildenbrand wrote:
>>>>> On 29.08.19 13:33, David Hildenbrand wrote:
>>>>>> On 29.08.19 10:23, Michal Hocko wrote:
>>>>>>> On Thu 29-08-19 09:00:08, David Hildenbrand wrote:
>>>>>>>> This is the successor of "[PATCH v2 0/6] mm/memory_hotplug: Cons=
ider all
>>>>>>>> zones when removing memory". I decided to go one step further an=
d finally
>>>>>>>> factor out the shrinking of zones from memory removal code. Zone=
s are now
>>>>>>>> fixed up when offlining memory/onlining of memory fails/before r=
emoving
>>>>>>>> ZONE_DEVICE memory.
>>>>>>>
>>>>>>> I was about to say Yay! but then reading...
>>>>>>
>>>>>> Almost ;)
>>>>>>
>>>>>>>
>>>>>>>> Example:
>>>>>>>>
>>>>>>>> :/# cat /proc/zoneinfo
>>>>>>>> Node 1, zone  Movable
>>>>>>>>         spanned  0
>>>>>>>>         present  0
>>>>>>>>         managed  0
>>>>>>>> :/# echo "online_movable" > /sys/devices/system/memory/memory41/=
state=20
>>>>>>>> :/# echo "online_movable" > /sys/devices/system/memory/memory43/=
state
>>>>>>>> :/# cat /proc/zoneinfo
>>>>>>>> Node 1, zone  Movable
>>>>>>>>         spanned  98304
>>>>>>>>         present  65536
>>>>>>>>         managed  65536
>>>>>>>> :/# echo 0 > /sys/devices/system/memory/memory43/online
>>>>>>>> :/# cat /proc/zoneinfo
>>>>>>>> Node 1, zone  Movable
>>>>>>>>         spanned  32768
>>>>>>>>         present  32768
>>>>>>>>         managed  32768
>>>>>>>> :/# echo 0 > /sys/devices/system/memory/memory41/online
>>>>>>>> :/# cat /proc/zoneinfo
>>>>>>>> Node 1, zone  Movable
>>>>>>>>         spanned  0
>>>>>>>>         present  0
>>>>>>>>         managed  0
>>>>>>>
>>>>>>> ... this made me realize that you are trying to fix it instead. C=
ould
>>>>>>> you explain why do we want to do that? Why don't we simply remove=
 all
>>>>>>> that crap? Why do we even care about zone boundaries when offlini=
ng or
>>>>>>> removing memory? Zone shrinking was mostly necessary with the pre=
vious
>>>>>>> onlining semantic when the zone type could be only changed on the
>>>>>>> boundary or unassociated memory. We can interleave memory zones n=
ow
>>>>>>> arbitrarily.
>>>>>>
>>>>>> Last time I asked whether we can just drop all that nasty
>>>>>> zone->contiguous handling I was being told that it does have a
>>>>>> significant performance impact and is here to stay. The boundaries=
 are a
>>>>>> key component to detect whether a zone is contiguous.
>>>>>>
>>>>>> So yes, while we allow interleaved memory zones, having contiguous=
 zones
>>>>>> is beneficial for performance. That's why also memory onlining cod=
e will
>>>>>> try to online memory as default to the zone that will keep/make zo=
nes
>>>>>> contiguous.
>>>>>>
>>>>>> Anyhow, I think with this series most of the zone shrinking code b=
ecomes
>>>>>> "digestible". Except minor issues with ZONE_DEVICE - which is acce=
ptable.
>>>>>>
>>>>>
>>>>> Also, there are plenty of other users of
>>>>> node_spanned_pages/zone_spanned_pages etc.. I don't think this can =
go -
>>>>> not that easy :)
>>>>>
>>>>
>>>> ... re-reading, your suggestion is to drop the zone _shrinking_ code
>>>> only, sorry :) That makes more sense.
>>>>
>>>> This would mean that once a zone was !contiguous, it will always rem=
ain
>>>> like that. Also, even empty zones after unplug would not result in
>>>> zone_empty() =3D=3D true.
>>>
>>> exactly. We only need to care about not declaring zone !contigious wh=
en
>>> offlining from ends but that should be trivial.
>>
>> That won't help a lot (offlining a DIMM will offline first to last
>> memory block, so unlikely we can keep the zone !contiguous). However, =
we
>> could limit zone shrinking to offlining code only (easy) and not perfo=
rm
>> it at all for ZONE_DEVICE memory. That would simplify things *a lot*.
>>
>> What's your take? Remove it completely or do it only for !ZONE_DEVICE
>> memory when offlining/onlining fails?
>>
>> I think I would prefer to try to shrink for !ZONE_DEVICE memory, then =
we
>> can at least try to keep contiguous set and reset in case it's possibl=
e.
>=20
> I would remove that code altogether if that is possible and doesn't
> introduce any side effects I am not aware right now. All the existing
> code has to deal with holes already so I do not see any reason why it
> cannot do the same with holes at both ends.

I'll share a version that keeps shrinking the zones when
offlining/removing memory - so we can eventually set zone->contiguous
again (and keep it set on memory unplug) -  and drops the shrinking part
for ZONE_DEVICE memory, because there it really seems to be useless and
broken right now.

The series I am preparing right now minimizes shrinking code to a bare
minimum, which looks much better.

--=20

Thanks,

David / dhildenb

