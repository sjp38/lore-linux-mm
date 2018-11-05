Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD12E6B0276
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:20:09 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id 88-v6so9313670wrp.21
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:20:09 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a19-v6si20714285wme.132.2018.11.05.13.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Nov 2018 13:20:08 -0800 (PST)
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7693f8a2-e180-520a-0d07-cc3090d2139f@infradead.org>
Date: Mon, 5 Nov 2018 13:19:50 -0800
MIME-Version: 1.0
In-Reply-To: <20181105165558.11698-2-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On 11/5/18 8:55 AM, Daniel Jordan wrote:
> Motivates and explains the ktask API for kernel clients.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  Documentation/core-api/index.rst |   1 +
>  Documentation/core-api/ktask.rst | 213 +++++++++++++++++++++++++++++++
>  2 files changed, 214 insertions(+)
>  create mode 100644 Documentation/core-api/ktask.rst

Hi,

> diff --git a/Documentation/core-api/ktask.rst b/Documentation/core-api/ktask.rst
> new file mode 100644
> index 000000000000..c3c00e1f802f
> --- /dev/null
> +++ b/Documentation/core-api/ktask.rst
> @@ -0,0 +1,213 @@
> +.. SPDX-License-Identifier: GPL-2.0+
> +
> +============================================
> +ktask: parallelize CPU-intensive kernel work
> +============================================
> +
> +:Date: November, 2018
> +:Author: Daniel Jordan <daniel.m.jordan@oracle.com>
> +
> +
> +Introduction
> +============

[snip]


> +Resource Limits
> +===============
> +
> +ktask has resource limits on the number of work items it sends to workqueue.

                                                                  to a workqueue.
or:                                                               to workqueues.

> +In ktask, a workqueue item is a thread that runs chunks of the task until the
> +task is finished.
> +
> +These limits support the different ways ktask uses workqueues:
> + - ktask_run to run threads on the calling thread's node.
> + - ktask_run_numa to run threads on the node(s) specified.
> + - ktask_run_numa with nid=NUMA_NO_NODE to run threads on any node in the
> +   system.
> +
> +To support these different ways of queueing work while maintaining an efficient
> +concurrency level, we need both system-wide and per-node limits on the number

I would prefer to refer to ktask as ktask instead of "we", so
s/we need/ktask needs/


> +of threads.  Without per-node limits, a node might become oversubscribed
> +despite ktask staying within the system-wide limit, and without a system-wide
> +limit, we can't properly account for work that can run on any node.

s/we/ktask/

> +
> +The system-wide limit is based on the total number of CPUs, and the per-node
> +limit on the CPU count for each node.  A per-node work item counts against the
> +system-wide limit.  Workqueue's max_active can't accommodate both types of
> +limit, no matter how many workqueues are used, so ktask implements its own.
> +
> +If a per-node limit is reached, the work item is allowed to run anywhere on the
> +machine to avoid overwhelming the node.  If the global limit is also reached,
> +ktask won't queue additional work items until we fall below the limit again.

s/we fall/ktask falls/
or s/we fall/it falls/

> +
> +These limits apply only to workqueue items--that is, helper threads beyond the
> +one starting the task.  That way, one thread per task is always allowed to run.


thanks.
-- 
~Randy
