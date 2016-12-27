Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9FEF6B0069
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 15:17:35 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so285329069itb.3
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 12:17:35 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id l74si29341161ita.30.2016.12.27.12.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 12:17:35 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id n68so34398490itn.3
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 12:17:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyXXKdjbidzVC=waiaAaUJpwqZQZv-kKoZfaiWtYy3z=A@mail.gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com> <20161225030030.23219-3-npiggin@gmail.com>
 <CA+55aFzqgtz-782MmLOjQ2A2nB5YVyLAvveo6G_c85jqqGDA0Q@mail.gmail.com>
 <20161226111654.76ab0957@roar.ozlabs.ibm.com> <CA+55aFz1n_JSTc_u=t9Qgafk2JaffrhPAwMLn_Dr-L9UKxqHMg@mail.gmail.com>
 <20161227211946.3770b6ce@roar.ozlabs.ibm.com> <CA+55aFw22e6njM9L4sareRRJw3RjW9XwGH3B7p-ND86EtTWWDQ@mail.gmail.com>
 <CA+55aFzKuiLS0CvTTqo5=8eyoksC1==30+XMiXZhQqzXr9JM3A@mail.gmail.com>
 <CA+55aFzNU53+9PT_xzrPRYdbUYP6V4Y52wCo8V_tANB0tLStnw@mail.gmail.com> <CA+55aFyXXKdjbidzVC=waiaAaUJpwqZQZv-kKoZfaiWtYy3z=A@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 27 Dec 2016 12:17:34 -0800
Message-ID: <CA+55aFwjcEmtWjNXhugX3GfH0zvypLVi0r90PWL3DCD-jA4v5Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for
 a page bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

On Tue, Dec 27, 2016 at 11:40 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> This patch at least might have a chance in hell of working. Let's see..

Ok, with that fixed, things do indeed seem to work.

And things also look fairly good on my "lots of nasty little
shortlived scripts" benchmark ("make -j32 test" for git, in case
people care).

That benchmark used to have "unlock_page()" and "__wake_up_bit()"
together using about 3% of all CPU time.

Now __wake_up_bit() doesn't show up at all (ok, it's something like
0.02%, so it's technically still there, but..) and "unlock_page()" is
at 0.66% of CPU time. So it's about a quarter of where it used to be.
And now it's about the same cost as the "try_lock_page() that is
inlined into filemap_map_pages() - it used to be that unlocking the
page was much more expensive than locking it because of all the
unnecessary waitqueue games.

So the benchmark still does a ton of page lock/unlock action, but it
doesn't stand out in the profiles as some kind of WTF thing any more.
And the profiles really show that the cost is the atomic op itself
rather than bad effects from bad code generation, which is what you
want to see.

Would I love to fix this all by not taking the page lock at all? Yes I
would. I suspect we should be able to do something clever and lockless
at least in theory.

But in the meantime, I'm happy with where our page locking overhead
is. And while I haven't seen the NUMA numbers from Dave Hansen with
this all, the early testing from Dave was that the original patch from
Nick already fixed the regression and was the fastest one anyway. And
this optimization will only have improved on things further, although
it might not be as noticeable on NUMA as it is on just a regular
single socket system.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
