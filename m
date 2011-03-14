Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 771E68D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:02:07 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2EGuUG9029208
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:56:31 -0700
Received: by iyf13 with SMTP id 13so7153689iyf.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 09:56:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
 <20110314155232.GB10696@random.random> <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 14 Mar 2011 09:56:10 -0700
Message-ID: <AANLkTikvt+o+UaksmvM5C7FWt7hTMJyaPiUGhQ+6OKBg@mail.gmail.com>
Subject: Re: [PATCH] thp+memcg-numa: fix BUG at include/linux/mm.h:370!
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2011 at 9:37 AM, Hugh Dickins <hughd@google.com> wrote:
>
> I did try it that way at first (didn't help when I mistakenly put
> #ifndef instead of #ifdef around the put_page!), but was repulsed
> by seeing yet another #ifdef CONFIG_NUMA, so went with the duplicating
> version - which Linus has now taken.

I have to admit to being repulsed by the whole patch, but my main
source of "that's effin ugly" was from the crazy lock handling.

Does mem_cgroup_newpage_charge() even _need_ the mmap_sem at all? And
if not, why not release the read-lock early? And even if it _does_
need it, why not do

    ret = mem_cgroup_newpage_charge();
    up_read(&mm->mmap_sem);
    if (ret) {
        ...

finally, the #ifdef CONFIG_NUMA is ugly, but it's ugly in the return
path of the function too, and the nicer way would probably be to have
it in one place and do something like

    /*
     * The allocation rules are different for the NUMA/non-NUMA cases
     * For the NUMA case, we allocate here, for the non-numa case we
     * use the allocation in *hpage
     */
    static inline struct page *collapse_alloc_hugepage(struct page **hpage)
    {
    #ifdef CONFIG_NUMA
        VM_BUG_ON(*hpage);
        return alloc_hugepage_vma(khugepaged_defrag(), vma, address, node);
    #else
        VM_BUG_ON(!*hpage);
        return *hpage;
    #endif
    }

    static inline void collapse_free_hugepage(struct page *page)
    {
    #ifdef CONFIG_NUMA
        put_page(new_page);
    #else
        /* Nothing to do */
    #endif
    }

and use that instead. The point being that the #ifdef'fery now ends up
being in a much more targeted area and much better abstracted, rather
than in the middle of code, and ugly as sin.

But as mentioned, the lock handling is disgusting. Why is it even safe
to drop and re-take the lock at all?

                                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
