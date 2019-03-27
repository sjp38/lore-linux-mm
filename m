Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB7ADC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 23:42:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6497D2075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 23:42:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6497D2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004356B0007; Wed, 27 Mar 2019 19:42:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF6AE6B0008; Wed, 27 Mar 2019 19:41:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0D396B000A; Wed, 27 Mar 2019 19:41:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB9656B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 19:41:59 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c67so16140542qkg.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:41:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=BeB7hoeWy9kjQaS4Sd5OdJaic8mGCKYcftDRgfnyLmQ=;
        b=jpTUb3HjUZ/R7STZ2fRHgnVB/xhMTyIaZx06TC8SP44Jy8D59zqPAeFxytooU4CPzt
         0knXQU06GHlT2tvsxVoOBNbar6NH+WoSwb4XFjbrhdTtaWLKKXpvC561G2oWTDsLT/j3
         qAjsCXyK0B0c4vVRL2dZW8K2yH4T/VnRH0yu5k5HnHGkFaq03EJ1VEZ72HOpRuiA4MqR
         V+Y3hUzEVb3rc1xaUZHirYf8BxavMuDn0xA+Fs/ide/tY8LNIxookA5xz04ojmLWwe2M
         QYZCF06qibSCqZZqLUpss9oX5XML6dhA4Y1RXO98BU/6oyWLyvGZMANrg0f4uhKUGbb6
         vbLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU2ncNfXTieb95++Tz1vY4JqgFLrc9vwSP1T/PLQp2U1Olro8X4
	9QrRlRvfw/3459CTurjT4Z+fTRrfqvhxvYmCKqga0qQqj+lIP90uoRGi4exvurq3Qf56b02JKCw
	RiUv0PSqdJiOnr6J1WDvFcwCJw4GMXkm66freiVWcRmYvGYgho8eb4zb2lgTtQruqrg==
X-Received: by 2002:a0c:c68f:: with SMTP id d15mr33368183qvj.72.1553730119541;
        Wed, 27 Mar 2019 16:41:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQuvV2hSVyhqx+KDt3exV9i1tksUkMtQZyZOLtGSWV2iwWqjo0cKjsSQMTqor2J9unFM7W
X-Received: by 2002:a0c:c68f:: with SMTP id d15mr33368157qvj.72.1553730119027;
        Wed, 27 Mar 2019 16:41:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553730119; cv=none;
        d=google.com; s=arc-20160816;
        b=J/WOUBSXoTxoCZlOak41K+qVy4RD/s/RVRxkmIYYj80I4NFisn+SGeHHI2QpuZixKZ
         aa2JmbO3yQNTSc7nLsm/NIjrYhiEKLx2zwtIcPJOL2UmKwodGdWpTePnAA7NuCjR6TMe
         rR/nqJOetpP2SUtptX8TP2ZJ2SguOtGYsr4gu0L0CGGmkUOY6vtpI34eDc7yNyDNVGaP
         9GdmZJLd6Zfs1OfRT74vaLCW1ki478iHNYEtnNB7i3jH6rBI+4PMjTIK2Sl6MW+UZaAy
         zdu8RJKlqAKcoRPziy9DgQJ2J1Bv18U6YDQVQB3lXVAOv/2oWoggl8gGiRXYjGP+quKY
         a27A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:organization;
        bh=BeB7hoeWy9kjQaS4Sd5OdJaic8mGCKYcftDRgfnyLmQ=;
        b=dRegZkmn+W2iBiFZhSWtvDD4yIgIxCtsGQWXxbDhSrA1RBPSGzSmPrUFkM3xlpCGhK
         6K8Wz8WAXaWbAh5cGOXiRzDKgP7xNUEKY1aE6SpH9Tf2BSxtYs2pLRB049GDcfuR3QxC
         y0D/2RCZWeIBba602xiSiARj9SNgqHlRz+InMwYc/5E6UJ2eRlyqyf8jq9YfYFAlr4OE
         TWVQFqxrjaCOqKZPp95A4D9/x2xu5bzvg7j3W5Pg3hPYHJFC0/muScdHYLp1OOnFUiKU
         F/dT2SU5QzB0ZaPNSBgFjFn6p+4awhSKrgjEZwEwTktwsmERWcw8aGmUUhlTku2dD+mP
         ZjOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c11si3044522qko.203.2019.03.27.16.41.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 16:41:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 48E54C079903;
	Wed, 27 Mar 2019 23:41:58 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-98.rdu2.redhat.com [10.10.121.98])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C1ED95D9C4;
	Wed, 27 Mar 2019 23:41:56 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 11/68] vfs: Convert zsmalloc to use the new mount API
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>,
 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 dhowells@redhat.com
Date: Wed, 27 Mar 2019 23:41:55 +0000
Message-ID: <155373011498.7602.17060911792199285815.stgit@warthog.procyon.org.uk>
In-Reply-To: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
References: <155372999953.7602.13784796495137723805.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 27 Mar 2019 23:41:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert the zsmalloc filesystem to the new internal mount API as the old
one will be obsoleted and removed.  This allows greater flexibility in
communication of mount parameters between userspace, the VFS and the
filesystem.

See Documentation/filesystems/mount_api.txt for more information.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Minchan Kim <minchan@kernel.org>
cc: Nitin Gupta <ngupta@vflare.org>
cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
cc: linux-mm@kvack.org
---

 mm/zsmalloc.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0787d33b80d8..02bfc7f70fab 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -52,6 +52,7 @@
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/migrate.h>
 #include <linux/pagemap.h>
 #include <linux/fs.h>
@@ -1814,19 +1815,21 @@ static void lock_zspage(struct zspage *zspage)
 	} while ((page = get_next_page(page)) != NULL);
 }
 
-static struct dentry *zs_mount(struct file_system_type *fs_type,
-				int flags, const char *dev_name, void *data)
-{
-	static const struct dentry_operations ops = {
-		.d_dname = simple_dname,
-	};
+static const struct dentry_operations zs_dentry_operations = {
+	.d_dname = simple_dname,
+};
 
-	return mount_pseudo(fs_type, "zsmalloc:", NULL, &ops, ZSMALLOC_MAGIC);
+
+static int zs_init_fs_context(struct fs_context *fc)
+{
+	return vfs_init_pseudo_fs_context(fc, "zsmalloc:",
+					  NULL, NULL,
+					  &zs_dentry_operations, ZSMALLOC_MAGIC);
 }
 
 static struct file_system_type zsmalloc_fs = {
 	.name		= "zsmalloc",
-	.mount		= zs_mount,
+	.init_fs_context = zs_init_fs_context,
 	.kill_sb	= kill_anon_super,
 };
 

