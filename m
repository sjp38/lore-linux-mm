Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 3D8246B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 17:28:39 -0400 (EDT)
Date: Wed, 27 Mar 2013 14:28:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 1/2] mm: limit growth of 3% hardcoded other user
 reserve
Message-Id: <20130327142832.8505be7276064bf4b1daab5c@linux-foundation.org>
In-Reply-To: <20130318214442.GA1441@localhost.localdomain>
References: <20130318214442.GA1441@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Mon, 18 Mar 2013 17:44:42 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:

> Add user_reserve_kbytes knob.
> 
> Limit the growth of the memory reserved for other user
> processes to min(3% current process size, user_reserve_pages).
> 
> user_reserve_pages defaults to min(3% free pages, 128MB)

That was an epic changelog ;)

>
> ...
>
> +int __meminit init_user_reserve(void)
> +{
> +	unsigned long free_kbytes;
> +
> +	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
> +
> +	sysctl_user_reserve_kbytes = min(free_kbytes / 32, 1UL << 17);
> +	return 0;
> +}
> +module_init(init_user_reserve)

Problem is, the initial default values will become wrong if memory if
hot-added or hot-removed.

That could be fixed up by appropriate use of
register_memory_notifier(), but what would the notification handler do
if the operator has modified the value?  Proportionally scale it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
