Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 56B826B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:25:31 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q12-v6so12480263plr.17
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:25:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r79si4196085pfb.149.2018.04.04.07.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 07:25:30 -0700 (PDT)
Date: Wed, 4 Apr 2018 10:25:27 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404102527.763250b4@gandalf.local.home>
In-Reply-To: <20180404141052.GH6312@dhcp22.suse.cz>
References: <20180403121614.GV5501@dhcp22.suse.cz>
	<20180403082348.28cd3c1c@gandalf.local.home>
	<20180403123514.GX5501@dhcp22.suse.cz>
	<20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
	<20180403101753.3391a639@gandalf.local.home>
	<20180403161119.GE5501@dhcp22.suse.cz>
	<20180403185627.6bf9ea9b@gandalf.local.home>
	<20180404062039.GC6312@dhcp22.suse.cz>
	<20180404085901.5b54fe32@gandalf.local.home>
	<20180404141052.GH6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, 4 Apr 2018 16:10:52 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 04-04-18 08:59:01, Steven Rostedt wrote:
> [...]
> > +       /*
> > +        * Check if the available memory is there first.
> > +        * Note, si_mem_available() only gives us a rough estimate of available
> > +        * memory. It may not be accurate. But we don't care, we just want
> > +        * to prevent doing any allocation when it is obvious that it is
> > +        * not going to succeed.
> > +        */
> > +       i = si_mem_available();
> > +       if (i < nr_pages)
> > +               return -ENOMEM;
> > +
> > 
> > Better?  
> 
> I must be really missing something here. How can that work at all for
> e.g. the zone_{highmem/movable}. You will get false on the above tests
> even when you will have hard time to allocate anything from your
> destination zones.

You mean we will get true on the above tests?  Again, the current
method is to just say screw it and try to allocate.

I originally just used NORETRY which would only allocate memory that is
currently available and not try to reclaim anything. But people like
Joel at Google that required increasing the buffer when memory was
mostly taken up by page cache changed it from NORETRY to RETRY_MAYFAIL.

But this now causes the issue that a large allocation can take up all
memory even when the allocation requested is guaranteed to fail,
because there is not enough memory to pull this off.

We just want a way to say "hey, is there enough memory in the system to
allocate all these pages before we try? We don't need specifics, we
just want to make sure we are not allocating way too much".

The answer I want is "yes there may be enough (but you may not be able
to use it)" or "no, there is definitely not enough for that".

Currently si_mem_available() is the closest thing we have to answering
that question. I'm fine if the answer is "Yes" even if I can't allocate
that memory.

I'm looking for something where "yes" means "there may be enough, but
there may not be, buyer beware", and "no" means "forget it, don't even
start, because you just asked for more than possible".

-- Steve
