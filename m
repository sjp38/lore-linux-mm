Message-ID: <42ED503A.6060101@yahoo.com.au>
Date: Mon, 01 Aug 2005 08:27:06 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com> <42EC2ED6.2070700@yahoo.com.au> <20050731105234.GA2254@lnx-holt.americas.sgi.com> <42ECB0EC.4000808@yahoo.com.au> <20050731113059.GC2254@lnx-holt.americas.sgi.com> <20050731120900.GE2254@lnx-holt.americas.sgi.com>
In-Reply-To: <20050731120900.GE2254@lnx-holt.americas.sgi.com>
Content-Type: multipart/mixed;
 boundary="------------010900010107060104090306"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010900010107060104090306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Robin Holt wrote:

> So far, I think the case for setting VM_FAULT_RACE only when there
> is a conflict for writable seems strong.
> 

But that's 1162 collisions out of how many faults? And only
on the get_user_pages faults does the return value really
make a difference.

How about the following? This should catch some cases. You
still miss the case where you're racing with anotyher writer
though.

-- 
SUSE Labs, Novell Inc.


--------------010900010107060104090306
Content-Type: text/plain;
 name="mm-gup-write-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-gup-write-fix.patch"

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2005-07-31 11:49:35.000000000 +1000
+++ linux-2.6/mm/memory.c	2005-08-01 08:21:21.000000000 +1000
@@ -971,7 +971,9 @@ int get_user_pages(struct task_struct *t
 					 * that we have actually performed
 					 * the write fault (below).
 					 */
-					continue;
+					if (write)
+						continue;
+					break;
 				default:
 					BUG();
 				}

--------------010900010107060104090306--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
