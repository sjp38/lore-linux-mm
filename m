Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77261C48BE7
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 18:03:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 458192070B
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 18:03:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="NHX+A4Hn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 458192070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0BDD6B0003; Sat, 22 Jun 2019 14:03:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBC4E8E0002; Sat, 22 Jun 2019 14:03:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5D128E0001; Sat, 22 Jun 2019 14:03:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF5E6B0003
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 14:03:10 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id q12so1512615ljc.4
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 11:03:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rTVQwNdpEANBFFxnKdTYMSvJa37ECLsEqk9sL0w2aCY=;
        b=GKfbaDiQftndmMGMxuHS+zHTpZNXluRJ00RKmGSJ0uqW/4ZZDFbTNHs2XZTSvWp1Dj
         9PIipEvOCH+2PKU2mMO77Z9460SvkWVLuSGbQW3IcmCXnhjrmgoYZcxEDIThtKKevJh8
         UAWnI3FLwjVrGVtU76EZtBn+qiIJswSJzwrHM9Yflf2rAWCJ534+rHf7qxF4h4XKaSDj
         i/otLTNN6ybZEodNVzoh5OXTWY08OD4ZcaY2Ti3CU1c/Q8JkiZt8ALjqGxFVbtdQLLqt
         FUdlaEc2m56cHQQVgWxRsj2s2R6igb6U1uC31c2SQAZDNA1rfJtCQDVTVOeJj84wwp4q
         h85A==
X-Gm-Message-State: APjAAAUFViPmF/54ZdLQbvE0vPdFgn+fl5JuZxp+SVrF3spnyZfhYJVs
	cOmvqKQrIzf/58aNFH8FegNv7HXRWFBn8qseG6rcwlSKlLcstKot/ynFPboNy6v022061owf8lN
	cQU/JnfETO6NJL8HnMytMkfKofC9W2VHUhWdPGZz6jBb4Kvi5Y1GSzu+6MlEuBHVajg==
X-Received: by 2002:a2e:2b8f:: with SMTP id r15mr5759635ljr.210.1561226589471;
        Sat, 22 Jun 2019 11:03:09 -0700 (PDT)
X-Received: by 2002:a2e:2b8f:: with SMTP id r15mr5759606ljr.210.1561226588194;
        Sat, 22 Jun 2019 11:03:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561226588; cv=none;
        d=google.com; s=arc-20160816;
        b=jHcCvMBEJOCwZytsoSbVcNq1FcOGfSsy78s/W8PJCo+4joogba25lqPMxHET3wrCSv
         l3mG1dE1CglNHtCTcFD9bIl1vii9RMiYJ7QDaBEojIRqaSA4tAY5t0jM7y7T3P+ohu+X
         8lzkHyDRmoeUAtRGzExZ4XmLWNFnEiLq08DOouahVKm5zvh84J8N6t4HXk1PB5ldb8Ci
         KjrVKdYurQDLhkDAOXzIksFEMAsScTY16BlRP5thzTj62RX+U3snWAusitEhcRQHyQ7T
         GXIa9Vt8T8sJbwqN8OqXb6kziT3LYjR9e4m3ZxwwAsYCrui6hvgOb9tSdtbpndlATEZ9
         Mf5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rTVQwNdpEANBFFxnKdTYMSvJa37ECLsEqk9sL0w2aCY=;
        b=jWIK79PXeMIovhIMAYcti3AvawnR1DHpzJJYLvYzszE8Fe77J4CcFtfPWBDzrX6gB8
         1HPip/J7vRKEfLrQ9M1f/bAM1EYWVcyNtZp0QbmPdsKKELbGh+bnQ3BHV/eU4F33Wl6t
         7MYPbB5HFNn2nPNMF4XzTb5gLH7EV5vALi35Niy9pgADbbbC3S1koQ56y5IaNFKSdXQP
         Ihz1mgEqJ/1OydncME56qzJLvdsTvtGtwtplS26QsByB+afftTW4fcJZRKlwO64SKtj5
         pN6z5LEmIFiR8dtfMMhpXzmwQ+/5qb5yC3vzXT67TgajD+eVWnj61OEWLHLF8ik5PGm2
         fx5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=NHX+A4Hn;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor3156816ljg.43.2019.06.22.11.03.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Jun 2019 11:03:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=NHX+A4Hn;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rTVQwNdpEANBFFxnKdTYMSvJa37ECLsEqk9sL0w2aCY=;
        b=NHX+A4Hn+9k1GJ8KSdLWDJGit6XGMQmGE4DEU3fZsyRFWfBpw3wMmna3jspZ8npHAG
         uKBQSW6kfbmK1saH4HAnCB+CK4PhAc0azGjSfqk5NUcxI70V/w92Nb9Dpol9ZFldVFig
         uzoE3MUGDKRzt4OKUC0byx12pDyJL1JGvGwcI=
