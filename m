Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6C16B009F
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 10:15:03 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id p9so11975537lbv.28
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 07:15:02 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id 2si1606240lak.120.2014.09.11.07.14.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 07:14:54 -0700 (PDT)
Received: by mail-la0-f49.google.com with SMTP id pv20so2433820lab.36
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 07:14:53 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
	<20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
	<alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
	<20140910140759.GC31903@thunk.org>
	<alpine.LNX.2.00.1409101625160.5523@pobox.suse.cz>
	<20140910152104.GS6549@mwanda>
	<alpine.LNX.2.00.1409101725340.5523@pobox.suse.cz>
Date: Thu, 11 Sep 2014 16:14:52 +0200
In-Reply-To: <alpine.LNX.2.00.1409101725340.5523@pobox.suse.cz> (Jiri Kosina's
	message of "Wed, 10 Sep 2014 17:28:11 +0200 (CEST)")
Message-ID: <87oaumdz1f.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 10 2014, Jiri Kosina <jkosina@suse.cz> wrote:

> On Wed, 10 Sep 2014, Dan Carpenter wrote:
>
>> > BTW if we stretch this argument a little bit more, we should also kill the 
>> > ZERO_OR_NULL_PTR() check from kfree() and make it callers responsibility 
>> > to perform the checking only if applicable ... we are currently doing a 
>> > lot of pointless checking in cases where caller would be able to guarantee 
>> > that the pointer is going to be non-NULL.
>> 
>> What you're saying is that we should remove the ZERO_SIZE_PTR
>> completely.  ZERO_SIZE_PTR is a very useful idiom and also it's too late
>> to remove it because everything depends on it.
>
> I was just argumenting that if we care about single additional test in 
> this path, the ZERO_OR_NULL_PTR() should have never been added at the 
> first place, and the responsibility for checking should have been kept at 
> callers.

I think it makes a lot of sense to have the domain of kfree() be exactly
the codomain of kmalloc() and friends. That is, what is acceptable to
pass to kfree() is exactly the set of values that might be returned from
kmalloc() et al. Those include NULL and the very useful unique
zero-sized "object" ZERO_SIZE_PTR, but does not include any ERR_PTR().

Having every caller of kfree() check for NULL would bloat the code size
considerably, and it seems that these checks are being actively removed.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
