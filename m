Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 354466B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:47:26 -0500 (EST)
Received: by wwf10 with SMTP id 10so8296250wwf.26
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:47:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1111201923330.1806@sister.anvils>
References: <CAJd=RBDP_z68Ewvw_O_dMxOnE0=weXqt+1FQy85_n76HAEdFHg@mail.gmail.com>
	<alpine.LSU.2.00.1111201923330.1806@sister.anvils>
Date: Mon, 21 Nov 2011 21:47:22 +0800
Message-ID: <CAJd=RBBa-ZoZ3GhYQ-aM=TJ9Zw6ZSu177PWw+s8+zyFnzyUV_w@mail.gmail.com>
Subject: Re: [PATCH] ksm: use FAULT_FLAG_ALLOW_RETRY in breaking COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michel Lespinasse <walken@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Mon, Nov 21, 2011 at 12:16 PM, Hugh Dickins <hughd@google.com> wrote:
> On Sat, 19 Nov 2011, Hillf Danton wrote:
>
>> The flag, FAULT_FLAG_ALLOW_RETRY, was introduced by the patch,
>>
>> =C2=A0 =C2=A0 =C2=A0 mm: retry page fault when blocking on disk transfer
>> =C2=A0 =C2=A0 =C2=A0 commit: d065bd810b6deb67d4897a14bfe21f8eb526ba99
>>
>> for reducing mmap_sem hold times that are caused by waiting for disk
>> transfers when accessing file mapped VMAs.
>>
>> To break COW, handle_mm_fault() is repeated with mmap_sem held, where
>> the introduced flag could be used again.
>>
>> The straight way is to add changes in break_ksm(), but the function coul=
d be
>> under write-mode mmap_sem, so it has to be dupilcated.
>>
>> Signed-off-by: Hillf Danton <dhillf@gmail.com>
>
> Thank you for making the patch; but unless I'm mistaken - please
> correct me if so - I think it's better to keep break_cow() simple
> than add special FAULT_FLAG_ALLOW_RETRY handling there. =C2=A0Do you
> have any evidence that its down_read of mmap_sem is a problem in
> some workload? =C2=A0I sense that you're using it "because it's there".
>
> I'm sceptical on several grounds.
>
> One, break_cow() is itself only called on an "error" path: not
> really an error, but when KSM's bet that it can merge pages turns
> out to be wrong before it can complete the merge; not a rare case,
> but not on the hot path.
>
> Two, break_ksm()'s loop is required for correctness, but it
> is a rare case that it actually needs to go round a second time.
> The typical case it's needed (am I forgetting a more common one?)
> is when userspace access flips a pte bit in between handle_pte_fault()
> noting faulting pte, and the chosen fault handler checking pte_same()
> before committing to its action. =C2=A0With the page marked PageKsm, yet
> not in the stable tree, even page reclaim is unable to interfere.
>
> Three, FAULT_FLAG_ALLOW_RETRY is acted upon only in lock_page_or_retry(),
> which is called only from filemap_fault() (not the case here since we
> don't consider file pages for conversion to PageKsm) or do_swap_page();
> yet the fault we're provoking would be handled by do_wp_page().
>
> Four, lock_page_or_retry() is called in those places when there's a
> possibility that the page is being read in from disk, to drop the
> mmap_sem across the slow I/O. =C2=A0There is no precedent for dropping
> mmap_sem here while allocating a new page, nor when pte_same() fails:
> in the former case it could only be a win when the system is already
> slowed by memory pressure, in the latter case there's little point,
> since mmap_sem would be reacquired in a moment.
>
> I think that amounts to a genial Nack!
>
Hello Hugh,

After reading your reply and the comments in break_ksm(), if the patch does
not mess up
	"The important thing is to not let VM_MERGEABLE be cleared while any
	 such pages might remain in the area",
and
	"because handle_mm_fault() may back out if there's
	 any difficulty e.g. if pte accessed bit gets updated concurrently",

then if the path in which lock_page_or_retry() is called is not involved,
mmap_sem is not upped, so the patch has nearly same behavior with break_ksm=
.

And the overhead of the patch, I think, could match break_ksm.

With dozen cases of writers of mmap_sem in the mm directory, the patch look=
s
more flexible in rare and rare corners.

Best regards
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
