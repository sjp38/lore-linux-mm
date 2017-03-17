Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA5626B038A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 06:25:54 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c85so63529446qkg.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 03:25:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v24si6114952qtv.214.2017.03.17.03.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 03:25:54 -0700 (PDT)
Date: Fri, 17 Mar 2017 11:25:47 +0100
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
Message-ID: <20170317112547.18c7630c@nial.brq.redhat.com>
In-Reply-To: <20170316190125.GT27056@redhat.com>
References: <20170315091347.GA32626@dhcp22.suse.cz>
	<87shmedddm.fsf@vitty.brq.redhat.com>
	<20170315122914.GG32620@dhcp22.suse.cz>
	<87k27qd7m2.fsf@vitty.brq.redhat.com>
	<20170315131139.GK32620@dhcp22.suse.cz>
	<20170315163729.GR27056@redhat.com>
	<20170316053122.GA14701@js1304-P5Q-DELUXE>
	<20170316190125.GT27056@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Andi Kleen <ak@linux.intel.com>

On Thu, 16 Mar 2017 20:01:25 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

[...]
> If we can make zone overlap work with a 100% overlap across the whole
> node that would be a fine alternative, the zoneinfo.py output will
> look weird, but if that's the only downside it's no big deal. With
> sticky movable pageblocks it'll all be ZONE_NORMAL, with overlap it'll
> all be both ZONE_NORMAL and ZONE_MOVABLE at the same time.
Looks like I'm not getting idea with zone overlap, so

We potentially have a flag that hotplugged block is removable
so on hotplug we could register them with zone MOVABLE as default,
however here comes zone balance issue so we can't do it until
it's solved.

As Vitaly's suggested we could steal(convert) existing blocks from
the border of MOVABLE zone into zone NORMAL when there isn't enough
memory in zone NORMAL to accommodate page tables extension for
just arrived new memory block. That would make a memory module
containing stolen block non-removable, but that may be acceptable
sacrifice to keep system alive. Potentially on attempt to remove it
kernel could even inform hardware(hypervisor) that memory module
become non removable using _OST ACPI method.


> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
