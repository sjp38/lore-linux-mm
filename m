Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5CE6B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 16:41:43 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id q15so43882wra.22
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:41:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c7si1656821wmc.61.2018.03.06.13.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 13:41:42 -0800 (PST)
Date: Tue, 6 Mar 2018 13:41:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/4 v2] Define killable version for
 access_remote_vm() and use it in fs/proc
Message-Id: <20180306134139.375e15abab173329962f7d5a@linux-foundation.org>
In-Reply-To: <b576e32b-9c47-ee67-a576-b5a0c05c2864@linux.alibaba.com>
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
	<20180306124540.d8b5f6da97ab69a49566f950@linux-foundation.org>
	<b576e32b-9c47-ee67-a576-b5a0c05c2864@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mingo@kernel.org, adobriyan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 6 Mar 2018 13:17:37 -0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> 
> 
> It just mitigates the hung task warning, can't resolve the mmap_sem 
> scalability issue. Furthermore, waiting on pure uninterruptible state 
> for reading /proc sounds unnecessary. It doesn't wait for I/O completion.

OK.

> >
> > Where the heck are we holding mmap_sem for so long?  Can that be fixed?
> 
> The mmap_sem is held for unmapping a large map which has every single 
> page mapped. This is not a issue in real production code. Just found it 
> by running vm-scalability on a machine with ~600GB memory.
> 
> AFAIK, I don't see any easy fix for the mmap_sem scalability issue. I 
> saw range locking patches (https://lwn.net/Articles/723648/) were 
> floating around. But, it may not help too much on the case that a large 
> map with every single page mapped.

Well it sounds fairly simple to mitigate?  Simplistically: don't unmap
600G in a single hit; do it 1G at a time, dropping mmap_sem each time. 
A smarter version might only come up for air if there are mmap_sem
waiters and if it has already done some work.  I don't think we have
any particular atomicity requirements when unmapping?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
