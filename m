Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C111D6B0283
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:09:42 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e26so1691552pgv.16
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:09:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v32sor6005198plb.104.2018.01.10.18.09.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:09:41 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 26/38] sctp: Define usercopy region in SCTP proto slab cache
Date: Wed, 10 Jan 2018 18:02:58 -0800
Message-Id: <1515636190-24061-27-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Vlad Yasevich <vyasevich@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, "David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org, netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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

This region is known as the slab cache's usercopy region. Slab caches
can now check that each dynamically sized copy operation involving
cache-managed memory falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: split from network patch, move struct members adjacent]
[kees: add SCTPv6 struct whitelist, provide usage trace]
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-sctp@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/sctp/structs.h | 9 +++++++--
 net/sctp/socket.c          | 8 ++++++++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 16f949eef52f..6168e3449131 100644
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
index 014847e25648..efbc8f52c531 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -8470,6 +8470,10 @@ struct proto sctp_prot = {
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
@@ -8509,6 +8513,10 @@ struct proto sctpv6_prot = {
 	.unhash		= sctp_unhash,
 	.get_port	= sctp_get_port,
 	.obj_size	= sizeof(struct sctp6_sock),
+	.useroffset	= offsetof(struct sctp6_sock, sctp.subscribe),
+	.usersize	= offsetof(struct sctp6_sock, sctp.initmsg) -
+				offsetof(struct sctp6_sock, sctp.subscribe) +
+				sizeof_field(struct sctp6_sock, sctp.initmsg),
 	.sysctl_mem	= sysctl_sctp_mem,
 	.sysctl_rmem	= sysctl_sctp_rmem,
 	.sysctl_wmem	= sysctl_sctp_wmem,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
