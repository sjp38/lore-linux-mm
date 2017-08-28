Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83CEA6B04AD
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:43:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so2638371pgb.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:59 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id w9si995054plk.601.2017.08.28.14.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:43:58 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id r133so5005256pgr.3
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:58 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 21/30] sctp: Define usercopy region in SCTP proto slab cache
Date: Mon, 28 Aug 2017 14:35:02 -0700
Message-Id: <1503956111-36652-22-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Vlad Yasevich <vyasevich@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, "David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

The SCTP socket event notification subscription information need to be
copied to/from userspace. In support of usercopy hardening, this patch
defines a region in the struct proto slab cache in which userspace copy
operations are allowed. Additionally moves the usercopy fields to be
adjacent for the region to cover both.

example usage trace:

    net/sctp/socket.c:
        sctp_getsockopt_events(...):
            ...
            copy_to_user(..., &sctp_sk(sk)->subscribe, len)

        sctp_setsockopt_events(...):
            ...
            copy_from_user(&sctp_sk(sk)->subscribe, ..., optlen)

        sctp_getsockopt_initmsg(...):
            ...
            copy_to_user(..., &sctp_sk(sk)->initmsg, len)

This region is known as the slab cache's usercopy region. Slab caches can
now check that each copy operation involving cache-managed memory falls
entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: split from network patch, move struct member adjacent, provide usage]
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-sctp@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/sctp/structs.h | 9 +++++++--
 net/sctp/socket.c          | 4 ++++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5ab29af8ca8a..f1d7810e200e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -202,12 +202,17 @@ struct sctp_sock {
 	/* Flags controlling Heartbeat, SACK delay, and Path MTU Discovery. */
 	__u32 param_flags;
 
-	struct sctp_initmsg initmsg;
 	struct sctp_rtoinfo rtoinfo;
 	struct sctp_paddrparams paddrparam;
-	struct sctp_event_subscribe subscribe;
 	struct sctp_assocparams assocparams;
 
+	/*
+	 * These two structures must be grouped together for the usercopy
+	 * whitelist region.
+	 */
+	struct sctp_event_subscribe subscribe;
+	struct sctp_initmsg initmsg;
+
 	int user_frag;
 
 	__u32 autoclose;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1db478e34520..c8784cb216e4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -8235,6 +8235,10 @@ struct proto sctp_prot = {
 	.unhash      =	sctp_unhash,
 	.get_port    =	sctp_get_port,
 	.obj_size    =  sizeof(struct sctp_sock),
+	.useroffset  =  offsetof(struct sctp_sock, subscribe),
+	.usersize    =  offsetof(struct sctp_sock, initmsg) -
+				offsetof(struct sctp_sock, subscribe) +
+				sizeof_field(struct sctp_sock, initmsg),
 	.sysctl_mem  =  sysctl_sctp_mem,
 	.sysctl_rmem =  sysctl_sctp_rmem,
 	.sysctl_wmem =  sysctl_sctp_wmem,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
