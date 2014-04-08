Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 618146B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 13:41:55 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id id10so1053159vcb.26
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:41:55 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id dl6si529188veb.73.2014.04.08.10.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 10:41:54 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id ld13so1050645vcb.19
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 10:41:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140408173031.GS10526@twins.programming.kicks-ass.net>
References: <1396962570-18762-1-git-send-email-mgorman@suse.de>
	<53440A5D.6050301@zytor.com>
	<CA+55aFwc6Jdf+As9RJ3wJWuOGEGmiaYWNa-jp2aCb9=ZiiqV+A@mail.gmail.com>
	<20140408164652.GL7292@suse.de>
	<20140408173031.GS10526@twins.programming.kicks-ass.net>
Date: Tue, 8 Apr 2014 10:41:54 -0700
Message-ID: <CA+55aFyAY4LrVZEZLNH8Pyxpz0ixjeBkkBbWR3fcGJ13qqRJGw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Use an alternative to _PAGE_PROTNONE for
 _PAGE_NUMA v2
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 8, 2014 at 10:30 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> Like this:
>
>   https://lkml.org/lkml/2012/11/13/431
>
> That used the generic PROT_NONE infrastructure and compared, on fault,
> the page protection bits against the vma->vm_page_prot bits?
>
> So the objection to that approach was the vma-> dereference in
> pte_numa() ?

So the important thing is that as long as it works exactly like
PROT_NONE as far as hardware (and that includes paravirtualized setups
too!) then I guess we should be ok.

But that "pte_numa()" does make me go "Hmm.. but does it?". If virtual
environments have to look at the vma in order to look at page tables,
that's not possible. They have to be able to work with the page tables
on their own, _without_ any special rules that are private to the
guest.

So I'm not seeing any *use* of pte_numa() in places that would make me
worry, though. So maybe it works.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
