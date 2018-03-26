Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2F996B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:37:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id z13so6166893pgu.5
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:37:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w2-v6si15824503plk.702.2018.03.26.11.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Mar 2018 11:37:31 -0700 (PDT)
Date: Mon, 26 Mar 2018 11:37:25 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180326183725.GB27373@bombadil.infradead.org>
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, gorcunov@openvz.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 27, 2018 at 02:20:39AM +0800, Yang Shi wrote:
> +++ b/kernel/sys.c
> @@ -1959,7 +1959,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>  			return error;
>  	}
>  
> -	down_write(&mm->mmap_sem);
> +	down_read(&mm->mmap_sem);
>  
>  	/*
>  	 * We don't validate if these members are pointing to
> @@ -1980,10 +1980,13 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>  	mm->start_brk	= prctl_map.start_brk;
>  	mm->brk		= prctl_map.brk;
>  	mm->start_stack	= prctl_map.start_stack;
> +
> +	spin_lock(&mm->arg_lock);
>  	mm->arg_start	= prctl_map.arg_start;
>  	mm->arg_end	= prctl_map.arg_end;
>  	mm->env_start	= prctl_map.env_start;
>  	mm->env_end	= prctl_map.env_end;
> +	spin_unlock(&mm->arg_lock);
>  
>  	/*
>  	 * Note this update of @saved_auxv is lockless thus

I see the argument for the change to a write lock was because of a BUG
validating arg_start and arg_end, but more generally, we are updating these
values, so a write-lock is probably a good idea, and this is a very rare
operation to do, so we don't care about making this more parallel.  I would
not make this change (but if other more knowledgable people in this area
disagree with me, I will withdraw my objection to this part).
