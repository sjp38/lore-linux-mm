Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 72DB76B0088
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 23:48:51 -0500 (EST)
Received: by iyj17 with SMTP id 17so14603330iyj.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 20:48:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
Date: Wed, 5 Jan 2011 13:48:50 +0900
Message-ID: <AANLkTikCQbzQcUjxtgLrSVtF76Jr9zTmXUhO_yDWss5k@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix memory migration of shmem swapcache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jan 5, 2011 at 1:00 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> Hi.
>
> This is a fix for a problem which has bothered me for a month.
>
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> In current implimentation, mem_cgroup_end_migration() decides whether the page
> migration has succeeded or not by checking "oldpage->mapping".
>
> But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> NULL from the begining, so the check would be invalid.
> As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> even if it's not, so "newpage" would be freed while it's not uncharged.
>
> This patch fixes it by passing mem_cgroup_end_migration() the result of the
> page migration.
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch. I don't oppose the patch.
But as looking the code in unmap_and_move, I feel part of mem cgroup
migrate is rather awkward.

int unmap_and_move()
{
   charge = mem_cgroup_prepare_migration(xxx);
   ..
   BUG_ON(charge); <-- BUG if it is charged?
   ..
uncharge:
   if (!charge)    <-- why do we have to uncharge !charge?
      mem_group_end_migration(xxx);
   ..
}

'charge' local variable isn't good. How about changing "uncharge" or whatever?
Of course, It would be another patch.
If you don't mind, I will send the patch or you may send the patch.

Thanks,

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
