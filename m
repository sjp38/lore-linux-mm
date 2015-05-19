Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 686E86B00EC
	for <linux-mm@kvack.org>; Tue, 19 May 2015 19:20:46 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so132878915wic.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 16:20:46 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id cb3si22666447wjc.44.2015.05.19.16.20.44
        for <linux-mm@kvack.org>;
        Tue, 19 May 2015 16:20:45 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v4 1/3] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Date: Wed, 20 May 2015 01:46:05 +0200
Message-ID: <1526358.9aMpXL2Hv2@vostro.rjw.lan>
In-Reply-To: <CALUN=qLrXryb-aZTjXqoUhzjz68fvOae1bDxitYcJ3jBn_1EDg@mail.gmail.com>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu> <7216052.tCNGRiLFYJ@vostro.rjw.lan> <CALUN=qLrXryb-aZTjXqoUhzjz68fvOae1bDxitYcJ3jBn_1EDg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Monday, May 18, 2015 12:23:00 PM Anisse Astier wrote:
> Hi Rafael,
> 
> Thanks for taking the time to review this.
> 
> On Sat, May 16, 2015 at 2:28 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > On Thursday, May 14, 2015 04:19:46 PM Anisse Astier wrote:
> >> SANITIZE_FREED_PAGES feature relies on having all pages going through
> >> the free_pages_prepare path in order to be cleared before being used. In
> >> the hibernate use case, free pages will automagically appear in the
> >> system without being cleared, left there by the loading kernel.
> >>
> >> This patch will make sure free pages are cleared on resume; when we'll
> >> enable SANITIZE_FREED_PAGES. We free the pages just after resume because
> >> we can't do it later: going through any device resume code might
> >> allocate some memory and invalidate the free pages bitmap.
> >>
> >> Signed-off-by: Anisse Astier <anisse@astier.eu>
> >> ---
> >>  kernel/power/hibernate.c |  4 +++-
> >>  kernel/power/power.h     |  2 ++
> >>  kernel/power/snapshot.c  | 22 ++++++++++++++++++++++
> >>  3 files changed, 27 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> >> index 2329daa..0a73126 100644
> >> --- a/kernel/power/hibernate.c
> >> +++ b/kernel/power/hibernate.c
> >> @@ -305,9 +305,11 @@ static int create_image(int platform_mode)
> >>                       error);
> >>       /* Restore control flow magically appears here */
> >>       restore_processor_state();
> >> -     if (!in_suspend)
> >> +     if (!in_suspend) {
> >>               events_check_enabled = false;
> >>
> >> +             clear_free_pages();
> >
> > Again, why don't you do that at the swsusp_free() time?
> 
> Because it's too late, the kernel has already been through device
> resume code, and the free pages bitmap isn't valid anymore; device
> resume code might allocate memory, and we'd be clearing those pages as
> well.

Are we both talking about the same thing?

swsusp_free() is *the* function that, well, frees all the pages allocated
by the hibernate core, so how isn't the free pages bitmap valid when it is
called?

Why don't you add the clearing in there, right at the spot when the pages
are actually freed?

Moreover, why is the resume code path the only one where freed pages need to
be sanitized? 


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
