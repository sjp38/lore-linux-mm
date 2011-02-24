Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8310C8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:43:14 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1OMOFjG026193
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:24:15 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1OMhC3F208730
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:43:12 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1OMhBns019874
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:43:12 -0300
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1298425922-23630-9-git-send-email-andi@firstfloor.org>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
	 <1298425922-23630-9-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 24 Feb 2011 14:43:04 -0800
Message-ID: <1298587384.9138.23.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

On Tue, 2011-02-22 at 17:52 -0800, Andi Kleen wrote:
> @@ -2286,6 +2290,9 @@ void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
>  		spin_unlock(&mm->page_table_lock);
>  		return;
>  	}
> +
> +	count_vm_event(THP_SPLIT);
> +
>  	page = pmd_page(*pmd);
>  	VM_BUG_ON(!page_count(page));
>  	get_page(page);

Hey Andi,

Your split counter tracks the split_huge_page_pmd() calls, but misses
plain split_huge_page() calls.  Did you do this on purpose?  Could we
move the counter in to the low-level split function like below?

---

 linux-2.6.git-dave/mm/huge_memory.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/huge_memory.c~move-THP_SPLIT mm/huge_memory.c
--- linux-2.6.git/mm/huge_memory.c~move-THP_SPLIT	2011-02-24 14:37:32.825288409 -0800
+++ linux-2.6.git-dave/mm/huge_memory.c	2011-02-24 14:39:01.767939971 -0800
@@ -1342,6 +1342,8 @@ static void __split_huge_page(struct pag
 	BUG_ON(!PageHead(page));
 	BUG_ON(PageTail(page));
 
+	count_vm_event(THP_SPLIT);
+
 	mapcount = 0;
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
@@ -2293,8 +2295,6 @@ void __split_huge_page_pmd(struct mm_str
 		return;
 	}
 
-	count_vm_event(THP_SPLIT);
-
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
