Date: Sat, 21 Aug 2004 10:48:04 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
Message-ID: <20040821174804.GB3045@holomorphy.com>
References: <4126B3F9.90706@jp.fujitsu.com> <20040821025543.GS11200@holomorphy.com> <20040821.135624.74737461.taka@valinux.co.jp> <20040821052116.GU11200@holomorphy.com> <4126DFB4.7070404@jp.fujitsu.com> <20040821053735.GV11200@holomorphy.com> <4126E76E.2050403@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4126E76E.2050403@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Sat, Aug 21, 2004 at 03:10:54PM +0900, Hiroyuki KAMEZAWA wrote:
> Oh, I said these 2 lines are needless ;) ,sorry for my vagueness.
>     buddy2 = base + page_idx;
> (*) BUG_ON(bad_range(zone, buddy1));
> (*) BUG_ON(bad_range(zone, buddy2));
> I understand a test before accessing "buddy1" is necessary.

Well, the only reason a test before accessing buddy2 isn't necessary
is because of the assumption that the start of a zone is MAX_ORDER
aligned.


On Sat, Aug 21, 2004 at 03:10:54PM +0900, Hiroyuki KAMEZAWA wrote:
> But as I mentioned in other mail, I'm afraid of memory hole in zone.
> This cannot be detected by simple range check.
> Is this special case of IA64 ? (I don't know other archs than i386 and IA64)
> I think
> + if (!pfn_valid(buddy1))
> +     break;
> will work enough if pfn_valid() works correctly fot zone with hole.

On most architectures the pfn_valid() will do something much like
bad_range() but less efficiently. My understanding is that MAP_NR_DENSE()
and analogues aren't supported in 2.6, so to avoid the overhead for
machines not needing it some kind of conditional check would be good. My
current understanding is that the mem_map setup in arch/ia64 now will not
make these kinds of bounds checks fail, but I'm willing to be corrected.
ia64_pfn_valid() is highly unusual and probably extremely inefficient.


On Sat, Aug 21, 2004 at 03:10:54PM +0900, Hiroyuki KAMEZAWA wrote:
> If ZONE is not MAX_ORDER aligned,
> if (bad_range(zone,buddy1))
>     break;
> will be needed too.

We've usually assumed the start of the zone MAX_ORDER -aligned, but
adding if (bad_range(zone, buddy2)) break; or similar would relax that
restriction, assuming that above you meant buddy2.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
