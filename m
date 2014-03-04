Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3066B0039
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 20:20:36 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so4553230pab.10
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 17:20:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bs8si6391033pad.128.2014.03.03.17.20.33
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 17:20:33 -0800 (PST)
Date: Mon, 3 Mar 2014 17:23:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: per-thread vma caching
Message-Id: <20140303172348.3f00c9df.akpm@linux-foundation.org>
In-Reply-To: <1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	<20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	<1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 03 Mar 2014 16:59:38 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:

> > >...
> > >
> > > +static bool vmacache_valid(struct mm_struct *mm)
> > > +{
> > > +	struct task_struct *curr = current;
> > > +
> > > +	if (mm != curr->mm)
> > > +		return false;
> > 
> > What's going on here?  Handling a task poking around in someone else's
> > mm?  I'm thinking "__access_remote_vm", but I don't know what you were
> > thinking ;) An explanatory comment would be revealing.
> 
> I don't understand the doubt here. Seems like a pretty obvious thing to
> check -- yes it's probably unlikely but we certainly don't want to be
> validating the cache on an mm that's not ours... or are you saying it's
> redundant??

Well it has to be here for a reason and I'm wondering that that reason
is.  If nobody comes here with a foreign mm then let's remove it.  Or
perhaps stick a WARN_ON_ONCE() in there to detect the unexpected.  If
there _is_ a real reason, let's write that down.

> And no, we don't want __access_remote_vm() here.

__access_remote_vm doesn't look at the vma cache, so scrub that
explanation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
