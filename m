Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB829C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F43322CED
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:19:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F43322CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1EDC6B0003; Thu, 29 Aug 2019 11:19:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA8616B0269; Thu, 29 Aug 2019 11:19:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C98396B026A; Thu, 29 Aug 2019 11:19:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0193.hostedemail.com [216.40.44.193])
	by kanga.kvack.org (Postfix) with ESMTP id A36BE6B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:19:56 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4544D75B0
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:19:56 +0000 (UTC)
X-FDA: 75875825592.10.fold39_90e3ae15d7000
X-HE-Tag: fold39_90e3ae15d7000
X-Filterd-Recvd-Size: 8163
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:19:55 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6E945AF61;
	Thu, 29 Aug 2019 15:19:53 +0000 (UTC)
Date: Thu, 29 Aug 2019 17:19:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andy Lutomirski <luto@kernel.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Arun KS <arunks@codeaurora.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dave Airlie <airlied@redhat.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	John Hubbard <jhubbard@nvidia.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Oscar Salvador <osalvador@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>, Qian Cai <cai@lca.pw>,
	Rich Felker <dalias@libc.org>, Robin Murphy <robin.murphy@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Steve Capper <steve.capper@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Tony Luck <tony.luck@intel.com>, Vasily Gorbik <gor@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will@kernel.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v3 00/11] mm/memory_hotplug: Shrink zones before removing
 memory
Message-ID: <20190829151950.GI28313@dhcp22.suse.cz>
References: <20190829070019.12714-1-david@redhat.com>
 <20190829082323.GT28313@dhcp22.suse.cz>
 <ff42b158-11bb-5dd6-7c3b-0394b6b919bc@redhat.com>
 <ef4a4973-3df9-4368-cf50-463e2970348f@redhat.com>
 <90313ec8-a13e-5353-cc25-1c8993d5269c@redhat.com>
 <20190829121515.GE28313@dhcp22.suse.cz>
 <ac7f1b53-f30d-35d0-375f-18fa6262b059@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ac7f1b53-f30d-35d0-375f-18fa6262b059@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 29-08-19 14:29:22, David Hildenbrand wrote:
> On 29.08.19 14:15, Michal Hocko wrote:
> > On Thu 29-08-19 14:08:48, David Hildenbrand wrote:
> >> On 29.08.19 13:43, David Hildenbrand wrote:
> >>> On 29.08.19 13:33, David Hildenbrand wrote:
> >>>> On 29.08.19 10:23, Michal Hocko wrote:
> >>>>> On Thu 29-08-19 09:00:08, David Hildenbrand wrote:
> >>>>>> This is the successor of "[PATCH v2 0/6] mm/memory_hotplug: Consider all
> >>>>>> zones when removing memory". I decided to go one step further and finally
> >>>>>> factor out the shrinking of zones from memory removal code. Zones are now
> >>>>>> fixed up when offlining memory/onlining of memory fails/before removing
> >>>>>> ZONE_DEVICE memory.
> >>>>>
> >>>>> I was about to say Yay! but then reading...
> >>>>
> >>>> Almost ;)
> >>>>
> >>>>>
> >>>>>> Example:
> >>>>>>
> >>>>>> :/# cat /proc/zoneinfo
> >>>>>> Node 1, zone  Movable
> >>>>>>         spanned  0
> >>>>>>         present  0
> >>>>>>         managed  0
> >>>>>> :/# echo "online_movable" > /sys/devices/system/memory/memory41/state 
> >>>>>> :/# echo "online_movable" > /sys/devices/system/memory/memory43/state
> >>>>>> :/# cat /proc/zoneinfo
> >>>>>> Node 1, zone  Movable
> >>>>>>         spanned  98304
> >>>>>>         present  65536
> >>>>>>         managed  65536
> >>>>>> :/# echo 0 > /sys/devices/system/memory/memory43/online
> >>>>>> :/# cat /proc/zoneinfo
> >>>>>> Node 1, zone  Movable
> >>>>>>         spanned  32768
> >>>>>>         present  32768
> >>>>>>         managed  32768
> >>>>>> :/# echo 0 > /sys/devices/system/memory/memory41/online
> >>>>>> :/# cat /proc/zoneinfo
> >>>>>> Node 1, zone  Movable
> >>>>>>         spanned  0
> >>>>>>         present  0
> >>>>>>         managed  0
> >>>>>
> >>>>> ... this made me realize that you are trying to fix it instead. Could
> >>>>> you explain why do we want to do that? Why don't we simply remove all
> >>>>> that crap? Why do we even care about zone boundaries when offlining or
> >>>>> removing memory? Zone shrinking was mostly necessary with the previous
> >>>>> onlining semantic when the zone type could be only changed on the
> >>>>> boundary or unassociated memory. We can interleave memory zones now
> >>>>> arbitrarily.
> >>>>
> >>>> Last time I asked whether we can just drop all that nasty
> >>>> zone->contiguous handling I was being told that it does have a
> >>>> significant performance impact and is here to stay. The boundaries are a
> >>>> key component to detect whether a zone is contiguous.
> >>>>
> >>>> So yes, while we allow interleaved memory zones, having contiguous zones
> >>>> is beneficial for performance. That's why also memory onlining code will
> >>>> try to online memory as default to the zone that will keep/make zones
> >>>> contiguous.
> >>>>
> >>>> Anyhow, I think with this series most of the zone shrinking code becomes
> >>>> "digestible". Except minor issues with ZONE_DEVICE - which is acceptable.
> >>>>
> >>>
> >>> Also, there are plenty of other users of
> >>> node_spanned_pages/zone_spanned_pages etc.. I don't think this can go -
> >>> not that easy :)
> >>>
> >>
> >> ... re-reading, your suggestion is to drop the zone _shrinking_ code
> >> only, sorry :) That makes more sense.
> >>
> >> This would mean that once a zone was !contiguous, it will always remain
> >> like that. Also, even empty zones after unplug would not result in
> >> zone_empty() == true.
> > 
> > exactly. We only need to care about not declaring zone !contigious when
> > offlining from ends but that should be trivial.
> 
> That won't help a lot (offlining a DIMM will offline first to last
> memory block, so unlikely we can keep the zone !contiguous). However, we
> could limit zone shrinking to offlining code only (easy) and not perform
> it at all for ZONE_DEVICE memory. That would simplify things *a lot*.
> 
> What's your take? Remove it completely or do it only for !ZONE_DEVICE
> memory when offlining/onlining fails?
> 
> I think I would prefer to try to shrink for !ZONE_DEVICE memory, then we
> can at least try to keep contiguous set and reset in case it's possible.

I would remove that code altogether if that is possible and doesn't
introduce any side effects I am not aware right now. All the existing
code has to deal with holes already so I do not see any reason why it
cannot do the same with holes at both ends.
-- 
Michal Hocko
SUSE Labs

