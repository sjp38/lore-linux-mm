Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id EBF4D6B13FE
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 20:51:19 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so159618pbc.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 17:51:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F31D03B.9040707@openvz.org>
References: <20120207074905.29797.60353.stgit@zurg> <CA+55aFy3NZ2sWX0CNVd9FnPSx0mUKSe0XzDWpDsNfU21p6ebHQ@mail.gmail.com>
 <4F31D03B.9040707@openvz.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 7 Feb 2012 17:50:59 -0800
Message-ID: <CA+55aFx24n-W4-wTtrfbt9PNvVd7n+SvThnO6OQ74uW4yNrGxw@mail.gmail.com>
Subject: Re: [PATCH 0/4] radix-tree: iterating general cleanup
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Feb 7, 2012 at 5:30 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
>
> If do not count comments here actually is negative line count change.

Ok, fair enough.

> And if drop (almost) unused radix_tree_gang_lookup_tag_slot() and
> radix_tree_gang_lookup_slot() total bloat-o-meter score becomes negative
> too.

Good.

> There also some simple bit-hacks: find-next-bit instead of dumb loops in
> tagged-lookup.
>
> Here some benchmark results: there is radix-tree with 1024 slots, I fill =
and
> tag every <step> slot,
> and run lookup for all slots with radix_tree_gang_lookup() and
> radix_tree_gang_lookup_tag() in the loop.
> old/new rows -- nsec per iteration over whole tree.
>
> tagged-lookup
> step =A0 =A01 =A0 =A0 =A0 2 =A0 =A0 =A0 3 =A0 =A0 =A0 4 =A0 =A0 =A0 5 =A0=
 =A0 =A0 6 =A0 =A0 =A0 7 =A0 =A0 =A0 8 =A0 =A0 =A0 9 =A0 =A0 =A0 10 =A0 =A0=
 =A011 =A0 =A0 =A012 =A0 =A0 =A013 =A0 =A0 =A014 =A0 =A0 =A015 =A0 =A0 =A01=
6
> old =A0 =A0 7035 =A0 =A05248 =A0 =A04742 =A0 =A04308 =A0 =A04217 =A0 =A04=
133 =A0 =A04030 =A0 =A03920 =A0 =A04038 =A0 =A03933 =A0 =A03914 =A0 =A03796=
 =A0 =A03851 =A0 =A03755 =A0 =A03819 =A0 =A03582
> new =A0 =A0 3578 =A0 =A02617 =A0 =A01899 =A0 =A01426 =A0 =A01220 =A0 =A01=
058 =A0 =A0936 =A0 =A0 822 =A0 =A0 845 =A0 =A0 749 =A0 =A0 695 =A0 =A0 679 =
=A0 =A0 648 =A0 =A0 575 =A0 =A0 591 =A0 =A0 509
>
> so, new tagged-lookup always faster, especially for sparse trees.

Do you have any benchmarks when it's actually used by higher levels,
though? I guess that will involve find_get_pages(), and we don't have
all that any of them, but it would be lovely to see some real load
(even if it is limited to one of the filesystems that uses this)
numbers too..

> New normal lookup works faster for dense trees, on sparse trees it slower=
.

I think that should be the common case, so that may be fine. Again, it
would be nice to see numbers that are for something else than just the
lookup - an actual use of it in some real context.

Anyway, the patches themselves looked fine to me, modulo the fact that
I wasn't all that happy with the new __find_next_bit, and I think it's
better to not expose it in a generic header file. But I would really
like to see more "real" numbers for the series

Thanks,

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
