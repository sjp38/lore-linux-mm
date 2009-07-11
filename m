Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D31386B004F
	for <linux-mm@kvack.org>; Sat, 11 Jul 2009 15:13:27 -0400 (EDT)
Date: Sat, 11 Jul 2009 20:22:11 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: KSM: current madvise rollup
In-Reply-To: <4A57C3D1.7000407@redhat.com>
Message-ID: <Pine.LNX.4.64.0907111916001.30651@sister.anvils>
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils>
 <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils>
 <4A4A5C56.5000109@redhat.com> <Pine.LNX.4.64.0907010057320.4255@sister.anvils>
 <4A4B317F.4050100@redhat.com> <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
 <4A57C3D1.7000407@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 11 Jul 2009, Izik Eidus wrote:
>... 
> Isnt it mean that we are "stop using the stable tree help" ?
> It look like every item that will go into the stable tree will get flushed
> from it in the second run, that will highly increase the ksmd cpu usage, and
> will make it find less pages...
> Was this what you wanted to do? or am i missed anything?

You sorted this one out for yourself before I got around to it.

> 
> Beside this one more thing i noticed while checking this code:
> beacuse the new "Ksm shared page" is not File backed page, it isnt count in
> top as a shared page, and i couldnt find a way to see how many pages are
> shared for each application..

Hah!  I can't quite call that a neat trick, but it is amusing.

Yes, checking up on where top gets SHR from, it does originate from
file_rss, and your previous definition of PageKsm was such that those
pages had to get counted as file_rss.

If I thought for a moment that these pages really are like file pages,
I'd immediately revert my PageKsm change, and instead make page->mapping
point to a fictional address_space (rather like swapper_space), so that
those pages could still be definitively identified.

But they are not file pages, they are anon pages: anon pages which are
shared (in this case shared via KSM rather than shared via fork); and
I was fixing the accounting by making them look like anon pages again.
And it'll be more important for them to look like anon pages when we
get to swapping them next time around.

Bundling them in with file_rss may have made some numbers stand out
more obviously to you; but it was a masquerade, they weren't really
the numbers you were wanting.

> This is important for management tools such as a tool that will want to know
> what Virtual Machines it want to migrate from the host into another host based
> on the memory sharing in that specific host (Meaning how much ram it really
> take on that specific host)

Okay, I can see that you may well want such info.

> 
> So I started to prepre a patch that will show merged pages count inside
> /proc/pid/mergedpages, But then i thought this statics lie:
> if we will have 2 applications: application A and application B, that share
> the same page, how should it look like?:
> 
> cat /proc/pid_of_A/merged_pages -> 1
> cat /proc/pid_of_B/merged_pages -> 1
> 
> or:
> 
> cat /proc/pid_of_A/merged_pages -> 0 (beacuse this one was shared with the
> page of B)
> cat /proc/pid_of_B/merged_pages -> 1

I happen to think that the second method, plausible though it
starts out, ends up leading to more grief than the first.

But two more important things to say.

One, I'm the wrong person to be asking about this: I've little
experience to draw on here, and my interest wanes when it comes
to the number gathering end of this.

Two, I don't think you can do it with a count like that at all.
If you're thinking of migrating A away from B, or A and B together
away from the rest, don't you need to know how much they're sharing
with each other, how much they're sharing with the rest?  If A and B
are different instances of the same app, they're likely to be sharing
much more with each other than with the rest as a whole: and that'll
make a huge difference to your decisions on migration.

A single number (probably of that first kind) may be a nice kind
of reassurance that things are working, and worth providing.  But
for detailed migration/provisioning decisions, I'd have thought
you'd need the kernel to provide a list of "id"s of KSM-shared
pages for each process, which your management tools could then
crunch upon (observing the different sharings of ids) to try out
different splits; or else, doing it the other way around, a
representation of the stable_tree itself, with pids at the nodes.

Though once you got into that detail, I wonder if you'd find that
you need such info, not just about the KSM pages, but about the
rest as well (how much are the anon pages being shared across fork,
for example? which of the file pages are shmem/tmpfs pages needing
swap? how much swap is being used?).

I think it becomes quite a big subject, and you may be able to
excite other people with it.

> 
> To make the second method thing work as much as reaible as we can we would
> want to break KsmPages that have just one mapping into them...

We may want to do that anyway.  It concerned me a lot when I was
first testing (and often saw kernel_pages_allocated greater than
pages_shared - probably because of the original KSM's eagerness to
merge forked pages, though I think there may have been more to it
than that).  But seems much less of an issue now (that ratio is much
healthier), and even less of an issue once KSM pages can be swapped.
So I'm not bothering about it at the moment, but it may make sense.

> 
> What do you think about that? witch direction should we take for that?

If nobody else volunteers in on that, I could perhaps make up an
incriminating list of mm people who have an interest in such things!

> 
> (Other than this stuff, everything running happy and nice,

Glad to hear it, yes, same at my end (I did have a hang in the cow
breaking the night before I sent out the rollup, but included the
fix in that, and it has stood up since).

> I think cpu is
> little bit too high beacuse the removing of the stable_tree issue)

I think you've resolved that as a non-issue, but is cpu still looking
too high to you?  It looks high to me, but then I realize that I've
tuned it to be high anyway.  Do you have any comparison against the
/dev/ksm KSM, or your first madvise version?

Oh, something that might be making it higher, that I didn't highlight
(and can revert if you like, it was just more straightforward this way):
with scan_get_next_rmap skipping the non-present ptes, pages_to_scan is
currently a limit on the _present_ pages scanned in one batch.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
