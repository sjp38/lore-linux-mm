Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 72FE09000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 00:38:19 -0400 (EDT)
Received: by wwj40 with SMTP id 40so451538wwj.26
        for <linux-mm@kvack.org>; Wed, 06 Jul 2011 21:38:16 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 38032] New: default values of
 /proc/sys/net/ipv4/udp_mem does not consider huge page allocation
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1310011173.2481.20.camel@edumazet-laptop>
References: <bug-38032-10286@https.bugzilla.kernel.org/>
	 <20110706160318.2c604ae9.akpm@linux-foundation.org>
	 <6.2.5.6.2.20110706212254.05bff4c8@binnacle.cx>
	 <1310011173.2481.20.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 07 Jul 2011 06:38:10 +0200
Message-ID: <1310013490.2481.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: starlight@binnacle.cx, David Miller <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org, Rafael Aquini <aquini@linux.com>

Lets use following patch ?

[PATCH] net: refine {udp|tcp|sctp}_mem limits

Current tcp/udp/sctp global memory limits are not taking into account
hugepages allocations, and allow 50% of ram to be used by buffers of a
single protocol [ not counting space used by sockets / inodes ...]

Lets use nr_free_buffer_pages() and allow a default of 1/8 of kernel ram
per protocol, and a minimum of 128 pages.
Heavy duty machines sysadmins probably need to tweak limits anyway.


References: https://bugzilla.stlinux.com/show_bug.cgi?id=38032
Reported-by: starlight <starlight@binnacle.cx>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp.c      |   10 ++--------
 net/ipv4/udp.c      |   10 ++--------
 net/sctp/protocol.c |   11 +----------
 3 files changed, 5 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 054a59d..46febca 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3220,7 +3220,7 @@ __setup("thash_entries=", set_thash_entries);
 void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
-	unsigned long nr_pages, limit;
+	unsigned long limit;
 	int i, max_share, cnt;
 	unsigned long jiffy = jiffies;
 
@@ -3277,13 +3277,7 @@ void __init tcp_init(void)
 	sysctl_tcp_max_orphans = cnt / 2;
 	sysctl_max_syn_backlog = max(128, cnt / 256);
 
-	/* Set the pressure threshold to be a fraction of global memory that
-	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
-	 * memory, with a floor of 128 pages.
-	 */
-	nr_pages = totalram_pages - totalhigh_pages;
-	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
-	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
 	sysctl_tcp_mem[0] = limit / 4 * 3;
 	sysctl_tcp_mem[1] = limit;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 48cd88e..198f75b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2209,16 +2209,10 @@ void __init udp_table_init(struct udp_table *table, const char *name)
 
 void __init udp_init(void)
 {
-	unsigned long nr_pages, limit;
+	unsigned long limit;
 
 	udp_table_init(&udp_table, "UDP");
-	/* Set the pressure threshold up by the same strategy of TCP. It is a
-	 * fraction of global memory that is up to 1/2 at 256 MB, decreasing
-	 * toward zero with the amount of memory, with a floor of 128 pages.
-	 */
-	nr_pages = totalram_pages - totalhigh_pages;
-	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
-	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
 	sysctl_udp_mem[0] = limit / 4 * 3;
 	sysctl_udp_mem[1] = limit;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 67380a2..207175b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1058,7 +1058,6 @@ SCTP_STATIC __init int sctp_init(void)
 	int status = -EINVAL;
 	unsigned long goal;
 	unsigned long limit;
-	unsigned long nr_pages;
 	int max_share;
 	int order;
 
@@ -1148,15 +1147,7 @@ SCTP_STATIC __init int sctp_init(void)
 	/* Initialize handle used for association ids. */
 	idr_init(&sctp_assocs_id);
 
-	/* Set the pressure threshold to be a fraction of global memory that
-	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
-	 * memory, with a floor of 128 pages.
-	 * Note this initializes the data in sctpv6_prot too
-	 * Unabashedly stolen from tcp_init
-	 */
-	nr_pages = totalram_pages - totalhigh_pages;
-	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
-	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
 	sysctl_sctp_mem[0] = limit / 4 * 3;
 	sysctl_sctp_mem[1] = limit;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
