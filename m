Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4893B6B002E
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 05:01:19 -0400 (EDT)
Subject: [PATCH 0/6] skb fragment API: convert network drivers (part V, take
 2)
From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 20 Oct 2011 10:01:15 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

The following series is the second attempt to convert a fifth (and
hopefully final) batch of network drivers to the SKB pages fragment API
introduced in 131ea6675c76.

There are four drivers here (mlx4, cxgb4, cxgb4vf and cxgbi) which used
skb_frag_t as part of their internal datastructures which meant that
they are impacted by changes to that type more than most drivers. To
break this dependency I added a "struct page_frag" (struct page + offset
+ len) and converted them to use it. These conversions are a little less
trivial than most of the preceding ones and I have only been able to
compile test them.

The struct page_frag addition has been acked by Andrew Morton to go
through the net tree. (Andrew, I took you "yes please" as an Acked-by. I
hope that's ok).

The final patch here wraps the page member of skb_frag_t in a structure,
this is a precursor to adding the destructor here (those patches need a
little more work, arising from comments made at LPC, I'll post regarding
those shortly). This should help ensure that no direct uses of the page
get introduced in the meantime.

In the previous posting of this series I ran an allmodconfig build on a
boatload architectures[2] on a baseline of the then current
net-next/master (88c5100c28b0) and with that series. Although the
baseline didn't build for most architectures I used "make -k" and
confirmed that this series added no new warnings or errors. For this
iteration I have just rebuilt things which changed in the interval
88c5100c28b0..a0bec1cd8f7a (current net-next/master) on amd64 and
eyeballed the diff for new uses of frag->page (I saw none).

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
