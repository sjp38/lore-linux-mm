Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 08357828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:22:26 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fe3so75524456pab.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:22:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id oi7si4029265pab.183.2016.03.11.01.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 01:22:25 -0800 (PST)
Date: Fri, 11 Mar 2016 10:22:18 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160311092218.GY6344@twins.programming.kicks-ass.net>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160224185025.65711ed6@thinkpad>
 <20160225150744.GA19707@node.shutemov.name>
 <alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
 <20160310161035.GD30716@redhat.com>
 <20160310163439.GS6356@twins.programming.kicks-ass.net>
 <20160310170406.GF30716@redhat.com>
 <20160310172249.GG30716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310172249.GG30716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Mar 10, 2016 at 06:22:49PM +0100, Andrea Arcangeli wrote:
> On Thu, Mar 10, 2016 at 06:04:06PM +0100, Andrea Arcangeli wrote:
> > that costs memory in the mm unless we're lucky with the slab hw
> > alignment), then I think synchronize_srcu may actually be preferable
> > than a full synchronize_sched that affects the entire system with
> > thousand of CPUs. A per-cpu inc wouldn't be a big deal and it would at
> > least avoid to stall for the whole system if a stall eventually has to
> > happen (unless every cpu is actually running gup_fast but that's ok in
> > such case).
> 
> Thinking more about this, it'd be ok if the pgtable freeing srcu
> context was global, no need of mess with the mm. A __percpu inside mm
> wouldn't fly anyway. With srcu we'd wait only for those CPUs that are
> effectively inside gup_fast, most of the time none or a few.

You've not looked at srcu, right? That's not going to make it faster,
not without some serious surgery.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
