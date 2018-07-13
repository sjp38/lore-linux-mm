Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 252816B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 13:26:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k15-v6so5845847wrq.1
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 10:26:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 14-v6sor1319160wmv.82.2018.07.13.10.26.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 10:26:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180713100519.pn7ium7a4ga24dys@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-6-git-send-email-joro@8bytes.org> <BEEA447A-26A1-49C9-925A-63F96E9115B0@amacapital.net>
 <20180713100519.pn7ium7a4ga24dys@8bytes.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 13 Jul 2018 10:26:30 -0700
Message-ID: <CALCETrWD7jhBarEr7r0iCN_Z8A2GvsE7VUi_4OVkQWwg8U516w@mail.gmail.com>
Subject: Re: [PATCH 05/39] x86/entry/32: Unshare NMI return path
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Fri, Jul 13, 2018 at 3:05 AM, Joerg Roedel <joro@8bytes.org> wrote:
> On Thu, Jul 12, 2018 at 01:53:19PM -0700, Andy Lutomirski wrote:
>> > On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> > NMI will no longer use most of the shared return path,
>> > because NMI needs special handling when the CR3 switches for
>> > PTI are added.
>>
>> Why?  What would go wrong?
>>
>> How many return-to-usermode paths will we have?  64-bit has only one.
>
> In the non-NMI return path we make a decission on whether we return to
> user-space or kernel-space and do different things based on that. For
> example, when returning to user-space we call
> prepare_exit_to_usermode(). With the CR3 switches added later we also
> unconditionally switch to user-cr3 when we are in the return-to-user
> path.
>
> The NMI return path does not need any of that, as it doesn't call
> prepare_exit_to_usermode() even when it returns to user-space. It
> doesn't even care where it returns to. It just remembers stack and cr3
> on entry in callee-safed registers and restores that on exit. This works
> in the NMI path because it is pretty simple and doesn't do any fancy
> work on exit.
>
> While working on a previous version I also tried to store stack and cr3
> in a callee-safed register and restore that on exit again, but it didn't
> work, most likley because something in-between overwrote one of the
> registers. I also found it a bit fragile to make make two registers
> untouchable in the whole entry-code. It doesn't make future changes
> simpler or more robust.
>
> So long story short, the NMI path can be simpler wrt. stack and cr3
> handling as the other entry/exit points, and therefore it is handled
> differently.
>
>

We used to do it this way on 64-bit, but I had to change it because of
a nasty case where we *fail* the return to user mode when we're
returning from an NMI.  In theory this can't happen any more due to a
bunch of tightening up of the way we handle segmentation, but it's
still quite nasty.  The whole situation on 32-bit isn't quite as
fragile because espfix32 is much more robust than espfix64.

So I suppose this is okay, but I wouldn't be totally shocked if we
need to redo it down the road.
