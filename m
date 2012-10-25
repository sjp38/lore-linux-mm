Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id D06F66B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 16:17:41 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1372039wgb.26
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 13:17:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121025124832.840241082@chello.nl>
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 25 Oct 2012 13:17:19 -0700
Message-ID: <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 5:16 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> From: Rik van Riel <riel@redhat.com>
>
> @@ -306,11 +306,26 @@ int ptep_set_access_flags(struct vm_area
>                           pte_t entry, int dirty)
>  {
>         int changed = !pte_same(*ptep, entry);
> +       /*
> +        * If the page used to be inaccessible (_PAGE_PROTNONE), or
> +        * this call upgrades the access permissions on the same page,
> +        * it is safe to skip the remote TLB flush.
> +        */
> +       bool flush_remote = false;
> +       if (!pte_accessible(*ptep))
> +               flush_remote = false;
> +       else if (pte_pfn(*ptep) != pte_pfn(entry) ||
> +                       (pte_write(*ptep) && !pte_write(entry)) ||
> +                       (pte_exec(*ptep) && !pte_exec(entry)))
> +               flush_remote = true;
>
>         if (changed && dirty) {

Did anybody ever actually look at this sh*t-for-brains patch?

Yeah, I'm grumpy. But I'm wasting time looking at patches that have
new code in them that is stupid and retarded.

This is the VM, guys, we don't add stupid and retarded code.

LOOK at the code, for chrissake. Just look at it. And if you don't see
why the above is stupid and retarded, you damn well shouldn't be
touching VM code.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
