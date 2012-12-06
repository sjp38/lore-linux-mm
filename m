Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C77BB6B00A7
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:51:16 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hq12so682414wib.2
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 08:51:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206161934.GA17258@suse.de>
References: <20121206091744.GA1397@polaris.bitmath.org> <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Dec 2012 08:50:54 -0800
Message-ID: <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, Henrik Rydberg <rydberg@euromail.se>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 6, 2012 at 8:19 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> Still travelling and am not in a position to test this properly :(.
> However, this bug feels very similar to a bug in the migration scanner where
> a pfn_valid check is missed because the start is not aligned.

Ugh. This patch makes my eyes bleed.

Is there no way to do this nicely in the caller? IOW, fix the
'end_pfn' logic way upstream where it is computed, and just cap it at
the MAX_ORDER_NR_PAGES boundary?

For example, isolate_freepages_range() seems to have this *other*
end-point alignment thing going on, and does it in a loop. Wouldn't it
be much better to have a separate loop that looped up to the next
MAX_ORDER_NR_PAGES boundary instead of having this kind of very random
test in the middle of a loop.

Even the name ("isolate_freepages_block") implies that we have a
"block" of pages. Having to have a random "oops, this block can have
other blocks inside of it that aren't mapped" test in the middle of
that function really makes me go "Uhh, no".

Plus, is it even guaranteed that the *first* pfn (that we get called
with) is pfnvalid to begin with?

So I guess this patch fixes things, but it does make me go "That's
really *really* ugly".

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