X-Google-Smtp-Source: APXvYqxjWM1193ns2bcySGgA89seNTr/kkaFerWxQiRpX+/F8IVUHQc18FaYohBjWO7nIxHiH4k3nw==
X-Received: by 2002:a2e:3211:: with SMTP id y17mr14035991ljy.86.1561226585705;
        Sat, 22 Jun 2019 11:03:05 -0700 (PDT)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com. [209.85.208.169])
        by smtp.gmail.com with ESMTPSA id h11sm873174lfm.14.2019.06.22.11.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 11:03:04 -0700 (PDT)
Received: by mail-lj1-f169.google.com with SMTP id 131so8822324ljf.4
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 11:03:04 -0700 (PDT)
X-Received: by 2002:a2e:9a58:: with SMTP id k24mr30871577ljj.165.1561226584112;
 Sat, 22 Jun 2019 11:03:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190620022008.19172-1-peterx@redhat.com> <20190620022008.19172-3-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-3-peterx@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 22 Jun 2019 11:02:48 -0700
X-Gmail-Original-Message-ID: <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
Message-ID: <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
Subject: Re: [PATCH v5 02/25] mm: userfault: return VM_FAULT_RETRY on signals
To: Peter Xu <peterx@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>, 
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, 
	Pavel Emelyanov <xemul@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

So I still think this all *may* ok, but at a minimum some of the
comments are misleading, and we need more docs on what happens with
normal signals.

I'm picking on just the first one I noticed, but I think there were
other architectures with this too:

On Wed, Jun 19, 2019 at 7:20 PM Peter Xu <peterx@redhat.com> wrote:
>
> diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
> index 6836095251ed..3517820aea07 100644
> --- a/arch/arc/mm/fault.c
> +++ b/arch/arc/mm/fault.c
> @@ -139,17 +139,14 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
>          */
>         fault = handle_mm_fault(vma, address, flags);
>
> -       if (fatal_signal_pending(current)) {
> -
> +       if (unlikely((fault & VM_FAULT_RETRY) && signal_pending(current))) {
> +               if (fatal_signal_pending(current) && !user_mode(regs))
> +                       goto no_context;
>                 /*
>                  * if fault retry, mmap_sem already relinquished by core mm
>                  * so OK to return to user mode (with signal handled first)
>                  */
> -               if (fault & VM_FAULT_RETRY) {
> -                       if (!user_mode(regs))
> -                               goto no_context;
> -                       return;
> -               }
> +               return;
>         }

So note how the end result of this is:

 (a) if a fatal signal is pending, and we're returning to kernel mode,
we do the exception handling

 (b) otherwise, if *any* signal is pending, we'll just return and
retry the page fault

I have nothing against (a), and (b) is likely also ok, but it's worth
noting that (b) happens for kernel returns too. But the comment talks
about returning to user mode.

Is it ok to return to kernel mode when signals are pending? The signal
won't be handled, and we'll just retry the access.

Will we possibly keep retrying forever? When we take the fault again,
we'll set the FAULT_FLAG_ALLOW_RETRY again, so any fault handler that
says "if it allows retry, and signals are pending, just return" would
keep never making any progress, and we'd be stuck taking page faults
in kernel mode forever.

So I think the x86 code sequence is the much safer and more correct
one, because it will actually retry once, and set FAULT_FLAG_TRIED
(and it will clear the "FAULT_FLAG_ALLOW_RETRY" flag - but you'll
remove that clearing later in the series).

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 46df4c6aae46..dcd7c1393be3 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1463,16 +1463,20 @@ void do_user_addr_fault(struct pt_regs *regs,
>          * that we made any progress. Handle this case first.
>          */
>         if (unlikely(fault & VM_FAULT_RETRY)) {
> +               bool is_user = flags & FAULT_FLAG_USER;
> +
>                 /* Retry at most once */
>                 if (flags & FAULT_FLAG_ALLOW_RETRY) {
>                         flags &= ~FAULT_FLAG_ALLOW_RETRY;
>                         flags |= FAULT_FLAG_TRIED;
> +                       if (is_user && signal_pending(tsk))
> +                               return;
>                         if (!fatal_signal_pending(tsk))
>                                 goto retry;
>                 }
>
>                 /* User mode? Just return to handle the fatal exception */
> -               if (flags & FAULT_FLAG_USER)
> +               if (is_user)
>                         return;
>
>                 /* Not returning to user mode? Handle exceptions or die: */

However, I think the real issue is that it just needs documentation
that a fault handler must not react to signal_pending() as part of the
fault handling itself (ie the VM_FAULT_RETRY can not be *because* of a
non-fatal signal), and there needs to be some guarantee of forward
progress.

At that point the "infinite page faults in kernel mode due to pending
signals" issue goes away. But it's not obvious in this patch, at
least.

               Linus

