Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id CF9146B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 11:53:47 -0400 (EDT)
Message-ID: <5081777A.8050104@redhat.com>
Date: Fri, 19 Oct 2012 11:53:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: question on NUMA page migration
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Andrea, Peter,

I have a question on page refcounting in your NUMA
page migration code.

In Peter's case, I wonder why you introduce a new
MIGRATE_FAULT migration mode. If the normal page
migration / compaction logic can do without taking
an extra reference count, why does your code need it?

In Andrea's case, we have a comment suggesting an
extra refcount is needed, immediately followed by
a put_page:

         /*
          * Pin the head subpage at least until the first
          * __isolate_lru_page succeeds (__isolate_lru_page pins it
          * again when it succeeds). If we unpin before
          * __isolate_lru_page successd, the page could be freed and
          * reallocated out from under us. Thus our previous checks on
          * the page, and the split_huge_page, would be worthless.
          *
          * We really only need to do this if "ret > 0" but it doesn't
          * hurt to do it unconditionally as nobody can reference
          * "page" anymore after this and so we can avoid an "if (ret >
          * 0)" branch here.
          */
         put_page(page);

This also confuses me.

If we do not need the extra refcount (and I do not
understand why NUMA migrate-on-fault needs one more
refcount than normal page migration), we can get
rid of the MIGRATE_FAULT mode.

If we do need the extra refcount, why is normal
page migration safe? :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
