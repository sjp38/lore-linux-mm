Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 808AB8D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 21:01:53 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	<20110216193700.GA6377@elte.hu>
	<AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	<AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	<20110217090910.GA3781@tiehlicka.suse.cz>
	<AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	<20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	<AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	<20110218122938.GB26779@tiehlicka.suse.cz>
	<20110218162623.GD4862@tiehlicka.suse.cz>
	<AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	<m1oc68ilw7.fsf@fess.ebiederm.org>
	<AANLkTincrnq1kMcAYEWYLf5vdbQ4DYbYObbg=0cLfHnm@mail.gmail.com>
Date: Sat, 19 Feb 2011 18:01:36 -0800
In-Reply-To: <AANLkTincrnq1kMcAYEWYLf5vdbQ4DYbYObbg=0cLfHnm@mail.gmail.com>
	(Linus Torvalds's message of "Sat, 19 Feb 2011 07:33:45 -0800")
Message-ID: <m1oc67zcov.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Fri, Feb 18, 2011 at 10:22 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> It looks like the same problematic dellink pattern made it into net_namespace.c,
>> and your new LIST_DEBUG changes caught it.
>
> Hey, goodie. Committing that patch felt like locking the barn door
> after the horse had bolted, so I'm happy to hear it was actually worth
> it.
>
>> I will cook up a patch after I get some sleep.

After some sleep and some more looking I think I understand what is
going on and what is happening.

The first is that I was wrong about net_namespace.c being the culprit.
The list debug failures are new with Linus's patch and there is not a
single list_move net_namespace.c.

So this brings me back to unregister_netdevice_queue and the unreg_list.

In the beginning with batching unreg_list was a list that was used only
once in the lifetime of a network device (I think).  Now we have calls
using the unreg_list that can happen multiple times in the life of a
network device like dev_deactivate and dev_close that are also using the
unreg_list.  In addition in unregister_netdevice_queue we also do a
list_move because for devices like veth pairs it is possible that
unregister_netdevice_queue will be called multiple times.

So I think the change below to fix dev_deactivate which Eric D. missed
will fix this problem.  Now to go test that.

In other news my userspace is still very unhappy.  So it looks like I am
going to be tracking 2.6.38-rcN bugs for a while.

Eric

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 8acba45..7a10a8d 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1229,6 +1229,7 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 	}
 	mutex_unlock(&local->iflist_mtx);
 	unregister_netdevice_many(&unreg_list);
+	list_del(&unreg_list);
 }
 
 static u32 ieee80211_idle_off(struct ieee80211_local *local,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 34dc598..1bc6980 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -839,6 +839,7 @@ void dev_deactivate(struct net_device *dev)
 
 	list_add(&dev->unreg_list, &single);
 	dev_deactivate_many(&single);
+	list_del(&single);
 }
 
 static void dev_init_scheduler_queue(struct net_device *dev,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
