Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id E68DC6B0038
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 21:42:36 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id i7so6395804oag.33
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 18:42:36 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id dm7si16860523oeb.93.2014.03.03.18.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 18:42:36 -0800 (PST)
Message-ID: <1393900953.30648.32.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v4] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 03 Mar 2014 18:42:33 -0800
In-Reply-To: <20140303172348.3f00c9df.akpm@linux-foundation.org>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	 <20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	 <1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
	 <20140303172348.3f00c9df.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-03-03 at 17:23 -0800, Andrew Morton wrote:
> On Mon, 03 Mar 2014 16:59:38 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > > >...
> > > >
> > > > +static bool vmacache_valid(struct mm_struct *mm)
> > > > +{
> > > > +	struct task_struct *curr = current;
> > > > +
> > > > +	if (mm != curr->mm)
> > > > +		return false;
> > > 
> > > What's going on here?  Handling a task poking around in someone else's
> > > mm?  I'm thinking "__access_remote_vm", but I don't know what you were
> > > thinking ;) An explanatory comment would be revealing.
> > 
> > I don't understand the doubt here. Seems like a pretty obvious thing to
> > check -- yes it's probably unlikely but we certainly don't want to be
> > validating the cache on an mm that's not ours... or are you saying it's
> > redundant??
> 
> Well it has to be here for a reason and I'm wondering that that reason
> is.  If nobody comes here with a foreign mm then let's remove it.

find_vma() can be called by concurrent threads sharing the mm->mmap_sem
for reading, thus this check needs to be there.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
