Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFE5A8E00CA
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:46:57 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 128so3253100itw.8
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:46:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor7604631iol.91.2018.12.11.10.46.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 10:46:56 -0800 (PST)
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
 <09e3d156-66fc-ca17-efac-63f080a27a1d@kernel.dk>
 <20181211184553.GH6830@bombadil.infradead.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <75267003-9407-101f-33ee-685e345a2c8a@kernel.dk>
Date: Tue, 11 Dec 2018 11:46:53 -0700
MIME-Version: 1.0
In-Reply-To: <20181211184553.GH6830@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, fsdevel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>

On 12/11/18 11:45 AM, Matthew Wilcox wrote:
> On Tue, Dec 11, 2018 at 11:41:55AM -0700, Jens Axboe wrote:
>> On Wed, Nov 28, 2018 at 11:35 AM Matthew Wilcox <willy@infradead.org> wrote:
>>>
>>>         rcu_read_lock();
>>> -       table = rcu_dereference(mm->ioctx_table);
>>> -
>>> -       if (!table || id >= table->nr)
>>> -               goto out;
>>> -
>>> -       ctx = rcu_dereference(table->table[id]);
>>> +       ctx = xa_load(&mm->ioctx, id);
>>>         if (ctx && ctx->user_id == ctx_id) {
>>>                 if (percpu_ref_tryget_live(&ctx->users))
>>>                         ret = ctx;
>>>         }
>>
>> Question on this part - do we need that RCU read lock around this now? I
>> don't think we do.
> 
> I think we need the rcu read lock here to prevent ctx from being freed
> under us by free_ioctx().

Then that begs the question, how about __xa_load() that is already called
under RCU read lock?

-- 
Jens Axboe
