Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A2F658E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:41:58 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id n25so15326486iog.13
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:41:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9sor7567955iom.6.2018.12.11.10.41.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 10:41:57 -0800 (PST)
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
Message-ID: <09e3d156-66fc-ca17-efac-63f080a27a1d@kernel.dk>
Date: Tue, 11 Dec 2018 11:41:55 -0700
MIME-Version: 1.0
In-Reply-To: <20181128183531.5139-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, fsdevel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>

On Wed, Nov 28, 2018 at 11:35 AM Matthew Wilcox <willy@infradead.org> wrote:
> @@ -1026,24 +979,17 @@ static struct kioctx *lookup_ioctx(unsigned long ctx_id)
>         struct aio_ring __user *ring  = (void __user *)ctx_id;
>         struct mm_struct *mm = current->mm;
>         struct kioctx *ctx, *ret = NULL;
> -       struct kioctx_table *table;
>         unsigned id;
>
>         if (get_user(id, &ring->id))
>                 return NULL;
>
>         rcu_read_lock();
> -       table = rcu_dereference(mm->ioctx_table);
> -
> -       if (!table || id >= table->nr)
> -               goto out;
> -
> -       ctx = rcu_dereference(table->table[id]);
> +       ctx = xa_load(&mm->ioctx, id);
>         if (ctx && ctx->user_id == ctx_id) {
>                 if (percpu_ref_tryget_live(&ctx->users))
>                         ret = ctx;
>         }

Question on this part - do we need that RCU read lock around this now? I
don't think we do.

-- 
Jens Axboe
