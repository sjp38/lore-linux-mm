Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 738C46B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 07:16:55 -0400 (EDT)
Received: by wetk59 with SMTP id k59so4965462wet.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 04:16:55 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id ef7si2705879wib.34.2015.03.17.04.16.54
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 04:16:54 -0700 (PDT)
Date: Tue, 17 Mar 2015 12:16:53 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: rowhammer and pagemap (was Re: [RFC, PATCH] pagemap: do not leak
 physical addresses to non-privileged userspace)
Message-ID: <20150317111653.GA23711@amd>
References: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
 <20150316211122.GD11441@amd>
 <CAL82V5O6awBrpj8uf2_cEREzZWPfjLfqPtRbHEd5_zTkRLU8Sg@mail.gmail.com>
 <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU8SeOTSexLOi36sX7Smwfv0baraK=A3hq8twoyBN7NBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>



> > Given that, I think it would still be worthwhile to disable /proc/PID/pagemap.
> 
> Having slept on this further, I think that unprivileged pagemap access
> is awful and we should disable it with no option to re-enable.  If we
> absolutely must, we could allow programs to read all zeros or to read
> addresses that are severely scrambled (e.g. ECB-encrypted by a key
> generated once per open of pagemap).

>  - It could easily leak direct-map addresses, and there's a nice paper
> detailing a SMAP bypass using that technique.

Do you have a pointer?

> Can we just try getting rid of it except with global CAP_SYS_ADMIN.
> 
> (Hmm.  Rowhammer attacks targeting SMRAM could be interesting.)

:-).

> >> Can we do anything about that? Disabling cache flushes from userland
> >> should make it no longer exploitable.
> >
> > Unfortunately there's no way to disable userland code's use of
> > CLFLUSH, as far as I know.
> >
> > Maybe Intel or AMD could disable CLFLUSH via a microcode update, but
> > they have not said whether that would be possible.
> 
> The Intel people I asked last week weren't confident.  For one thing,
> I fully expect that rowhammer can be exploited using only reads and
> writes with some clever tricks involving cache associativity.  I don't
> think there are any fully-associative caches, although the cache
> replacement algorithm could make the attacks interesting.

We should definitely get Intel/AMD to disable CLFLUSH, then.

Because if it can be exploited using reads, it is _extremely_
important to know. As it probably means rowhammer can be exploited
using Javascript / Java... and affected machines are unsafe even
without remote users.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
