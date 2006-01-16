Message-ID: <43CBC27B.6010405@shadowen.org>
Date: Mon, 16 Jan 2006 15:57:47 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] BUG: gfp_zone() not mapping zone modifiers correctly
 and bad ordering of fallback lists
References: <20060113155026.GA4811@skynet.ie> <20060113121652.114941a3.akpm@osdl.org>
In-Reply-To: <20060113121652.114941a3.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

I think we need to be careful here. Although the __GFP_* modifiers
appear to be directly convertable to ZONE_* types they don't have
to be.  We could potentially have a new modifier which would want
to specify a different list combination whilst not representing
a zone in and of itself; for example __GFP_NODEONLY which might
request use of zones which are NUMA node local.  The bits covered
by GFP_ZONEMASK represent 'zone modifier space', those GFP bits
which affect where we should try and get memory. The zonelists
correspond to the lists of zones to try for that combination in
'zone modifier space' not for a specific zone.

Right now there is a near one-to-one correspondance between
the __GFP_x and ZONE_x identifiers. As more zones are added we
exponentially waste more and more 'zone modifier space' to allow
for the possible combinations. If we are willing and able to assert
that only one memory zone related modifier is valid at once we
could deliberatly squash the zone number into the bottom corner of
'zone modifier space' whilst still maintaining that space and the
ability to allow new bits to be combined with it.

My feeling is that as long as we don't lose the ability to have
modifiers combine and select separate lists and there is currently
no use of combined zone modifiers then we can make this optimisation.

Comments?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
