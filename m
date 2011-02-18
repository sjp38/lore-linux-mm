Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B61E68D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 03:54:44 -0500 (EST)
Received: by fxm12 with SMTP id 12so3612037fxm.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 00:54:42 -0800 (PST)
Subject: [PATCH 1/2] net: dont leave active on stack LIST_HEAD
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1298014191.2642.11.camel@edumazet-laptop>
References: <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <m1sjvm822m.fsf@fess.ebiederm.org>
	 <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
	 <20110217.203647.193696765.davem@davemloft.net>
	 <1298010320.2642.7.camel@edumazet-laptop>
	 <1298014191.2642.11.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Feb 2011 09:54:38 +0100
Message-ID: <1298019278.2595.83.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, ebiederm@xmission.com, opurdila@ixiacom.com, mingo@elte.hu, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

Eric W. Biderman and Michal Hocko reported various memory corruptions
that we suspected to be related to a LIST head located on stack, that
was manipulated after thread left function frame (and eventually exited,
so its stack was freed and reused).

Eric Dumazet suggested the problem was probably coming from commit
443457242beb (net: factorize
sync-rcu call in unregister_netdevice_many)

This patch fixes __dev_close() and dev_close() to properly deinit their
respective LIST_HEAD(single) before exiting.

References: https://lkml.org/lkml/2011/2/16/304
References: https://lkml.org/lkml/2011/2/14/223

Reported-by: Michal Hocko <mhocko@suse.cz>
Reported-by: Eric W. Biderman <ebiderman@xmission.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: Octavian Purdila <opurdila@ixiacom.com>
CC: Eric W. Biderman <ebiderman@xmission.com>
---
 net/core/dev.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8e726cb..a18c164 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1280,10 +1280,13 @@ static int __dev_close_many(struct list_head *head)
 
 static int __dev_close(struct net_device *dev)
 {
+	int retval;
 	LIST_HEAD(single);
 
 	list_add(&dev->unreg_list, &single);
-	return __dev_close_many(&single);
+	retval = __dev_close_many(&single);
+	list_del(&single);
+	return retval;
 }
 
 int dev_close_many(struct list_head *head)
@@ -1325,7 +1328,7 @@ int dev_close(struct net_device *dev)
 
 	list_add(&dev->unreg_list, &single);
 	dev_close_many(&single);
-
+	list_del(&single);
 	return 0;
 }
 EXPORT_SYMBOL(dev_close);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
