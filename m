Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFA726B026B
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 17:30:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8so8410602pfh.13
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 14:30:36 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c13si6782267pfb.373.2018.03.30.14.30.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 14:30:35 -0700 (PDT)
Date: Fri, 30 Mar 2018 17:30:31 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180330173031.257a491a@gandalf.local.home>
In-Reply-To: <20180330205356.GA13332@bombadil.infradead.org>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180330205356.GA13332@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, 30 Mar 2018 13:53:56 -0700
Matthew Wilcox <willy@infradead.org> wrote:

> It seems to me that what you're asking for at the moment is
> lower-likelihood-of-failure-than-GFP_KERNEL, and it's not entirely
> clear to me why your allocation is so much more important than other
> allocations in the kernel.

The ring buffer is for fast tracing and is allocated when a user
requests it. Usually there's plenty of memory, but when a user wants a
lot of tracing events stored, they may increase it themselves.

> 
> Also, the pattern you have is very close to that of vmalloc.  You're
> allocating one page at a time to satisfy a multi-page request.  In lieu
> of actually thinking about what you should do, I might recommend using the
> same GFP flags as vmalloc() which works out to GFP_KERNEL | __GFP_NOWARN
> (possibly | __GFP_HIGHMEM if you can tolerate having to kmap the pages
> when accessed from within the kernel).

When the ring buffer was first created, we couldn't use vmalloc because
vmalloc access wasn't working in NMIs (that has recently changed with
lots of work to handle faults). But the ring buffer is broken up into
pages (that are sent to the user or to the network), and allocating one
page at a time makes everything work fine.

The issue that happens when someone allocates a large ring buffer is
that it will allocate all memory in the system before it fails. This
means that there's a short time that any allocation will cause an OOM
(which is what is happening).

I think I agree with Joel and Zhaoyang, that we shouldn't allocate a
ring buffer if there's not going to be enough memory to do it. If we
can see the available memory before we start allocating one page at a
time, and if the available memory isn't going to be sufficient, there's
no reason to try to do the allocation, and simply send to the use
-ENOMEM, and let them try something smaller.

I'll take a look at si_mem_available() that Joel suggested and see if
we can make that work.

-- Steve
