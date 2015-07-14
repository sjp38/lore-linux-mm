Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 659BB6B0282
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 18:52:53 -0400 (EDT)
Received: by pacan13 with SMTP id an13so12595062pac.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 15:52:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cm3si4066032pbb.125.2015.07.14.15.52.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 15:52:52 -0700 (PDT)
Date: Tue, 14 Jul 2015 15:52:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v3 1/3] mm, oom: organize oom context into struct
Message-Id: <20150714155251.ddb7ef5a54b3b1f49d5fc968@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1507081641480.16585@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1507011435150.14014@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1507081641480.16585@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 8 Jul 2015 16:42:42 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> There are essential elements to an oom context that are passed around to
> multiple functions.
> 
> Organize these elements into a new struct, struct oom_control, that
> specifies the context for an oom condition.
> 
> This patch introduces no functional change.
> 
> ...
>
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -12,6 +12,14 @@ struct notifier_block;
>  struct mem_cgroup;
>  struct task_struct;
>  
> +struct oom_control {
> +	struct zonelist *zonelist;
> +	nodemask_t	*nodemask;
> +	gfp_t		gfp_mask;
> +	int		order;
> +	bool		force_kill;
> +};

Some docs would be nice.

gfp_mask and order are what the page-allocating caller originally asked
for, I think?  They haven't been mucked with?

It's somewhat obvious what force_kill does, but why is it provided, why
is it set?  And what does it actually kill?  A process which was
selected based on the other fields...

Also, it's a bit odd that zonelist and nodemask are here.  They're
low-level implementation details whereas the other three fields are
high-level caller control stuff.

Anyway, please have a think about it.  The definition site for a controlling
structure can be a great place to reveal the overall design and operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
