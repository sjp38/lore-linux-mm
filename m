Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18F606B038E
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:09:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g8so3127723wmg.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 07:09:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p144sor177015wme.11.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Mar 2017 07:09:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170317132036.GI26298@dhcp22.suse.cz>
References: <20170315091347.GA32626@dhcp22.suse.cz> <20170317132036.GI26298@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@gmail.com>
Date: Tue, 21 Mar 2017 07:09:15 -0700
Message-ID: <CAA9_cmffsak7vYnEkNmvmg6rrd_iECAJBmYU8eRU2HQwBWAi_w@mail.gmail.com>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, Toshi Kani <toshi.kani@hpe.com>, xieyisheng1@huawei.com, slaoub@gmail.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Andi Kleen <ak@linux.intel.com>

On Fri, Mar 17, 2017 at 6:20 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 15-03-17 10:13:47, Michal Hocko wrote:
> [...]
>> It seems that all this is just started by the semantic introduced by
>> 9d99aaa31f59 ("[PATCH] x86_64: Support memory hotadd without sparsemem")
>> quite some time ago. When the movable onlinining has been introduced it
>> just built on top of this. It seems that the requirement to have
>> freshly probed memory associated with the zone normal is no longer
>> necessary. HOTPLUG depends on CONFIG_SPARSEMEM these days.
>>
>> The following blob [2] simply removes all the zone specific operations
>> from __add_pages (aka arch_add_memory) path.  Instead we do page->zone
>> association from move_pfn_range which is called from online_pages. The
>> criterion for movable/normal zone association is really simple now. We
>> just have to guarantee that zone Normal is always lower than zone
>> Movable. It would be actually sufficient to guarantee they do not
>> overlap and that is indeed trivial to implement now. I didn't do that
>> yet for simplicity of this change though.
>
> Does anybody have any comments on this? Any issues I've overlooked
> (except for the one pointed by Toshi Kani which is already fixed in my
> local branch)?

It disables the ZONE_DEVICE use case, but like we chatted about at LSF
I'll take a look at having devm_memremap_pages() call
move_pfn_range().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
