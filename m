Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 34A656B0102
	for <linux-mm@kvack.org>; Wed, 20 May 2015 07:57:41 -0400 (EDT)
Received: by wibt6 with SMTP id t6so57242614wib.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 04:57:40 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id hf1si28971358wjc.22.2015.05.20.04.57.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 04:57:39 -0700 (PDT)
Received: by wichy4 with SMTP id hy4so57204645wic.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 04:57:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1526358.9aMpXL2Hv2@vostro.rjw.lan>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
 <7216052.tCNGRiLFYJ@vostro.rjw.lan> <CALUN=qLrXryb-aZTjXqoUhzjz68fvOae1bDxitYcJ3jBn_1EDg@mail.gmail.com>
 <1526358.9aMpXL2Hv2@vostro.rjw.lan>
From: Anisse Astier <anisse@astier.eu>
Date: Wed, 20 May 2015 13:57:18 +0200
Message-ID: <CALUN=qKYyzxRJNiEN9LC4YuzsQCUdJtc5-q6poGCfCg4791=gg@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, May 20, 2015 at 1:46 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> On Monday, May 18, 2015 12:23:00 PM Anisse Astier wrote:
>> Hi Rafael,
>>
>> Thanks for taking the time to review this.
>>
>> On Sat, May 16, 2015 at 2:28 AM, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
>> > On Thursday, May 14, 2015 04:19:46 PM Anisse Astier wrote:
>> >> SANITIZE_FREED_PAGES feature relies on having all pages going through
>> >> the free_pages_prepare path in order to be cleared before being used. In
>> >> the hibernate use case, free pages will automagically appear in the
>> >> system without being cleared, left there by the loading kernel.
>> >>
>> >> This patch will make sure free pages are cleared on resume; when we'll
>> >> enable SANITIZE_FREED_PAGES. We free the pages just after resume because
>> >> we can't do it later: going through any device resume code might
>> >> allocate some memory and invalidate the free pages bitmap.
>> >>
>> >> Signed-off-by: Anisse Astier <anisse@astier.eu>
>> >> ---
>> >>  kernel/power/hibernate.c |  4 +++-
>> >>  kernel/power/power.h     |  2 ++
>> >>  kernel/power/snapshot.c  | 22 ++++++++++++++++++++++
>> >>  3 files changed, 27 insertions(+), 1 deletion(-)
>> >>
>> >> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
>> >> index 2329daa..0a73126 100644
>> >> --- a/kernel/power/hibernate.c
>> >> +++ b/kernel/power/hibernate.c
>> >> @@ -305,9 +305,11 @@ static int create_image(int platform_mode)
>> >>                       error);
>> >>       /* Restore control flow magically appears here */
>> >>       restore_processor_state();
>> >> -     if (!in_suspend)
>> >> +     if (!in_suspend) {
>> >>               events_check_enabled = false;
>> >>
>> >> +             clear_free_pages();
>> >
>> > Again, why don't you do that at the swsusp_free() time?
>>
>> Because it's too late, the kernel has already been through device
>> resume code, and the free pages bitmap isn't valid anymore; device
>> resume code might allocate memory, and we'd be clearing those pages as
>> well.
>
> Are we both talking about the same thing?

I think we aren't talking about the same thing. The free_pages_map is
used for all free pages, plus the memory used for suspend (when it
intersects with forbidden_page_map).

We don't need to clear the memory in swsusp_free, because it already
calls the __free_page code path that clears free pages. What we need,
is to clear pages left by the loader kernel before it jumped into the
resumed kernel.

>
> swsusp_free() is *the* function that, well, frees all the pages allocated
> by the hibernate core, so how isn't the free pages bitmap valid when it is
> called?

Because swsusp_free will only free the intersection of free_pages_map
and forbidden_pages_map. This intersection is the set of pages used
for suspend, and they are in fact allocated, not free. The rest of
free_pages_map are the real free pages, but as I said, once we resume,
it will also include the pages left hanging by the loading kernel.

In addition, the free_pages_map contains a reference to all the free
pages at the moment of suspend, but this reference isn't valid by the
time we reach swsusp_free(), because we've been through many drivers'
resume by then, and those can allocate memory; they might even want
already zeroed memory, which they won't get because of the __GFP_ZERO
optimization in the next patch; we just expect all free pages to be
already cleared, but pages from the loading kernel aren't.

>
> Why don't you add the clearing in there, right at the spot when the pages
> are actually freed?
>
> Moreover, why is the resume code path the only one where freed pages need to
> be sanitized?

Because all pages in the system go through the page freeing path
(which clears them) when leaving the (no)bootmem allocator.

It's a bit long, so I hope that I'm clear in my explanation.

Regards,

Anisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
