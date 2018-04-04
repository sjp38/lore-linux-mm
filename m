Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6AF6B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:47:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v8so8664513wmv.1
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:47:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 69si2317218wmp.44.2018.04.04.07.47.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 07:47:36 -0700 (PDT)
Date: Wed, 4 Apr 2018 16:47:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404144735.GL6312@dhcp22.suse.cz>
References: <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home>
 <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home>
 <20180403135607.GC5501@dhcp22.suse.cz>
 <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
 <20180404062340.GD6312@dhcp22.suse.cz>
 <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404103111.2ea16efa@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404103111.2ea16efa@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed 04-04-18 10:31:11, Steven Rostedt wrote:
> On Wed, 4 Apr 2018 16:23:29 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Wed 04-04-18 10:11:49, Steven Rostedt wrote:
> > > On Wed, 4 Apr 2018 08:23:40 +0200
> > > Michal Hocko <mhocko@kernel.org> wrote:
> > >   
> > > > If you are afraid of that then you can have a look at {set,clear}_current_oom_origin()
> > > > which will automatically select the current process as an oom victim and
> > > > kill it.  
> > > 
> > > Would it even receive the signal? Does alloc_pages_node() even respond
> > > to signals? Because the OOM happens while the allocation loop is
> > > running.  
> > 
> > Well, you would need to do something like:
> > 
> > > 
> > > I tried it out, I did the following:
> > > 
> > > 	set_current_oom_origin();
> > > 	for (i = 0; i < nr_pages; i++) {
> > > 		struct page *page;
> > > 		/*
> > > 		 * __GFP_RETRY_MAYFAIL flag makes sure that the allocation fails
> > > 		 * gracefully without invoking oom-killer and the system is not
> > > 		 * destabilized.
> > > 		 */
> > > 		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
> > > 				    GFP_KERNEL | __GFP_RETRY_MAYFAIL,
> > > 				    cpu_to_node(cpu));
> > > 		if (!bpage)
> > > 			goto free_pages;
> > > 
> > > 		list_add(&bpage->list, pages);
> > > 
> > > 		page = alloc_pages_node(cpu_to_node(cpu),
> > > 					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0);
> > > 		if (!page)
> > > 			goto free_pages;  
> > 
> > 		if (fatal_signal_pending())
> > 			fgoto free_pages;
> 
> But wouldn't page be NULL in this case?

__GFP_RETRY_MAYFAIL itself fails rather than triggers the OOM killer.
You still might get killed from other allocation context which can
trigger the OOM killer though. In any case you would back off and fail,
no?

> > > 		bpage->page = page_address(page);
> > > 		rb_init_page(bpage->page);
> > > 	}
> > > 	clear_current_oom_origin();  
> > 
> > If you use __GFP_RETRY_MAYFAIL it would have to be somedy else to
> > trigger the OOM killer and this user context would get killed. If you
> > drop __GFP_RETRY_MAYFAIL it would be this context to trigger the OOM but
> > it would still be the selected victim.
> 
> Then we guarantee to kill the process instead of just sending a
> -ENOMEM, which would change user space ABI, and is a NO NO.

I see. Although I would expect it would be echo writing to a file most
of the time. But I am not really familiar what traces usually do so I
will not speculate.

> Ideally, we want to avoid an OOM. I could add the above as well, when
> si_mem_avaiable() returns something that is greater than what is
> available, and at least this is the process that will get the OOM if it
> fails to allocate.
> 
> Would that work for you?

I have responded wrt si_mem_avaiable in other email but yes, using the
oom_origin would reduce the immediate damage at least.
-- 
Michal Hocko
SUSE Labs
