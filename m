Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E2CFE6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:22:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7MYYt014877
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:22:34 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 34EEE45DE55
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:22:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 034B945DE4E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:22:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DCADCE78001
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:22:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 95E0B1DB803C
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:22:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 6/7] cifs: Don't use PF_MEMALLOC
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Message-Id: <20091117162111.3DE8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:22:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Steve French <sfrench@samba.org>, linux-cifs-client@lists.samba.org, samba-technical@lists.samba.org
List-ID: <linux-mm.kvack.org>


Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
memory, anyone must not prevent it. Otherwise the system cause
mysterious hang-up and/or OOM Killer invokation.

Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs-client@lists.samba.org
Cc: samba-technical@lists.samba.org
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/cifs/connect.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 63ea83f..f9b1553 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -337,7 +337,6 @@ cifs_demultiplex_thread(struct TCP_Server_Info *server)
 	bool isMultiRsp;
 	int reconnect;
 
-	current->flags |= PF_MEMALLOC;
 	cFYI(1, ("Demultiplex PID: %d", task_pid_nr(current)));
 
 	length = atomic_inc_return(&tcpSesAllocCount);
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
