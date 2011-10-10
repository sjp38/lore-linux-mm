Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF416B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 07:11:20 -0400 (EDT)
Subject: [PATCH 0/9] skb fragment API: convert network drivers (part V)
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 10 Oct 2011 12:11:16 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: linux-scsi@vger.kernel.org, linux-mm@kvack.org

The following series converts a fifth (and hopefully final) batch of
network drivers to the SKB pages fragment API introduced in
131ea6675c76.

There are four drivers here (mlx4, cxgb4, cxgb4vf and cxgbi) which used
skb_frag_t as part of their internal datastructures which meant that
they are impacted by changes to that type more than most drivers. To
break this dependency I added a "struct subpage" (struct page + offset +
len) and converted them to use it. These conversions are a little less
trivial than most of the preceding ones and I have only been able to
compile test them.

I think "struct subpage" is a generally useful tuple I added to a
central location (mm_types.h) rather than somewhere networking or driver
specific but I can trivially move if preferred.

The remaining three drivers in the series (ehea, emac, ll_temac) are
normal conversions which I either missed in my first pass or which have
had direct uses of the fragment pages added since then.

The final patch here wraps the page member of skb_frag_t in a structure,
this is a precursor to adding the destructor here (those patches need a
little more work, arising from comments made at LPC, I'll post regarding
those shortly). This should help ensure that no direct uses of the page
get introduced in the meantime.

I have run an allmodconfig build on a boatload architectures[2] on a
baseline of current net-next/master (88c5100c28b0) and with this series.
Although the baseline didn't build for most architectures I used "make
-k" and confirmed that this series added no new warnings or errors.

This is part of my series to enable visibility into SKB paged fragment's
lifecycles, [0] contains some more background and rationale but
basically the completed series will allow entities which inject pages
into the networking stack to receive a notification when the stack has
really finished with those pages (i.e. including retransmissions,
clones, pull-ups etc) and not just when the original skb is finished
with, which is beneficial to many subsystems which wish to inject pages
into the network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
[2] arm amd64 blackfin cris i386 ia64 m68k mips64 mips powerpc64 powerpc
s390x sh4 sparc64 sparc xtensa 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
