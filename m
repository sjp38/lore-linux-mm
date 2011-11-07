Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8343E6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 12:29:09 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: RE: [PATCH v5 04/10] per-cgroup tcp buffers control
Date: Mon, 7 Nov 2011 17:28:50 +0000
Message-ID: <D1C30CD88081EA42BD6A1AA039A44650705B78@US-EXCH1.sw.swsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "paul@paulmenage.org" <paul@paulmenage.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "davem@davemloft.net" <davem@davemloft.net>, "gthelen@google.com" <gthelen@google.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill@shutemov.name" <kirill@shutemov.name>, Andrey Vagin <avagin@parallels.com>, "devel@openvz.org" <devel@openvz.org>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "kamezawa.hiroyu@jp.fujtisu.com" <kamezawa.hiroyu@jp.fujtisu.com>

Ok, I forgot to change the temporary name I was using for the jump label. S=
hame on me :)=0A=
=0A=
--- Mensagem Original ---=0A=
=0A=
De: Glauber Costa <glommer@parallels.com>=0A=
Enviado: 7 de novembro de 2011 07/11/11=0A=
Para: linux-kernel@vger.kernel.org=0A=
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.co=
m, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@v=
ger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, Andrey Vagin <ava=
gin@parallels.com>, devel@openvz.org, eric.dumazet@gmail.com, Glauber Costa=
 <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com=
>=0A=
Assunto: [PATCH v5 04/10] per-cgroup tcp buffers control=0A=
=0A=
With all the infrastructure in place, this patch implements=0A=
per-cgroup control for tcp memory pressure handling.=0A=
=0A=
A resource conter is used to control allocated memory, except=0A=
for the root cgroup, that will keep using global counters.=0A=
=0A=
This patch is the one that actually enables/disables the=0A=
jump labels controlling cgroup. To this point, they were always=0A=
disabled.=0A=
=0A=
Signed-off-by: Glauber Costa <glommer@parallels.com>=0A=
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>=0A=
CC: David S. Miller <davem@davemloft.net>=0A=
CC: Eric W. Biederman <ebiederm@xmission.com>=0A=
CC: Eric Dumazet <eric.dumazet@gmail.com>=0A=
---=0A=
 include/net/tcp.h       |   18 +++++++=0A=
 include/net/transp_v6.h |    1 +=0A=
 mm/memcontrol.c         |  125 +++++++++++++++++++++++++++++++++++++++++++=
+++-=0A=
 net/core/sock.c         |   46 +++++++++++++++--=0A=
 net/ipv4/af_inet.c      |    3 +=0A=
 net/ipv4/tcp_ipv4.c     |   12 +++++=0A=
 net/ipv6/af_inet6.c     |    3 +=0A=
 net/ipv6/tcp_ipv6.c     |   10 ++++=0A=
 8 files changed, 211 insertions(+), 7 deletions(-)=0A=
=0A=
diff --git a/include/net/tcp.h b/include/net/tcp.h=0A=
index ccaa3b6..7301ca8 100644=0A=
--- a/include/net/tcp.h=0A=
+++ b/include/net/tcp.h=0A=
@@ -253,6 +253,22 @@ extern int sysctl_tcp_cookie_size;=0A=
 extern int sysctl_tcp_thin_linear_timeouts;=0A=
 extern int sysctl_tcp_thin_dupack;=0A=
 =0A=
+struct tcp_memcontrol {=0A=
+	/* per-cgroup tcp memory pressure knobs */=0A=
+	struct res_counter tcp_memory_allocated;=0A=
+	struct percpu_counter tcp_sockets_allocated;=0A=
+	/* those two are read-mostly, leave them at the end */=0A=
+	long tcp_prot_mem[3];=0A=
+	int tcp_memory_pressure;=0A=
+};=0A=
+=0A=
+long *sysctl_mem_tcp(struct mem_cgroup *memcg);=0A=
+struct percpu_counter *sockets_allocated_tcp(struct mem_cgroup *memcg);=0A=
+int *memory_pressure_tcp(struct mem_cgroup *memcg);=0A=
+struct res_counter *memory_allocated_tcp(struct mem_cgroup *memcg);=0A=
+int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);=0A=
+void tcp_destroy_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);=0A=
+=0A=
 extern atomic_long_t tcp_memory_allocated;=0A=
 extern struct percpu_counter tcp_sockets_allocated;=0A=
 extern int tcp_memory_pressure;=0A=
