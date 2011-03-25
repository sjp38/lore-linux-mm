Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8435C8D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 12:48:53 -0400 (EDT)
Date: Fri, 25 Mar 2011 17:48:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: get_page() vs __split_huge_page_refcount()
Message-ID: <20110325164847.GD431@random.random>
References: <AANLkTinHBouEU2pAVOfuakxYqA_QFVLz=qY-f8ZW6fTG@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinHBouEU2pAVOfuakxYqA_QFVLz=qY-f8ZW6fTG@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm <linux-mm@kvack.org>

Hi Michel,

On Thu, Mar 24, 2011 at 10:00:16PM -0700, Michel Lespinasse wrote:
> My question is this: After someone obtains a page reference using
> get_user_pages(), what prevents them from getting additional
> references with get_page() ? I always thought it was legal to
> duplicate references that way, but now I don't see how it'd be safe
> doing so on anon pages with THP enabled.

It's not legal anymore as you noticed, but I'm not aware of anything
doing that. I don't see an useful case where a driver could need to
take one extra refcount after GUP returned. The normal API is
GUP/put_page. We could make it legal again by taking the compound_lock
after a PageCompound check though. I hope it's not needed though. It's
unavoidable in put_page because put_page will run out of order with
regard to __split_huge_page_refcount. But serializing get_page in GUP
against __split_huge_page_refcount is automatic through the
pmd_trans_splitting bit and needed for all page table walkers anyway.

Maybe it's good idea to add a comment to transhuge.txt about that? I
don't think I added it.

Grepping for get_page in drivers doesn't show too many, they mostly
run through the vm_ops->fault handler. Most important I can't see how
possibly it could be useful to run a get_page after
get_user_pages(FOLL_GET) returns.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
