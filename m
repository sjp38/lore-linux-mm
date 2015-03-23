Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 655656B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 17:26:04 -0400 (EDT)
Received: by weop45 with SMTP id p45so148502962weo.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 14:26:04 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id jj2si13642752wid.42.2015.03.23.14.26.02
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 14:26:02 -0700 (PDT)
Date: Mon, 23 Mar 2015 22:26:00 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC, PATCH] pagemap: do not leak physical addresses to
 non-privileged userspace
Message-ID: <20150323212559.GF14779@amd>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
 <20150316211122.GD11441@amd>
 <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
 <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
 <550AC636.9030406@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <550AC636.9030406@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andy Lutomirski <luto@amacapital.net>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>

On Thu 2015-03-19 13:51:02, Vlastimil Babka wrote:
> On 03/17/2015 02:21 AM, Andy Lutomirski wrote:
> > On Mon, Mar 16, 2015 at 5:49 PM, Mark Seaborn <mseaborn@chromium.org> wrote:
> >> On 16 March 2015 at 14:11, Pavel Machek <pavel@ucw.cz> wrote:
> >>
> >>> Can we do anything about that? Disabling cache flushes from userland
> >>> should make it no longer exploitable.
> >>
> >> Unfortunately there's no way to disable userland code's use of
> >> CLFLUSH, as far as I know.
> >>
> >> Maybe Intel or AMD could disable CLFLUSH via a microcode update, but
> >> they have not said whether that would be possible.
> > 
> > The Intel people I asked last week weren't confident.  For one thing,
> > I fully expect that rowhammer can be exploited using only reads and
> > writes with some clever tricks involving cache associativity.  I don't
> > think there are any fully-associative caches, although the cache
> > replacement algorithm could make the attacks interesting.
> 
> I've been thinking the same. But maybe having to evict e.g. 16-way cache would
> mean accessing 16x more lines which could reduce the frequency for a single line
> below dangerous levels. Worth trying, though :)

How many ways do recent CPU L1 caches have?

> BTW, by using clever access patterns and measurement of access latencies one
> could also possibly determine which cache lines alias/colide, without needing to
> read pagemap. It would just take longer. Hugepages make that simpler as well.
> 
> I just hope we are not going to disable lots of stuff including clflush and e.g.
> transparent hugepages just because some part of the currently sold hardware is
> vulnerable...

Well, "some part" seems to be > 50% of all machines without ECC, which
means > 50% notebooks.

If your machine is not affected, disabling clflush will not be
neccessary. But... I'd still like separate users on my machines to be
separated (I use separate acount for browsing with Flash), and Android
actually relies on that.

And if it is exploitable without clflush, that's _bad_, because it
means you can probably exploit it using Java/JavaScript from web
browser.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
