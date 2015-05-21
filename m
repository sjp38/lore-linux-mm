Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D39DA6B0145
	for <linux-mm@kvack.org>; Wed, 20 May 2015 20:45:51 -0400 (EDT)
Received: by wghq2 with SMTP id q2so69453137wgh.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 17:45:51 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id ha1si103265wib.100.2015.05.20.17.45.49
        for <linux-mm@kvack.org>;
        Wed, 20 May 2015 17:45:50 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v4 1/3] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Date: Thu, 21 May 2015 03:11:12 +0200
Message-ID: <4282804.3atZjAcjTt@vostro.rjw.lan>
In-Reply-To: <CALUN=q+0mUTeJKE0OV8Bkny33M2Psdp4U5dF3vBcyo+mxNb-Nw@mail.gmail.com>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu> <555C73E7.23237.269170A5@pageexec.freemail.hu> <CALUN=q+0mUTeJKE0OV8Bkny33M2Psdp4U5dF3vBcyo+mxNb-Nw@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: PaX Team <pageexec@freemail.hu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wednesday, May 20, 2015 02:07:36 PM Anisse Astier wrote:
> On Wed, May 20, 2015 at 1:45 PM, PaX Team <pageexec@freemail.hu> wrote:
> >
> >> Moreover, why is the resume code path the only one where freed pages need to
> >> be sanitized?
> >
> > ... i had a bug report before (http://marc.info/?l=linux-pm&m=132871433416256)
> > which is why i asked Anisse to figure this out before upstreaming the feature.
> > i've also asked him already to explain why his approach is the proper fix for
> > the problem (which should include the description of the root cause as a start)
> > but he hasn't answered that yet.
> >
> > anyway, the big question is how there can be free memory pages after resume
> > which are not sanitized. now i have no idea about the hibernation logic but
> > i assume that it doesn't save/restore free pages so the question is how the
> > kernel gets to learn about these free pages during resume and whether there's
> > a path where __free_page() or some other wrapper around free_pages_prepare()
> > doesn't get called at all.
> 
> In my opinion the free pages left are those used by the loading kernel.

Well, that is not a matter of opinion really, but it's actually correct.

> If I understand correctly, a suspend (hibernate) image contains *all*
> the memory necessary for the OS to work; so when you restore it, you
> restore it all, page tables, and kernel code section included. So when
> the kernel does a hibernate restoration, it loads it all the pages
> into memory, then architecture-specific code will jump into the new
> "resumed" kernel by restoring page table entries and CPU context. When
> it does that, it leaves the "loader" kernel memory hanging; this
> memory is seen as free pages by the resumed kernel, but it isn't
> cleared.

Correct, except that some of the boot kernel's memory will be overwritten
by the image kernel and all.

> Rafael, am I getting something wrong on the hibernation resume process
> ? What do you think of this analysis ?

That's more-or-less what's happening.  IOW, after hibernation and resume you
may see stuff in pages that were previously all zeros as long as they are
regarded as free by the image kernel.  The stuff in there is all garbage from
its perspective though.


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
