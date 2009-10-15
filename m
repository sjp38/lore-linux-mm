Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F2296B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:04:16 -0400 (EDT)
Date: Fri, 16 Oct 2009 00:04:14 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/9] swap_info: change to array of pointers
In-Reply-To: <Pine.LNX.4.64.0910152324220.4447@sister.anvils>
Message-ID: <Pine.LNX.4.64.0910152356110.9759@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150146210.3291@sister.anvils>
 <20091015111107.b505b676.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0910152324220.4447@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nigel Cunningham <ncunningham@crca.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, Hugh Dickins wrote:
> On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> > On Thu, 15 Oct 2009 01:48:01 +0100 (BST)
> > Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > > @@ -1675,11 +1674,13 @@ static void *swap_start(struct seq_file
> > >  	if (!l)
> > >  		return SEQ_START_TOKEN;
> > >  
> > > -	for (i = 0; i < nr_swapfiles; i++, ptr++) {
> > > -		if (!(ptr->flags & SWP_USED) || !ptr->swap_map)
> > > +	for (type = 0; type < nr_swapfiles; type++) {
> > > +		smp_rmb();	/* read nr_swapfiles before swap_info[type] */
> > > +		si = swap_info[type];
> > 
> > 		if (!si) ?

Re-reading, I see that I missed your interjection there.

Precisely because we read swap_info[type] after reading nr_swapfiles,
with smp_rmb() here to enforce that, and smp_wmb() where they're set
in swapon, there is no way for si to be seen as NULL here.  Is there?

Or are you asking for a further comment here on why that's so?
I think I'd rather just switch to taking swap_lock in swap_start()
and swap_next(), than be adding comments on why we don't need it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
