Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C24856B0003
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 17:43:33 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b8-v6so3816439qto.13
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 14:43:33 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id o82-v6si4149166qki.221.2018.06.05.14.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 14:43:33 -0700 (PDT)
Date: Tue, 5 Jun 2018 21:43:32 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
In-Reply-To: <CAKYffwqf5EhabhFwT85iTYNLjpR0noQ9Kua+2aOYNZ5AaJAWOw@mail.gmail.com>
Message-ID: <01000163d1e7b1bf-7bd8565a-7d5e-4d61-b998-6e59557cf8e4-000000@email.amazonses.com>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com> <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com> <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com> <20180601205837.GB29651@bombadil.infradead.org>
 <CAGXu5jLvN5bmakZ3aDu4TRB9+_DYVaCX2LTLtKvsqgYpjMaNsA@mail.gmail.com> <CAKYffwpAAgD+a+0kebid43tpyS6L+8o=4hBbDvhfgaoV_gze1g@mail.gmail.com> <01000163d08f00b4-068f6b54-5d34-447d-90c6-010a24fc36d5-000000@email.amazonses.com>
 <CAKYffwqf5EhabhFwT85iTYNLjpR0noQ9Kua+2aOYNZ5AaJAWOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Eidelman <anton@lightbitslabs.com>
Cc: Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

On Tue, 5 Jun 2018, Anton Eidelman wrote:

> What I am still wondering about (and investigating), is how kernel_sendpage()
> with slab payload results in slab payload on another socket RX.
> Do you see how page ref-counting can be broken with extra references taken
> on a slab page containing the fragments, and dropped when networking is
> done with them?

The slab allocators do not use page refcounting. The objects may be
destroyed via poisioning etc if you use kfree() while still holding a
refcount on the page. Even without poisoning the slab allocator may
overwrite the object.
