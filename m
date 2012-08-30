Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6F9226B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 17:34:03 -0400 (EDT)
Date: Thu, 30 Aug 2012 14:34:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] rbtree based interval tree as a prio_tree
 replacement
Message-Id: <20120830143401.be06d61b.akpm@linux-foundation.org>
In-Reply-To: <1344324343-3817-1-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue,  7 Aug 2012 00:25:38 -0700
Michel Lespinasse <walken@google.com> wrote:

> This patchset goes over the rbtree changes that have been already integrated
> into Andrew's -mm tree, as well as the augmented rbtree proposal which is
> currently pending.

hm.  Well I grabbed these for a bit of testing.

It's a large change in MM and it depends on code which hasn't yet been
merged in mainline.  It's probably prudent to do all this in two steps
- we'll see.

It would good to have solid acknowledgement from Rik that this approach
does indeed suit his pending vma changes.

The templates-with-CPP thing is not terribly appealing.  It's not
obvious that it really needed to be done this way - we've avoided it in
plenty of other places.  It would be nice to see that alternatives have
been thoroughly explored, and why they were rejected.

AFAICT the code will work OK when expanding macros which reference their
arguments multiple times.  For example, interval_tree.c has

#define ITLAST(n)  ((n)->vm_pgoff + \
		    (((n)->vm_end - (n)->vm_start) >> PAGE_SHIFT) - 1)

which will explode if passed "foo++".  Things like that.

The code uses the lame-and-useless "inline" absolutely all over the
place.  I do think that for new code it would be better to get down and
actually make proper engineering decisions about which functions should
be inlined and mark them __always_inline.

Hillf has made a review suggestion which AFAICT remains unresponded to.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
