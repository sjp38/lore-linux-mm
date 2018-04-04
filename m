Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 339696B0005
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 10:11:55 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s23-v6so14614179plr.15
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 07:11:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u23si2078783pfh.22.2018.04.04.07.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 07:11:54 -0700 (PDT)
Date: Wed, 4 Apr 2018 10:11:49 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404101149.08f6f881@gandalf.local.home>
In-Reply-To: <20180404062340.GD6312@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180403110612.GM5501@dhcp22.suse.cz>
	<20180403075158.0c0a2795@gandalf.local.home>
	<20180403121614.GV5501@dhcp22.suse.cz>
	<20180403082348.28cd3c1c@gandalf.local.home>
	<20180403123514.GX5501@dhcp22.suse.cz>
	<20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
	<CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
	<20180404062340.GD6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, 4 Apr 2018 08:23:40 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> If you are afraid of that then you can have a look at {set,clear}_current_oom_origin()
> which will automatically select the current process as an oom victim and
> kill it.

Would it even receive the signal? Does alloc_pages_node() even respond
to signals? Because the OOM happens while the allocation loop is
running.

I tried it out, I did the following:

	set_current_oom_origin();
	for (i = 0; i < nr_pages; i++) {
		struct page *page;
		/*
		 * __GFP_RETRY_MAYFAIL flag makes sure that the allocation fails
		 * gracefully without invoking oom-killer and the system is not
		 * destabilized.
		 */
		bpage = kzalloc_node(ALIGN(sizeof(*bpage), cache_line_size()),
				    GFP_KERNEL | __GFP_RETRY_MAYFAIL,
				    cpu_to_node(cpu));
		if (!bpage)
			goto free_pages;

		list_add(&bpage->list, pages);

		page = alloc_pages_node(cpu_to_node(cpu),
					GFP_KERNEL | __GFP_RETRY_MAYFAIL, 0);
		if (!page)
			goto free_pages;
		bpage->page = page_address(page);
		rb_init_page(bpage->page);
	}
	clear_current_oom_origin();

The first time I ran my ring buffer memory stress test, it killed the
stress test. The second time I ran it, it killed polkitd.

Still doesn't help as much as the original patch.

You haven't convinced me that using si_mem_available() is a bad idea.
If anything, you've solidified my confidence in it.

-- Steve
