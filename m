Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B8F066B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 23:11:00 -0500 (EST)
Date: Mon, 22 Nov 2010 13:09:54 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [BUGFIX][PATCH] pagemap: set pagemap walk limit to PMD boundary
Message-ID: <20101122040953.GB3017@spritzera.linux.bs1.fc.nec.co.jp>
References: <1290157665-17215-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20101122120102.e0e76373.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20101122120102.e0e76373.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

> > @@ -776,7 +777,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
> >  		unsigned long end;
> >
> >  		pm.pos = 0;
> > -		end = start_vaddr + PAGEMAP_WALK_SIZE;
> > +		end = (start_vaddr + PAGEMAP_WALK_SIZE) & PAGEMAP_WALK_MASK;
> >  		/* overflow ? */
> >  		if (end < start_vaddr || end > end_vaddr)
> >  			end = end_vaddr;
>
> Ack.
>
> But ALIGN() can't be used ?

ALIGN() returns the same address as the input if it is already aligned,
but what we need here is the next PMD boundary. So something like

                end = IS_ALIGNED(start_vaddr, PAGEMAP_WALK_SIZE) ?
                        start_vaddr + PAGEMAP_WALK_SIZE :
                        ALIGN(start_vaddr, PAGEMAP_WALK_SIZE)          

keeps the semantics, but I don't like it because it's lengthy.

Anyway, thanks for your comment.

Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
