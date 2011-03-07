Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D943F8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 01:50:27 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p276oNQc002043
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 22:50:23 -0800
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq12.eem.corp.google.com with ESMTP id p276oDdC012663
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 22:50:22 -0800
Received: by qyk7 with SMTP id 7so3207486qyk.3
        for <linux-mm@kvack.org>; Sun, 06 Mar 2011 22:50:21 -0800 (PST)
MIME-Version: 1.0
Date: Sun, 6 Mar 2011 22:50:21 -0800
Message-ID: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
Subject: THP, rmap and page_referenced_one()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

Hi,

I have been wondering about the following:

Before the THP work, the if (vma->vm_flags & VM_LOCKED) test in
page_referenced_one() was placed after the page_check_address() call,
but now it is placed above it. Could this be a problem ?

My understanding is that the page_check_address() check may return
false positives - for example, if an anon page was created before a
process forked, rmap will indicate that the page could be mapped in
both of the processes, even though one of them might have since broken
COW. What would happen if the child process mlocks the corresponding
VMA ? my understanding is that this would break COW, but not cause
rmap to be updated, so the parent's page would still be marked in rmap
as being possibly mapped in the children's VM_LOCKED vma. With the
VM_LOCKED check now placed above the page_check_address() call, this
would cause vmscan to see both the parent's and the child's pages as
being unevictable.

Am I missing something there ? In particular, I am not sure if marking
the children's VMA as mlocked would somehow cause rmap to realize it
can't share pages with the parent anymore (but I don't think that's
the case, and it could cause other issues if it was...)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
