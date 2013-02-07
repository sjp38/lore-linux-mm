Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 842F86B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 22:13:45 -0500 (EST)
Message-ID: <51131B88.6040809@cn.fujitsu.com>
Date: Thu, 07 Feb 2013 11:12:08 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] net: fix functions and variables related to netns_ipvs->sysctl_sync_qlen_max
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: davem@davemloft.net, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Since the type of netns_ipvs->sysctl_sync_qlen_max has been changed to
unsigned long, type of its related proc var sync_qlen_max should be changed
to unsigned long, too. Also the return type of function sysctl_sync_qlen_max().

Cc: David Miller <davem@davemloft.net>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>
Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/net/ip_vs.h            |    4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 68c69d5..ba3bd85 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
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
