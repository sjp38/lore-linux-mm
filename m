Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACC56B0011
	for <linux-mm@kvack.org>; Mon,  2 May 2011 16:05:04 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1304100150.2559.28.camel@mulgrave.site>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <BANLkTimpMJRX0CF7tZ75_x1kWmTkFx3XxA@mail.gmail.com>
	 <1304091436.2559.8.camel@mulgrave.site>
	 <1304094672.2559.12.camel@mulgrave.site>
	 <1304100150.2559.28.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 02 May 2011 15:04:55 -0500
Message-ID: <1304366695.15370.24.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, 2011-04-29 at 13:02 -0500, James Bottomley wrote:
> On Fri, 2011-04-29 at 11:31 -0500, James Bottomley wrote:
> > On Fri, 2011-04-29 at 10:37 -0500, James Bottomley wrote:
> > > On Fri, 2011-04-29 at 12:23 +0200, Sedat Dilek wrote:
> > > > But as I see these RCU (CPU) stalls, the patch from [1] might be worth a try.
> > > > First, I have seen negative effects on my UP-system was when playing
> > > > with linux-next [2].
> > > > It was not clear what the origin was and the the side-effects were
> > > > somehow "bizarre".
> > > > The issue could be easily reproduced by tar-ing the kernel build-dir
> > > > to an external USB-hdd.
> > > > The issue kept RCU and TIP folks really busy.
> > > > Before stepping 4 weeks in the dark, give it a try and let me know in
> > > > case of success.
> > > 
> > > Well, it's highly unlikely because that's a 2.6.39 artifact and the bug
> > > showed up in 2.6.38 ... I tried it just in case with no effect, so we
> > > know it isn't the cause.
> > 
> > Actually, I tell a lie: it does't stop kswapd spinning on PREEMPT, but
> > it does seem to prevent non-PREEMPT from locking up totally (at least it
> > survives three back to back untar runs).
> > 
> > It's probable it alters the memory pin conditions that cause the spin,
> > so it's masking the problem rather than fixing it.
> 
> Confirmed ... it's just harder to reproduce with the hrtimers init fix.
> The problem definitely still exists (I had to load up the system more
> before doing the tar).
> 
> This time I've caught kswapd in mem_cgroup_shrink_node_zone.  sysrq-w
> doesn't complete for an unknown reason

As a follow on to this, there's a shrink_zone(0, ...) in the cgroup
path.  This causes it to scan all memory exhaustively (generating quite
a lot of work).  The comment above it implies it's some type of hack for
cgroup accounting, but reducing it to DEF_PRIORITY makes the hang go
away (verified on both 2.6.39-rc4 and 2.6.38.4).  Note that I still get
soft lockups in kswapd0, but they no longer hang the box.  I'll prepare
a patch for the next round of debate.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
