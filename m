Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m48LjMZw007376
	for <linux-mm@kvack.org>; Thu, 8 May 2008 22:45:22 +0100
Received: from an-out-0708.google.com (anac24.prod.google.com [10.100.54.24])
	by zps19.corp.google.com with ESMTP id m48LjFl0016181
	for <linux-mm@kvack.org>; Thu, 8 May 2008 14:45:19 -0700
Received: by an-out-0708.google.com with SMTP id c24so242632ana.57
        for <linux-mm@kvack.org>; Thu, 08 May 2008 14:45:14 -0700 (PDT)
Message-ID: <6599ad830805081445w5991b47cld2861aab26ac6323@mail.gmail.com>
Date: Thu, 8 May 2008 14:45:13 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 3/4] Add rlimit controller accounting and control
In-Reply-To: <48230FBB.20105@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080503213726.3140.68845.sendpatchset@localhost.localdomain>
	 <20080503213814.3140.66080.sendpatchset@localhost.localdomain>
	 <6599ad830805062029m37b507dcue737e1affddeb120@mail.gmail.com>
	 <48230FBB.20105@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 8, 2008 at 7:35 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  I currently intend to use this controller for controlling memory related
>  rlimits, like address space and mlock'ed memory. How about we use something like
>  "memrlimit"?

Sounds reasonable.

>
>  Good suggestion, but it will be hard if not impossible to account the data
>  correctly as it changes, if we do the accounting/summation at bind time. We'll
>  need a really big lock to do it, something I want to avoid. Did you have
>  something else in mind?

Yes, it'll be tricky but I think worthwhile. I believe it can be done
without the charge/uncharge code needing to take a global lock, except
for when we're actually binding/unbinding, with careful use of RCU.

My first thought for how to do this was that we have a field
"bind_transition" that indicates whether we're transitioning between
bound and unbound, and a bind_mutex. By default the charge/unpath uses
RCU, but by marking that we're in a transition state, the charge path
will use the mutex instead. By waiting for all existing chargers that
are using RCU to exit, we can then take the lock and synchronize with
the chargers.

So the charge/uncharge path would do:

  rcu_read_lock();
  if (ss->tranistioning) {
    rcu_read_unlock();
    locked = 1;
    mutex_lock(&ss->bind_mutex);
  }
  if (ss->active) {
    /* do charge/uncharge stuff, which must not block */
  }
  if (locked) {
    mutex_unlock(&ss->bind_mutex);
  } else {
    rcu_read_unlock();
  }

and the bind path would do something like:

ss->transitioning = 1;
synchronize_rcu();
mutex_lock(&ss->bind_mutex);
for_each_mm(mm) {
  down_read(&mm->mmap_sem);
  add_charge_for_mm();
  up_read(&mm->mmap_sem);
}
mutex_unlock(&ss->bind_mutex);
ss->transitioning = 0;

But this would break because we're nesting mmap_sem inside bind_mutex
in the bind path, but in the charge path we're nesting bind_mutex
inside mmap_sem. So we'd probably need to define a new bit
MMF_RLIMIT_ACCOUNTED in mm->flags to indicate whether that mm's
address space usage is accounted for. Once we've done that, we can use
mmap_sem to synchronize changes to the per-mm charged status for free,
since we already hold mmap_sem whenever we're doing the charging,
right? So it becomes simple:

charge path:

if (!test_bit(MMF_RLIMIT_ACCOUNTED, &mm->flags))
  return 0;
/* do charge/uncharge stuff */

bind path:

while((mm = find_unaccounted_mm()) {
  down_write(&mm->mmap_sem);
  add_charge_for_mm();
  set_bit(MMF_RLIMIT_ACCOUNTED, &mm->flags);
  up_write(&mm->mmap_sem);
}

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
