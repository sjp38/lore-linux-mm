Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0E5C6B0008
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 09:32:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so3583405plm.12
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 06:32:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id bj1-v6si537573plb.690.2018.04.03.06.32.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 06:32:48 -0700 (PDT)
Date: Tue, 3 Apr 2018 09:32:45 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403093245.43e7e77c@gandalf.local.home>
In-Reply-To: <20180403123514.GX5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180403110612.GM5501@dhcp22.suse.cz>
	<20180403075158.0c0a2795@gandalf.local.home>
	<20180403121614.GV5501@dhcp22.suse.cz>
	<20180403082348.28cd3c1c@gandalf.local.home>
	<20180403123514.GX5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 3 Apr 2018 14:35:14 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> > If we use NORETRY, then we have those that complain that we do not try
> > hard enough to reclaim memory. If we use RETRY_MAYFAIL we have this
> > issue of taking up all memory before we get what we want.  
> 
> Just try to do what admin asks for and trust it will not try to shoot
> his foot? I mean there are other ways admin can shoot the machine down.

Allowing the admin to just shoot her foot is not an option.

Yes there are many ways to bring down a machine, but this shouldn't be
one of them. All one needs to do is echo too big of a number
into /sys/kernel/tracing/buffer_size_kb and OOM may kill a critical
program on a production machine. Tracing is made for production, and
should not allow an easy way to trigger OOM.

> Being clever is OK if it doesn't add a tricky code. And relying on
> si_mem_available is definitely tricky and obscure.

Can we get the mm subsystem to provide a better method to know if an
allocation will possibly succeed or not before trying it? It doesn't
have to be free of races. Just "if I allocate this many pages right
now, will it work?" If that changes from the time it asks to the time
it allocates, that's fine. I'm not trying to prevent OOM to never
trigger. I just don't want to to trigger consistently.

> 
> > Perhaps I should try to allocate a large group of pages with
> > RETRY_MAYFAIL, and if that fails go back to NORETRY, with the thinking
> > that the large allocation may reclaim some memory that would allow the
> > NORETRY to succeed with smaller allocations (one page at a time)?  
> 
> That again relies on a subtle dependencies of the current
> implementation. So I would rather ask whether this is something that
> really deserves special treatment. If admin asks for a buffer of a
> certain size then try to do so. If we get OOM then bad luck you cannot
> get large memory buffers for free...

That is not acceptable to me nor to the people asking for this.

The problem is known. The ring buffer allocates memory page by page,
and this can allow it to easily take all memory in the system before it
fails to allocate and free everything it had done.

If you don't like the use of si_mem_available() I'll do the larger
pages method. Yes it depends on the current implementation of memory
allocation. It will depend on RETRY_MAYFAIL trying to allocate a large
number of pages, and fail if it can't (leaving memory for other
allocations to succeed).

The allocation of the ring buffer isn't critical. It can fail to
expand, and we can tell the user -ENOMEM. I original had NORETRY
because I rather have it fail than cause an OOM. But there's folks
(like Joel) that want it to succeed when there's available memory in
page caches.

I'm fine if the admin shoots herself in the foot if the ring buffer
gets big enough to start causing OOMs, but I don't want it to cause
OOMs if there's not even enough memory to fulfill the ring buffer size
itself.

-- Steve
