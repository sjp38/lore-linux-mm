Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8299E6B0275
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 22:19:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n15so8850128pff.14
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 19:19:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x6si6487557pgq.260.2018.03.30.19.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Mar 2018 19:19:03 -0700 (PDT)
Date: Fri, 30 Mar 2018 19:18:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180331021857.GD13332@bombadil.infradead.org>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home>
 <20180330205356.GA13332@bombadil.infradead.org>
 <20180330173031.257a491a@gandalf.local.home>
 <20180330174209.4cb77003@gandalf.local.home>
 <CAJWu+orx=NZrkAf7x_HqttnrMssmW7DPZOL1fxR=N6D_-fbmtw@mail.gmail.com>
 <20180330214151.415e90ea@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180330214151.415e90ea@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Joel Fernandes <joelaf@google.com>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, Mar 30, 2018 at 09:41:51PM -0400, Steven Rostedt wrote:
> On Fri, 30 Mar 2018 16:38:52 -0700
> Joel Fernandes <joelaf@google.com> wrote:
> 
> > > --- a/kernel/trace/ring_buffer.c
> > > +++ b/kernel/trace/ring_buffer.c
> > > @@ -1164,6 +1164,11 @@ static int __rb_allocate_pages(long nr_pages, struct list_head *pages, int cpu)
> > >         struct buffer_page *bpage, *tmp;
> > >         long i;
> > >
> > > +       /* Check if the available memory is there first */
> > > +       i = si_mem_available();
> > > +       if (i < nr_pages)  
> > 
> > Does it make sense to add a small margin here so that after ftrace
> > finishes allocating, we still have some memory left for the system?
> > But then then we have to define a magic number :-|
> 
> I don't think so. The memory is allocated by user defined numbers. They
> can do "free" to see what is available. The original patch from
> Zhaoyang was due to a script that would just try a very large number
> and cause issues.
> 
> If the memory is available, I just say let them have it. This is
> borderline user space issue and not a kernel one.

Again though, this is the same pattern as vmalloc.  There are any number
of places where userspace can cause an arbitrarily large vmalloc to be
attempted (grep for kvmalloc_array for a list of promising candidates).
I'm pretty sure that just changing your GFP flags to GFP_KERNEL |
__GFP_NOWARN will give you the exact behaviour that you want with no
need to grub around in the VM to find out if your huge allocation is
likely to succeed.
