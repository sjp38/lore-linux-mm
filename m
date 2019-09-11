Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34BDCC49ED7
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 03:14:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5BE221928
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 03:14:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5BE221928
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F4396B0005; Tue, 10 Sep 2019 23:14:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A5E16B0006; Tue, 10 Sep 2019 23:14:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BAD46B0007; Tue, 10 Sep 2019 23:14:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0013.hostedemail.com [216.40.44.13])
	by kanga.kvack.org (Postfix) with ESMTP id 25D956B0005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:14:05 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B9BFC181AC9C4
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:14:04 +0000 (UTC)
X-FDA: 75921170808.18.book56_5da7479f9d254
X-HE-Tag: book56_5da7479f9d254
X-Filterd-Recvd-Size: 2502
Received: from r3-18.sinamail.sina.com.cn (r3-18.sinamail.sina.com.cn [202.108.3.18])
	by imf21.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 03:14:03 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([61.148.244.178])
	by sina.com with ESMTP
	id 5D7866760000B868; Wed, 11 Sep 2019 11:14:00 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 61573515074644
From: Hillf Danton <hdanton@sina.com>
To: Mike Christie <mchristi@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	axboe@kernel.dk,
	James.Bottomley@HansenPartnership.com,
	martin.petersen@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-block@vger.kernel.org,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
Date: Wed, 11 Sep 2019 11:13:48 +0800
Message-Id: <20190911031348.9648-1-hdanton@sina.com>
In-Reply-To: <20190910100000.mcik63ot6o3dyzjv@box.shutemov.name>
References: 
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 10 Sep 2019 11:06:03 -0500 From: Mike Christie <mchristi@redhat.c=
om>
>
> > Really? Without any privilege check? So any random user can tap into
> > __GFP_NOIO allocations?
>
> That was a mistake on my part. I will add it in.
>
You may alternatively madvise a nutcracker as long as you would have
added a sledgehammer under /proc instead of a gavel.

--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -45,6 +45,7 @@
 #define MADV_SEQUENTIAL	2		/* expect sequential page references */
 #define MADV_WILLNEED	3		/* will need these pages */
 #define MADV_DONTNEED	4		/* don't need these pages */
+#define MADV_NOIO	5		/* set PF_MEMALLOC_NOIO */
=20
 /* common parameters: try to keep these consistent across architectures =
*/
 #define MADV_FREE	8		/* free pages only if memory pressure */
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -716,6 +716,7 @@ madvise_behavior_valid(int behavior)
 	case MADV_WILLNEED:
 	case MADV_DONTNEED:
 	case MADV_FREE:
+	case MADV_NOIO:
 #ifdef CONFIG_KSM
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
@@ -813,6 +814,11 @@ SYSCALL_DEFINE3(madvise, unsigned long,
 	if (!madvise_behavior_valid(behavior))
 		return error;
=20
+	if (behavior =3D=3D MADV_NOIO) {
+		current->flags |=3D PF_MEMALLOC_NOIO;
+		return 0;
+	}
+
 	if (start & ~PAGE_MASK)
 		return error;
 	len =3D (len_in + ~PAGE_MASK) & PAGE_MASK;


