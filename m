In-reply-to: <alpine.LFD.1.00.0801181106340.2957@woody.linux-foundation.org>
	(message from Linus Torvalds on Fri, 18 Jan 2008 11:08:57 -0800 (PST))
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
 files
References: <12006091182260-git-send-email-salikhmetov@gmail.com>  <12006091211208-git-send-email-salikhmetov@gmail.com>  <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu>  <1200651337.5920.9.camel@twins> <1200651958.5920.12.camel@twins>
 <alpine.LFD.1.00.0801180949040.2957@woody.linux-foundation.org> <E1JFvgx-0000zz-2C@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801181033580.2957@woody.linux-foundation.org> <E1JFwOz-00019k-Uo@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801181106340.2957@woody.linux-foundation.org>
Message-Id: <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 18 Jan 2008 20:22:32 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, peterz@infradead.org, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> > 
> > But then background writeout, sync(2), etc, wouldn't update the times.
> 
> Sure it would, but only when doing the final unmap.
> 
> Did you miss the "on unmap and msync" part?

No :)

What I'm saying is that the times could be left un-updated for a long
time if program doesn't do munmap() or msync(MS_SYNC) for a long time.

If program has this pattern:

mmap()
write to map
msync(MS_ASYNC)
sleep(long)
write to map
msync(MS_ASYNC)
sleep(long)
...

Then we'd never see time updates (until the program exits, but that
could be years).

Maybe this doesn't matter, I'm just saying this is a disadvantage
compared to the "update on first dirtying" approach, which would
ensure, that times are updated at least once per 30s.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
