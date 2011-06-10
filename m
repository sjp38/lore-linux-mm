Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CEB516B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 18:16:06 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p5AMG4OK021537
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:16:04 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by wpaz21.hot.corp.google.com with ESMTP id p5AMFkV3017563
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:16:02 -0700
Received: by pvg13 with SMTP id 13so1666368pvg.40
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 15:16:02 -0700 (PDT)
Date: Fri, 10 Jun 2011 15:16:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
In-Reply-To: <20110610220748.GO24424@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.00.1106101510000.23076@chino.kir.corp.google.com>
References: <alpine.LFD.2.02.1106012043080.3078@ionos> <alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com> <alpine.LFD.2.02.1106012134120.3078@ionos> <4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org>
 <BANLkTimC8K2_H7ZEu2XYoWdA09-3XxpV7Q@mail.gmail.com> <20110610091233.GJ24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101150280.17197@chino.kir.corp.google.com> <20110610185858.GN24424@n2100.arm.linux.org.uk> <alpine.DEB.2.00.1106101456080.23076@chino.kir.corp.google.com>
 <20110610220748.GO24424@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

On Fri, 10 Jun 2011, Russell King - ARM Linux wrote:

> > We're talking about two different things.  Linus is saying that if GFP_DMA 
> > should be a no-op if the hardware doesn't require DMA memory because the 
> > kernel was correctly compiled without CONFIG_ZONE_DMA.  I'm asking about a 
> > kernel that was incorrectly compiled without CONFIG_ZONE_DMA and now we're 
> > returning memory from anywhere even though we actually require GFP_DMA.
> 
> How do you distinguish between the two states?  Answer: you can't.
> 

By my warning which says "enable CONFIG_ZONE_DMA _if_ needed."  The 
alternative is to silently return memory from anywhere, which is what the 
page allocator does now, which doesn't seem very user friendly when the 
device randomly works depending on the chance it was actually allocated 
from the DMA mask.  If it actually wants DMA and the kernel is compiled 
incorrectly, then I think a single line in the kernel log would be nice to 
point them in the right direction.  Users who disable the option usually 
know what they're doing (it's only allowed for CONFIG_EXPERT on x86, for 
example), so I don't think they'll mind the notification and choose to 
ignore it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
