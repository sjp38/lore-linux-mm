Date: Thu, 13 Sep 2007 04:47:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc4-mm1: deadlock while mmaping video device
Message-Id: <20070913044726.1aa48f45.akpm@linux-foundation.org>
In-Reply-To: <46E9226F.9010700@gmail.com>
References: <46E9226F.9010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-mm@kvack.org, Linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007 13:43:43 +0200 Jiri Slaby <jirislaby@gmail.com> wrote:

> Hi,
> 
> I have this circular lock dependency on 2.6.23-rc4-mm1 when opening
> /dev/video0 and mmaping it. the v4l driver is stk11xx:
> http://www.fi.muni.cz/~xslaby/sklad/panics/mm-deadlock.png
> 
> Using slub on x86_64 if that matters.
> 
> For now, I'm unable to set up a netconsole, so only the picture linked above
> is the best I have.
> 

oop, I think you'll want this:

--- a/mm/memory.c~memory-controller-memory-accounting-v7-fix
+++ a/mm/memory.c
@@ -1135,7 +1135,7 @@ static int insert_page(struct mm_struct 
 {
 	int retval;
 	pte_t *pte;
-	spinlock_t *ptl;  
+	spinlock_t *ptl;
 
 	retval = mem_container_charge(page, mm);
 	if (retval)
@@ -1160,6 +1160,7 @@ static int insert_page(struct mm_struct 
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
 	retval = 0;
+	pte_unmap_unlock(pte, ptl);
 	return retval;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
@@ -2184,8 +2185,8 @@ static int do_anonymous_page(struct mm_s
 	if (!page)
 		goto oom;
 
-		if (mem_container_charge(page, mm))
-			goto oom_free_page;
+	if (mem_container_charge(page, mm))
+		goto oom_free_page;
 
 	entry = mk_pte(page, vma->vm_page_prot);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
