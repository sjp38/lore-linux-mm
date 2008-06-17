Subject: Re: [Bad page] trying to free locked page? (Re: [PATCH][RFC] fix
	kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3)
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080617181527.5bcbbccc.nishimura@mxp.nes.nec.co.jp>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080617180314.2d1b0efa.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080617181527.5bcbbccc.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain
Date: Tue, 17 Jun 2008 14:29:45 -0400
Message-Id: <1213727385.8707.53.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-17 at 18:15 +0900, Daisuke Nishimura wrote:
> On Tue, 17 Jun 2008 18:03:14 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 17 Jun 2008 16:47:09 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Tue, 17 Jun 2008 16:35:01 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > Hi.
> > > > 
> > > > I got this bug while migrating pages only a few times
> > > > via memory_migrate of cpuset.
> > > > 
> > > > Unfortunately, even if this patch is applied,
> > > > I got bad_page problem after hundreds times of page migration
> > > > (I'll report it in another mail).
> > > > But I believe something like this patch is needed anyway.
> > > > 
> > > 
> > > I got bad_page after hundreds times of page migration.
> > > It seems that a locked page is being freed.

I'm seeing *mlocked* pages [PG_mlocked] being freed now with my stress
load, with just the "if(!page->mapping) { } clause removed, as proposed
in your rfc patch in previous mail.  Need to investigate this...

I'm not seeing *locked* pages [PG_lock], tho'.  From your stack trace,
it appears that migrate_page() left locked pages on the list of pages to
be putback.  The pages get locked and unlocked in unmap_and_move().  I
haven't found a path [yet] where the page can be returned still locked.
I think I need to duplicate the problem.

> > > 
> > Good catch, and I think your investigation in the last e-mail was correct.
> > I'd like to dig this...but it seems some kind of big fix is necessary.
> > Did this happen under page-migraion by cpuset-task-move test ?
> > 
> Yes.
> 
> I made 2 cpuset directories, run some processes in each cpusets,
> and run a script like below infinitely to move tasks and migrate pages.

What processes/tests do you run in each cpuset?

> 
> ---
> #!/bin/bash
> 
> G1=$1
> G2=$2
> 
> move_task()
> {
>         for pid in $1
>         do
>                 echo $pid >$2/tasks 2>/dev/null
>         done
> }
> 
> G1_TASK=`cat ${G1}/tasks`
> G2_TASK=`cat ${G2}/tasks`
> 
> move_task "${G1_TASK}" ${G2} &
> move_task "${G2_TASK}" ${G1} &
> 
> wait
> ---
> 
> I got this bad_page after running this script for about 600 times.
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
