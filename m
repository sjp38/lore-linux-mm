Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3EACD6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 23:18:21 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so5403348pdj.7
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 20:18:20 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so5880263pad.0
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 20:18:18 -0700 (PDT)
Date: Tue, 24 Sep 2013 20:18:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: make mpol_to_str robust and always
 succeed
In-Reply-To: <20130925031127.GA4210@redhat.com>
Message-ID: <alpine.DEB.2.02.1309242012070.27940@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309241957280.26415@chino.kir.corp.google.com> <20130925031127.GA4210@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chen Gang <gang.chen@asianux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Sep 2013, Dave Jones wrote:

>  >  	case MPOL_BIND:
>  > -		/* Fall through */
>  >  	case MPOL_INTERLEAVE:
>  >  		nodes = pol->v.nodes;
>  >  		break;
> 
> Any reason not to leave this ?
> 
> "missing break" is the 2nd most common thing that coverity picks up.
> Most of them are false positives like the above, but the lack of annotations
> in our source makes it time-consuming to pick through them all to find the
> real bugs.
> 

Check out things like drivers/mfd/wm5110-tables.c that do things like

	switch (reg) {
	case ARIZONA_SOFTWARE_RESET:
	case ARIZONA_DEVICE_REVISION:
	case ARIZONA_CTRL_IF_SPI_CFG_1:
	case ARIZONA_CTRL_IF_I2C1_CFG_1:
	case ARIZONA_CTRL_IF_I2C2_CFG_1:
	case ARIZONA_CTRL_IF_I2C1_CFG_2:
	case ARIZONA_CTRL_IF_I2C2_CFG_2:
	...

and that file has over 1,000 case statements.  Having a

	/* fall through */

for all of them would be pretty annoying.

I don't remember any coding style rule about this (in fact 
Documentation/CodingStyle has examples of case statements without such a 
comment), I think it's just personal preference so I'll leave it to Andrew 
and what he prefers.

(And if he prefers the /* fall through */ then we should ask that it be 
added to checkpatch.pl since it warns about a million other things and not 
this.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
