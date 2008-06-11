Date: Wed, 11 Jun 2008 12:25:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080611122500.677757c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080611120345.07ddadc6.nishimura@mxp.nes.nec.co.jp>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<20080610163550.65c97f6a.nishimura@mxp.nes.nec.co.jp>
	<20080610172637.39ffff5c.kamezawa.hiroyu@jp.fujitsu.com>
	<20080611120345.07ddadc6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 12:03:45 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > Or, instead of implementing rollback in kernel,
> > > how about making user(or middle ware?) re-echo pid to rollbak
> > > on failure?
> > > 
> > 
> > "If the users does well, the system works in better way" is O.K.
> > "If the users doesn't well, the system works in broken way" is very bad.
> > 
> Hum...
> 
> I think users must know what they are doing.
> 
yes. but it's a different problem,
 - "a user must know what they does."
 - "a system works without BUG even if the user is crazy."


> They must know that moving a process to another group
> that doesn't have enough room for it may fail with half state,
> if it is the behavior of kernel.
> And they should handle the error by themselves, IMHO.
> 

I'm now considering following logic. How do you think ?

Assume: move TASK from group:CURR to group:DEST.

== move_task(TASK, CURR, DEST)

if (DEST's limit is unlimited)
	moving TASK
	return success.

usage = check_usage_of_task(TASK).

/* try to reserve enough room in destionation */
if (try_to_reserve_enough_room(DEST, usage)) {
	move TASK to DEST and move pages AMAP.
	/* usage_of_task(TASK) can be changed while we do this.
	   Then, we move AMAP. */
	return success;
}
return failure.
==

The difficult point will be reservation but can be implemented without
complexity.


Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
