Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B74E68E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:45:56 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id p9so13383652pfj.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:45:56 -0800 (PST)
Date: Tue, 11 Dec 2018 10:45:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
Message-ID: <20181211184553.GH6830@bombadil.infradead.org>
References: <20181128183531.5139-1-willy@infradead.org>
 <09e3d156-66fc-ca17-efac-63f080a27a1d@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <09e3d156-66fc-ca17-efac-63f080a27a1d@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, fsdevel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, Dec 11, 2018 at 11:41:55AM -0700, Jens Axboe wrote:
> On Wed, Nov 28, 2018 at 11:35 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> >         rcu_read_lock();
> > -       table = rcu_dereference(mm->ioctx_table);
> > -
> > -       if (!table || id >= table->nr)
> > -               goto out;
> > -
> > -       ctx = rcu_dereference(table->table[id]);
> > +       ctx = xa_load(&mm->ioctx, id);
> >         if (ctx && ctx->user_id == ctx_id) {
> >                 if (percpu_ref_tryget_live(&ctx->users))
> >                         ret = ctx;
> >         }
> 
> Question on this part - do we need that RCU read lock around this now? I
> don't think we do.

I think we need the rcu read lock here to prevent ctx from being freed
under us by free_ioctx().
