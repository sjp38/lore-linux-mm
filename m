Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27E83C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:10:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E38DE2184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 16:10:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E38DE2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AA778E0006; Thu, 14 Mar 2019 12:10:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65A388E0001; Thu, 14 Mar 2019 12:10:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 525EF8E0006; Thu, 14 Mar 2019 12:10:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DDEA8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:10:04 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l87so5133046qki.10
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:10:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=j5uUCQJBz5JmKP1KlHzae1+TV6NX8eEj5Y5pDLdlYvs=;
        b=qFdsDrsu4t3CUZstwn3QxMHcgdsCqL3VuDuEbhsCMV95Rt4MfZi/eLNXq7zR5VIDeD
         Hx0FPx21okR3zMK/8NObuJYCechE+/H+H8ll6cRuqe49/B7HkU8BwUL5FAgqfSPYRzcf
         hHoFSogvuBW2yGktW0Q7oSIyXEd2rFVVlLXLejczAX0tMGciJXkG7sqAsGG3wsSHaJOV
         arnawlClaLt5xJQ4121wLYikZIBW89hBt6cB46ID4eoX+7GbGsC1j8hxnZ6mRVuepxWd
         l9kHDTQB8VUrU261nXC9hSRuSrfyFwixH/zuk62j0SKHfL+lz/zscJLKcmlm/QBGmhpm
         MF7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWREwEyrcSYYv9SMb4x6dd1yBGVFOTh3Go2kh+UR425x12v7ewY
	+EbS4u4Y9RQDk8yC2MIeYSBRxcQ+I594a78ikCx3iwKw1CGFJWe1zG1EdsdFXAg2Gh5DMdlLyQq
	y8l/yCCbi+CdYV08bIhdywsdNvKQWF2SoTPnYE51J25Ysrk8Z8qr9XqMm1iNiUZr+yg==
X-Received: by 2002:a0c:b5ca:: with SMTP id o10mr39131116qvf.147.1552579803953;
        Thu, 14 Mar 2019 09:10:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxe6OqQFMyLtXs7L33S7WPLyh4yMuqDEP8TzRAzM3MUALN1fIBC2iWG5akPmzNtyzgx1qfE
X-Received: by 2002:a0c:b5ca:: with SMTP id o10mr39131046qvf.147.1552579803042;
        Thu, 14 Mar 2019 09:10:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552579803; cv=none;
        d=google.com; s=arc-20160816;
        b=iHfE3bsxm4bDzhAS3OhqExyBuqacEHUa2Dugx8g8uwIQanWWZoLRTBWBPeMzjtq0Xd
         fB0M/J8hUPmHv4rXi5JZ1oCbP8WpaPimvsdiWuCIpNFD4riB+OcwxS31Iy5jiLkxdueq
         LWB/Cua6tqVjC4rErFZ9F/ePdqmwmf6oG1v6k7m8UobsDbCblqYLu20tJTXsZtGuzp3o
         s4qH83p0ceSZzZuCe0jP+GoHRKl7NJ4Cx8ejqKB2TzO8bsyRRVThup9oPlzuYXOQhDjL
         Uq4mz2muYDFi2FXcyGPs0tf1FnE380wXJh6TUx652zCQej1AJMQi7phZmlW7KYE+kjBH
         6Tqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:organization;
        bh=j5uUCQJBz5JmKP1KlHzae1+TV6NX8eEj5Y5pDLdlYvs=;
        b=Nuz+i8FO8lPoa3Cj974fCi1Bn5Y7DixtcJX4CKLd05JewkTxdb35yA1guPOl5ALjSP
         ERHFVsilypeOxew6STZDUjBbMjiSqIa74xtmgT2P4E9Q1bi4Pbh5amINLqgT2RfHLz7p
         MaSrR6fIxVYC39FPjDlZA3/0/WiRXjjwapg4wM5+yc6r5UcrAoWrBpNP7A0m3x926Jwf
         NectPjGvzWxqj0MEydGaJHWgIwGAop518P7Aj/JI7naXW4GQuDjQyYLmYDLrTdKmt7Ij
         VxLJhERnb9ruAFIGZVZwyQBq3avKGV8FKc6QnubAUEPQzoo3z+UFIcp69EZWaG9+sxgL
         T7+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m126si7937609qkc.163.2019.03.14.09.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 09:10:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2D09511DB89;
	Thu, 14 Mar 2019 16:10:02 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-148.rdu2.redhat.com [10.10.121.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9D9BB5D9C4;
	Thu, 14 Mar 2019 16:10:00 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [PATCH 08/38] vfs: Convert zsmalloc to fs_context
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>,
 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org,
 dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org
Date: Thu, 14 Mar 2019 16:09:59 +0000
Message-ID: <155257979989.13720.3823457480635712878.stgit@warthog.procyon.org.uk>
In-Reply-To: <155257972443.13720.11743171471060355965.stgit@warthog.procyon.org.uk>
References: <155257972443.13720.11743171471060355965.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 14 Mar 2019 16:10:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
 

