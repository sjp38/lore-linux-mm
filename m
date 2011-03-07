Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 595798D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 03:35:39 -0500 (EST)
Received: by iwl42 with SMTP id 42so5020004iwl.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 00:35:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
Date: Mon, 7 Mar 2011 17:35:37 +0900
Message-ID: <AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com>
Subject: Re: THP, rmap and page_referenced_one()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon, Mar 7, 2011 at 3:50 PM, Michel Lespinasse <walken@google.com> wrote:
> Hi,
>
> I have been wondering about the following:
>
> Before the THP work, the if (vma->vm_flags & VM_LOCKED) test in
> page_referenced_one() was placed after the page_check_address() call,
> but now it is placed above it. Could this be a problem ?
>
> My understanding is that the page_check_address() check may return
> false positives - for example, if an anon page was created before a
> process forked, rmap will indicate that the page could be mapped in
> both of the processes, even though one of them might have since broken
> COW. What would happen if the child process mlocks the corresponding
> VMA ? my understanding is that this would break COW, but not cause
> rmap to be updated, so the parent's page would still be marked in rmap
> as being possibly mapped in the children's VM_LOCKED vma. With the
> VM_LOCKED check now placed above the page_check_address() call, this
> would cause vmscan to see both the parent's and the child's pages as
> being unevictable.

I agree.

There are two processes called P_A, P_B.
P_B is child of P_A.

A page "page A" is share between V_A(A's VMA)and V_B(B's VMA) since
P_B is created by forking from P_A. When P_B calls mlock the V_B, P_B
allocates new page B instead of reusing page A by COW and mapped P_B's
page table but rmap of page A still indicates page A is mapped by V_A
and V_B.

The page_check_address can filter this situation that V_B doesn't
include page A any more.
So page_check_address should be placed before checking the VM_LOCKED.

I think it's valuable to add the comment why we need
page_check_address should be placed before the checking VM_LOCKED.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
