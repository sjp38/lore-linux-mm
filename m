Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3F8446B0148
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 07:55:20 -0400 (EDT)
Date: Mon, 21 Sep 2009 12:55:24 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
In-Reply-To: <1253531550.5216.32.camel@penberg-laptop>
Message-ID: <Pine.LNX.4.64.0909211244510.6209@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
 <1253256805.4959.8.camel@penberg-laptop>  <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
  <1253260528.4959.13.camel@penberg-laptop>  <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
  <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>
 <4AB487FD.5060207@cs.helsinki.fi>  <Pine.LNX.4.64.0909211149360.32504@sister.anvils>
 <1253531550.5216.32.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: ngupta@vflare.org, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Mon, 21 Sep 2009, Pekka Enberg wrote:
> On Mon, 2009-09-21 at 12:07 +0100, Hugh Dickins wrote:
> > Is the main basis for your disgust at the way that Nitin installs the
> > callback, that loop down the swap_info_structs?  I should point out
> > that it was I who imposed that on Nitin: before that he was passing a
> > swap entry (or was it a swap type extracted from a swap entry?
> > I forget), which was the sole reference to a swp_entry_t in his
> > driver - I advised a bdev interface.
> 
> The callback setup from ->read() just looks gross. However, it's your
> call Hugh so I'll just shut up now. ;-)

Ah, no, please don't!  So it's _that_ end of it that's upsetting you,
and rightly so, I hadn't grasped that.

I must have glanced at that end, setting the notifier in ramzswap_read(),
in a previous revision, to have spotted the swp_entry_t that was there;
but haven't refreshed my memory of it recently.

(Nitin, your patch division is quite wrong: you should present a patch
in which your driver works, albeit poorly, without the notifier; then
a patch in which the notifier is added at the swapfile.c end and your
driver end, so we can see how they fit together.)

I'd naively hoped when suggesting the bdev interface that it would
then be usable at opening time, but I guess we don't know enough then.

I don't think installing the notifier at ramzswap_read() time quite
covers all cases: though it's a exceptional, imagine writing some
stuff out to swap, then swapoff called while all those pages are
still in swapcache - no reads would be done, the swap would be
freed, but the notifier never even installed, let alone called.

Well, it remains the case that I don't have time to review this at
present.  But when I get back here I ought to take another look at
your patch (if it's not superseded by something obviously better
from one or another).

Though exporting the swap_info_struct still bothers me, and it
seems convoluted that the block device should have a method, so
swapon can call the block device, so the block device can call
swapfile.c to install a callout, so that swapfile.c can call the
block device when freeing swap.  I'm not saying there is a better
way, just that I'd be glad of a better way.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
