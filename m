Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 610736B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 22:58:38 -0400 (EDT)
Date: Thu, 30 Apr 2009 19:54:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-Id: <20090430195439.e02edc26.akpm@linux-foundation.org>
In-Reply-To: <20090430215034.4748e615@riellaptop.surriel.com>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<20090430072057.GA4663@eskimo.com>
	<20090430174536.d0f438dd.akpm@linux-foundation.org>
	<20090430205936.0f8b29fc@riellaptop.surriel.com>
	<20090430181340.6f07421d.akpm@linux-foundation.org>
	<20090430215034.4748e615@riellaptop.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 21:50:34 -0400 Rik van Riel <riel@redhat.com> wrote:

> > Which would cause exactly the problem Elladan saw?
> 
> Yes.  It was not noticable in the initial split LRU code,
> but after we decided to ignore the referenced bit on active
> file pages and deactivate pages regardless, it has gotten
> exacerbated.
> 
> That change was very good for scalability, so we should not
> undo it.  However, we do need to put something in place to
> protect the working set from streaming IO.
> 
> > > Currently the kernel has no effective code to protect the 
> > > page cache working set from streaming IO.  Elladan's bug
> > > report shows that we do need some kind of protection...
> > 
> > Seems to me that reclaim should treat swapcache-backed mapped mages in
> > a similar fashion to file-backed mapped pages?
> 
> Swapcache-backed pages are not on the same set of LRUs as
> file-backed mapped pages.

yup.

> Furthermore, there is no streaming IO on the anon LRUs like
> there is on the file LRUs. Only the file LRUs need (and want)
> use-once replacement, which means that we only need special
> protection of the working set for file-backed pages.

OK.

> When we implement working set protection, we might as well
> do it for frequently accessed unmapped pages too.  There is
> no reason to restrict this protection to mapped pages.

Well.  Except for empirical observation, which tells us that biasing
reclaim to prefer to retain mapped memory produces a better result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
