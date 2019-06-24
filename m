Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBAF1C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:43:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83AD5208CA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:43:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83AD5208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 339E88E0005; Mon, 24 Jun 2019 03:43:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EA3D8E0001; Mon, 24 Jun 2019 03:43:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 202928E0005; Mon, 24 Jun 2019 03:43:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2D9D8E0001
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 03:43:14 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id i196so15267274qke.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:43:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XulIcrJUq716+zFR/83RDSIxp1rZeFywfO+TEUOl8zA=;
        b=rv4ilxcIqsldO0gnBBu0/+l2wc40adXvoqMrHv3r34VGPqPjORQ9vXuRpbgH7FyJXm
         nYSviRKIv8AoPGk1E7zDma6o/eoRRuXKYMKPTxD78yeDS65pBO3vYmnlYrUSgZaTcyHN
         CrkB0RzKqBbFu+bOqLKOmp2r9y9oUFCr2qYiFEykZQfbQ0Vojwsq9k8AcVdJ0wvARfNP
         BfSb73nxW04iz+/yD1iSbEvZ78seELIlIqLN3LSCSORBadD0LXiw3hwcXJ2ezx4vccVr
         oyUMPO0cAHXpOrXixWxDiRwPmsCJjS0oDJb1JG2EpAxFi+E1vHl29LUjRrxIxa71H2Xq
         DnDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXnVenpXK0oqW667nwQzHz+g2RDuHjVOSgBumuLdrAvvwfVWYp/
	2sL/nGJigAB5h0Lxk/6fYBtY7aeAWugl+WbDVlTXJIf4gPANcYVjhn2db4pqUZOHcgMPEIfltu9
	iTZfdvBu+T86+8b+QgQsrCjGine1zyVjrVvYrvBvEVBCbIVwZRtXK0RoVndyRBFm0bg==
X-Received: by 2002:a37:e409:: with SMTP id y9mr33136295qkf.109.1561362194750;
        Mon, 24 Jun 2019 00:43:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn90uP6UOZ/LarVHTx0t0Pl7/ROY4hbGJaubUxJRXkshtCd7bktm4A04IipLtxRvgxB5hl
X-Received: by 2002:a37:e409:: with SMTP id y9mr33136257qkf.109.1561362193740;
        Mon, 24 Jun 2019 00:43:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561362193; cv=none;
        d=google.com; s=arc-20160816;
        b=nQ7i5IymVh4iCnUPAxrmwYSnftiC8UXLY9Mxp/lz6cF1UbV1b6lzp+4vU54+hd0aZs
         Skp/9Xr/WgRd6JmMbF2NiREGHGcikJfoVTVB98L6mFL2agmFlW0b9ubwuqPmXQRzd6xI
         niLgRcDNfaReuqt4bmDseH9s2bz8ETYSimLAnmN5qKiHwzsStOvV6t6GColYDxi7PGWW
         Q3lDpcXDYmBgyuKMYpXO3m2aedYiIhe4Aqt/gqXyd9/0NLIExvc/K3kEPdjvI92azjJS
         I12hqBAGA5gfB5JEVvRjJFvte0xnNYCPzi9Ijc5tHwQIjNTPr8r+t0q+N6erco723TuP
         3V+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XulIcrJUq716+zFR/83RDSIxp1rZeFywfO+TEUOl8zA=;
        b=mMwNUe91fBjCvODyqPaKpYGITgv5bv/G5v/dl12iFnvoGMp0g2gVIpXk++u4HxUXjd
         ToI1QioMNUpbL6QYaMzLi2MpQOEIa8BJWXVZXbnBeo0S6nZa1ZA2YqIKEVl3i1xke1bH
         gYjQdCtz8Xj5Np+8z1q7+mseYh0tJxWtv8+Yx4YHcovPympYQf/YPNgE48jji/pjpv0Y
         RZFr67YAWbIcOwWa6Hc0ytuldStXHI5SZ+AXlYTV6CN6uTSjPBkI29moA2vOKZVi95XD
         HcGgrye8J9fR1/l9u9BQeoWLBY9B43wLVkRYmEsLWbvop9/4dD94uPwvImtV6/1l3u7v
         tbRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u30si7354941qvh.46.2019.06.24.00.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 00:43:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8D8943084246;
	Mon, 24 Jun 2019 07:43:12 +0000 (UTC)
Received: from xz-x1 (ovpn-12-60.pek2.redhat.com [10.72.12.60])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E03965C1B5;
	Mon, 24 Jun 2019 07:42:59 +0000 (UTC)
Date: Mon, 24 Jun 2019 15:42:50 +0800
From: Peter Xu <peterx@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v5 02/25] mm: userfault: return VM_FAULT_RETRY on signals
Message-ID: <20190624074250.GF6279@xz-x1>
References: <20190620022008.19172-1-peterx@redhat.com>
 <20190620022008.19172-3-peterx@redhat.com>
 <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 24 Jun 2019 07:43:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 22, 2019 at 11:02:48AM -0700, Linus Torvalds wrote:
