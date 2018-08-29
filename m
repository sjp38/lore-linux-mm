Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 329976B4C62
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:17:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w23-v6so3469649pgv.1
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 09:17:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i7-v6si3870572plt.433.2018.08.29.09.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 Aug 2018 09:17:57 -0700 (PDT)
Date: Wed, 29 Aug 2018 09:17:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Tagged pointers in the XArray
Message-ID: <20180829161756.GB30396@bombadil.infradead.org>
References: <20180828222727.GD11400@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828222727.GD11400@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Gao Xiang <gaoxiang25@huawei.com>, zhong jiang <zhongjiang@huawei.com>, Chao Yu <yuchao0@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Aug 28, 2018 at 03:27:27PM -0700, Matthew Wilcox wrote:
> I find myself caught between two traditions.
> 
> On the one hand, the radix tree has been calling the page cache dirty &
> writeback bits "tags" for over a decade.
> 
> On the other hand, using some of the bits _in a pointer_ as a tag has been
> common practice since at least the 1960s.
> https://en.wikipedia.org/wiki/Tagged_pointer and
> https://en.wikipedia.org/wiki/31-bit
> 
> EROFS wants to use tagged pointers in the radix tree / xarray.  Right now,
> they're building them by hand, which is predictably grotty-looking.
> I think it's reasonable to provide this functionality as part of the
> XArray API, _but_ it's confusing to have two different things called tags.
> 
> I've done my best to document my way around this, but if we want to rename
> the things that the radix tree called tags to avoid the problem entirely,
> now is the time to do it.  Anybody got a Good Idea?

I have two ideas now.

First, we could rename radix tree tags to xarray marks.  That is,

xa_mark_t
xa_set_mark()
xas_clear_mark()
xas_for_each_marked() { }
xa_marked()
etc

Second, we could call the tagged pointers typed pointers.  That is,

void *xa_mk_type(void *p, unsigned int type);
void *xa_to_ptr(void *entry);
int xa_ptr_type(void *entry);

Any better ideas, or violent revulsion to either of the above ideas?
