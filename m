Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C4A9E6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 14:41:38 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hm4so567732wib.8
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 11:41:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508AD2FF.5020306@redhat.com>
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
 <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <CA+55aFwpZ5pO2G7gs3Pga5et1DQZ4qMoe1CLFkSrVQK_4K4rhA@mail.gmail.com>
 <508ACE6E.8060303@redhat.com> <CA+55aFyYvu20qHtJ2SuNK3Dd466Hs9m9U3_41E8HtQ6KiRVRKw@mail.gmail.com>
 <508AD2FF.5020306@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 Oct 2012 11:41:17 -0700
Message-ID: <CA+55aFy7LvPP+DAENWftMpL=H_M5Pn9mVCHiEP7YVbFHcmbVbQ@mail.gmail.com>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Fri, Oct 26, 2012 at 11:14 AM, Rik van Riel <riel@redhat.com> wrote:
>
> I suspect the next context switch would flush out the TLB,
> making it a slowdown, not a lockup.

Common case, yes. But the page fault might happen in kernel space (due
to a "put_user()" call, say), and with CONFIG_PREEMPT=n.

Sure, put_user() is always done in a context where blocking (and
scheduling) is legal, but that doesn't necessarily equate scheduling
actually happening. If we're returning to kernel space and don't have
any IO, it might never happen.

Anyway, I suspect such behavior it's almost impossible to trigger.
Which would just make it rather hard to find.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
