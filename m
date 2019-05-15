Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72A22C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 11:55:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26FBD20657
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 11:55:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="J2Ynm2oD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26FBD20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C89F66B0007; Wed, 15 May 2019 07:55:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C140E6B0008; Wed, 15 May 2019 07:55:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B02196B000A; Wed, 15 May 2019 07:55:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4782A6B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 07:55:45 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id x10so551325lfe.20
        for <linux-mm@kvack.org>; Wed, 15 May 2019 04:55:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=CfT2mw9Voryfx7z4pzvbGxS8fdbuS8Bjj6c0PWDezKs=;
        b=tvxZdubxILfxYL6Fd016V0geEsi6QCsD+B1cUhRZwki8pQhOjZ3W33jdFikZF/Q9bY
         a3k+RSovN4aQHgcBFi//jv+lGzNbBaI5afATaeD15vjHxTO0dkPrQIMK5SfVu9mj5t7U
         gqIITKpbzy4gZM5ewa0694EipLLzsxeP5uCmNwBmpZRnUHQv9XVctX2N+wluNZPjBK8R
         HYvvKnZlaFBkx2XTNkiRbUkOQ7DYZVgqYN5oUlDUkLwnrOQTo4xJ81VoGfwMnwHUDJR+
         0I/eJJgtrDAGZ8eYcxoUEkfA25rp5j9pnkn2hGM6hlMLxrU0M7XXW6Fn5yaKb5/LjSQY
         JSWQ==
X-Gm-Message-State: APjAAAWhLqRTx9cbBFCUGTQ1wNsiILdGJjE7GJYM7f+eYUSgKvT73Uco
	zqj7ubtWBCsAXtREClJ+2t8j+/vmRWhe1j91ari1e8DP3QDC1GeV9nb1ERcDVKu6cwr79pUI7V1
	anTfTvgL99dFptneds2pQoRwQYS+yYznhKsYGZbV+uv8jrgqHbgCIeOnUFzTMy1ztuQ==
X-Received: by 2002:a2e:824b:: with SMTP id j11mr19556807ljh.197.1557921344710;
        Wed, 15 May 2019 04:55:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+YzHRjsWnGxjhwSIOSB6lNXbRMNoynJdrt8KXNWsTV5c9YejV7loiocLr7Q+aLsgL0F6K
X-Received: by 2002:a2e:824b:: with SMTP id j11mr19556756ljh.197.1557921343459;
        Wed, 15 May 2019 04:55:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557921343; cv=none;
        d=google.com; s=arc-20160816;
        b=cZYtfkQSSnKXFrbHQvS2iu7sJrpPxAs07sza6cUJR3F8DcTZyYTKoIiSoe9uR6kcWR
         sHQDjSV80zoE8A2FZtTb4wFjLx7X7ms+axV2MSVJx13khCi19iR85h4RnwWx97WI5XR1
         HKuauKQB4L6Xm9vZnpETv+86WA8TWurlIUW3hedMUYeog0/ZiIXcEL2xIQkhIxUS6l8D
         8WZFFY92zfCdVNKVi1WljIdACX8k2U9PuCWIXXj2QeuSzUSVmvnEAHoPLIaXQqn65YAc
         9a02ExW6W/nV+fC6xe7cCzozUS5s4vnKrE8YjLptB7xkXCJd9mE9NgBQA145R2df6RS2
         evBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject:dkim-signature;
        bh=CfT2mw9Voryfx7z4pzvbGxS8fdbuS8Bjj6c0PWDezKs=;
        b=hBvbu4hm/j+h1+WIioBjNDKFSsv5wv2u8SzObZurG7cmjxyzs3nOuyXTgtPIQokjMS
         aSpCFjqNIgu5eXDE+irqe+Vxe3B/hdLiOVzjkfoyb74NTO8vQA1EBqUdRlTygEc5ByTO
         UP+H73tzc0JIcAiRQ2CMjBqf+1ep2Qk75DQGPEAMIixb0y9/O3Do/pgo+Q1DQOZZCSM+
         TcsWljBg8nC2zHaqywmONuoZtQ2IJpssuwUyI/svMTbYskMj1r+A6hGrinzJpvo7UAkM
         fMOKM/W62LQX10e1AHWMfKQsh0MntdorpKqE5KB70FsM+JEAvoctBZ1iIS38vb0T64WX
         xoDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=J2Ynm2oD;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [2a02:6b8:0:1472:2741:0:8b6:217])
        by mx.google.com with ESMTP id f9si1797161ljj.216.2019.05.15.04.55.43
        for <linux-mm@kvack.org>;
        Wed, 15 May 2019 04:55:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) client-ip=2a02:6b8:0:1472:2741:0:8b6:217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=J2Ynm2oD;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1472:2741:0:8b6:217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id D738C2E0ABC;
	Wed, 15 May 2019 14:55:42 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id 7Uaf6EnKr8-tgsS7u6u;
	Wed, 15 May 2019 14:55:42 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1557921342; bh=CfT2mw9Voryfx7z4pzvbGxS8fdbuS8Bjj6c0PWDezKs=;
	h=Message-ID:Date:To:From:Subject;
	b=J2Ynm2oDP1Lw2/V1Y9ufeN0W22FUMXnolWMJrZE6QZQ3N9yRRA+POCOF3gWyPv2d7
	 JlSLIwIdfa3ZsjusBfq51I9nYvXGu0NIorP9fsPGzs+NUcDwaazaG0SrYIc13KDJE9
	 AgFvJ6E+avYNVjR2T1fMO4kxaFzu/iFhiWAqq5MY=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:ed19:3833:7ce1:2324])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id GGfHxKOueD-tglO5KqC;
	Wed, 15 May 2019 14:55:42 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH RFC] proc/meminfo: add NetBuffers counter for socket buffers
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Date: Wed, 15 May 2019 14:55:41 +0300
Message-ID: <155792134187.1641.3858215257559626632.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Socket buffers always were dark-matter that lives by its own rules.
This patch adds line NetBuffers that exposes most common kinds of them.

