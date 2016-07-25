Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A43F16B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 19:20:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so433892735pfb.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 16:20:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g9si35838184pfk.211.2016.07.25.16.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 16:20:24 -0700 (PDT)
Date: Mon, 25 Jul 2016 16:20:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 0/7] Make cpuid <-> nodeid mapping persistent
Message-Id: <20160725162022.e90e9c6c74a5d147e39e5945@linux-foundation.org>
In-Reply-To: <1469435749-19582-1-git-send-email-douly.fnst@cn.fujitsu.com>
References: <1469435749-19582-1-git-send-email-douly.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dou Liyang <douly.fnst@cn.fujitsu.com>
Cc: cl@linux.com, tj@kernel.org, mika.j.penttila@gmail.com, mingo@redhat.com, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, len.brown@intel.com, lenb@kernel.org, tglx@linutronix.de, chen.tang@easystack.cn, rafael@kernel.org, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 25 Jul 2016 16:35:42 +0800 Dou Liyang <douly.fnst@cn.fujitsu.com> wrote:

> [Problem]
> 
> cpuid <-> nodeid mapping is firstly established at boot time. And workqueue caches
> the mapping in wq_numa_possible_cpumask in wq_numa_init() at boot time.
> 
> When doing node online/offline, cpuid <-> nodeid mapping is established/destroyed,
> which means, cpuid <-> nodeid mapping will change if node hotplug happens. But
> workqueue does not update wq_numa_possible_cpumask.
> 
> So here is the problem:
> 
> Assume we have the following cpuid <-> nodeid in the beginning:
> 
>   Node | CPU
> ------------------------
> node 0 |  0-14, 60-74
> node 1 | 15-29, 75-89
> node 2 | 30-44, 90-104
> node 3 | 45-59, 105-119
> 
> and we hot-remove node2 and node3, it becomes:
> 
>   Node | CPU
> ------------------------
> node 0 |  0-14, 60-74
> node 1 | 15-29, 75-89
> 
> and we hot-add node4 and node5, it becomes:
> 
>   Node | CPU
> ------------------------
> node 0 |  0-14, 60-74
> node 1 | 15-29, 75-89
> node 4 | 30-59
> node 5 | 90-119
> 
> But in wq_numa_possible_cpumask, cpu30 is still mapped to node2, and the like.
> 
> When a pool workqueue is initialized, if its cpumask belongs to a node, its
> pool->node will be mapped to that node. And memory used by this workqueue will
> also be allocated on that node.

Plan B is to hunt down and fix up all the workqueue structures at
hotplug-time.  Has that option been evaluated?


Your fix is x86-only and this bug presumably affects other
architectures, yes?  I think a "Plan B" would fix all architectures?


Thirdly, what is the merge path for these patches?  Is an x86
or ACPI maintainer working with you on them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
