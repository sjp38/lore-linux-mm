Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 76A2E6B0002
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 22:24:59 -0400 (EDT)
Date: Mon, 25 Mar 2013 12:54:45 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130325022445.GH29157@marvin.atrad.com.au>
References: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
 <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
 <20130321070750.GV30145@marvin.atrad.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130321070750.GV30145@marvin.atrad.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jonathan Woithe <jwoithe@atrad.com.au>

This post ties up a few loose ends in this thread which remained after my
21 March 2013 post.

 * The memory leak was not present in 2.6.36.

 * The patch to 2.6.35.11 at the end of this email (based on
   48e6b121605512d87f8da1ccd014313489c19630 from linux-stable) resolves the
   memory leak in 2.6.35.11.

This gives us a workable solution while we await fixes to current mainline
in the r8169 driver.  Once that's done we can revalidate our systems against
a more recent kernel and start shipping that.

Thanks to those who assisted with this issue.

Regards
  jonathan

--- a/net/netlink/af_netlink.c	2013-03-25 10:32:15.365781434 +1100
+++ b/net/netlink/af_netlink.c	2013-03-25 10:32:15.373782107 +1100
@@ -1387,6 +1387,8 @@ static int netlink_sendmsg(struct kiocb
 	err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags&MSG_DONTWAIT);
 
 out:
+	scm_destroy(siocb->scm);
+	siocb->scm = NULL;
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
