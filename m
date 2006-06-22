Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5MBxXFT010031
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 07:59:34 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5MBxiUM031090
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 05:59:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5MBxXon015465
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 05:59:33 -0600
Date: Thu, 22 Jun 2006 06:59:07 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: Possible bug in do_execve()
Message-ID: <20060622115907.GD27074@sergelap.austin.ibm.com>
References: <20060620022506.GA3673@kevlar.burdell.org> <20060621184129.GB16576@sergelap.austin.ibm.com> <20060621185508.GA9234@kevlar.burdell.org> <20060621190910.GC16576@sergelap.austin.ibm.com> <20060621192726.GA10052@kevlar.burdell.org> <20060621194250.GD16576@sergelap.austin.ibm.com> <20060621201258.GB10052@kevlar.burdell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060621201258.GB10052@kevlar.burdell.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sonny Rao <sonny@burdell.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

Quoting Sonny Rao (sonny@burdell.org):
> > > It seems to assume that mm->context is valid before doing a check.
> > > 
> > > Since I don't have a sparc64 box, I can't check to see if this
> > > actually breaks things or not.
> > 
> > So we can either go through all arch's and make sure destroy_context is
> > safe for invalid context, or split mmput() and destroy_context()...
> > 
> > The former seems easier, but the latter seems more robust in the face of
> > future code changes I guess.
> 
> Yes, the former does seem easier, and perhaps easiest is to do that
> and document what the pre-conditions are so future developers at least
> have a clue.

Hmm, but document it where, since there is no single destroy_context()
definition?  At the mmput() and __mmdrop() definitions in kernel/fork.c?

(like so: ?)

-serge

From: Serge E. Hallyn <hallyn@sergelap.(none)>
Date: Wed, 21 Jun 2006 13:37:27 -0500
Subject: [PATCH] powerpc: check for proper mm->context before destroying

arch/powerpc/mm/mmu_context_64.c:destroy_context() can be called
from __mmput() in do_execve() if init_new_context() failed.  This
can result in idr_remove() being called for an invalid context.

So, don't call idr_remove if there is no context.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>

---

 arch/powerpc/mm/mmu_context_64.c |    3 +++
 kernel/fork.c                    |    4 ++++
 2 files changed, 7 insertions(+), 0 deletions(-)

d4fdebfda2170615db87f5aaf45b8478e223824a
diff --git a/arch/powerpc/mm/mmu_context_64.c b/arch/powerpc/mm/mmu_context_64.c
index 714a84d..552d590 100644
--- a/arch/powerpc/mm/mmu_context_64.c
+++ b/arch/powerpc/mm/mmu_context_64.c
@@ -55,6 +55,9 @@ again:
 
 void destroy_context(struct mm_struct *mm)
 {
+	if (mm->context.id == NO_CONTEXT)
+		return;
+
 	spin_lock(&mmu_context_lock);
 	idr_remove(&mmu_context_idr, mm->context.id);
 	spin_unlock(&mmu_context_lock);
diff --git a/kernel/fork.c b/kernel/fork.c
index ac8100e..0fe51aa 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -354,6 +354,10 @@ struct mm_struct * mm_alloc(void)
  * Called when the last reference to the mm
  * is dropped: either by a lazy thread or by
  * mmput. Free the page directory and the mm.
+ *
+ * Arch-specific destroy_context() implementations
+ * should be aware that this can be called when
+ * the mm->context initialization has failed.
  */
 void fastcall __mmdrop(struct mm_struct *mm)
 {
-- 
1.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
