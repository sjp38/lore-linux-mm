Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 8D97F6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:57:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3641192pbb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:57:38 -0700 (PDT)
Date: Fri, 8 Jun 2012 12:57:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oomkillers gone wild.
In-Reply-To: <20120605185239.GA28172@redhat.com>
Message-ID: <alpine.DEB.2.00.1206081256330.19054@chino.kir.corp.google.com>
References: <20120604152710.GA1710@redhat.com> <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com> <20120605174454.GA23867@redhat.com> <20120605185239.GA28172@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 5 Jun 2012, Dave Jones wrote:

>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME 
> 142524 142420  99%    9.67K  47510	  3   1520320K task_struct
> 142560 142417  99%    1.75K   7920	 18    253440K signal_cache
> 142428 142302  99%    1.19K   5478	 26    175296K task_xstate
> 306064 289292  94%    0.36K   6956	 44    111296K debug_objects_cache
> 143488 143306  99%    0.50K   4484	 32     71744K cred_jar
> 142560 142421  99%    0.50K   4455       32     71280K task_delay_info
> 150753 145021  96%    0.45K   4308	 35     68928K kmalloc-128
> 
> Why so many task_structs ? There's only 128 processes running, and most of them
> are kernel threads.
> 

Do you have CONFIG_OPROFILE enabled?

> /sys/kernel/slab/task_struct/alloc_calls shows..
> 
>  142421 copy_process.part.21+0xbb/0x1790 age=8/19929576/48173720 pid=0-16867 cpus=0-7
> 
> I get the impression that the oom-killer hasn't cleaned up properly after killing some of
> those forked processes.
> 
> any thoughts ?
> 

If we're leaking task_struct's, meaning that put_task_struct() isn't 
actually freeing them when the refcount goes to 0, then it's certainly not 
because of the oom killer which only sends a SIGKILL to the selected 
process.

Have you tried kmemleak?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
