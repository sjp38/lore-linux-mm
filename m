Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 6608A6B004D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:44:36 -0500 (EST)
Date: Thu, 8 Mar 2012 21:44:25 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-ID: <20120308214425.GA23916@ZenIV.linux.org.uk>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120308130256.c7855cbd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120308130256.c7855cbd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, tyhicks@canonical.com, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>

On Thu, Mar 08, 2012 at 01:02:56PM -0800, Andrew Morton wrote:
> > This fix the below lockdep warning
> 
> OK, what's going on here.

Deadlock in hugetlbfs mmap getting misreported.

One last time: ->mmap_sem nests inside ->i_mutex.  Both for regular
files and for directories.  Always had.

For directories there's copy_to_user() from ->readdir() done under ->i_mutex.
For regular files there's copy_from_user() from ->write(), usually done under
->i_mutex.  On hugetlbfs there's copy_to_user() from ->read() done under
->i_mutex.

It had not changed at all.  Lockdep sees both call chains; the only question
is which chain is seen first.  And usually reading a directory happens earlier
in the boot than writing into a file.  That's all there is to it.

Unfortunately, the fact that call chain being reported is obviously about
directories leads to false hopes that deadlock doesn't exist - mmap()
obviously can't happen to a directory inode, so people hope that it's a
false positive.  It isn't.

Patch separating directory and non-directory ->i_mutex into different classes
went in at some point, precisely due to those hopes.  It had a braino that
made it useless.  Fix for that braino had been posted and sits my queue; I'll
push it to Linus along with other pending fixes tonight.

It will *not* eliminate the (very real) deadlock.  It might make the warning
go away, but only if read() on hugetlbfs files doesn't happen during boot.

I suspect that they right thing would be to have a way to set explicit
nesting rules, not tied to speficic call trace.  I hadn't looked into
lockdep guts, so no idea how much will that hurt to implement.  As in
lockdep_lock_nests(class_outer, class_inner, message), acting as if
there had been a call chain where class_outer had been taken before
class_inner, with message going in place of call trace for that chain
when we run into a conflict...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
