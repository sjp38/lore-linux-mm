Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A447BC43331
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 09:21:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53AA52082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 09:21:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53AA52082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 930CE6B0003; Fri,  6 Sep 2019 05:21:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E1D76B0006; Fri,  6 Sep 2019 05:21:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A83C6B0007; Fri,  6 Sep 2019 05:21:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0250.hostedemail.com [216.40.44.250])
	by kanga.kvack.org (Postfix) with ESMTP id 54F226B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 05:21:36 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id D711A1B660
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:21:35 +0000 (UTC)
X-FDA: 75903952950.15.pies50_653016b1e3d4b
X-HE-Tag: pies50_653016b1e3d4b
X-Filterd-Recvd-Size: 9696
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 09:21:35 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 55BDE308FC20;
	Fri,  6 Sep 2019 09:21:33 +0000 (UTC)
Received: from [10.36.117.162] (ovpn-117-162.ams2.redhat.com [10.36.117.162])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 404525D9CA;
	Fri,  6 Sep 2019 09:21:24 +0000 (UTC)
Subject: Re: [PATCH v4 0/8] mm/memory_hotplug: Shrink zones before removing
 memory
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Andy Lutomirski <luto@kernel.org>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Dave Hansen <dave.hansen@linux.intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Halil Pasic <pasic@linux.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Jun Yao <yaojun8558363@gmail.com>,
 Logan Gunthorpe <logang@deltatee.com>, Mark Rutland <mark.rutland@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>,
 Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
 Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
 Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Tom Lendacky <thomas.lendacky@amd.com>, Tony Luck <tony.luck@intel.com>,
 Vasily Gorbik <gor@linux.ibm.com>, Wei Yang <richard.weiyang@gmail.com>,
 Wei Yang <richardw.yang@linux.intel.com>, Will Deacon <will@kernel.org>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Yu Zhao <yuzhao@google.com>
References: <20190830091428.18399-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d77b4ef9-2524-cfab-58aa-a2a6d42bb121@redhat.com>
Date: Fri, 6 Sep 2019 11:21:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190830091428.18399-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 06 Sep 2019 09:21:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.08.19 11:14, David Hildenbrand wrote:
> This series fixes the access of uninitialized memmaps when shrinking
> zones/nodes and when removing memory.
> 
> We stop trying to shrink ZONE_DEVICE, as it's buggy, fixing it would be
> more involved (we don't have SECTION_IS_ONLINE as an indicator), and
> shrinking is only of limited use (set_zone_contiguous() cannot detect
> the ZONE_DEVICE as contiguous). As far as I can tell, this should be fine
> for ZONE_DEVICE.
> 
> We continue shrinking zones, but I reduced the amount of code to a
> minimum. Shrinking is especially necessary to keep zone->contiguous set
> where possible, especially on memory unplug of DIMMs at zone boundaries.
> 
> --------------------------------------------------------------------------
> 
> Zones are now properly shrunk when offlining memory blocks or when
> onlining failed. This allows to properly shrink zones on memory unplug
> even if the separate memory blocks of a DIMM were onlined to different
> zones or re-onlined to a different zone after offlining.
> 
> Example:
> 
> :/# cat /proc/zoneinfo
> Node 1, zone  Movable
>         spanned  0
>         present  0
>         managed  0
> :/# echo "online_movable" > /sys/devices/system/memory/memory41/state
> :/# echo "online_movable" > /sys/devices/system/memory/memory43/state
> :/# cat /proc/zoneinfo
> Node 1, zone  Movable
>         spanned  98304
>         present  65536
>         managed  65536
> :/# echo 0 > /sys/devices/system/memory/memory43/online
> :/# cat /proc/zoneinfo
> Node 1, zone  Movable
>         spanned  32768
>         present  32768
>         managed  32768
> :/# echo 0 > /sys/devices/system/memory/memory41/online
> :/# cat /proc/zoneinfo
> Node 1, zone  Movable
>         spanned  0
>         present  0
>         managed  0
> 
> --------------------------------------------------------------------------
> 
> I tested this with DIMMs on x86, but didn't test the ZONE_DEVICE part yet.
> 
> 
> v3 -> v4:
> - Drop "mm/memremap: Get rid of memmap_init_zone_device()"
> -- As Alexander noticed, it was messy either way :)
> - Drop "mm/memory_hotplug: Exit early in __remove_pages() on BUGs"
> - Drop "mm: Exit early in set_zone_contiguous() if already contiguous"
> - Drop "mm/memory_hotplug: Optimize zone shrinking code when checking for
>   holes"
> - Merged "mm/memory_hotplug: Remove pages from a zone before removing
>   memory" and "mm/memory_hotplug: Remove zone parameter from
>   __remove_pages()" into "mm/memory_hotplug: Shrink zones when offlining
>   memory"
> - Added "mm/memory_hotplug: Poison memmap in remove_pfn_range_from_zone()"
> - Stop shrinking ZONE_DEVICE
> - Reshuffle patches, moving all fixes to the front. Add Fixes: tags.
> - Change subject/description of various patches
> - Minor changes (too many to mention)
> 
> 
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>

Friendly ping. Can any of the devmem folks verify that this fixes the
devmem issues (and not breaks it :) )?

-- 

Thanks,

David / dhildenb

