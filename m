Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D26766B005D
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 13:49:40 -0500 (EST)
Date: Sun, 16 Dec 2012 13:49:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on
 mmap
Message-ID: <20121216184933.GA912@cmpxchg.org>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk>
 <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
 <20121214144927.GS4939@ZenIV.linux.org.uk>
 <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
 <20121216170403.GC4939@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216170403.GC4939@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>

On Sun, Dec 16, 2012 at 05:04:03PM +0000, Al Viro wrote:
> BTW, the __get_user_pages()/find_extend_vma()/mlock_vma_pages_range() pile is
> really asking for trouble; sure, the recursion there is limited, but it
> deserves a comment.

Agreed, how about this?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: mlock: document scary-looking stack expansion mlock
 chain

The fact that mlock calls get_user_pages, and get_user_pages might
call mlock when expanding a stack looks like a potential recursion.

However, mlock makes sure the requested range is already contained
within a vma, so no stack expansion will actually happen from mlock.

Should this ever change: the stack expansion mlocks only the newly
expanded range and so will not result in recursive expansion.

Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/mlock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index f0b9ce5..17cf905 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -186,6 +186,10 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
 		gup_flags |= FOLL_FORCE;
 
+	/*
+	 * We made sure addr is within a VMA, so the following will
+	 * not result in a stack expansion that recurses back here.
+	 */
 	return __get_user_pages(current, mm, addr, nr_pages, gup_flags,
 				NULL, NULL, nonblocking);
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
