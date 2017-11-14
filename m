Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 229266B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 10:53:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 82so7450150pfp.5
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 07:53:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si6440348pgn.593.2017.11.14.07.53.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 07:53:31 -0800 (PST)
Date: Tue, 14 Nov 2017 15:53:27 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Allocation failure of ring buffer for trace
Message-ID: <20171114155327.5ugozxxsofqoohv2@suse.de>
References: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
 <20171114114633.6ltw7f4y7qwipcqp@suse.de>
 <48b66fc4-ef82-983c-1b3d-b9c0a482bc51@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <48b66fc4-ef82-983c-1b3d-b9c0a482bc51@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: rostedt@goodmis.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, koki.sanagi@us.fujitsu.com

On Tue, Nov 14, 2017 at 10:39:19AM -0500, YASUAKI ISHIMATSU wrote:
> 
> 
> On 11/14/2017 06:46 AM, Mel Gorman wrote:
> > On Mon, Nov 13, 2017 at 12:48:36PM -0500, YASUAKI ISHIMATSU wrote:
> >> When using trace_buf_size= boot option, memory allocation of ring buffer
> >> for trace fails as follows:
> >>
> >> [ ] x86: Booting SMP configuration:
> >> <SNIP>
> >>
> >> In my server, there are 384 CPUs, 512 GB memory and 8 nodes. And
> >> "trace_buf_size=100M" is set.
> >>
> >> When using trace_buf_size=100M, kernel allocates 100 MB memory
> >> per CPU before calling free_are_init_core(). Kernel tries to
> >> allocates 38.4GB (100 MB * 384 CPU) memory. But available memory
> >> at this time is about 16GB (2 GB * 8 nodes) due to the following commit:
> >>
> >>   3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages
> >>                  if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
> >>
> > 
> > 1. What is the use case for such a large trace buffer being allocated at
> >    boot time?
> 
> I'm not sure the use case. I found the following commit log:
> 
>   commit 864b9a393dcb5aed09b8fd31b9bbda0fdda99374
>   Author: Michal Hocko <mhocko@suse.com>
>   Date:   Fri Jun 2 14:46:49 2017 -0700
> 
>       mm: consider memblock reservations for deferred memory initialization sizing
> 
> So I thought similar memory exhaustion may occurs on other boot option.
> And I reproduced the issue.
> 

That was different, it was a premature OOM caused by reservations that
were of a known size. It's not related to trace_buf_size in any fashion.

> 
> > 2. Is disabling CONFIG_DEFERRED_STRUCT_PAGE_INIT at compile time an
> >    option for you given that it's a custom-built kernel and not a
> >    distribution kernel?
> 
> The issue also occurred on distribution kernels. So we have to fix the issue.
> 

I'm aware of now bugs against a distribution kernel. However, does the
patch work for you?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
