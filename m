Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 44E1B6B00FE
	for <linux-mm@kvack.org>; Wed, 20 May 2015 07:48:03 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so70110560lab.2
        for <linux-mm@kvack.org>; Wed, 20 May 2015 04:48:02 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id e8si11016635lah.96.2015.05.20.04.48.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 May 2015 04:48:01 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Wed, 20 May 2015 13:45:43 +0200
MIME-Version: 1.0
Subject: Re: [PATCH v4 1/3] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Reply-to: pageexec@freemail.hu
Message-ID: <555C73E7.23237.269170A5@pageexec.freemail.hu>
In-reply-to: <1526358.9aMpXL2Hv2@vostro.rjw.lan>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>, <CALUN=qLrXryb-aZTjXqoUhzjz68fvOae1bDxitYcJ3jBn_1EDg@mail.gmail.com>, <1526358.9aMpXL2Hv2@vostro.rjw.lan>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 20 May 2015 at 1:46, Rafael J. Wysocki wrote:

> swsusp_free() is *the* function that, well, frees all the pages allocated
> by the hibernate core, so how isn't the free pages bitmap valid when it is
> called?
> 
> Why don't you add the clearing in there, right at the spot when the pages
> are actually freed?

actually swsusp_free uses __free_page which in turn will go through the
page sanitization logic so there's no need for extra sanitization. that
said ...

> Moreover, why is the resume code path the only one where freed pages need to
> be sanitized? 

... i had a bug report before (http://marc.info/?l=linux-pm&m=132871433416256)
which is why i asked Anisse to figure this out before upstreaming the feature.
i've also asked him already to explain why his approach is the proper fix for
the problem (which should include the description of the root cause as a start)
but he hasn't answered that yet.

anyway, the big question is how there can be free memory pages after resume
which are not sanitized. now i have no idea about the hibernation logic but
i assume that it doesn't save/restore free pages so the question is how the
kernel gets to learn about these free pages during resume and whether there's
a path where __free_page() or some other wrapper around free_pages_prepare()
doesn't get called at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
