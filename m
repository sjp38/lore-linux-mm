Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37C826B0010
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 09:50:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f3-v6so1489613plf.1
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 06:50:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l6si1859836pgq.550.2018.03.14.06.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 06:50:28 -0700 (PDT)
Date: Wed, 14 Mar 2018 22:50:21 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH 8/8] trace_uprobe/sdt: Document about reference counter
Message-Id: <20180314225021.64109239de8b14b0aec1e1c5@kernel.org>
In-Reply-To: <20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On Tue, 13 Mar 2018 18:26:03 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> No functionality changes.

Please consider to describe what is this change and why, here.

> 
> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
> ---
>  Documentation/trace/uprobetracer.txt | 16 +++++++++++++---
>  kernel/trace/trace.c                 |  2 +-
>  2 files changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/trace/uprobetracer.txt b/Documentation/trace/uprobetracer.txt
> index bf526a7c..8fb13b0 100644
> --- a/Documentation/trace/uprobetracer.txt
> +++ b/Documentation/trace/uprobetracer.txt
> @@ -19,15 +19,25 @@ user to calculate the offset of the probepoint in the object.
>  
>  Synopsis of uprobe_tracer
>  -------------------------
> -  p[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a uprobe
> -  r[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a return uprobe (uretprobe)
> -  -:[GRP/]EVENT                           : Clear uprobe or uretprobe event
> +  p[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
> +  r[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]

Ah, OK in this context, [] means optional syntax :)

> +  -:[GRP/]EVENT
> +
> +  p : Set a uprobe
> +  r : Set a return uprobe (uretprobe)
> +  - : Clear uprobe or uretprobe event
>  
>    GRP           : Group name. If omitted, "uprobes" is the default value.
>    EVENT         : Event name. If omitted, the event name is generated based
>                    on PATH+OFFSET.
>    PATH          : Path to an executable or a library.
>    OFFSET        : Offset where the probe is inserted.
> +  REF_CTR_OFFSET: Reference counter offset. Optional field. Reference count
> +                  gate the invocation of probe. If present, by default
> +                  reference count is 0. Kernel needs to increment it before
> +                  tracing the probe and decrement it when done. This is
> +                  identical to semaphore in Userspace Statically Defined
> +                  Tracepoints (USDT).
>  
>    FETCHARGS     : Arguments. Each probe can have up to 128 args.
>     %REG         : Fetch register REG
> diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
> index 20a2300..2104d03 100644
> --- a/kernel/trace/trace.c
> +++ b/kernel/trace/trace.c
> @@ -4604,7 +4604,7 @@ static int tracing_trace_options_open(struct inode *inode, struct file *file)
>    "place (kretprobe): [<module>:]<symbol>[+<offset>]|<memaddr>\n"
>  #endif
>  #ifdef CONFIG_UPROBE_EVENTS
> -	"\t    place: <path>:<offset>\n"
> +  "   place (uprobe): <path>:<offset>[(ref_ctr_offset)]\n"
>  #endif
>  	"\t     args: <name>=fetcharg[:type]\n"
>  	"\t fetcharg: %<register>, @<address>, @<symbol>[+|-<offset>],\n"
> -- 
> 1.8.3.1
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
