Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFA36B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 13:42:30 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so20417010ieb.4
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 10:42:30 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id ko3si8357263icc.101.2015.03.07.10.42.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Mar 2015 10:42:30 -0800 (PST)
Received: by igbhn18 with SMTP id hn18so11605639igb.2
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 10:42:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwSQgrYqfXPr6RPvQ+8OJfexXJRY_GVEKg5QtB2t38cWA@mail.gmail.com>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-4-git-send-email-mgorman@suse.de>
	<CA+55aFwSQgrYqfXPr6RPvQ+8OJfexXJRY_GVEKg5QtB2t38cWA@mail.gmail.com>
Date: Sat, 7 Mar 2015 10:42:29 -0800
Message-ID: <CA+55aFxwmysVRCkBKFA88m_h0Byb0-2QvWn0_2rb_QNb8Eeedg@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: numa: Mark huge PTEs young when clearing NUMA
 hinting faults
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, Mar 7, 2015 at 10:33 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>             Completely untested, but that "just
> or in the new protection bits" is what pnf_pte() does just a few lines
> above this.

Hmm. Looking at this, we do *not* want to set _PAGE_ACCESSED when we
turn a page into PROT_NONE or mark it for numa faulting. Nor do we
want to set it for mprotect for random pages that we haven't actually
accessed, just changed the protections for.

So my patch was obviously wrong, and I should feel bad for suggesting
it. I'm a moron, and my expectations that "pte_modify()" would just
take the accessed bit from the vm_page_prot field was stupid and
wrong.

Mel's patch is the right thing to do.

                                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
