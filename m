Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA8B6B00D2
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 13:04:16 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id wz7so3968319pbc.24
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 10:04:15 -0700 (PDT)
Received: from psmtp.com ([74.125.245.115])
        by mx.google.com with SMTP id hi3si12231194pbb.3.2013.10.22.10.04.13
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 10:04:14 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id cm18so3543855qab.10
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 10:04:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzwRoM4w8mGqSeeVuDGhQgnnomu=vxoWC6dbHD9w-9A+Q@mail.gmail.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
	<20131022154802.GA25490@localhost>
	<CA+55aFzwRoM4w8mGqSeeVuDGhQgnnomu=vxoWC6dbHD9w-9A+Q@mail.gmail.com>
Date: Tue, 22 Oct 2013 10:04:12 -0700
Message-ID: <CANN689EyWqCsr2rDBtHohMYwXG81dny+iQBKSt4AWqjEWnUkow@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm,vdso: preallocate new vmas
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Oct 22, 2013 at 9:20 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Oct 22, 2013 at 4:48 PM,  <walken@google.com> wrote:
>> Generally the problems I see with mmap_sem are related to long latency
>> operations. Specifically, the mmap_sem write side is currently held
>> during the entire munmap operation, which iterates over user pages to
>> free them, and can take hundreds of milliseconds for large VMAs.
>
> So this would be the *perfect* place to just downgrade the semaphore
> from a write to a read.

It's not as simple as that, because we currently rely on mmap_sem
write side being held during page table teardown in order to exclude
things like follow_page() which may otherwise access page tables while
we are potentially freeing them.

I do think it's solvable, but it gets complicated fast. Hugh & I have
been talking about it; the approach I'm looking at would involve
unwiring the page tables first (under protection of the mmap_sem write
lock) and then iterating on the unwired page tables to free the data
pages, issue TLB shootdowns and free the actual page tables (we
probably don't need even the mmap_sem read side at that point). But,
that's nowhere like a 10 line change anymore at that point...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
