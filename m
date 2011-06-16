Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D0E356B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 00:33:10 -0400 (EDT)
Received: from mail-ww0-f45.google.com (mail-ww0-f45.google.com [74.125.82.45])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5G4X6Aw028814
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 21:33:08 -0700
Received: by wwi36 with SMTP id 36so941865wwi.26
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 21:33:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de>
References: <47FAB15C-B113-40FD-9CE0-49566AACC0DF@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Jun 2011 21:32:45 -0700
Message-ID: <BANLkTimubRW2Az2MmRbgV+iTB+s6UEF5-w@mail.gmail.com>
Subject: Re: Oops in VMA code
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org List" <linux-kernel@vger.kernel.org>

On Wed, Jun 15, 2011 at 2:59 PM, Alexander Graf <agraf@suse.de> wrote:
> Hi memory management experts,
>
> I just had this crash while compiling code on my PPC G5. I was running my PPC KVM tree, which was pretty much 06e86849cf4019945a106913adb9ff0abcc01770 plus a few unrelated KVM patches. User space is 64-bit.
>
> Is this a known issue or did I hit something completely unexpected?

It doesn't look at all familiar to me, nor does google really seem to
find anything half-way related.

In fact, the only thing that that oops makes me think is that we
should get rid of that find_vma_prev() function these days (the vma
list is doubly linked since commit 297c5eee3724, and the whole "look
up prev" thing is some silly old stuff).

But that's an entirely unrelated issue.

Also, your disassembly and your gdb line lookup is apparently from
some other kernel, because the addresses don't match. The actual
running kernel actually says

  NIP [c000000000190598] .do_munmap+0x138/0x3f0

so it's do_munmap, not find_vma_prev(). Although gdb claiming
find_vma_prev() might be from some inlining issue, of course.
Regardless, it's useless for debugging - it's the do_munap()
disassembly we'd want (but I'm no longer all that fluent in ppc
assembly anyway, so ir probably wouldn't help).

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