TCP and UDP are most important species.
SCTP is added as example of modular protocol.
UNIX have no memory counter for now, should be easy to add.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/proc/meminfo.c  |    5 ++++-
 include/linux/mm.h |    6 ++++++
 mm/page_alloc.c    |    3 ++-
 net/core/sock.c    |   20 ++++++++++++++++++++
 net/sctp/socket.c  |    2 +-
 5 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 7bc14716fc5d..0ee2300a916d 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -41,6 +41,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	unsigned long sreclaimable, sunreclaim, misc_reclaimable;
 	unsigned long kernel_stack_kb, page_tables, percpu_pages;
 	unsigned long anon_pages, file_pages, swap_cached;
+	unsigned long net_buffers;
 	long kernel_misc;
 	int lru;
 
@@ -66,12 +67,13 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	kernel_stack_kb = global_zone_page_state(NR_KERNEL_STACK_KB);
 	page_tables = global_zone_page_state(NR_PAGETABLE);
 	percpu_pages = pcpu_nr_pages();
+	net_buffers = total_netbuffer_pages();
 
 	/* all other kinds of kernel memory allocations */
 	kernel_misc = i.totalram - i.freeram - anon_pages - file_pages
 		      - sreclaimable - sunreclaim - misc_reclaimable
 		      - (kernel_stack_kb >> (PAGE_SHIFT - 10))
-		      - page_tables - percpu_pages;
+		      - page_tables - percpu_pages - net_buffers;
 	if (kernel_misc < 0)
 		kernel_misc = 0;
 
@@ -137,6 +139,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "VmallocUsed:    ", 0ul);
 	show_val_kb(m, "VmallocChunk:   ", 0ul);
 	show_val_kb(m, "Percpu:         ", percpu_pages);
+	show_val_kb(m, "NetBuffers:     ", net_buffers);
 	show_val_kb(m, "KernelMisc:     ", kernel_misc);
 
 #ifdef CONFIG_MEMORY_FAILURE
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..d0a58355bfb7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2254,6 +2254,12 @@ extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern unsigned long arch_reserved_kernel_pages(void);
 #endif
 
+#ifdef CONFIG_NET
+extern unsigned long total_netbuffer_pages(void);
+#else
+static inline unsigned long total_netbuffer_pages(void) { return 0; }
+#endif
+
 extern __printf(3, 4)
 void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b13d3914176..fcdd7c6e72b9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5166,7 +5166,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu net_buffers:%lu\n"
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
@@ -5184,6 +5184,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_SHMEM),
 		global_zone_page_state(NR_PAGETABLE),
 		global_zone_page_state(NR_BOUNCE),
+		total_netbuffer_pages(),
 		global_zone_page_state(NR_FREE_PAGES),
 		free_pcp,
 		global_zone_page_state(NR_FREE_CMA_PAGES));
diff --git a/net/core/sock.c b/net/core/sock.c
index 75b1c950b49f..dfca4e024b74 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -142,6 +142,7 @@
 #include <trace/events/sock.h>
 
 #include <net/tcp.h>
+#include <net/udp.h>
 #include <net/busy_poll.h>
 
 static DEFINE_MUTEX(proto_list_mutex);
@@ -3573,3 +3574,22 @@ bool sk_busy_loop_end(void *p, unsigned long start_time)
 }
 EXPORT_SYMBOL(sk_busy_loop_end);
 #endif /* CONFIG_NET_RX_BUSY_POLL */
+
+#if IS_ENABLED(CONFIG_IP_SCTP)
+atomic_long_t sctp_memory_allocated;
+EXPORT_SYMBOL_GPL(sctp_memory_allocated);
+#endif
+
+unsigned long total_netbuffer_pages(void)
+{
+	unsigned long ret = 0;
+
+#if IS_ENABLED(CONFIG_IP_SCTP)
+	ret += atomic_long_read(&sctp_memory_allocated);
+#endif
+#ifdef CONFIG_INET
+	ret += atomic_long_read(&tcp_memory_allocated);
+	ret += atomic_long_read(&udp_memory_allocated);
+#endif
+	return ret;
+}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e4e892cc5644..9d11afdeeae4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -107,7 +107,7 @@ static int sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 			     enum sctp_socket_type type);
 
 static unsigned long sctp_memory_pressure;
-static atomic_long_t sctp_memory_allocated;
+extern atomic_long_t sctp_memory_allocated;
 struct percpu_counter sctp_sockets_allocated;
 
 static void sctp_enter_memory_pressure(struct sock *sk)

