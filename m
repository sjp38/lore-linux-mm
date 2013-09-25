Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 91E896B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 23:25:45 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so5439919pdi.5
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 20:25:45 -0700 (PDT)
Date: Tue, 24 Sep 2013 23:25:30 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [patch] mm, mempolicy: make mpol_to_str robust and always succeed
Message-ID: <20130925032530.GA4771@redhat.com>
References: <5215639D.1080202@asianux.com>
 <5227CF48.5080700@asianux.com>
 <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com>
 <20130925031127.GA4210@redhat.com>
 <alpine.DEB.2.02.1309242012070.27940@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309242012070.27940@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 24, 2013 at 08:18:16PM -0700, David Rientjes wrote:
 > On Tue, 24 Sep 2013, Dave Jones wrote:
 > 
 > >  >  	case MPOL_BIND:
 > >  > -		/* Fall through */
 > >  >  	case MPOL_INTERLEAVE:
 > >  >  		nodes = pol->v.nodes;
 > >  >  		break;
 > > 
 > > Any reason not to leave this ?
 > > 
 > > "missing break" is the 2nd most common thing that coverity picks up.
 > > Most of them are false positives like the above, but the lack of annotations
 > > in our source makes it time-consuming to pick through them all to find the
 > > real bugs.
 > > 
 > 
 > Check out things like drivers/mfd/wm5110-tables.c that do things like
 > 
 > 	switch (reg) {
 > 	case ARIZONA_SOFTWARE_RESET:
 > 	case ARIZONA_DEVICE_REVISION:
 > 	case ARIZONA_CTRL_IF_SPI_CFG_1:
 > 	case ARIZONA_CTRL_IF_I2C1_CFG_1:
 > 	case ARIZONA_CTRL_IF_I2C2_CFG_1:
 > 	case ARIZONA_CTRL_IF_I2C1_CFG_2:
 > 	case ARIZONA_CTRL_IF_I2C2_CFG_2:
 > 	...
 > 
 > and that file has over 1,000 case statements.  Having a

yikes, at first I thought that was output from a code generator.
 
 > 	/* fall through */
 > 
 > for all of them would be pretty annoying.
 
agreed, but with that example, it seems pretty obvious (to me at least)
that the lack of break's is intentional.  Where it gets trickier to
make quick judgment calls is cases like the one I mentioned above,
where there are only a few cases, and there's real code involved in
some but not all cases.

 > I don't remember any coding style rule about this (in fact 
 > Documentation/CodingStyle has examples of case statements without such a 
 > comment), I think it's just personal preference so I'll leave it to Andrew 
 > and what he prefers.
 > 
 > (And if he prefers the /* fall through */ then we should ask that it be 
 > added to checkpatch.pl since it warns about a million other things and not 
 > this.)

The question of course is how much gain there is in doing anything at all here.
So far, I've only seen false positives from that checker, but there are hundreds
of them to pick through, so who knows what's further down the pile.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
