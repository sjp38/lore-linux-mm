Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 484AF6B0141
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 07:07:26 -0400 (EDT)
Date: Mon, 21 Sep 2009 12:07:24 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
In-Reply-To: <4AB487FD.5060207@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0909211149360.32504@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
 <1253256805.4959.8.camel@penberg-laptop>  <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
  <1253260528.4959.13.camel@penberg-laptop>  <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
 <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>
 <4AB487FD.5060207@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: ngupta@vflare.org, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Sat, 19 Sep 2009, Pekka Enberg wrote:
> Nitin Gupta wrote:
> > It is understood that this swap notify callback is bit of a hack. I think
> > we will not gain much trying to beautify this hack. However, I agree with
> > Hugh's suggestion to rename this notify callback related function/variables
> > to make it explicit that its completely ramzswap related. I will send a path
> > that affects these renames as reply to patch 0/4.
> 
> I don't quite agree and do think that my approach is a better long-term
> solution. That said, it's Hugh's call, not mine. Hugh?

Sorry, Pekka, I do prefer Nitin's more explicit hackery.

Yours of course looks nicer: but again this method is actually just
for the one single use, and it is "exporting" the swap_info_struct to
the block device, whereas I'd prefer to move in the opposite direction,
making that struct internal to swapfile.c.  (I'd have done so already,
but noticed TuxOnIce making use of it, and don't want to make life
awkward there.)

Is the main basis for your disgust at the way that Nitin installs the
callback, that loop down the swap_info_structs?  I should point out
that it was I who imposed that on Nitin: before that he was passing a
swap entry (or was it a swap type extracted from a swap entry?
I forget), which was the sole reference to a swp_entry_t in his
driver - I advised a bdev interface.

Would a compromise be to extend the #ifdef CONFIG_HIBERNATION around
swap_type_of() to cover ramzswap too, then Nitin use swap_type_of()
on his bdev to get a swap type to use to install the notifier?

I'm not saying that would be better, haven't even thought through
if it works: I'm just looking for a compromise, whereby you and I
don't keep sending Nitin scurrying off in opposite directions.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
