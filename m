Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 141A56B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 01:53:07 -0500 (EST)
Date: Wed, 5 Jan 2011 15:47:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
Message-Id: <20110105154748.0a012407.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <AANLkTikCQbzQcUjxtgLrSVtF76Jr9zTmXUhO_yDWss5k@mail.gmail.com>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
	<AANLkTikCQbzQcUjxtgLrSVtF76Jr9zTmXUhO_yDWss5k@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jan 2011 13:48:50 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi,
> 
> On Wed, Jan 5, 2011 at 1:00 PM, Daisuke Nishimura
> <nishimura@mxp.nes.nec.co.jp> wrote:
> > Hi.
> >
> > This is a fix for a problem which has bothered me for a month.
> >
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> >
> > In current implimentation, mem_cgroup_end_migration() decides whether the page
> > migration has succeeded or not by checking "oldpage->mapping".
> >
> > But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> > NULL from the begining, so the check would be invalid.
> > As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> > even if it's not, so "newpage" would be freed while it's not uncharged.
> >
> > This patch fixes it by passing mem_cgroup_end_migration() the result of the
> > page migration.
> >
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Nice catch. I don't oppose the patch.
Thank you for your review.

> But as looking the code in unmap_and_move, I feel part of mem cgroup
> migrate is rather awkward.
> 
> int unmap_and_move()
> {
>    charge = mem_cgroup_prepare_migration(xxx);
>    ..
>    BUG_ON(charge); <-- BUG if it is charged?
>    ..
> uncharge:
>    if (!charge)    <-- why do we have to uncharge !charge?
>       mem_group_end_migration(xxx);
>    ..
> }
> 
> 'charge' local variable isn't good. How about changing "uncharge" or whatever?
hmm, I agree that current code seems a bit confusing, but I can't think of
better name to imply the result of 'charge'.

And considering more, I can't understand why we need to check "if (!charge)"
before mem_cgroup_end_migration() becase it must be always true and, IMHO,
mem_cgroup_end_migration() should do all necesarry checks to avoid double uncharge.
So, I think this local variable can be removed completely.

	rc = mem_cgroup_prepare_migration(..);
	if (rc == -ENOMEM)
		goto unlock;
	BUG_ON(rc);
	..
uncharge:
	mem_cgroup_end_migration(..);

KAMEZAWA-san, what do you think ?

> Of course, It would be another patch.
Yes.

> If you don't mind, I will send the patch or you may send the patch.
> 
I'll leave it to you, but anyway, please do it after this patch has merged.
it will conflict with this patch.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
