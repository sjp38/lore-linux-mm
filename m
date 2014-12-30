Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 76FB46B006E
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 17:35:08 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id f73so7583625yha.20
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 14:35:08 -0800 (PST)
Received: from rhlx01.hs-esslingen.de (rhlx01.hs-esslingen.de. [129.143.116.10])
        by mx.google.com with ESMTPS id dn5si77560328wjb.163.2014.12.30.00.32.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Dec 2014 00:32:31 -0800 (PST)
Date: Tue, 30 Dec 2014 09:32:30 +0100
From: Andreas Mohr <andi@lisas.de>
Subject: Re: [RFC PATCH 0/4] kstrdup optimization
Message-ID: <20141230083230.GA17639@rhlx01.hs-esslingen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54A25135.5030103@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

Hi,

Andrzej Hajda wrote:
> On 12/30/2014 07:45 AM, Andi Kleen wrote:
> > What happens if someone is to kfree() these strings?
> >
> > -Andi
> >
> kstrdup_const must be accompanied by kfree_const, I did not mention it
> in cover letter
> but it is described in the 1st patch commit message.
> Simpler alternative (but I am not sure if better) would be to add
> similar check
> (ie. if pointer is in .rodata) to kfree itself.

Seems like a large potential programmer-side (a)symmetry issue to me
(not unsimilar to the new/delete vs. malloc/free asymmetry PITA
encountered in case of "dirty C++ habits").

This symmetry issue probably could be cleanly avoided only
by having kfree() itself contain such an identifying check, as you suggest
(thereby slowing down kfree() performance).
(OTOH we do have nice helpers such as Coccinelle
to near-sufficiently deal with such issues,
albeit in a less preferrable/elegant/automatic manner).

If we decide to want to avoid this rats nest via clean builtin identification
but in case such a kfree-side .rodata check is unjustifiably expensive,
one could try to have *builtin* (i.e., fully or at least almost *non*-runtime)
branching of their differing handling,
by marking _const-originated "allocations" via a special easily checkable flag -
but since in such kalloc/kfree API cases
we're dealing with simple raw pointer results
rather than more complex structs,
such identification markup probably could only be achieved
via internal mapping overhead (of management structs) -
unless those APIs happen to have internal bookkeeping already
(in which case the only penalty would either be setting/evaluating a flag
of common shared bookkeeping structs,
or full/clean branching into distinctly handled management parts,
which might be able to cause less runtime overhead).

Andreas Mohr

-- 
GNU/Linux. It's not the software that's free, it's you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
