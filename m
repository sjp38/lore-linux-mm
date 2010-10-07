Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1AAD76B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 02:32:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o976W6sN001807
	for <linux-mm@kvack.org> (envelope-from seto.hidetoshi@jp.fujitsu.com);
	Thu, 7 Oct 2010 15:32:07 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EC1245DE61
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:32:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7356545DE5B
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:32:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C3D9E38003
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:32:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0145BE08004
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 15:32:01 +0900 (JST)
Message-ID: <4CAD6943.2020805@jp.fujitsu.com>
Date: Thu, 07 Oct 2010 15:31:31 +0900
From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] HWPOISON: Copy si_addr_lsb to user
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org> <1286398141-13749-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286398141-13749-3-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

(2010/10/07 5:48), Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> The original hwpoison code added a new siginfo field si_addr_lsb to
> pass the granuality of the fault address to user space. Unfortunately
> this field was never copied to user space. Fix this here.
> 
> I added explicit checks for the MCEERR codes to avoid having
> to patch all potential callers to initialize the field.

Now QEMU uses signalfd to catch the SIGBUS delivered to the
main thread, so I think similar fix to copy lsb to user is
required for signalfd too. 


Thanks,
H.Seto

=====

From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Subject: [PATCH] signalfd: add support addr_lsb

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 fs/signalfd.c            |   10 ++++++++++
 include/linux/signalfd.h |    3 ++-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fs/signalfd.c b/fs/signalfd.c
index 1c5a6ad..3e28173 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -99,6 +99,16 @@ static int signalfd_copyinfo(struct signalfd_siginfo __user *uinfo,
 #ifdef __ARCH_SI_TRAPNO
 		err |= __put_user(kinfo->si_trapno, &uinfo->ssi_trapno);
 #endif
+#ifdef BUS_MCEERR_AO
+		/* 
+		 * Other callers might not initialize the si_lsb field,
+		 * so check explicitely for the right codes here.
+		 */
+		if (kinfo->si_code == BUS_MCEERR_AR ||
+		    kinfo->si_code == BUS_MCEERR_AO)
+			err |= __put_user((short) kinfo->si_addr_lsb,
+					  &uinfo->ssi_addr_lsb);
+#endif
 		break;
 	case __SI_CHLD:
 		err |= __put_user(kinfo->si_pid, &uinfo->ssi_pid);
diff --git a/include/linux/signalfd.h b/include/linux/signalfd.h
index b363b91..3ff4961 100644
--- a/include/linux/signalfd.h
+++ b/include/linux/signalfd.h
@@ -33,6 +33,7 @@ struct signalfd_siginfo {
 	__u64 ssi_utime;
 	__u64 ssi_stime;
 	__u64 ssi_addr;
+	__u16 ssi_addr_lsb;
 
 	/*
 	 * Pad strcture to 128 bytes. Remember to update the
@@ -43,7 +44,7 @@ struct signalfd_siginfo {
 	 * comes out of a read(2) and we really don't want to have
 	 * a compat on read(2).
 	 */
-	__u8 __pad[48];
+	__u8 __pad[46];
 };
 
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
