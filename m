Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 569C26B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 17:29:15 -0500 (EST)
Received: by yenm2 with SMTP id m2so1469762yen.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 14:29:14 -0800 (PST)
Date: Thu, 12 Jan 2012 14:29:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Don't warn if memdup_user fails
In-Reply-To: <20120112135803.1fb98fd6.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1201121418060.1124@chino.kir.corp.google.com>
References: <1326300636-29233-1-git-send-email-levinsasha928@gmail.com> <20120111141219.271d3a97.akpm@linux-foundation.org> <1326355594.1999.7.camel@lappy> <CAOJsxLEYY=ZO8QrxiWL6qAxPzsPpZj3RsF9cXY0Q2L44+sn7JQ@mail.gmail.com>
 <alpine.DEB.2.00.1201121309340.17287@chino.kir.corp.google.com> <20120112135803.1fb98fd6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Sasha Levin <levinsasha928@gmail.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tyler Hicks <tyhicks@canonical.com>, Dustin Kirkland <kirkland@canonical.com>, ecryptfs@vger.kernel.org

On Thu, 12 Jan 2012, Andrew Morton wrote:

> > I think it's good to fix ecryptfs like Tyler is doing and, at the same 
> > time, ensure that the len passed to memdup_user() makes sense prior to 
> > kmallocing memory with GFP_KERNEL.  Perhaps something like
> > 
> > 	if (WARN_ON(len > PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> > 		return ERR_PTR(-ENOMEM);
> > 
> > in which case __GFP_NOWARN is irrelevant.
> 
> If someone is passing huge size_t's into kmalloc() and getting failures
> then that's probably a bug.  So perhaps we should add a warning to
> kmalloc itself if the size_t is out of bounds, and !__GFP_NOWARN.
> 

That's already done.  For slub, for example, the largest object size 
handled by the allocator itself is an order-1 page; everything else gets 
passed through to the page allocator and its limitation is MAX_ORDER, 
which is the warning that we're seeing in Sasha's changelog when 
!__GFP_NOWARN.

> But none of this will be very effective.  If someone is passing an
> unchecked size_t into kmalloc then normal testing will not reveal the
> problem because the testers won't pass stupid numbers into their
> syscalls.
> 

They'll get the same warning that Sasha got, which is because the page 
allocator can't handle larger than MAX_ORDER orders.  The intention in my 
WARN_ON() above specifically for memdup_user() is to avoid the infinite 
loop in the page allocator for GFP_KERNEL allocations where the order 
is less than PAGE_ALLOC_COSTLY_ORDER and avoid the oom killer.  It returns 
immediately rather than passing __GFP_NORETRY since we don't want to incur 
the side-effects of direct reclaim or compaction as well.

The real fix would be to convert all callers to pass gfp flags into 
memdup_user() to determine the behavior they want, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
