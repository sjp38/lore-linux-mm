Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76B916B02F2
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 05:05:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k14so11185134pga.5
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:05:34 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id d3si5478963pfl.420.2017.04.28.02.05.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 02:05:33 -0700 (PDT)
Subject: Re: Generic approach to customizable zones - was: Re: [PATCH v7 0/7]
 Introduce ZONE_CMA
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop> <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <d3c0d01c-ef3f-56f8-2701-a32f8be2d13b@huawei.com>
 <20170428083625.GG8143@dhcp22.suse.cz>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <94c6467f-39a8-9819-9a57-8229cefd7971@huawei.com>
Date: Fri, 28 Apr 2017 12:04:03 +0300
MIME-Version: 1.0
In-Reply-To: <20170428083625.GG8143@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com



On 28/04/17 11:36, Michal Hocko wrote:
> I didn't read this thoughly yet because I will be travelling shortly

ok, thanks for bearing with me =)

> but
> this point alone just made ask, because it seems there is some
> misunderstanding

It is possible, so far I did some changes, but I have not completed the
whole conversion.

> On Fri 28-04-17 11:04:27, Igor Stoppa wrote:
> [...]
>> * if one is happy to have a 64bits type, allow for as many zones as
>>   it's possible to fit, or anyway more than what is possible with
>>   the 32 bit mask.
> 
> zones are currently placed in struct page::flags. And that already is
> 64b size on 64b arches. 

Ok, the issues I had so fare were related to the enum for zones being
treated as 32b.

> And we do not really have any room spare there.
> We encode page flags, zone id, numa_nid/sparse section_nr there. How can
> you add more without enlarging the struct page itself or using external
> means to store the same information (page_ext comes to mind)?

Then I'll be conservative and assume I can't, unless I can prove otherwise.

There is still the possibility I mentioned of loosely coupling DMA,
DMA32 and HIGHMEM with the bits currently reserved for them, right?

If my system doesn't use those zones as such, because it doesn't
have/need them, those bits are wasted for me. Otoh someone else is
probably not interested in what I'm after but needs one or more of those
zones.

Making the meaning of the bits configurable should still be a viable
option. It's not altering their amount, just their purpose on a specific
build.

> Even if
> the later would be possible then note thatpage_zone() is used in many
> performance sensitive paths and making it perform well with special
> casing would be far from trivial.


If the solution I propose is acceptable, I'm willing to bite the bullet
and go for implementing the conversion.

In my case I really would like to be able to use kmalloc, because it
would provide an easy path to convert also other portions of the kernel,
besides SE Linux.

I suspect I would encounter overall far less resistance if the type of
change I propose is limited to:

s/GFP_KERNEL/GFP_LOCKABLE/

And if I can guarrantee that GFP_LOCKABLE falls back to GFP_KERNEL when
the "lockable" feature is not enabled.


--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
