Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 326866B1B25
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:24:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b12-v6so10492456plr.17
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 14:24:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i2-v6si11002958plt.112.2018.08.20.14.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 14:24:41 -0700 (PDT)
Date: Mon, 20 Aug 2018 14:24:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Fix comment for NODEMASK_ALLOC
Message-Id: <20180820142440.1f9ccbebefc5d617c881b41e@linux-foundation.org>
In-Reply-To: <20180820085516.9687-1-osalvador@techadventures.net>
References: <20180820085516.9687-1-osalvador@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: tglx@linutronix.de, joe@perches.com, arnd@arndb.de, mhocko@suse.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Mon, 20 Aug 2018 10:55:16 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:

> From: Oscar Salvador <osalvador@suse.de>
> 
> Currently, NODEMASK_ALLOC allocates a nodemask_t with kmalloc when
> NODES_SHIFT is higher than 8, otherwise it declares it within the stack.
> 
> The comment says that the reasoning behind this, is that nodemask_t will be
> 256 bytes when NODES_SHIFT is higher than 8, but this is not true.
> For example, NODES_SHIFT = 9 will give us a 64 bytes nodemask_t.
> Let us fix up the comment for that.
> 
> Another thing is that it might make sense to let values lower than 128bytes
> be allocated in the stack.
> Although this all depends on the depth of the stack
> (and this changes from function to function), I think that 64 bytes
> is something we can easily afford.
> So we could even bump the limit by 1 (from > 8 to > 9).
> 

I agree.  Such a change will reduce the amount of testing which the
kmalloc version receives, but I assume there are enough people out
there testing with large NODES_SHIFT values.

And while we're looking at this, it would be nice to make NODES_SHIFT
go away.  Ensure that CONFIG_NODES_SHIFT always has a setting and use
that directly.
