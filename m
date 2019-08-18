Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D565C3A59F
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:39:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DECE2146E
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:39:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UmY6BiMK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DECE2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B66AA6B000C; Sun, 18 Aug 2019 15:39:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B17356B000D; Sun, 18 Aug 2019 15:39:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A060D6B000E; Sun, 18 Aug 2019 15:39:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0014.hostedemail.com [216.40.44.14])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3296B000C
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 15:39:28 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 27FE8181AC9AE
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:39:28 +0000 (UTC)
X-FDA: 75836562816.24.brush99_1867f08ce8945
X-HE-Tag: brush99_1867f08ce8945
X-Filterd-Recvd-Size: 4765
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:39:27 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id p3so5622015pgb.9
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 12:39:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=tJjwWl4XQTgcmRcDEc+l30pX8XFo75tSFumPFai+auM=;
        b=UmY6BiMKjLfJtTbMPr2YL48+gSi6VOnzYOGmB49byG2y+gNWR+LHccMEOjU3uV6rzU
         vs47bj1Wda0bHM3M+0tVfVnkUn5JeYWMuWoPyJiWhssB5oqJi3lvuowfQ5qRiqzyKByF
         037PGyd0fWngnsSpBjBk4owPIqAYkSIl8DR9T1VCkYVvWLNNd/4SLogCYlENV5fXi/GI
         qnVGwINwsEAhgY5m/Vu9VC+dsD3inyTVFkMorxi2MckhRHGG3v9Saij0nBgVh07rb5wE
         OqTFjDg2ifQD/yQ8Uj40xNeOboRbiBcdRommtkDta5yDTw5vCbifx/WTDfU1ckZxVYSw
         PlKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=tJjwWl4XQTgcmRcDEc+l30pX8XFo75tSFumPFai+auM=;
        b=WSmYnBIQaMifijo5vLKEdmAAz3QY3FZFtcCR7oJL3Dse35J/QaMdZBiNtcpznxWitg
         mu9zagbliiCM/uMwHAsQ9iDZBfCEjLR13/YGHEpcfascixE6CHpyWivD3FOVWtgmwiWI
         DdY4si/zwcSRjk87rqzj3tDKMDx4F8rtQ5tZ0xwQUZ3ykCLuJRZTpWsXe1/2fQ+P+KO8
         mX4x3CYx7ZWglEfYRvrqltmfINjAwILs6eA7OfOWxSM0IVNR2UogXclCP+mbl9wDXZhB
         mrgRQHVm8/kZRbXjsA6lf2q+ekGmNDEeCBK+oI1iwGwfleMazWqu4saj9+7Mub3yL0wG
         DD2g==
X-Gm-Message-State: APjAAAXDYlsxoi8Of+ov+AoDqYxiWtLmp5uHgRgnh9TEEUvyMsCRz1G1
	nrUDCziqMvhWnyvYkxTIi3s=
X-Google-Smtp-Source: APXvYqx7tVVfV+B2SMb5KcGTV0Iw93mnZu+rvdEXioARTktPChwDBCq20S1nC96AwKkuvChntzXpWw==
X-Received: by 2002:a63:4e05:: with SMTP id c5mr16328693pgb.82.1566157166340;
        Sun, 18 Aug 2019 12:39:26 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id k5sm11318890pgo.45.2019.08.18.12.39.25
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Aug 2019 12:39:25 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	jhubbard@nvidia.com
Cc: jglisse@redhat.com,
	ira.weiny@intel.com,
	gregkh@linuxfoundation.org,
	arnd@arndb.de,
	william.kucharski@oracle.com,
	hch@lst.de,
	inux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>,
	linux-kernel@vger.kernel.org
Subject: [Linux-kernel-mentees][PATCH v6 1/2] sgi-gru: Convert put_page() to put_user_page*()
Date: Mon, 19 Aug 2019 01:08:54 +0530
Message-Id: <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel-mentees@lists.linuxfoundation.org
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufa=
ult.c
index 4b713a8..61b3447 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struc=
t *vma,
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D =
0)
 		return -EFAULT;
 	*paddr =3D page_to_phys(page);
-	put_page(page);
+	put_user_page(page);
 	return 0;
 }
=20
--=20
2.7.4


