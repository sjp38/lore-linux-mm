Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD119000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 10:26:23 -0400 (EDT)
Date: Mon, 26 Sep 2011 16:25:41 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] mm: remove sysctl to manually rescue unevictable pages
Message-ID: <20110926142540.GE14333@redhat.com>
References: <1316948380-1879-1-git-send-email-consul.kautuk@gmail.com>
 <20110926112944.GC14333@redhat.com>
 <CAFPAmTQPiHU8AKnQvzMM5KiQr1GnUY+Yf8PwVC6++QK8u149Ew@mail.gmail.com>
 <CAFPAmTQbHhj8wodFEutpstXdQ6Kc2_qRV6Pe69ngHwz1erF29Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAFPAmTQbHhj8wodFEutpstXdQ6Kc2_qRV6Pe69ngHwz1erF29Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Sep 26, 2011 at 05:59:39PM +0530, kautuk.c @samsung.com wrote:
> On Mon, Sep 26, 2011 at 5:40 PM, kautuk.c @samsung.com
> <consul.kautuk@gmail.com> wrote:
> > On Mon, Sep 26, 2011 at 4:59 PM, Johannes Weiner <jweiner@redhat.com> wrote:
> >> On Sun, Sep 25, 2011 at 04:29:40PM +0530, Kautuk Consul wrote:
> >>> write_scan_unavictable_node checks the value req returned by
> >>> strict_strtoul and returns 1 if req is 0.
> >>>
> >>> However, when strict_strtoul returns 0, it means successful conversion
> >>> of buf to unsigned long.
> >>>
> >>> Due to this, the function was not proceeding to scan the zones for
> >>> unevictable pages even though we write a valid value to the
> >>> scan_unevictable_pages sys file.
> >>
> >> Given that there is not a real reason for this knob (anymore) and that
> >> it apparently never really worked since the day it was introduced, how
> >> about we just drop all that code instead?
> >>
> >>        Hannes
> >>
> >> ---
> >> From: Johannes Weiner <jweiner@redhat.com>
> >> Subject: mm: remove sysctl to manually rescue unevictable pages
> >>
> >> At one point, anonymous pages were supposed to go on the unevictable
> >> list when no swap space was configured, and the idea was to manually
> >> rescue those pages after adding swap and making them evictable again.
> >> But nowadays, swap-backed pages on the anon LRU list are not scanned
> >> without available swap space anyway, so there is no point in moving
> >> them to a separate list anymore.
> >
> > Is this code only for anonymous pages ?
> > It seems to look at all pages in the zone both file as well as anon.
> >
> >>
> >> The manual rescue could also be used in case pages were stranded on
> >> the unevictable list due to race conditions.  But the code has been
> >> around for a while now and newly discovered bugs should be properly
> >> reported and dealt with instead of relying on such a manual fixup.
> >
> > What you say seems to be all right for anon pages, but what about file
> > pages ?
> > I'm not sure about how this could happen, but what if some file-system caused
> > a file cache page to be set to evictable or reclaimable without
> > actually removing
> > that page from the unevictable list ?
> 
> What I would like to also add is that while the transition of an anon
> page from and
> to the unevictable lists is straight-forward, should we make the same assumption
> about file cache pages ?

We should make no assumptions if our code base is open source :-)

> I am not sure about this, but could a file-system cause this kind of a problem
> independent of the mlocking behaviour of a user-mode app ?

Currently, I only see shmem and ramfs meddling with unevictability
outside of mlock and they both look correct to me.

I'd say that if a filesystem required this knob and user-intervention
for the VM to behave correctly, it needs fixing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
