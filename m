Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B760C6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 13:06:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a82so16637730pfc.8
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 10:06:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u39si4835007pgn.208.2017.06.08.10.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 10:06:01 -0700 (PDT)
Date: Thu, 8 Jun 2017 10:05:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170608170557.GA8118@bombadil.infradead.org>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608144831.GA19903@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 08, 2017 at 04:48:31PM +0200, Michal Hocko wrote:
> On Wed 07-06-17 13:56:01, David Rientjes wrote:
> > I agree it's probably going to bisect to 338a16ba15495 since it's the 
> > cond_resched() at the line number reported, but I think there must be 
> > something else going on.  I think the list of locks held by khugepaged is 
> > correct because it matches with the implementation.  The preempt_count(), 
> > as suggested by Andrew, does not.  If this is reproducible, I'd like to 
> > know what preempt_count() is.
> 
> collapse_huge_page
>   pte_offset_map
>     kmap_atomic
>       kmap_atomic_prot
>         preempt_disable
>   __collapse_huge_page_copy
>   pte_unmap
>     kunmap_atomic
>       __kunmap_atomic
>         preempt_enable
> 
> I suspect, so cond_resched seems indeed inappropriate on 32b systems.

Then why doesn't it trigger on 64-bit systems too?

#ifndef ARCH_HAS_KMAP
...
static inline void *kmap_atomic(struct page *page)
{
        preempt_disable();
        pagefault_disable();
        return page_address(page);
}
#define kmap_atomic_prot(page, prot)    kmap_atomic(page)


... oh, wait, I see.  Because pte_offset_map() doesn't call kmap_atomic()
on 64-bit.  Indeed, it doesn't necessarily call kmap_atomic() on 32-bit
either; only with CONFIG_HIGHPTE enabled.  How much of a performance
penalty would it be to call kmap_atomic() unconditionally on 64 bit to
make sure that this kind of problem doesn't show on 32-bit systems only?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
