Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA776B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 16:10:58 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id j1so4841410ywj.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 13:10:58 -0800 (PST)
Received: from ns.sciencehorizons.net (ns.sciencehorizons.net. [71.41.210.147])
        by mx.google.com with SMTP id k28si16268907ybj.327.2017.01.05.13.10.57
        for <linux-mm@kvack.org>;
        Thu, 05 Jan 2017 13:10:57 -0800 (PST)
Date: 5 Jan 2017 16:10:56 -0500
Message-ID: <20170105211056.18340.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: A use case for MAP_COPY
In-Reply-To: <CA+55aFyNFb7Ns7O2yjWsKZHOEzgGkyVznp=kLRE9an-mEUC0BQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@sciencehorizons.net, torvalds@linux-foundation.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mgorman@techsingularity.net, riel@surriel.com

Linus Torvalds wrote:
> On Wed, Jan 4, 2017 at 10:37 PM, George Spelvin
> <linux@sciencehorizons.net> wrote:
> Back in 2001, Linus had some very negative things to say about MAP_COPY.
>> I'm going to try to change that opinion.

> Not going to happen.

Really?  Because the rest of your response is a lot more encouraging.

> Basically, the way you can change that opinion is if you can show some
> clever zero-cost versioning model that "just work".  With an actual
> patch.

That's the response I was hoping for!  That's a change from "it's a
stupid idea and crazily impractical" to "I seriously doubt it can be done
cheap enough."

> And without it being zero cost to all the _real_ users, I'm not adding
> a MAP_COPY that absolutely nobody will ever use because it's not
> standard, and it's not useful enough to them.

FWIW, I was writing some code and wishing for some semantics like this,
which is what led me to learn about MAP_COPY and all that.

I have a big config file full of strings, which I parse and index.
The vast majority of them contain no metacharacters, and I thought I
could just cache a (ptr, len) into the mapped config file, and save a
lot of allocation and copying.  But someone could put a metacharacter
into the file after I parse it.

Would that constitute a security problem?  Damn it, now I have to do a
much more complex analysis.  Moan, bitch, grumble, whinge, "there ought
to be a way."  And this idea popped out.

The thing is, TOCTTOU is a well-known security problem.  We already have
custom interfaces in the kernel specifically to address this issue.
So it seemed possible that this might be of broader interest.

> We've had a history of failed clever interfaces that end up being very
> painful to maintain (splice() being the most obvious one, but we've
> had a numebr of filesystem innovations that just didn't work either,
> devfs being the most spectacularly bad one).

Absolutely.  That's why I wanted to float the idea before I did a ton
of implementation work and got emotionally attached to the result.

> But the hard part is for all *other* users that might write to the
> page now need to do the cow for somebody else. So it basically
> requires a per-page count (possibly just flag) of "this has a copy
> mapping", along with everybody who might write to it that currently
> just get a ref to the page to check it, and do the rmap thing etc.

Yes, that's the same thing I identified as the unsolved hard part.
I'm going to need to go away and study dark MM lore for a while.

I agree the implementation may run into trouble, but "now we're just
haggling over the price".  That's a big difference from the *idea*
being stupid because no possible implementation is practical.

The nice thing is that I don't care very much how expensive the COW is.
It's Not Supposed To Happen unless there's a legitimate race condition
bug or an illegtimate race condition explot.  It just has to be less of
a DoS attack than MAP_DENYWRITE.

Thank you very much for your insights into the implementation
practicalities.  I'll direct more detailed discussions to people
like Rik, Mel and Kirill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
