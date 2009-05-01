Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 175B76B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 16:18:28 -0400 (EDT)
Date: Fri, 1 May 2009 13:17:48 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-ID: <20090501201748.GH25905@eskimo.com>
References: <20090429114708.66114c03@cuia.bos.redhat.com> <20090430072057.GA4663@eskimo.com> <20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com> <20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com> <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <2c0942db0905011104u4e6df9ap9d95fa30b1284294@mail.gmail.com> <49FB4EBB.3030404@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49FB4EBB.3030404@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, Andrew Morton <akpm@linux-foundation.org>, elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 03:34:19PM -0400, Rik van Riel wrote:
> Ray Lee wrote:
>
>> Said way #3: We desktop users really want a way to say "Please don't
>> page my executables out when I'm running a system with 3gig of RAM." I
>> hate knobs, but I'm willing to beg for one in this case. 'cause
>> mlock()ing my entire working set into RAM seems pretty silly.
>>
>> Does any of that make sense, or am I talking out of an inappropriate orifice?
>
> The "don't page my executables out" part makes sense.
>
> However, I believe that kind of behaviour should be the
> default.  Desktops and servers alike have a few different
> kinds of data in the page cache:
> 1) pages that have been frequently accessed at some point
>    in the past and got promoted to the active list
> 2) streaming IO
>
> I believe that we want to give (1) absolute protection from
> (2), provided there are not too many pages on the active file
> list.  That way we will provide executables, cached indirect
> and inode blocks, etc. from streaming IO.
>
> Pages that are new to the page cache start on the inactive
> list.  Only if they get accessed twice while on that list,
> they get promoted to the active list.
>
> Streaming IO should normally be evicted from memory before
> it can get accessed again.  This means those pages do not
> get promoted to the active list and the working set is
> protected.
>
> Does this make sense?

I think this is a simplistic view of things.

Keep in mind that the goal of a VM is: "load each page before it's needed."
LRU, use-once heuristics, and the like are ways of trying to guess when a page
is needed and when it isn't, because you don't know the future.

For high throughput, treating all pages equally (or with some simple weighting)
is often appropriate, because it allows you to balance various sorts of working
sets dynamically.

But user interfaces are a realtime problem.  When the user presses a button,
you have a deadline to respond before it's annoying, and another deadline
before the user will hit the power button.  With this in mind, the user's
application UI has essentially infinite priority for memory -- it's either
paged into ram before the user presses a button, or you fail.

Very often, this is just a case of streaming IO vs. everything else, in which
case detecting streaming IO (because of the usage pattern) will help.  That's a
pretty simple case.  But imagine I start up a big compute job in the background
-- for example, I run a video encoder or something similar, and this program
touches the source data many times, such that it does not appear to be
"streaming" by a simple heuristic.

Particularly if I walk away from the computer, from any algorithm just based on
recent usage, this will appear to be the only thing worth doing at that time,
so the UI will be paged out.  And of course, when I walk back to the computer
and press a button, the UI will not respond, and will have shocking latency
until I've touched every bit of it that I use again.

That's a bad outcome.  User interactivity is a real-time problem, and your
deadline is less than 30 disk seeks.

Of course, if the bulk job completes dramatically faster with some extra
memory, then the alternative (pinning the entire UI ram) is also a bad outcome.
There's no perfect solution here, and I suspect a really functional system
ultimately needs all sorts of weird hints from the UI.  Or alternatively, a
naive VM (which pins the UI), and enough RAM to keep the user and any bulk jobs
happy.

-Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
