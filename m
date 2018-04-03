Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04CC36B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 10:17:58 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x8-v6so9992130pln.9
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 07:17:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o69si2253678pfj.329.2018.04.03.07.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 07:17:56 -0700 (PDT)
Date: Tue, 3 Apr 2018 10:17:53 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403101753.3391a639@gandalf.local.home>
In-Reply-To: <20180403135607.GC5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180403110612.GM5501@dhcp22.suse.cz>
	<20180403075158.0c0a2795@gandalf.local.home>
	<20180403121614.GV5501@dhcp22.suse.cz>
	<20180403082348.28cd3c1c@gandalf.local.home>
	<20180403123514.GX5501@dhcp22.suse.cz>
	<20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 3 Apr 2018 15:56:07 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 03-04-18 09:32:45, Steven Rostedt wrote:
> > On Tue, 3 Apr 2018 14:35:14 +0200
> > Michal Hocko <mhocko@kernel.org> wrote:  
> [...]
> > > Being clever is OK if it doesn't add a tricky code. And relying on
> > > si_mem_available is definitely tricky and obscure.  
> > 
> > Can we get the mm subsystem to provide a better method to know if an
> > allocation will possibly succeed or not before trying it? It doesn't
> > have to be free of races. Just "if I allocate this many pages right
> > now, will it work?" If that changes from the time it asks to the time
> > it allocates, that's fine. I'm not trying to prevent OOM to never
> > trigger. I just don't want to to trigger consistently.  
> 
> How do you do that without an actuall allocation request? And more
> fundamentally, what if your _particular_ request is just fine but it
> will get us so close to the OOM edge that the next legit allocation
> request simply goes OOM? There is simply no sane interface I can think
> of that would satisfy a safe/sensible "will it cause OOM" semantic.

That's where I'm fine with the admin shooting herself in the foot. If
they ask for almost all memory, and then the system needs more, that's
not our problem.

I'm more worried about putting in a couple of extra zeros by mistake,
which will pretty much guarantee an OOM on an active system.

>  
> > > > Perhaps I should try to allocate a large group of pages with
> > > > RETRY_MAYFAIL, and if that fails go back to NORETRY, with the thinking
> > > > that the large allocation may reclaim some memory that would allow the
> > > > NORETRY to succeed with smaller allocations (one page at a time)?    
> > > 
> > > That again relies on a subtle dependencies of the current
> > > implementation. So I would rather ask whether this is something that
> > > really deserves special treatment. If admin asks for a buffer of a
> > > certain size then try to do so. If we get OOM then bad luck you cannot
> > > get large memory buffers for free...  
> > 
> > That is not acceptable to me nor to the people asking for this.
> > 
> > The problem is known. The ring buffer allocates memory page by page,
> > and this can allow it to easily take all memory in the system before it
> > fails to allocate and free everything it had done.  
> 
> Then do not allow buffers that are too large. How often do you need
> buffers that are larger than few megs or small % of the available
> memory? Consuming excessive amount of memory just to trace workload
> which will need some memory on its own sounds just dubious to me.

For recording 100s of million events per second, it requires hundreds
of megs of memory. Large buffers are required for tracing. That's
extremely common.

> 
> > If you don't like the use of si_mem_available() I'll do the larger
> > pages method. Yes it depends on the current implementation of memory
> > allocation. It will depend on RETRY_MAYFAIL trying to allocate a large
> > number of pages, and fail if it can't (leaving memory for other
> > allocations to succeed).
> > 
> > The allocation of the ring buffer isn't critical. It can fail to
> > expand, and we can tell the user -ENOMEM. I original had NORETRY
> > because I rather have it fail than cause an OOM. But there's folks
> > (like Joel) that want it to succeed when there's available memory in
> > page caches.  
> 
> Then implement a retry logic on top of NORETRY. You can control how hard
> to retry to satisfy the request yourself. You still risk that your
> allocation will get us close to OOM for _somebody_ else though.
> 
> > I'm fine if the admin shoots herself in the foot if the ring buffer
> > gets big enough to start causing OOMs, but I don't want it to cause
> > OOMs if there's not even enough memory to fulfill the ring buffer size
> > itself.  
> 
> I simply do not see the difference between the two. Both have the same
> deadly effect in the end. The direct OOM has an arguable advantage that
> the effect is immediate rather than subtle with potential performance
> side effects until the machine OOMs after crawling for quite some time.

The difference is if the allocation succeeds or not. If it doesn't
succeed, we free all memory that we tried to allocate. If it succeeds
and causes issues, then yes, that's the admins fault. I'm worried about
the accidental putting in too big of a number, either by an admin by
mistake, or some stupid script that just thinks the current machines
has terabytes of memory.

I'm under the assumption that if I allocate an allocation of 32 pages
with RETRY_MAYFAIL, and there's 2 pages available, but not 32, and
while my allocation is reclaiming memory, and another task comes in and
asks for a single page, it can still succeed. This would be why I would
be using RETRY_MAYFAIL with higher orders of pages, that it doesn't
take all memory in the system if it fails. Is this assumption incorrect?

The current approach of allocating 1 page at a time with RETRY_MAYFAIL
is that it will succeed to get any pages that are available, until
there are none, and if some unlucky task asks for memory during that
time, it is guaranteed to fail its allocation triggering an OOM.

I was thinking of doing something like:

	large_pages = nr_pages / 32;
	if (large_pages) {
		pages = alloc_pages_node(cpu_to_node(cpu),
				GFP_KERNEL | __GFP_RETRY_MAYFAIL, 5);
		if (pages)
			/* break up pages */
		else
			/* try to allocate with NORETRY */
	}

Now it will allocate memory in 32 page chunks using reclaim. If it
fails to allocate them, it would not have taken up any smaller chunks
that were available, leaving them for other users. It would then go
back to singe pages, allocating with RETRY. Or I could just say screw
it, and make the allocation of the ring buffer always be 32 page chunks
(or at least make it user defined).

-- Steve
