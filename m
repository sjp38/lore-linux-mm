Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E50226B00EC
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 15:42:32 -0400 (EDT)
Date: Tue, 20 Mar 2012 12:42:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC]swap: don't do discard if no discard option added
Message-Id: <20120320124230.21990008.akpm@linux-foundation.org>
In-Reply-To: <4F68795E.9030304@kernel.org>
References: <4F68795E.9030304@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, Holger Kiehl <Holger.Kiehl@dwd.de>, Hugh Dickins <hughd@google.com>

On Tue, 20 Mar 2012 20:34:38 +0800
Shaohua Li <shli@kernel.org> wrote:

> 
> Even don't add discard option, swapon will do discard, this sounds buggy,
> especially when discard is slow or buggy.
> 

That changelog is pretty hard to understand.  I rewrote it as below.


From: Shaohua Li <shli@kernel.org>
Subject: swap: don't do discard if no discard option added

When swapon() was not passed the SWAP_FLAG_DISCARD option, sys_swapon()
will still perform a discard operation.  This can cause problems if discard
is slow or buggy.

Reverse the order of the check so that a discard operation is performed
only if the sys_swapon() caller is attempting to enable discard.

Signed-off-by: Shaohua Li <shli@fusionio.com>
Reported-by: Holger Kiehl <Holger.Kiehl@dwd.de>
Tested-by: Holger Kiehl <Holger.Kiehl@dwd.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/swapfile.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/swapfile.c~swap-dont-do-discard-if-no-discard-option-added mm/swapfile.c
--- a/mm/swapfile.c~swap-dont-do-discard-if-no-discard-option-added
+++ a/mm/swapfile.c
@@ -2105,7 +2105,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 			p->flags |= SWP_SOLIDSTATE;
 			p->cluster_next = 1 + (random32() % p->highest_bit);
 		}
-		if (discard_swap(p) == 0 && (swap_flags & SWAP_FLAG_DISCARD))
+		if ((swap_flags & SWAP_FLAG_DISCARD) && discard_swap(p) == 0)
 			p->flags |= SWP_DISCARDABLE;
 	}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
