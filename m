Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A4DEF6B00B3
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 19:21:16 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so6368715pab.10
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 16:21:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t4si25332956pdn.117.2014.09.09.16.21.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 16:21:15 -0700 (PDT)
Date: Tue, 9 Sep 2014 16:21:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-Id: <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, 9 Sep 2014 23:25:28 +0200 (CEST) Jiri Kosina <jkosina@suse.cz> wrote:

> kfree() is happy to accept NULL pointer and does nothing in such case. 
> It's reasonable to expect it to behave the same if ERR_PTR is passed to 
> it.
> 
> Inspired by a9cfcd63e8d ("ext4: avoid trying to kfree an ERR_PTR 
> pointer").
> 
> ...
>
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3612,7 +3612,7 @@ void kfree(const void *objp)
>  
>  	trace_kfree(_RET_IP_, objp);
>  
> -	if (unlikely(ZERO_OR_NULL_PTR(objp)))
> +	if (unlikely(ZERO_OR_NULL_PTR(objp) || IS_ERR(objp)))
>  		return;

kfree() is quite a hot path to which this will add overhead.  And we
have (as far as we know) no code which will actually use this at
present.

How about a new

kfree_safe(...)
{
	if (IS_ERR(...))
		return;
	if (other-stuff-when-we-think-of-it)
		return;
	kfree(...);
}

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
