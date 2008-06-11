Date: Wed, 11 Jun 2008 13:14:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080611131437.76961fc3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080611034446.4C5535A23@siro.lan>
References: <20080611122500.677757c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611034446.4C5535A23@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, menage@google.com, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 12:44:46 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> > I'm now considering following logic. How do you think ?
> > 
> > Assume: move TASK from group:CURR to group:DEST.
> > 
> > == move_task(TASK, CURR, DEST)
> > 
> > if (DEST's limit is unlimited)
> > 	moving TASK
> > 	return success.
> > 
> > usage = check_usage_of_task(TASK).
> > 
> > /* try to reserve enough room in destionation */
> > if (try_to_reserve_enough_room(DEST, usage)) {
> > 	move TASK to DEST and move pages AMAP.
> > 	/* usage_of_task(TASK) can be changed while we do this.
> > 	   Then, we move AMAP. */
> > 	return success;
> > }
> > return failure.
> > ==
> 
> AMAP means that you might leave some random charges in CURR?
> 
yes. but we can reduce bad case by some way 
 - reserve more than necessary.
 or
 - read_lock mm->sem while move.

> i think that you can redirect new charges in TASK to DEST
> so that usage_of_task(TASK) will not grow.
> 

Hmm, to do that, we have to handle complicated cgroup's attach ops.

at this moving, memcg is pointed by
 - TASK->cgroup->memcg(CURR)
after move
 - TASK->another_cgroup->memcg(DEST)

This move happens before cgroup is replaced by another_cgroup.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
