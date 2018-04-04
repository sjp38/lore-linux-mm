Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BEBFD6B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:47:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q12-v6so12756571plr.17
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:47:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f59-v6si3562135plf.38.2018.04.04.08.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:47:33 -0700 (PDT)
Date: Wed, 4 Apr 2018 11:47:30 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404114730.65118279@gandalf.local.home>
In-Reply-To: <20180404142329.GI6312@dhcp22.suse.cz>
References: <20180403110612.GM5501@dhcp22.suse.cz>
	<20180403075158.0c0a2795@gandalf.local.home>
	<20180403121614.GV5501@dhcp22.suse.cz>
	<20180403082348.28cd3c1c@gandalf.local.home>
	<20180403123514.GX5501@dhcp22.suse.cz>
	<20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
	<CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
	<20180404062340.GD6312@dhcp22.suse.cz>
	<20180404101149.08f6f881@gandalf.local.home>
	<20180404142329.GI6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, 4 Apr 2018 16:23:29 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> > 
> > I tried it out, I did the following:
> > 
> > 	set_current_oom_origin();
> > 	for (i = 0; i < nr_pages; i++) {
> > 		struct page *page;
> > 		/*
> > 		 * __GFP_RETRY_MAYFAIL flag makes sure that the allocation fails
> > 		 * gracefully without invoking oom-killer and the system is not
> > 		 * destabilized.
> > 		 */
> > 		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
> > 				    GFP_KERNEL | __GFP_RETRY_MAYFAIL,
> > 				    cpu_to_node(cpu));
> > 		if (!bpage)
> > 			goto free_pages;
> > 
> > 		list_add(&bpage->list, pages);
> > 
> > 		page = alloc_pages_node(cpu_to_node(cpu),
> > 					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0);
> > 		if (!page)
> > 			goto free_pages;  
> 
> 		if (fatal_signal_pending())
> 			fgoto free_pages;

I originally was going to remove the RETRY_MAYFAIL, but adding this
check (at the end of the loop though) appears to have OOM consistently
kill this task.

I still like to keep RETRY_MAYFAIL, because it wont trigger OOM if
nothing comes in and tries to do an allocation, but instead will fail
nicely with -ENOMEM.

-- Steve


> 
> > 		bpage->page = page_address(page);
> > 		rb_init_page(bpage->page);
> > 	}
> > 	clear_current_oom_origin();  
