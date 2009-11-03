Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3951C6B004D
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 09:00:46 -0500 (EST)
Date: Tue, 3 Nov 2009 23:00:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCHv2 2/5] vmscan: Kill hibernation specific reclaim logic and unify it
In-Reply-To: <200911022003.52125.rjw@sisk.pl>
References: <20091103002506.8869.A69D9226@jp.fujitsu.com> <200911022003.52125.rjw@sisk.pl>
Message-Id: <20091103141200.0B3C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Monday 02 November 2009, KOSAKI Motohiro wrote:
> > > > Then, This patch changed shrink_all_memory() to only the wrapper function of 
> > > > do_try_to_free_pages(). it bring good reviewability and debuggability, and solve 
> > > > above problems.
> > > > 
> > > > side note: Reclaim logic unificication makes two good side effect.
> > > >  - Fix recursive reclaim bug on shrink_all_memory().
> > > >    it did forgot to use PF_MEMALLOC. it mean the system be able to stuck into deadlock.
> > > >  - Now, shrink_all_memory() got lockdep awareness. it bring good debuggability.
> > > 
> > > As I said previously, I don't really see a reason to keep shrink_all_memory().
> > > 
> > > Do you think that removing it will result in performance degradation?
> > 
> > Hmm...
> > Probably, I misunderstood your mention. I thought you suggested to kill
> > all hibernation specific reclaim code. I did. It's no performance degression.
> > (At least, I didn't observe)
> > 
> > But, if you hope to kill shrink_all_memory() function itsef, the short answer is,
> > it's impossible.
> > 
> > Current VM reclaim code need some preparetion to caller, and there are existing in
> > both alloc_pages_slowpath() and try_to_free_pages(). We can't omit its preparation.
> 
> Well, my grepping for 'shrink_all_memory' throughout the entire kernel source
> code seems to indicate that hibernate_preallocate_memory() is the only current
> user of it.  I may be wrong, but I doubt it, unless some new users have been
> added since 2.6.31.
> 
> In case I'm not wrong, it should be safe to drop it from
> hibernate_preallocate_memory(), because it's there for performance reasons
> only.  Now, since hibernate_preallocate_memory() appears to be the only user of
> it, it should be safe to drop it entirely.

Hmmm...
I've try the dropping shrink_all_memory() today. but I've got bad result.

In 3 times test, result were

 2 times: kernel hang-up ;)
 1 time:   success, but make slower than with shrink_all_memory() about 100x times.


Did you try to drop it yourself on your machine? Is this success?



> > Please see following shrink_all_memory() code. it's pretty small. it only have
> > few vmscan preparation. I don't think it is hard to maintainance.
> 
> No, it's not, but I'm really not sure it's worth keeping.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
