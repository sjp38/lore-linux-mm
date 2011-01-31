Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9EFB8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:31:19 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0VNCutG001610
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:12:56 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 02B334DE803F
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:30:46 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0VNVH4b380940
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:31:17 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0VNVH5M009277
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 16:31:17 -0700
Subject: wait_split_huge_page() dependence on rmap.h
From: Dave Hansen <dave@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 31 Jan 2011 15:31:15 -0800
Message-ID: <1296516675.7797.5110.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: aarcange <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

wait_split_huge_page() is really only used in a few spots at the moment.
I was trying to use it in fs/proc/task_mmu.c, but simply including
huge_mm.h gets this:

fs/proc/task_mmu.c: In function a??smaps_pte_rangea??:
fs/proc/task_mmu.c:392: error: dereferencing pointer to incomplete type

I think it's due to the __anon_vma dereference below.  #including rmap.h
makes it go away, but I don't think it's really the correct thing to do
here.  Directly including rmap.h in huge_mm.h ends up with some really
interesting header dependencies and does not work either.

Any ideas?  Should we move the existing huge_mm.h stuff to a private
header and have a more public one that also brings in rmap.h?

#define wait_split_huge_page(__anon_vma, __pmd)                         \
        do {                                                            \
                pmd_t *____pmd = (__pmd);                               \
                spin_unlock_wait(&(__anon_vma)->root->lock);            \
                /*                                                      \
                 * spin_unlock_wait() is just a loop in C and so the    \
                 * CPU can reorder anything around it.                  \
                 */                                                     \
                smp_mb();                                               \
                BUG_ON(pmd_trans_splitting(*____pmd) ||                 \
                       pmd_trans_huge(*____pmd));                       \
        } while (0)


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
