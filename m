Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7856B0278
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 23:07:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i128so5932986pfg.2
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 20:07:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b17si7445385pfd.155.2018.03.30.20.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 20:07:37 -0700 (PDT)
Date: Fri, 30 Mar 2018 23:07:33 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180330230733.2bf010f2@gandalf.local.home>
In-Reply-To: <20180331021857.GD13332@bombadil.infradead.org>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180330205356.GA13332@bombadil.infradead.org>
	<20180330173031.257a491a@gandalf.local.home>
	<20180330174209.4cb77003@gandalf.local.home>
	<CAJWu+orx=NZrkAf7x_HqttnrMssmW7DPZOL1fxR=N6D_-fbmtw@mail.gmail.com>
	<20180330214151.415e90ea@gandalf.local.home>
	<20180331021857.GD13332@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joel Fernandes <joelaf@google.com>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, 30 Mar 2018 19:18:57 -0700
Matthew Wilcox <willy@infradead.org> wrote:

> Again though, this is the same pattern as vmalloc.  There are any number
> of places where userspace can cause an arbitrarily large vmalloc to be
> attempted (grep for kvmalloc_array for a list of promising candidates).
> I'm pretty sure that just changing your GFP flags to GFP_KERNEL |
> __GFP_NOWARN will give you the exact behaviour that you want with no
> need to grub around in the VM to find out if your huge allocation is
> likely to succeed.

Not sure how this helps. Note, I don't care about consecutive pages, so
this is not an array. It's a link list of thousands of pages. How do
you suggest allocating them? The ring buffer is a link list of pages.

What I currently do is to see how many more pages I need. Allocate them
one at a time and put them in a temporary list, if it succeeds I add
them to the ring buffer, if not, I free the entire list (it's an all or
nothing operation).

The allocation I'm making doesn't warn. The problem is the
GFP_RETRY_MAYFAIL, which will try to allocate any possible memory in
the system. When it succeeds, the ring buffer allocation logic will
then try to allocate another page. If we add too many pages, we will
allocate all possible pages and then try to allocate more. This
allocation will fail without causing an OOM. That's not the problem.
The problem is if the system is active during this time, and something
else tries to do any allocation, after all memory has been consumed,
that allocation will fail. Then it will trigger an OOM.

I showed this in my Call Trace, that the allocation that failed during
my test was something completely unrelated, and that failure caused an
OOM.

What this last patch does is see if there's space available before it
even starts the process.

Maybe I'm missing something, but I don't see how NOWARN can help. My
allocations are not what is giving the warning.

-- Steve
