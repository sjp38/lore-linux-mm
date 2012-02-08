Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 779656B13FB
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 20:30:40 -0500 (EST)
Received: by bkty12 with SMTP id y12so43144bkt.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 17:30:38 -0800 (PST)
Message-ID: <4F31D03B.9040707@openvz.org>
Date: Wed, 08 Feb 2012 05:30:35 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] radix-tree: iterating general cleanup
References: <20120207074905.29797.60353.stgit@zurg>  <CA+55aFy3NZ2sWX0CNVd9FnPSx0mUKSe0XzDWpDsNfU21p6ebHQ@mail.gmail.com>
In-Reply-To: <CA+55aFy3NZ2sWX0CNVd9FnPSx0mUKSe0XzDWpDsNfU21p6ebHQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Linus Torvalds wrote:
> On Mon, Feb 6, 2012 at 11:54 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org>  wrote:
>> This patchset implements common radix-tree iteration routine and
>> reworks page-cache lookup functions with using it.
>
> So what's the advantage? Both the line counts and the bloat-o-meter
> seems to imply this is all just bad.

If do not count comments here actually is negative line count change.
And if drop (almost) unused radix_tree_gang_lookup_tag_slot() and
radix_tree_gang_lookup_slot() total bloat-o-meter score becomes negative too.
There also some shrinkable stuff in shmem code.
So, if this is really a problem it is fixable. I just didn't want to bloat patchset.

>
> I assume there is some upside to it, but you really don't make that
> obvious, so why should anybody ever waste even a second of time
> looking at this?

Hmm, from my point of view, this unified iterator code looks cleaner than
current duplicated radix-tree code. That's why I was titled it "cleanup".

There also some simple bit-hacks: find-next-bit instead of dumb loops in tagged-lookup.

Here some benchmark results: there is radix-tree with 1024 slots, I fill and tag every <step> slot,
and run lookup for all slots with radix_tree_gang_lookup() and radix_tree_gang_lookup_tag() in the loop.
old/new rows -- nsec per iteration over whole tree.

tagged-lookup
step	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16
old	7035	5248	4742	4308	4217	4133	4030	3920	4038	3933	3914	3796	3851	3755	3819	3582
new	3578	2617	1899	1426	1220	1058	936	822	845	749	695	679	648	575	591	509

so, new tagged-lookup always faster, especially for sparse trees.

normal-lookup
step	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15	16
old	4156	2641	2068	1837	1630	1531	1467	1415	1373	1398	1333	1323	1308	1280	1236	1249
new	3048	2520	2429	2280	2266	2296	2215	2219	2188	2170	2218	2332	2166	2096	2100	2058

New normal lookup works faster for dense trees, on sparse trees it slower.
Looks like it caused by struct radix_tree_iter aliasing,
gcc cannot effectively use its field as loop counter in nested-loop.
But how important is this? Anyway, I'll think how to fix this misfortune.


>
>                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
