Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFC4EC5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 13:52:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C526206CD
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 13:52:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C526206CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CC846B0006; Wed, 11 Sep 2019 09:52:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17DAF6B0007; Wed, 11 Sep 2019 09:52:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 093CE6B0008; Wed, 11 Sep 2019 09:52:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0199.hostedemail.com [216.40.44.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA3F36B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:52:56 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4DEEF824CA0B
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:52:56 +0000 (UTC)
X-FDA: 75922780752.29.waves24_8de45d379e623
X-HE-Tag: waves24_8de45d379e623
X-Filterd-Recvd-Size: 2806
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn [202.108.3.165])
	by imf04.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:52:54 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([222.131.67.234])
	by sina.com with ESMTP
	id 5D78FC2E0001F1D2; Wed, 11 Sep 2019 21:52:50 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 191039629314
From: Hillf Danton <hdanton@sina.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Mike Christie <mchristi@redhat.com>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	axboe@kernel.dk,
	James.Bottomley@HansenPartnership.com,
	martin.petersen@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-block@vger.kernel.org,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [RFC PATCH] Add proc interface to set PF_MEMALLOC flags
Date: Wed, 11 Sep 2019 21:52:37 +0800
Message-Id: <20190911135237.11248-1-hdanton@sina.com>
In-Reply-To: <20190911031348.9648-1-hdanton@sina.com>
References: <20190911031348.9648-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 11 Sep 2019 19:07:34 +0900
>=20
> But I guess that there is a problem.

Not a new one. (see commit 7dea19f9ee63)

> Setting PF_MEMALLOC_NOIO causes
> current_gfp_context() to mask __GFP_IO | __GFP_FS, but the OOM killer c=
annot
> be invoked when __GFP_FS is masked. As a result, any userspace thread w=
hich
> has PF_MEMALLOC_NOIO cannot invoke the OOM killer.

Correct.

> If the userspace thread
> which uses PF_MEMALLOC_NOIO is involved in memory reclaiming activities=
,
> the memory reclaiming activities won't be able to make forward progress=
 when
> the userspace thread triggered e.g. a page fault. Can the "userspace co=
mponents
> that can run in the IO path" survive without any memory allocation?

Good question.

It can be solved without oom killer involved because user should be
aware of the risk of PF_MEMALLOC_NOIO if they ask for the convenience.
OTOH we are able to control any abuse of it as you worry, knowing that
the combination of __GFP_FS and oom killer can not get more than 50 users
works done, and we have to pay as much attention as we can to the decisio=
ns
they make. In case of PF_MEMALLOC_NOIO, we simply fail the allocation
rather than killing a random victim.


--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3854,6 +3854,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, un
 	 * out_of_memory). Once filesystems are ready to handle allocation
 	 * failures more gracefully we should just bail out here.
 	 */
+	if (current->flags & PF_MEMALLOC_NOIO)
+		goto out;
=20
 	/* The OOM killer may not free memory on a specific node */
 	if (gfp_mask & __GFP_THISNODE)


