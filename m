Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4046B004D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 18:58:28 -0400 (EDT)
Date: Fri, 29 May 2009 15:58:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-Id: <20090529155859.2cf20823.akpm@linux-foundation.org>
In-Reply-To: <20090520212413.GF10756@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<1242852158.6582.231.camel@laptop>
	<20090520212413.GF10756@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org, mingo@redhat.com, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 20 May 2009 14:24:13 -0700
"Larry H." <research@subreption.com> wrote:

> Your
> approach means forcing all developers to remember where they have to
> place this explicit clearing, and introducing unnecessary code
> duplication and an ever growing list of places adding these calls.

And your proposed approach requires that developers remember to use
GFP_SENSITIVE at allocation time.  In well-implemented code, there is a
single memory-freeing site, so there's really no difference here.

Other problems I see with the patch are:

- Adds a test-n-branch to all page-freeing operations.  Ouch.  The
  current approach avoids that cost.

- Fails to handle kmalloc()'ed memory.  Fixing this will probably
  require adding a test-n-branch to kmem_cache_alloc().  Ouch * N.

- Once kmalloc() is fixed, the page-allocator changes and
  GFP_SENSITIVE itself can perhaps go away - I expect that little
  security-sensitive memory is allocated direct from the page
  allocator.  Most callsites are probably using
  kmalloc()/kmem_cache_alloc() (might be wrong).

  If not wrong then we end up with a single requirement: zap the
  memory in kmem_cache_free().

  But how to do that?  Particular callsites don't get to alter
  kfree()'s behaviour.  So they'd need to use a new kfree_sensitive(). 
  Which is just syntactic sugar around the code whihc we presently
  implement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
