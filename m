Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 86C2E28027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:13:48 -0400 (EDT)
Received: by ykay190 with SMTP id y190so49111775yka.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:13:48 -0700 (PDT)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id v138si4101865ywe.4.2015.07.15.15.13.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 15:13:47 -0700 (PDT)
Received: by ykax123 with SMTP id x123so49206816yka.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:13:47 -0700 (PDT)
Date: Wed, 15 Jul 2015 18:13:45 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/5] Make cpuid <-> nodeid mapping persistent.
Message-ID: <20150715221345.GO15934@mtj.duckdns.org>
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, laijs@cn.fujitsu.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Tue, Jul 07, 2015 at 05:30:20PM +0800, Tang Chen wrote:
> [Solution]
> 
> To fix this problem, we establish cpuid <-> nodeid mapping for all the possible
> cpus at boot time, and make it invariable. And according to init_cpu_to_node(),
> cpuid <-> nodeid mapping is based on apicid <-> nodeid mapping and cpuid <-> apicid
> mapping. So the key point is obtaining all cpus' apicid.
> 
> apicid can be obtained by _MAT (Multiple APIC Table Entry) method or found in
> MADT (Multiple APIC Description Table). So we finish the job in the following steps:
> 
> 1. Enable apic registeration flow to handle both enabled and disabled cpus.
>    This is done by introducing an extra parameter to generic_processor_info to let the
>    caller control if disabled cpus are ignored.
> 
> 2. Introduce a new array storing all possible cpuid <-> apicid mapping. And also modify
>    the way cpuid is calculated. Establish all possible cpuid <-> apicid mapping when
>    registering local apic. Store the mapping in the array introduced above.
> 
> 4. Enable _MAT and MADT relative apis to return non-presnet or disabled cpus' apicid.
>    This is also done by introducing an extra parameter to these apis to let the caller
>    control if disabled cpus are ignored.
> 
> 5. Establish all possible cpuid <-> nodeid mapping.
>    This is done via an additional acpi namespace walk for processors.

Hmmm... given that we probably want to allocate lower ids to the
online cpus, as otherwise we can end up failing to bring existing cpus
online because NR_CPUS is lower than the number of possible cpus, I
wonder whether doing this lazily could be better / easier.  e.g. just
remember the mapping as cpus come online.  When a new cpu comes up,
look up whether it came up before.  If so, use the ids from the last
time.  If not, allocate new ones.  I think that would be less amount
of change but does require updating the mapping dynamically.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
