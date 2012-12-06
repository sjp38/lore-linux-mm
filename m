Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id C39878D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:41:35 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hq12so785532wib.2
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 10:41:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206183259.GA591@polaris.bitmath.org>
References: <20121206091744.GA1397@polaris.bitmath.org> <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de> <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
 <20121206175451.GC17258@suse.de> <CA+55aFwDZHXf2FkWugCy4DF+mPTjxvjZH87ydhE5cuFFcJ-dJg@mail.gmail.com>
 <20121206183259.GA591@polaris.bitmath.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Dec 2012 10:41:14 -0800
Message-ID: <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henrik Rydberg <rydberg@euromail.se>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 6, 2012 at 10:32 AM, Henrik Rydberg <rydberg@euromail.se> wrote:
>>
>> Henrik, does that - corrected - patch (*instead* of the previous one,
>> not in addition to) also fix your issue?
>
> Yes - I can no longer trigger the failpath, so it seems to work. Mel,
> enjoy the rest of the talk. ;-)
>
> Generally, I am a bit surprised that noone hit this before, given that
> it was quite easy to trigger. I will check 3.6 as well.

Actually, looking at it some more, I think that two-liner patch had
*ANOTHER* bug.

Because the other line seems buggy as well.

Instead of

        end_pfn = ALIGN(pfn + pageblock_nr_pages, pageblock_nr_pages);

I think it should be

        end_pfn = ALIGN(pfn+1, pageblock_nr_pages);

instead. ALIGN() already aligns upwards (but the "+1" is needed in
case pfn is already at a pageblock_nr_pages boundary, at which point
ALIGN() would have just returned that same boundary.

Hmm? Mel, please confirm. And Henrik, it might be good to test that
doubly-fixed patch. Because reading the patch and trying to fix bugs
in it that way is *not* the same as actually verifying it ;)

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
