Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DC0DE6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 11:32:03 -0400 (EDT)
Received: from mail-yw0-f41.google.com (mail-yw0-f41.google.com [209.85.213.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o91FVTsJ020548
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 08:31:30 -0700
Received: by ywl5 with SMTP id 5so1475816ywl.14
        for <linux-mm@kvack.org>; Fri, 01 Oct 2010 08:31:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1285909484-30958-3-git-send-email-walken@google.com>
References: <1285909484-30958-1-git-send-email-walken@google.com> <1285909484-30958-3-git-send-email-walken@google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 1 Oct 2010 08:31:01 -0700
Message-ID: <AANLkTinGgZC7eHW_Q-aR5Vmur4yjv_kKSJ8z3MX60e-r@mail.gmail.com>
Subject: Re: [PATCH 2/2] Release mmap_sem when page fault blocks on disk transfer.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

I have nothing against the 1/2 patch, it seems nice regardless.

This one is really messy, though. I think you're making the code much
less readable (and it's not wonderful to start with). That's
unacceptable.

On Thu, Sep 30, 2010 at 10:04 PM, Michel Lespinasse <walken@google.com> wro=
te:
> =A0 =A0 =A0 =A0int fault;
> + =A0 =A0 =A0 unsigned int release_flag =3D FAULT_FLAG_RELEASE;

Try this with just "flag", and make it look something like

   unsigned int flag;

   flag =3D FAULT_FLAG_RELEASE | (write ? FAULT_FLAG_WRITE : 0);

and just keep the whole mm_handle_fault() flags value in there. That
avoids one ugly/complex line, and makes it much easier to add other
flags if we ever do.

Also, I think the "RELEASE" naming is too much about the
implementation, not about the context. I think it would be more
sensible to call it "ALLOW_RETRY" or "ATOMIC" or something like this,
and not make it about releasing the page lock so much as about what
you want to happen.

Because quite frankly, I could imagine other reasons to allow page fault re=
try.

(Similarly, I would rename VM_FAULT_RELEASED to VM_FAULT_RETRY. Again:
name things for the _concept_, not for some odd implementation issue)

> - =A0 =A0 =A0 if (fault & VM_FAULT_MAJOR) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk->maj_flt++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ=
, 1, 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
regs, address);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk->min_flt++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN=
, 1, 0,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
regs, address);
> + =A0 =A0 =A0 if (release_flag) { =A0 =A0 /* Did not go through a retry *=
/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fault & VM_FAULT_MAJOR) {

I really don't know if this is correct. What if you have two major
faults due to the retry? What if the first one is a minor fault, but
when we retry it's a major fault because the page got released? The
nesting of the conditionals doesn't seem to make conceptual sense.

I dunno. I can see what you're doing ("only do statistics for the
first return"), but at the same time it just feels a bit icky.

> - =A0 =A0 =A0 lock_page(page);
> + =A0 =A0 =A0 /* Lock the page. */
> + =A0 =A0 =A0 if (!trylock_page(page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(vmf->flags & FAULT_FLAG_RELEASE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __lock_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Caller passed FAULT_FL=
AG_RELEASE flag.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This indicates it has =
read-acquired mmap_sem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and requests that it b=
e released if we have to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* wait for the page to b=
e transferred from disk.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Caller will then retry=
 starting with the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mmap_sem read-acquire.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_read(&vma->vm_mm->mmap_s=
em);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_on_page_locked(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret | VM_FAULT_RELEA=
SED;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }

I'd much rather see this abstracted out (preferably together with the
"did it get truncated" logic) into a small helper function of its own.
The main reason I say that is because I hate your propensity for
putting the comments deep inside the code. I think any code that needs
big comments at a deep indentation is fundamentally flawed.

You had the same thing in the x86 fault path. I really think it's
wrong. Needing a comment _inside_ a conditional is just nasty. You
shouldn't explain what just happened, you should explain what is
_going_ to happen, an why you do a test in the first place.

But on the whole I think that if the implementation didn't raise my
hackles so badly, I think the concept looks fine.

                                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
