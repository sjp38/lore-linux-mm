Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 53C816B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 11:02:46 -0400 (EDT)
Received: by iofb144 with SMTP id b144so61547574iof.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:02:46 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id 90si8333083ioq.190.2015.09.03.08.02.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 08:02:42 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so16582945igb.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 08:02:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150903060247.GV1933@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
Date: Thu, 3 Sep 2015 08:02:40 -0700
Message-ID: <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 2, 2015 at 11:02 PM, Dave Chinner <dchinner@redhat.com> wrote:
> On Wed, Sep 02, 2015 at 06:21:02PM -0700, Linus Torvalds wrote:
>> On Wed, Sep 2, 2015 at 5:51 PM, Mike Snitzer <snitzer@redhat.com> wrote:
>> >
>> > What I made possible with SLAB_NO_MERGE is for each subsystem to decide
>> > if they would prefer to not allow slab merging.
>>
>> .. and why is that a choice that even makes sense at that level?
>>
>> Seriously.
>>
>> THAT is the fundamental issue here.
>
> It makes a lot more sense than you think, Linus.

Not really. Even your argument isn't at all arguing for doing things
at a per-subsystem level - it's an argument about the potential sanity
of marking _individual_ slab caches non-mergable, not an argument for
something clearly insane like "mark all slabs for subsystem X
unmergable".

Can you just admit that that was insane? There is *no* sense in that
kind of behavior.

> Right, it's not xyzzy-specific where 'xyzzy' is a subsystem. The
> flag application is actually *object specific*. That is, the use of
> the individual objects that determines whether it should be merged
> or not.

Yes.

I do agree that something like SLAB_NO_MERGE can make sense on an
actual object-specific level, if you have very specific allocation
pattern knowledge and can show that the merging actually hurts.

But making the subsystem decide that all its slab caches should be
"no-merge" is just BS. You know that. It makes no sense, just admit
it.

> e.g. Slab fragmentation levels are affected more than anything by
> mixing objects with different life times in the same slab.  i.e. if
> we free all the short lived objects from a page but there is one
> long lived object on the page then that page is pinned and we free
> no memory. Do that to enough pages in the slab, and we end up with a
> badly fragmented slab.

The thing is, *if* you can show that kind of behavior for a particular
slab, and have numbers for it, then mark that slab as no-merge, and
document why you did it.

Even then, I'd personally probably prefer to name the bit differently:
rather than talk about an internal implementation detail within slab
("don't merge") it would probably be better to try to frame it in the
semantic different you are looking for (ie in "I want a slab with
private allocation patterns").

But aside from that kind of naming issue, that's very obviously not
what the patch series discussed was doing.

And quite frankly, I don't actually think you have the numbers to show
that theoretical bad behavior.  In contrast, there really *are*
numbers to show the advantages of merging.

So the fragmentation argument has been shown to generally be in favor
of merging, _not_ in favor of that "no-merge" behavior. If you have an
actual real load where that isn't the case, and can show it, then that
would be interesting, but at no point is that "the subsystem just
decided to mark all its slabs no-merge".

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
