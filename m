Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 3E31A6B00C4
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:19:57 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dq11so3313934wgb.26
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 10:19:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206175451.GC17258@suse.de>
References: <20121206091744.GA1397@polaris.bitmath.org> <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de> <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
 <20121206175451.GC17258@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Dec 2012 10:19:35 -0800
Message-ID: <CA+55aFwDZHXf2FkWugCy4DF+mPTjxvjZH87ydhE5cuFFcJ-dJg@mail.gmail.com>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, Henrik Rydberg <rydberg@euromail.se>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 6, 2012 at 9:55 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> Yeah. I was listening to a talk while I was writing it, a bit cranky and
> didn't see why I should suffer alone.

Makes sense.

> Quasimoto strikes again

Is that Quasimodo's Japanese cousin?

> -               end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
> +
> +               /*
> +                * As pfn may not start aligned, pfn+pageblock_nr_page
> +                * may cross a MAX_ORDER_NR_PAGES boundary and miss
> +                * a pfn_valid check. Ensure isolate_freepages_block()
> +                * only scans within a pageblock.
> +                */
> +               end_pfn = ALIGN(pfn + pageblock_nr_pages, pageblock_nr_pages);
> +               end_pfn = min(end_pfn, end_pfn);

Ok, this looks much nicer, except it's obviously buggy. The
min(end_pfn, end_pfn) thing is insane, and I'm sure you meant for that
line to be

+               end_pfn = min(end_pfn, zone_end_pfn);

Henrik, does that - corrected - patch (*instead* of the previous one,
not in addition to) also fix your issue?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
