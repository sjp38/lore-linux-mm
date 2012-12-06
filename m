Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id F07DC6B00D1
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 14:39:08 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dq11so3350767wgb.26
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 11:39:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206192845.GA599@polaris.bitmath.org>
References: <20121206091744.GA1397@polaris.bitmath.org> <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de> <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
 <20121206175451.GC17258@suse.de> <CA+55aFwDZHXf2FkWugCy4DF+mPTjxvjZH87ydhE5cuFFcJ-dJg@mail.gmail.com>
 <20121206183259.GA591@polaris.bitmath.org> <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
 <20121206192845.GA599@polaris.bitmath.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Dec 2012 11:38:47 -0800
Message-ID: <CA+55aFy4Lv+_aPEakOJNR2F9PR=09jviT6Z70_NkWV5bSH5ABw@mail.gmail.com>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henrik Rydberg <rydberg@euromail.se>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Ok, I've applied the patch.

Mel, some grepping shows that there is an old line that does

    end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);

which looks bogus. That should probably also use "+ 1" instead. But
I'll consider that an independent issue, so I applied the one patch
regardless.

There is also a

    low_pfn += pageblock_nr_pages;
    low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;

that looks suspicious for similar reasons. Maybe

    low_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages) - 1;

instead? Although that *can* result in the same low_pfn in the end, so
maybe that one was correct after all? I just did some grepping, no
actual semantic analysis...

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
