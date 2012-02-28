Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 99F9B6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:02:39 -0500 (EST)
Date: Tue, 28 Feb 2012 00:02:28 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] hugetlbfs: Add new rw_semaphore to fix truncate/read race
Message-ID: <20120228000228.GE23916@ZenIV.linux.org.uk>
References: <1330280398-27956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120227151135.7d4076c6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120227151135.7d4076c6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, hughd@google.com, linux-kernel@vger.kernel.org

On Mon, Feb 27, 2012 at 03:11:35PM -0800, Andrew Morton wrote:

> This patch comes somewhat out of the blue and I'm unsure what's going on.
> 
> You say there's some (potential?) deadlock with mmap, but it is
> undescribed.  Have people observed this deadlock?  Has it caused
> lockdep warnings?  Please update the changelog to fully describe the
> bug.

There's one simple rule: never, ever take ->i_mutex under ->mmap_sem.
E.g.  in any ->mmap() (obvious - mmap(2) calls that under ->mmap_sem) or
any ->release() of mappable file (munmap(2) does fput() under ->mmap_sem
and that will call ->release() if no other references are still around).

Hugetlbfs is slightly unusual since it takes ->i_mutex in read() - usually
that's done in write(), while read() doesn't bother with that.  In either
case you do copying to/from userland buffer while holding ->i_mutex, which
nests ->mmap_sem within it.

> Also, the new truncate_sem is undoumented.  This leaves readers to work
> out for themselves what it might be for.  Please let's add code
> comments which completely describe the race, and how this lock prevents
> it.
> 
> We should also document our locking rules.

Hell, yes.  I've spent the last couple of weeks crawling through VM-related
code and locking in there is _scary_.  "Convoluted" doesn't even begin to
cover it, especially when it gets to "what locks are required when accessing
this field" ;-/  Got quite a catch out of that trawl by now...

>  When should code take this
> lock?  What are its ranking rules with respect to i_mutex, i_mmap_mutex
> and possibly others?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