@@ -305,6 +321,7 @@ static inline int tcp_synq_no_recent_overflow(const str=
uct sock *sk)=0A=
 }=0A=
 =0A=
 extern struct proto tcp_prot;=0A=
+extern struct cg_proto tcp_cg_prot;=0A=
 =0A=
 #define TCP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.tcp_statistics=
, field)=0A=
 #define TCP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.tcp_stat=
istics, field)=0A=
@@ -1022,6 +1039,7 @@ static inline void tcp_openreq_init(struct request_so=
ck *req,=0A=
 	ireq->loc_port =3D tcp_hdr(skb)->dest;=0A=
 }=0A=
 =0A=
+extern void tcp_enter_memory_pressure_cg(struct sock *sk);=0A=
 extern void tcp_enter_memory_pressure(struct sock *sk);=0A=
 =0A=
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)=0A=
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h=0A=
index 498433d..1e18849 100644=0A=
--- a/include/net/transp_v6.h=0A=
+++ b/include/net/transp_v6.h=0A=
@@ -11,6 +11,7 @@ extern struct proto rawv6_prot;=0A=
 extern struct proto udpv6_prot;=0A=
 extern struct proto udplitev6_prot;=0A=
 extern struct proto tcpv6_prot;=0A=
+extern struct cg_proto tcpv6_cg_prot;=0A=
 =0A=
 struct flowi6;=0A=
 =0A=
diff --git a/mm/memcontrol.c b/mm/memcontrol.c=0A=
index 7d684d0..f14d7d2 100644=0A=
--- a/mm/memcontrol.c=0A=
+++ b/mm/memcontrol.c=0A=
@@ -49,6 +49,9 @@=0A=
 #include <linux/cpu.h>=0A=
 #include <linux/oom.h>=0A=
 #include "internal.h"=0A=
+#ifdef CONFIG_INET=0A=
+#include <net/tcp.h>=0A=
+#endif=0A=
 =0A=
 #include <asm/uaccess.h>=0A=
 =0A=
@@ -294,6 +297,10 @@ struct mem_cgroup {=0A=
 	 */=0A=
 	struct mem_cgroup_stat_cpu nocpu_base;=0A=
 	spinlock_t pcp_counter_lock;=0A=
+=0A=
+#ifdef CONFIG_INET=0A=
+	struct tcp_memcontrol tcp;=0A=
+#endif=0A=
 };=0A=
 =0A=
 /* Stuffs for move charges at task migration. */=0A=
@@ -377,7 +384,7 @@ enum mem_type {=0A=
 #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)=0A=
 =0A=
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);=0A=
-=0A=
+static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);=0A=
 static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)=0A=
 {=0A=
 	return (mem =3D=3D root_mem_cgroup);=0A=
@@ -387,6 +394,7 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup=
 *mem)=0A=
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM=0A=
 #ifdef CONFIG_INET=0A=
 #include <net/sock.h>=0A=
+#include <net/ip.h>=0A=
 =0A=
 void sock_update_memcg(struct sock *sk)=0A=
 {=0A=
@@ -451,6 +459,93 @@ u64 memcg_memory_allocated_read(struct mem_cgroup *mem=
cg, struct cg_proto *prot)=0A=
 				    RES_USAGE) >> PAGE_SHIFT ;=0A=
 }=0A=
 EXPORT_SYMBOL(memcg_memory_allocated_read);=0A=
+/*=0A=
+ * Pressure flag: try to collapse.=0A=
+ * Technical note: it is used by multiple contexts non atomically.=0A=
+ * All the __sk_mem_schedule() is of this nature: accounting=0A=
+ * is strict, actions are advisory and have some latency.=0A=
+ */=0A=
+void tcp_enter_memory_pressure_cg(struct sock *sk)=0A=
+{=0A=
+	struct mem_cgroup *memcg =3D sk->sk_cgrp;=0A=
+	if (!memcg->tcp.tcp_memory_pressure) {=0A=
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);=0A=
+		memcg->tcp.tcp_memory_pressure =3D 1;=0A=
+	}=0A=
+}=0A=
+EXPORT_SYMBOL(tcp_enter_memory_pressure_cg);=0A=
+=0A=
+long *sysctl_mem_tcp(struct mem_cgroup *memcg)=0A=
+{=0A=
+	return memcg-=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
