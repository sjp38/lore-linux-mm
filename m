Date: Wed, 30 Jul 2008 17:54:20 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org>
Message-ID: <alpine.LFD.1.10.0807301751320.3277@nehalem.linux-foundation.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 30 Jul 2008, Linus Torvalds wrote:
> 
> Personally, I think the right approach is to just realize that splice() is 
> _not_ a write() system call, and never will be. If you need synchronous 
> writing, you simply shouldn't use splice().

Side note: in-kernel users could probably do somethign about this. IOW, if 
there's some in-kernel usage (and yes, knfsd would be a prime example), 
that one may actually be able to do things that a _user_level user of 
splice() could never do.

That includes things like getting the inode semaphore over a write (so 
that you can guarantee that pages that are in flight are not modified, 
except again possibly by other mmap users), and/or a per-page callback for 
when splice() is done with a page (so that you could keep the page locked 
while it's getting spliced, for example).

And no, we don't actually have that either, of course.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
