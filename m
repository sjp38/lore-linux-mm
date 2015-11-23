Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id DEAC16B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 17:04:55 -0500 (EST)
Received: by ykfs79 with SMTP id s79so256088423ykf.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:04:55 -0800 (PST)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id i187si8968456ywg.133.2015.11.23.14.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 14:04:55 -0800 (PST)
Received: by ykdv3 with SMTP id v3so254474148ykd.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:04:54 -0800 (PST)
Date: Mon, 23 Nov 2015 17:04:51 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 0/5] Make cpuid <-> nodeid mapping persistent.
Message-ID: <20151123220451.GG19072@mtj.duckdns.org>
References: <1447906935-31899-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447906935-31899-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: cl@linux.com, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Thu, Nov 19, 2015 at 12:22:10PM +0800, Tang Chen wrote:
> [Solution]
> 
> There are four mappings in the kernel:
> 1. nodeid (logical node id)   <->   pxm
> 2. apicid (physical cpu id)   <->   nodeid
> 3. cpuid (logical cpu id)     <->   apicid
> 4. cpuid (logical cpu id)     <->   nodeid
> 
> 1. pxm (proximity domain) is provided by ACPI firmware in SRAT, and nodeid <-> pxm
>    mapping is setup at boot time. This mapping is persistent, won't change.
> 
> 2. apicid <-> nodeid mapping is setup using info in 1. The mapping is setup at boot
>    time and CPU hotadd time, and cleared at CPU hotremove time. This mapping is also
>    persistent.
> 
> 3. cpuid <-> apicid mapping is setup at boot time and CPU hotadd time. cpuid is
>    allocated, lower ids first, and released at CPU hotremove time, reused for other
>    hotadded CPUs. So this mapping is not persistent.
> 
> 4. cpuid <-> nodeid mapping is also setup at boot time and CPU hotadd time, and
>    cleared at CPU hotremove time. As a result of 3, this mapping is not persistent.
> 
> To fix this problem, we establish cpuid <-> nodeid mapping for all the possible
> cpus at boot time, and make it persistent. And according to init_cpu_to_node(),
> cpuid <-> nodeid mapping is based on apicid <-> nodeid mapping and cpuid <-> apicid
> mapping. So the key point is obtaining all cpus' apicid.

I don't know much about acpi so can't actually review the patches but
the overall approach looks good to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
