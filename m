Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DF2C46B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 17:41:24 -0400 (EDT)
Received: by eyh5 with SMTP id 5so4892779eyh.14
        for <linux-mm@kvack.org>; Tue, 31 Aug 2010 14:41:22 -0700 (PDT)
Subject: Re: [PATCH 03/10] Use percpu stats
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1008311635100.867@router.home>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	 <1281374816-904-4-git-send-email-ngupta@vflare.org>
	 <alpine.DEB.2.00.1008301114460.10316@router.home>
	 <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>
	 <1283290106.2198.26.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1008311635100.867@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 31 Aug 2010 23:41:18 +0200
Message-ID: <1283290878.2198.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Le mardi 31 aoA>>t 2010 A  16:35 -0500, Christoph Lameter a A(C)crit :
> On Tue, 31 Aug 2010, Eric Dumazet wrote:
> 
> > > Yes, this_cpu_add() seems sufficient. I can't recall why I used u64_stats_*
> > > but if it's not required for atomic access to 64-bit then why was it added to
> > > the mainline in the first place?
> >
> > Because we wanted to have fast 64bit counters, even on 32bit arches, and
> > this has litle to do with 'atomic' on one entity, but a group of
> > counters. (check drivers/net/loopback.c, lines 91-94). No lock prefix
> > used in fast path.
> >
> > We also wanted readers to read correct values, not a value being changed
> > by a writer, with inconsistent 32bit halves. SNMP applications want
> > monotonically increasing counters.
> >
> > this_cpu_add()/this_cpu_read() doesnt fit.
> >
> > Even for single counter, this_cpu_read(64bit) is not using an RMW
> > (cmpxchg8) instruction, so you can get very strange results when low
> > order 32bit wraps.
> 
> How about fixing it so that everyone benefits?
> 

IMHO, this_cpu_read() is fine as is : a _read_ operation.

Dont pretend it can be used in every context, its not true.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
