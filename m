Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC538D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 03:59:26 -0500 (EST)
Received: by fxm12 with SMTP id 12so3615231fxm.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 00:59:23 -0800 (PST)
Subject: [PATCH 2/2] net: deinit automatic LIST_HEAD
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <m17hcx7wca.fsf@fess.ebiederm.org>
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	 <20110216193700.GA6377@elte.hu>
	 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	 <20110217090910.GA3781@tiehlicka.suse.cz>
	 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <m1sjvm822m.fsf@fess.ebiederm.org>
	 <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	 <m17hcx7wca.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 09:59:19 +0100
Message-ID: <1298019559.2595.92.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, ebiederm@xmission.com, mingo@elte.hu, opurdila@ixiacom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, netdev <netdev@vger.kernel.org>, stable@kernel.org

commit 9b5e383c11b08784 (net: Introduce
unregister_netdevice_many()) left an active LIST_HEAD() in
rollback_registered(), with possible memory corruption.

Even if device is freed without touching its unreg_list (and therefore
touching the previous memory location holding LISTE_HEAD(single), better
close the bug for good, since its really subtle.

(Same fix for default_device_exit_batch() for completeness)

Reported-by: Michal Hocko <mhocko@suse.cz>
Reported-by: Eric W. Biderman <ebiderman@xmission.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: Octavian Purdila <opurdila@ixiacom.com>
CC: Eric W. Biderman <ebiderman@xmission.com>
CC: stable <stable@kernel.org> [.33+]
---
 net/core/dev.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index a18c164..8ae6631 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5066,6 +5066,7 @@ static void rollback_registered(struct net_device *dev)
 
 	list_add(&dev->unreg_list, &single);
 	rollback_registered_many(&single);
+	list_del(&single);
 }
 
 unsigned long netdev_fix_features(unsigned long features, const char *name)
@@ -6219,6 +6220,7 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 		}
 	}
 	unregister_netdevice_many(&dev_kill_list);
+	list_del(&dev_kill_list);
 	rtnl_unlock();
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
