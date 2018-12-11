Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 786028E00CE
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:54:56 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i12so3103276ita.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:54:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 194sor4821324itx.31.2018.12.11.10.54.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 10:54:55 -0800 (PST)
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
References: <20181128183531.5139-1-willy@infradead.org>
 <09e3d156-66fc-ca17-efac-63f080a27a1d@kernel.dk>
 <20181211184553.GH6830@bombadil.infradead.org>
 <75267003-9407-101f-33ee-685e345a2c8a@kernel.dk>
 <20181211185311.GJ6830@bombadil.infradead.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <1629a25c-a9e7-e731-230d-e179e9f7a9a7@kernel.dk>
Date: Tue, 11 Dec 2018 11:54:53 -0700
MIME-Version: 1.0
In-Reply-To: <20181211185311.GJ6830@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, fsdevel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>

On 12/11/18 11:53 AM, Matthew Wilcox wrote:
> On Tue, Dec 11, 2018 at 11:46:53AM -0700, Jens Axboe wrote:
>> On 12/11/18 11:45 AM, Matthew Wilcox wrote:
>>> I think we need the rcu read lock here to prevent ctx from being freed
>>> under us by free_ioctx().
>>
>> Then that begs the question, how about __xa_load() that is already called
>> under RCU read lock?
> 
> I've been considering adding it to the API, yes.  I was under the
> impression that nested rcu_read_lock() calls were not expensive, even
> with CONFIG_PREEMPT.

They are not expensive, but they are not free either. And if we know we
are already under a rcu read lock, it seems pretty pointless. For the
two cases (memremap and aio), the rcu read lock is right there, before
the call. Easy to verify that it's safe.

-- 
Jens Axboe
