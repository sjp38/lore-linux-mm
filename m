Date: Fri, 18 Jan 2008 09:58:04 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
 files
In-Reply-To: <1200651958.5920.12.camel@twins>
Message-ID: <alpine.LFD.1.00.0801180949040.2957@woody.linux-foundation.org>
References: <12006091182260-git-send-email-salikhmetov@gmail.com>  <12006091211208-git-send-email-salikhmetov@gmail.com>  <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu>  <1200651337.5920.9.camel@twins> <1200651958.5920.12.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>


On Fri, 18 Jan 2008, Peter Zijlstra wrote:
> 
> Bah, and will break on s390... so we'd need a page_mkclean() variant
> that doesn't actually clear dirty.

No, we simply want to not play all these very expensive games with dirty 
in the first place.

Guys, mmap access times aren't important enough for this. It's not 
specified closely enough, and people don't care enough.

Of the patches around so far, the best one by far seems to be the simple 
four-liner from Miklos.

And even in that four-liner, I suspect that the *last* two lines are 
actually incorrect: there's no point in updating the file time when the 
page *becomes* dirty, we should update the file time when it is marked 
clean, and "msync(MS_SYNC)" should update it as part of *that*.

So I think the file time update should be part of just the page writeout 
logic, not by msync() or page faulting itself or anything like that.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
