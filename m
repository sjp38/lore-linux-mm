Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFFA6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 17:23:45 -0500 (EST)
Received: by iaek3 with SMTP id k3so10485978iae.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 14:23:43 -0800 (PST)
Date: Mon, 21 Nov 2011 14:23:32 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: use FAULT_FLAG_ALLOW_RETRY in breaking COW
In-Reply-To: <CAJd=RBBa-ZoZ3GhYQ-aM=TJ9Zw6ZSu177PWw+s8+zyFnzyUV_w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1111211413460.1879@sister.anvils>
References: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com> <alpine.LSU.2.00.1111201923330.1806@sister.anvils> <CAJd=RBBa-ZoZ3GhYQ-aM=TJ9Zw6ZSu177PWw+s8+zyFnzyUV_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Mon, 21 Nov 2011, Hillf Danton wrote:
> On Mon, Nov 21, 2011 at 12:16 PM, Hugh Dickins <hughd@google.com> wrote:
> 
> After reading your reply and the comments in break_ksm(), if the patch does
> not mess up
> 	"The important thing is to not let VM_MERGEABLE be cleared while any
> 	 such pages might remain in the area",
> and
> 	"because handle_mm_fault() may back out if there's
> 	 any difficulty e.g. if pte accessed bit gets updated concurrently",
> 
> then if the path in which lock_page_or_retry() is called is not involved,
> mmap_sem is not upped, so the patch has nearly same behavior with break_ksm.
> 
> And the overhead of the patch, I think, could match break_ksm.
> 
> With dozen cases of writers of mmap_sem in the mm directory, the patch looks
> more flexible in rare and rare corners.

But what's the point in enlarging the kernel, adding code to make
break_cow() look more complicated, when there's no way in which the
addition can make an improvement?

Adding in a FAULT_FLAG_ALLOW_RETRY flag is not enough for mmap_sem
to be dropped for retry: you'd need a lock_page_or_retry() on the
faulting path and I do not see that here - please point it out to
me if you can see it.

(And I'll be somewhat sceptical if you respond with patches adding
lock_page_or_retry() all over, in order to meet this objection!)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
