Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B7F1760044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 18:47:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o03Nl2et010136
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Jan 2010 08:47:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 68D3845DE50
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:47:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 38CF645DD6F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:47:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FD4A1DB8040
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:47:01 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA4EC1DB803E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:47:00 +0900 (JST)
Date: Mon, 4 Jan 2010 08:43:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3 -mmotm-2009-12-10-17-19] Count zero page as file_rss
Message-Id: <20100104084347.c36d9855.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.0912301619500.3369@sister.anvils>
References: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com>
	<ae2928fe7bb3d94a7ca18d3b3274fdfeb009803a.1258773030.git.minchan.kim@gmail.com>
	<4B38876F.6010204@gmail.com>
	<alpine.LSU.2.00.0912301619500.3369@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Dec 2009 16:49:52 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> > > 
> > > Kame reported following as
> > > "Before starting zero-page works, I checked "questions" in lkml and
> > > found some reports that some applications start to go OOM after zero-page
> > > removal.
> > > 
> > > For me, I know one of my customer's application depends on behavior of
> > > zero page (on RHEL5). So, I tried to add again it before RHEL6 because
> > > I think removal of zero-page corrupts compatibility."
> > > 
> > > So how about adding zero page as file_rss again for compatibility?
> 
> I think not.
> 
> KAMEZAWA-san can correct me (when he returns in the New Year) if I'm
> wrong, but I don't think his customer's OOMs had anything to do with
> whether the ZERO_PAGE was counted in file_rss or not: the OOMs came
> from the fact that many pages were being used up where just the one
> ZERO_PAGE had been good before.  Wouldn't he have complained if the
> zero_pfn patches hadn't solved that problem?
> 
> You are right that I completely overlooked the issue of whether to
> include the ZERO_PAGE in rss counts (now being a !vm_normal_page,
> it was just natural to leave it out); and I overlooked the fact that
> it used to be counted into file_rss in the old days (being !PageAnon).
> 
> So I'm certainly at fault for that, and thank you for bringing the
> issue to attention; but once considered, I can't actually see a good
> reason why we should add code to count ZERO_PAGEs into file_rss now.
> And if this patch falls, then 1/3 and 3/3 would fall also.
> 
> And the patch below would be incomplete anyway, wouldn't it?
> There would need to be a matching change to zap_pte_range(),
> but I don't see that.
> 
> We really don't want to be adding more and more ZERO_PAGE/zero_pfn
> tests around the place if we can avoid them: KOSAKI-san has a strong
> argument for adding such a test in kernel/futex.c, but I don't the
> argument here.
> 

I agree that ZERO_PAGE shouldn't be counted as rss. Now, I feel that old
counting method(in old zero-page implementation) was bad.

Minchan-san, I'm sorry for noise.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
