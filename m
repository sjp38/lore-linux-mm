Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 172C66B003D
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 11:21:47 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so3566823pdj.8
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 08:21:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id st7si28249714pab.122.2014.09.10.08.21.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 08:21:45 -0700 (PDT)
Date: Wed, 10 Sep 2014 18:21:04 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910152104.GS6549@mwanda>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
 <20140910140759.GC31903@thunk.org>
 <alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 10, 2014 at 04:26:46PM +0200, Jiri Kosina wrote:
> On Wed, 10 Sep 2014, Theodore Ts'o wrote:
> 
> > I'd much rather depending on better testing and static checkers to fix 
> > them, since kfree *is* a hot path.
> 
> BTW if we stretch this argument a little bit more, we should also kill the 
> ZERO_OR_NULL_PTR() check from kfree() and make it callers responsibility 
> to perform the checking only if applicable ... we are currently doing a 
> lot of pointless checking in cases where caller would be able to guarantee 
> that the pointer is going to be non-NULL.

What you're saying is that we should remove the ZERO_SIZE_PTR
completely.  ZERO_SIZE_PTR is a very useful idiom and also it's too late
to remove it because everything depends on it.

Returning ZERO_SIZE_PTR is not an error.  Callers shouldn't test for it.
It works like this:
1) User space says "copy zero items to somewhere."
2) The kernel says "here is a zero size pointer"
3) We do some stuff like:
	copy_from_user(zero_pointer, src, 0)
   or:
	for (i = 0; i < 0; i++)
4) The caller frees the ZERO_SIZE_PTR.
5) We return success.

If we get rid of it then we're start returning -ENOMEM all over the
place and that breaks userspace.  Or we introduce zero as a special case
for every kmalloc.

You would think there would be a lot of bugs with ZERO_SIZE_POINTERs
but they seem fairly rare to me.  There are some where we allocate a
zero length string and then put a NUL terminator at the end.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
