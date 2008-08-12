Date: Mon, 11 Aug 2008 17:31:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 1/2] mm owner fix race between swap and exit
Message-Id: <20080811173138.71f5bbe4.akpm@linux-foundation.org>
In-Reply-To: <20080811100733.26336.31346.sendpatchset@balbir-laptop>
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
	<20080811100733.26336.31346.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2008 15:37:33 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> There's a race between mm->owner assignment and try_to_unuse(). The condition
> occurs when try_to_unuse() runs in parallel with an exiting task.
> 
> The race can be visualized below. To quote Hugh
> "I don't think your careful alternation of CPU0/1 events at the end matters:
> the swapoff CPU simply dereferences mm->owner after that task has gone"
> 
> But the alteration does help understand the race better (at-least for me :))
> 
> CPU0					CPU1
> 					try_to_unuse
> task 1 stars exiting			look at mm = task1->mm
> ..					increment mm_users
> task 1 exits
> mm->owner needs to be updated, but
> no new owner is found
> (mm_users > 1, but no other task
> has task->mm = task1->mm)
> mm_update_next_owner() leaves
> 
> grace period
> 					user count drops, call mmput(mm)
> task 1 freed
> 					dereferencing mm->owner fails
> 
> The fix is to notify the subsystem (via mm_owner_changed callback), if
> no new owner is found by specifying the new task as NULL.

This patch applies to mainline, 2.6.27-rc2 and even 2.6.26.

Against which kernel/patch is it actually applicable?

(If the answer was "all of the above" then please don't go embedding
mainline bugfixes in the middle of a -mm-only patch series!)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
