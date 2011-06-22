Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F12C0900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:39:49 -0400 (EDT)
Message-ID: <4E020CBC.7070604@redhat.com>
Date: Wed, 22 Jun 2011 11:39:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <4E01C752.10405@redhat.com> <4E01CC77.10607@ravellosystems.com> <4E01CDAD.3070202@redhat.com> <4E01CFD2.6000404@ravellosystems.com>
In-Reply-To: <4E01CFD2.6000404@ravellosystems.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: Avi Kivity <avi@redhat.com>, nai.xia@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 06/22/2011 07:19 AM, Izik Eidus wrote:

> So what we say here is: it is better to have little junk in the unstable
> tree that get flushed eventualy anyway, instead of make the guest
> slower....
> this race is something that does not reflect accurate of ksm anyway due
> to the full memcmp that we will eventualy perform...

With 2MB pages, I am not convinced they will get "flushed eventually",
because there is a good chance at least one of the 4kB pages inside
a 2MB page is in active use at all times.

I worry that the proposed changes may end up effectively preventing
KSM from scanning inside 2MB pages, when even one 4kB page inside
is in active use.  This could mean increased swapping on systems
that run low on memory, which can be a much larger performance penalty
than ksmd CPU use.

We need to scan inside 2MB pages when memory runs low, regardless
of the accessed or dirty bits.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
