Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 00D636B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 18:53:48 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id bj3so3710266pad.34
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 15:53:48 -0800 (PST)
Message-ID: <51241081.20006@gmail.com>
Date: Wed, 20 Feb 2013 07:53:37 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] IPVS: change type of netns_ipvs->sysctl_sync_qlen_max
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, horms@verge.net.au, ja@ssi.bg, davem@davemloft.net
Cc: Linux MM <linux-mm@kvack.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This member of struct netns_ipvs is calculated from nr_free_buffer_pages
so change its type to unsigned long in case of overflow. Also, type of
its related proc var sync_qlen_max and the return type of function
sysctl_sync_qlen_max() should be changed to unsigned long, too.

Besides, the type of ipvs_master_sync_state->sync_queue_len should be
changed to unsigned long accordingly.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/net/ip_vs.h            |    8 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68c69d5..108ebe8 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -874,7 +874,7 @@ struct ip_vs_app {
 struct ipvs_master_sync_state {
 	struct list_head	sync_queue;
 	struct ip_vs_sync_buff	*sync_buff;
-	int			sync_queue_len;
+	unsigned long		sync_queue_len;
 	unsigned int		sync_queue_delay;
 	struct task_struct	*master_thread;
 	struct delayed_work	master_wakeup_work;
@@ -966,7 +966,7 @@ struct netns_ipvs {
 	int			sysctl_snat_reroute;
 	int			sysctl_sync_ver;
 	int			sysctl_sync_ports;
-	int			sysctl_sync_qlen_max;
+	unsigned long		sysctl_sync_qlen_max;
 	int			sysctl_sync_sock_size;
 	int			sysctl_cache_bypass;
 	int			sysctl_expire_nodest_conn;
@@ -1052,7 +1052,7 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
 }
 
-static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_sync_qlen_max;
 }
@@ -1099,7 +1099,7 @@ static inline int sysctl_sync_ports(struct netns_ipvs *ipvs)
 	return 1;
 }
 
-static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
+static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
 {
 	return IPVS_SYNC_QLEN_MAX;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ec664cb..d79a530 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1747,9 +1747,9 @@ static struct ctl_table vs_vars[] = {
 	},
 	{
 		.procname	= "sync_qlen_max",
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax,
 	},
 	{
 		.procname	= "sync_sock_size",
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
