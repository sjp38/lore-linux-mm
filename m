Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B32158D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 18:40:31 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p2IMeOgx022740
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:40:24 -0700
Received: from iyf40 (iyf40.prod.google.com [10.241.50.104])
	by kpbe12.cbf.corp.google.com with ESMTP id p2IMeIVr015554
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:40:23 -0700
Received: by iyf40 with SMTP id 40so4975547iyf.36
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:40:18 -0700 (PDT)
Date: Fri, 18 Mar 2011 15:40:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte mapping
 to ksm pages
In-Reply-To: <201103181529.43659.nai.xia@gmail.com>
Message-ID: <alpine.LSU.2.00.1103181448100.2092@sister.anvils>
References: <201102262256.31565.nai.xia@gmail.com> <20110302143142.a3c0002b.akpm@linux-foundation.org> <201103181529.43659.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Fri, 18 Mar 2011, Nai Xia wrote:
> >On Thursday 03 March 2011, at 06:31:42, <Andrew Morton <akpm@linux-foundation.org>> wrote
> > This patch obviously wasn't tested with CONFIG_KSM=n, which was a
> > pretty basic patch-testing failure :(
> 
> Oops, I will be careful to avoid similar mistakes next time.
> 
> > 
> > I fixed up my tree with the below, but really the amount of ifdeffing
> > is unacceptable - please find a cleaner way to fix up this patch.
> 
> Ok, I will have a try in my next patch submit. 

A couple of notes on that.

akpm's fixup introduced an #ifdef CONFIG_KSM in mm/ksm.c: that should
be, er, unnecessary - since ksm.c is only compiled when CONFIG_KSM=y.

And PageKsm(page) evaluates to 0 when CONFIG_KSM is not set, so the
optimizer should eliminate code from most places without #ifdef:
though you need to keep the #ifdef around display in /proc/meminfo
itself, so as not to annoy non-KSM people with an always 0kB line.

But I am uncomfortable with the whole patch.

Can you make a stronger case for it?  KSM is designed to have its own
cycle, and to keep out of the way of the rest of mm as much as possible
(not as much as originally hoped, I admit).  Do we really want to show
its statistics in /proc/meminfo now?  And do we really care that they
don't keep up with exiting processes when the scan rate is low?

I am not asserting that we don't, nor am I nacking your patch:
but I would like to hear more support for it, before it adds
yet another line to our user interface in /proc/meminfo.

And there is an awkward little bug in your patch, which amplifies
a more significant and shameful pair of bugs of mine in KSM itself -
no wonder that I'm anxious about your patch going in!

Your bug is precisely where akpm added the #ifdef in ksm.c.  The
problem is that page_mapcount() is maintained atomically, generally
without spinlock or pagelock: so the value of mapcount there, unless
it is 1, can go up or down racily (as other processes sharing that
anonymous page fork or unmap at the same time).

I could hardly complain about that, while suggesting above that more
approximate numbers are good enough!  Except that, when KSM is turned
off, there's a chance that you'd be left showing a non-0 kB in
/proc/meminfo.  Then people will want a fix, and I don't yet know
what that fix will be.

My first bug is in the break_cow() technique used to get back to
normal, when merging into a KSM page fails for one reason or another:
that technique misses other mappings of the page.  I did have a patch
in progress to fix that a few months ago, but it wasn't quite working,
and then I realized the second bug: that even when successful, if
VM_UNMERGEABLE has been used in forked processes, then we could end up
with a KSM page in a VM_UNMERGEABLE area, which is against the spec.

A solution to all three problems would be to revert to allocating a
separate KSM page, instead of using one of the pages already there.
But that feels like a regression, and I don't think anybody is really
hurting from the current situation, so I've not jumped to fix it yet.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
