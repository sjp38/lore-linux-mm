Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9409E6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 19:27:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f19-v6so6855422pgv.4
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:27:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z3si8565496pfm.151.2018.04.30.16.27.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 16:27:00 -0700 (PDT)
Date: Mon, 30 Apr 2018 16:26:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: access to uninitialized struct page
Message-Id: <20180430162658.598dd5dcdd0c67e36953281c@linux-foundation.org>
In-Reply-To: <20180426202619.2768-1-pasha.tatashin@oracle.com>
References: <20180426202619.2768-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, tglx@linutronix.de, mhocko@suse.com, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rostedt@goodmis.org, fengguang.wu@intel.com, dennisszhou@gmail.com

On Thu, 26 Apr 2018 16:26:19 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> The following two bugs were reported by Fengguang Wu:
> 
> kernel reboot-without-warning in early-boot stage, last printk:
> early console in setup code
> 
> http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
> 
> ...
>
> --- a/init/main.c
> +++ b/init/main.c
> @@ -585,8 +585,8 @@ asmlinkage __visible void __init start_kernel(void)
>  	setup_log_buf(0);
>  	vfs_caches_init_early();
>  	sort_main_extable();
> -	trap_init();
>  	mm_init();
> +	trap_init();
>  
>  	ftrace_init();

Gulp.  Let's hope that nothing in mm_init() requires that trap_init()
has been run.  What happens if something goes wrong during mm_init()
and the architecture attempts to raise a software exception, hits a bus
error, div-by-zero, etc, etc?  Might there be hard-to-discover
dependencies in such a case?
