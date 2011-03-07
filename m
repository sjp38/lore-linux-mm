Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 549FC8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 02:33:16 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D19633EE0BB
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:33:08 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BAAE045DE53
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:33:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A534A45DE4D
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:33:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 979221DB8041
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:33:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F3891DB803F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:33:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: THP, rmap and page_referenced_one()
In-Reply-To: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
Message-Id: <20110307162920.89FB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 16:33:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

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
> 
> Am I missing something there ? In particular, I am not sure if marking
> the children's VMA as mlocked would somehow cause rmap to realize it
> can't share pages with the parent anymore (but I don't think that's
> the case, and it could cause other issues if it was...)

Hi

I think you are right. 
page_check_address() should be called before VM_LOCKED check.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
