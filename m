Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5516B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 17:25:32 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id nc12so919723qeb.26
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 14:25:32 -0800 (PST)
Received: from mailrelay.anl.gov (mailrelay.anl.gov. [130.202.101.22])
        by mx.google.com with ESMTPS id v3si19366386qat.101.2013.12.12.14.25.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 14:25:31 -0800 (PST)
Received: from zimbra.anl.gov (zimbra.anl.gov [130.202.101.12])
	by mailrelay.anl.gov (Postfix) with ESMTP id 45E937CC088
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 16:25:28 -0600 (CST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra.anl.gov (Postfix) with ESMTP id 2CA0829E002
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 16:25:28 -0600 (CST)
Received: from zimbra.anl.gov ([127.0.0.1])
	by localhost (zimbra.anl.gov [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 9Vje-Ycad0rN for <linux-mm@kvack.org>;
	Thu, 12 Dec 2013 16:25:28 -0600 (CST)
Received: from scrappy.mcs.anl.gov (scrappy.mcs.anl.gov [140.221.11.122])
	by zimbra.anl.gov (Postfix) with ESMTPSA id 1536C29E001
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 16:25:28 -0600 (CST)
Date: Thu, 12 Dec 2013 16:25:27 -0600
From: Kamil Iskra <iskra@mcs.anl.gov>
Subject: [PATCH] mm/memory-failure.c: send "action optional" signal to an
 arbitrary thread
Message-ID: <20131212222527.GD8605@mcs.anl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Please find below a trivial patch that changes the sending of BUS_MCEERR_AO
SIGBUS signals so that they can be handled by an arbitrary thread of the
target process.  The current implementation makes it impossible to create a
separate, dedicated thread to handle such errors, as the signal is always
sent to the main thread.

Also, do I understand it correctly that "action required" faults *must* be
handled by the thread that triggered the error?  I guess it makes sense for
it to be that way, even if it circumvents the "dedicated handling thread"
idea...

The patch is against the 3.12.4 kernel.

--- mm/memory-failure.c.orig	2013-12-08 10:18:58.000000000 -0600
+++ mm/memory-failure.c	2013-12-12 11:43:03.973334767 -0600
@@ -219,7 +219,7 @@ static int kill_proc(struct task_struct
 		 * to SIG_IGN, but hopefully no one will do that?
 		 */
 		si.si_code = BUS_MCEERR_AO;
-		ret = send_sig_info(SIGBUS, &si, t);  /* synchronous? */
+		ret = group_send_sig_info(SIGBUS, &si, t);  /* synchronous? */
 	}
 	if (ret < 0)
 		printk(KERN_INFO "MCE: Error sending signal to %s:%d: %d\n",

Thanks,

Kamil

-- 
Kamil Iskra, PhD
Argonne National Laboratory, Mathematics and Computer Science Division
9700 South Cass Avenue, Building 240, Argonne, IL 60439, USA
phone: +1-630-252-7197  fax: +1-630-252-5986

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
