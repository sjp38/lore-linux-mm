Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id C643F6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:58:23 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id ma3so2295377pbc.15
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:58:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bu3si7073224pbb.98.2014.06.19.13.58.22
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 13:58:22 -0700 (PDT)
Date: Thu, 19 Jun 2014 13:58:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] fork: reset mm->pinned_vm
Message-Id: <20140619135820.57c4934dd613c5e723f9ca82@linux-foundation.org>
In-Reply-To: <63d594c88850aa64729fceec769681f9d1d6fa68.1403168346.git.vdavydov@parallels.com>
References: <fa98629155872c1b97ba4dcd00d509a1e467c1c3.1403168346.git.vdavydov@parallels.com>
	<63d594c88850aa64729fceec769681f9d1d6fa68.1403168346.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: oleg@redhat.com, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jun 2014 13:07:47 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> mm->pinned_vm counts pages of mm's address space that were permanently
> pinned in memory by increasing their reference counter. The counter was
> introduced by commit bc3e53f682d9 ("mm: distinguish between mlocked and
> pinned pages"), while before it locked_vm had been used for such pages.
> 
> Obviously, we should reset the counter on fork if !CLONE_VM, just like
> we do with locked_vm, but currently we don't. Let's fix it.
> 
> ...
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -534,6 +534,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
>  	atomic_long_set(&mm->nr_ptes, 0);
>  	mm->map_count = 0;
>  	mm->locked_vm = 0;
> +	mm->pinned_vm = 0;
>  	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
>  	spin_lock_init(&mm->page_table_lock);
>  	mm_init_cpumask(mm);

What are the runtime effects of this?  I think it is only
"/proc/pid/status:VmPin is screwed up", because we don't use vm_pinned
in rlimit checks.  Yes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