> So I still think this all *may* ok, but at a minimum some of the
> comments are misleading, and we need more docs on what happens with
> normal signals.
> 
> I'm picking on just the first one I noticed, but I think there were
> other architectures with this too:
> 
> On Wed, Jun 19, 2019 at 7:20 PM Peter Xu <peterx@redhat.com> wrote:
> >
> > diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
> > index 6836095251ed..3517820aea07 100644
> > --- a/arch/arc/mm/fault.c
> > +++ b/arch/arc/mm/fault.c
> > @@ -139,17 +139,14 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
> >          */
> >         fault = handle_mm_fault(vma, address, flags);
> >
> > -       if (fatal_signal_pending(current)) {
> > -
> > +       if (unlikely((fault & VM_FAULT_RETRY) && signal_pending(current))) {
> > +               if (fatal_signal_pending(current) && !user_mode(regs))
> > +                       goto no_context;
> >                 /*
> >                  * if fault retry, mmap_sem already relinquished by core mm
> >                  * so OK to return to user mode (with signal handled first)
> >                  */
> > -               if (fault & VM_FAULT_RETRY) {
> > -                       if (!user_mode(regs))
> > -                               goto no_context;
> > -                       return;
> > -               }
> > +               return;
> >         }
> 
> So note how the end result of this is:
> 
>  (a) if a fatal signal is pending, and we're returning to kernel mode,
> we do the exception handling
> 
>  (b) otherwise, if *any* signal is pending, we'll just return and
> retry the page fault
> 
> I have nothing against (a), and (b) is likely also ok, but it's worth
> noting that (b) happens for kernel returns too. But the comment talks
> about returning to user mode.

True.  So even with the content of this patch, I should at least touch
up the comment but I obviously missed that.  Though when reading
through the reply I think it's the patch content that might need a
fixup rather than the comment...

> 
> Is it ok to return to kernel mode when signals are pending? The signal
> won't be handled, and we'll just retry the access.
> 
> Will we possibly keep retrying forever? When we take the fault again,
> we'll set the FAULT_FLAG_ALLOW_RETRY again, so any fault handler that
> says "if it allows retry, and signals are pending, just return" would
> keep never making any progress, and we'd be stuck taking page faults
> in kernel mode forever.
> 
> So I think the x86 code sequence is the much safer and more correct
> one, because it will actually retry once, and set FAULT_FLAG_TRIED
> (and it will clear the "FAULT_FLAG_ALLOW_RETRY" flag - but you'll
> remove that clearing later in the series).

Indeed at least the ARC code has more functional change than what has
been stated in the commit message (which is only about faster signal
handling).  I wasn't paying much attention before because I don't see
"multiple retries" a big problem here and after all that's what we
finally want to achieve with the follow up patches... But I agree that
maybe I should be even more explicit in this patch.  Do you think
below change (to be squashed into this patch) looks good to you?
That's also an example only with ARC architecture but I can do similar
things to the other archs if you prefer:

                /*
                 * if fault retry, mmap_sem already relinquished by core mm
                 * so OK to return to user mode (with signal handled first)
                 */
-               return;
+               if (user_mode(regs))
+                       return;

> 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index 46df4c6aae46..dcd7c1393be3 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1463,16 +1463,20 @@ void do_user_addr_fault(struct pt_regs *regs,
> >          * that we made any progress. Handle this case first.
> >          */
> >         if (unlikely(fault & VM_FAULT_RETRY)) {
> > +               bool is_user = flags & FAULT_FLAG_USER;
> > +
> >                 /* Retry at most once */
> >                 if (flags & FAULT_FLAG_ALLOW_RETRY) {
> >                         flags &= ~FAULT_FLAG_ALLOW_RETRY;
> >                         flags |= FAULT_FLAG_TRIED;
> > +                       if (is_user && signal_pending(tsk))
> > +                               return;
> >                         if (!fatal_signal_pending(tsk))
> >                                 goto retry;
> >                 }
> >
> >                 /* User mode? Just return to handle the fatal exception */
> > -               if (flags & FAULT_FLAG_USER)
> > +               if (is_user)
> >                         return;
> >
> >                 /* Not returning to user mode? Handle exceptions or die: */
> 
> However, I think the real issue is that it just needs documentation
> that a fault handler must not react to signal_pending() as part of the
> fault handling itself (ie the VM_FAULT_RETRY can not be *because* of a
> non-fatal signal), and there needs to be some guarantee of forward
> progress.

Should we still be able to react on signal_pending() as part of fault
handling (because that's what this patch wants to do, at least for an
user-mode page fault)?  Please kindly correct me if I misunderstood...

> 
> At that point the "infinite page faults in kernel mode due to pending
> signals" issue goes away. But it's not obvious in this patch, at
> least.

Thanks,

-- 
Peter Xu

