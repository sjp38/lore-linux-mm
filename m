Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 212D86B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 17:54:40 -0500 (EST)
Received: by pacej9 with SMTP id ej9so6272842pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:54:39 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id ia2si30190237pbb.85.2015.11.13.14.54.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 14:54:39 -0800 (PST)
Received: by pacej9 with SMTP id ej9so6272695pac.2
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 14:54:39 -0800 (PST)
Date: Fri, 13 Nov 2015 14:54:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory exhaustion testing?
In-Reply-To: <20151112215531.69ccec19@redhat.com>
Message-ID: <alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com>
References: <20151112215531.69ccec19@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>

On Thu, 12 Nov 2015, Jesper Dangaard Brouer wrote:

> Hi MM-people,
> 
> How do you/we test the error paths when the system runs out of memory?
> 
> What kind of tools do you use?
> or Any tricks to provoke this?
> 

Depends on the paths that you want to exercise when the system is out of 
memory :)  If it's just to trigger the oom killer, then no kernel module 
should be necessary if you're not limited by any cgroup and just disable 
swap and start off an anonymous memory hog that consumes all memory.

> For testing my recent change to the SLUB allocator, I've implemented a
> crude kernel module that tries to allocate all memory, so I can test the
> error code-path in kmem_cache_alloc_bulk.
> 

Trying to exercise certain paths under oom is difficult because the oom 
killer will usually quickly kill a process or you'll get hung up somewhere 
else that needs memory before the function you want to test.  This is why 
failslab had been used in the past, and does a good job at runtime 
testing.  My suggestion would just be to instrument the kernel to randomly 
fail as though the system is oom and ensure that it works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
