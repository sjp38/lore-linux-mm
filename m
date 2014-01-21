Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id C9C6D6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 00:34:48 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so771204yho.34
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 21:34:48 -0800 (PST)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id 21si1947098yhx.156.2014.01.20.21.34.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 21:34:47 -0800 (PST)
Received: by mail-yk0-f176.google.com with SMTP id 131so5453512ykp.7
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 21:34:47 -0800 (PST)
Date: Mon, 20 Jan 2014 21:34:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [question] how to figure out OOM reason? should dump slab/vmalloc
 info when OOM?
In-Reply-To: <52DCFC33.80008@huawei.com>
Message-ID: <alpine.DEB.2.02.1401202130590.21729@chino.kir.corp.google.com>
References: <52DCFC33.80008@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 20 Jan 2014, Jianguo Wu wrote:

> When OOM happen, will dump buddy free areas info, hugetlb pages info,
> memory state of all eligible tasks, per-cpu memory info.
> But do not dump slab/vmalloc info, sometime, it's not enough to figure out the
> reason OOM happened.
> 
> So, my questions are:
> 1. Should dump slab/vmalloc info when OOM happen? Though we can get these from proc file,
> but usually we do not monitor the logs and check proc file immediately when OOM happened.
> 

The problem is that slabinfo becomes excessively verbose and dumping it 
all to the kernel log often times causes important messages to be lost.  
This is why we control things like the tasklist dump with a VM sysctl.  It 
would be possible to dump, say, the top ten slab caches with the highest 
memory usage, but it will only be helpful for slab leaks.  Typically there 
are better debugging tools available than analyzing the kernel log; if you 
see unusually high slab memory in the meminfo dump, you can enable it.

> 2. /proc/$pid/smaps and pagecache info also helpful when OOM, should also be dumped?
> 

Also very verbose and would cause important messages to be lost, we try to 
avoid spamming the kernel log with all of this information as much as 
possible.

> 3. Without these info, usually how to figure out OOM reason?
> 

Analyze the memory usage in the meminfo and determine what is unusually 
high; if it's mostly anonymous memory, you can usually correlate it back 
to a high rss for a process in the tasklist that you didn't suspect to be 
using that much memory, for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
