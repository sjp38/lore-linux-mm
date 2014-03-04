Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 80AE46B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 22:22:46 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id rq2so4635227pbb.33
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 19:22:46 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xz2si12597980pbb.209.2014.03.03.19.22.45
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 19:22:45 -0800 (PST)
Date: Mon, 3 Mar 2014 19:26:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: per-thread vma caching
Message-Id: <20140303192601.5374b330.akpm@linux-foundation.org>
In-Reply-To: <1393902810.30648.36.camel@buesod1.americas.hpqcorp.net>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	<20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	<1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
	<20140303172348.3f00c9df.akpm@linux-foundation.org>
	<1393900953.30648.32.camel@buesod1.americas.hpqcorp.net>
	<20140303191224.96f93142.akpm@linux-foundation.org>
	<1393902810.30648.36.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 03 Mar 2014 19:13:30 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Mon, 2014-03-03 at 19:12 -0800, Andrew Morton wrote:
> > On Mon, 03 Mar 2014 18:42:33 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:
> > 
> > > On Mon, 2014-03-03 at 17:23 -0800, Andrew Morton wrote:
> > > > On Mon, 03 Mar 2014 16:59:38 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:
> > > > 
> > > > > > >...
> > > > > > >
> > > > > > > +static bool vmacache_valid(struct mm_struct *mm)
> > > > > > > +{
> > > > > > > +	struct task_struct *curr = current;
> > > > > > > +
> > > > > > > +	if (mm != curr->mm)
> > > > > > > +		return false;
> > > > > > 
> > > > > > What's going on here?  Handling a task poking around in someone else's
> > > > > > mm?  I'm thinking "__access_remote_vm", but I don't know what you were
> > > > > > thinking ;) An explanatory comment would be revealing.
> > > > > 
> > > > > I don't understand the doubt here. Seems like a pretty obvious thing to
> > > > > check -- yes it's probably unlikely but we certainly don't want to be
> > > > > validating the cache on an mm that's not ours... or are you saying it's
> > > > > redundant??
> > > > 
> > > > Well it has to be here for a reason and I'm wondering that that reason
> > > > is.  If nobody comes here with a foreign mm then let's remove it.
> > > 
> > > find_vma() can be called by concurrent threads sharing the mm->mmap_sem
> > > for reading, thus this check needs to be there.
> > 
> > Confused.  If the threads share mm->mmap_sem then they share mm and the
> > test will always be false?
> 
> Yes, I shortly realized that was silly... but I can say for sure it can
> happen and a quick qemu run confirms it. So I see your point as to
> asking why we need it, so now I'm looking for an explanation in the
> code.

Great, please do.  We may well find that we have buggy (or at least
inefficient) callers, which we can fix.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
