Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id DECCA6B003B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 20:51:41 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id bn7so7409062ieb.9
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 17:51:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1303261646070.23041@eggly.anvils>
References: <alpine.LNX.2.00.1303261646070.23041@eggly.anvils>
Date: Tue, 26 Mar 2013 17:51:40 -0700
Message-ID: <CANN689HuK7773-B3NOxLN9xRRXY=5i1j5Sv_CT8WKChMRw5_Aw@mail.gmail.com>
Subject: Re: Revert VM_POPULATE?
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 26, 2013 at 5:26 PM, Hugh Dickins <hughd@google.com> wrote:
> Michel, I propose that we revert 3.9-rc1's VM_POPULATE flag - 186930500985
> "mm: introduce VM_POPULATE flag to better deal with racy userspace programs".
>
> Konstantin's 3.7 cleanup of VM_flags has left several bits below 32
> free, but sooner or later someone will want to come through again and
> free some more, and I think VM_POPULATE will be among the first to go.
>
> It just doesn't add much value, and flags a transient condition which
> then sticks around indefinitely.  Better we remove it now than later.
>
> You said yourself in the 0/8 or 1/8:
>     - Patch 8 is optional to this entire series. It only helps to deal more
>       nicely with racy userspace programs that might modify their mappings
>       while we're trying to populate them. It adds a new VM_POPULATE flag
>       on the mappings we do want to populate, so that if userspace replaces
>       them with mappings it doesn't want populated, mm_populate() won't
>       populate those replacement mappings.
> when you were just testing the waters with 8/8 to see if it was wanted.
>
> I don't see any serious problem with it.  We can probably contrive
> a case in which someone mlocks-then-munlocks scattered segments of a
> large vma, and the VM_POPULATE flag left behind prevents the segments
> from being merged back into a single vma; but that can happen in other
> ways, so it doesn't count for much.
>
> (I presume VM_POPULATE is left uncleared, because there could always be
> races when it's cleared too soon - if userspace is racing with itself.)

Yes, VM_POPULATE is never cleared.

> I just don't see VM_POPLULATE solving any real problem: the kernel code
> appears to be safe enough without it, and if userspace wishes to play
> racing mmap games, oh, just let it.

All right. I have no major objections - the kernel will be fine
without VM_POPULATE, and the only downside of removing it is that we
might do more work to populate new mappings if userspace plays games,
as you say, unmapping and remapping vmas before the original mmap call
that created it returns (or while an mlock call that operates on it is
running). I don't care strongly about kernel behavior in such cases as
long as it doesn't affect other processes, so I'm OK with reverting
VM_POPULATE as long as others agree.

I'll send out a code review to do that.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
