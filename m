Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 12ABE6B0055
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:50:15 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9FNoDAs003586
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Oct 2009 08:50:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 581C045DE57
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:50:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 319B945DE51
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:50:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1428A1DB8041
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:50:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B73C21DB803E
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 08:50:12 +0900 (JST)
Date: Fri, 16 Oct 2009 08:47:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] swap_info: change to array of pointers
Message-Id: <20091016084748.762330b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910152356110.9759@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
	<Pine.LNX.4.64.0910150146210.3291@sister.anvils>
	<20091015111107.b505b676.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0910152324220.4447@sister.anvils>
	<Pine.LNX.4.64.0910152356110.9759@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nigel Cunningham <ncunningham@crca.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Oct 2009 00:04:14 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Thu, 15 Oct 2009, Hugh Dickins wrote:
> > On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 15 Oct 2009 01:48:01 +0100 (BST)
> > > Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > > > @@ -1675,11 +1674,13 @@ static void *swap_start(struct seq_file
> > > >  	if (!l)
> > > >  		return SEQ_START_TOKEN;
> > > >  
> > > > -	for (i = 0; i < nr_swapfiles; i++, ptr++) {
> > > > -		if (!(ptr->flags & SWP_USED) || !ptr->swap_map)
> > > > +	for (type = 0; type < nr_swapfiles; type++) {
> > > > +		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> > > > +		si = swap_info[type];
> > > 
> > > 		if (!si) ?
> 
> Re-reading, I see that I missed your interjection there.
> 
> Precisely because we read swap_info[type] after reading nr_swapfiles,
> with smp_rmb() here to enforce that, and smp_wmb() where they're set
> in swapon, there is no way for si to be seen as NULL here.  Is there?
> 
Ah, sorry this is my mistake. I don't understand "nr_swapfiles never decreases
and swap_info[] will be never invalidated."

> Or are you asking for a further comment here on why that's so?
No.

> I think I'd rather just switch to taking swap_lock in swap_start()
> and swap_next(), than be adding comments on why we don't need it.
> 

Hmm, maybe.

Thanks,
-Kame

> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
