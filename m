Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 053BD6B00AC
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 03:03:13 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA983AP4009170
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 17:03:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A2A845DE70
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:03:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F30C45DE60
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:03:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2481C1DB803F
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:03:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D1A411DB803A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 17:03:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
References: <87lj597hp9.fsf@gmail.com> <20101109162525.BC87.A69D9226@jp.fujitsu.com>
Message-Id: <20101109170303.BC90.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 17:03:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I've recently been trying to track down the root cause of my server's
> > persistent issue of thrashing horribly after being left inactive. It
> > seems that the issue is likely my nightly backup schedule (using rsync)
> > which traverses my entire 50GB home directory. I was surprised to find
> > that rsync does not use fadvise to notify the kernel of its use-once
> > data usage pattern.
> > 
> > It looks like a patch[1] was written (although never merged, it seems)
> > incorporating fadvise support, but I found its implementation rather
> > odd, using mincore() and FADV_DONTNEED to kick out only regions brought
> > in by rsync. It seemed to me the simpler and more appropriate solution
> > would be to simply flag every touched file with FADV_NOREUSE and let the
> > kernel manage automatically expelling used pages.
> > 
> > After looking deeper into the kernel implementation[2] of fadvise() the
> > reason for using DONTNEED became more apparant. It seems that the kernel
> > implements NOREUSE as a noop. A little googling revealed[3] that I not
> > the first person to encounter this limitation. It looks like a few
> > folks[4] have discussed addressing the issue in the past, but nothing
> > has happened as of 2.6.36. Are there plans to implement this
> > functionality in the near future? It seems like the utility of fadvise
> > is severely limited by lacking support for NOREUSE.
> 
> btw, Other OSs seems to also don't implement it.
> example,

I've heared other OSs status of fadvise() from private mail.

NetBSD: no-op (as linux)
FreeBSD/DragonflyBSD/OpenBSD: don't exist posix_fadvise(2)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
