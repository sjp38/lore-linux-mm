Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB2B6B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 02:58:42 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so18322610wic.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 23:58:41 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id gs6si9171088wib.105.2015.09.17.23.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Sep 2015 23:58:40 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 18 Sep 2015 07:58:40 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 397AC1B0804B
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 08:00:20 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8I6wccd33095846
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 06:58:38 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8I6wbNb026102
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 00:58:37 -0600
Date: Fri, 18 Sep 2015 08:58:35 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918085835.597fb036@mschwide>
In-Reply-To: <20150917193152.GJ2000@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
	<1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
	<20150917193152.GJ2000@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Thu, 17 Sep 2015 22:31:52 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> Thus when CONFIG_MEM_SOFT_DIRTY = n, the unuse_pte will be the same
> as it were without the patch, calling pte_same.
> 
> Now to the bit itself
> 
> #ifdef CONFIG_MEM_SOFT_DIRTY
> #define _PAGE_SWP_SOFT_DIRTY_PAGE_PSE
> #else
> #define _PAGE_SWP_SOFT_DIRTY_PAGE_PSE(_AT(pteval_t, 0))
> #endif
>
> it's 0 if CONFIG_MEM_SOFT_DIRTY=n, so any setup of this
> bit will simply become nop

Ok, that is what I have been missing with my soft dirty patch for s390.
_PAGE_BIT_SOFT_DIRTY is always defined but the _PAGE_SOFT_DIRTY and
_PAGE_SWP_SOFT_DIRTY are conditional. The primitives are always
defined but turn into nops with CONFIG_MEM_SOFT_DIRTY=n.

> #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
> static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
> {
> 	return pte_set_flags(pte, _PAGE_SWP_SOFT_DIRTY);
> }
> 
> static inline int pte_swp_soft_dirty(pte_t pte)
> {
> 	return pte_flags(pte) & _PAGE_SWP_SOFT_DIRTY;
> }
> 
> static inline pte_t pte_swp_clear_soft_dirty(pte_t pte)
> {
> 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
> }
> #endif
> 
> So I fear I'm lost where this "set" of the bit comes from
> when CONFIG_MEM_SOFT_DIRTY=n.
> 
> Martin, could you please elaborate? Seems I'm missing
> something obvious.
 
It is me who missed something.. thanks for the explanation.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
