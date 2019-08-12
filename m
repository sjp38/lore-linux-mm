Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F32DC41514
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:51:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 533442084D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:51:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n9WdsBYC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 533442084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 360DF6B0005; Sun, 11 Aug 2019 21:50:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C2E86B0006; Sun, 11 Aug 2019 21:50:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D0B6B0008; Sun, 11 Aug 2019 21:50:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0234.hostedemail.com [216.40.44.234])
	by kanga.kvack.org (Postfix) with ESMTP id E3B406B0005
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 21:50:58 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8175E181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:50:58 +0000 (UTC)
X-FDA: 75812097396.25.ants91_5fc50da95874f
X-HE-Tag: ants91_5fc50da95874f
X-Filterd-Recvd-Size: 6119
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:50:57 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id m9so47106173pls.8
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:50:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=//FfBrFJF4GgHRR+yYGohW47iWmsEIpsgR4o2CfLEaI=;
        b=n9WdsBYCNshNyrjNwoA988ZTa5cUmZ3ftfo2srk4qVaeFk/3QoLLi5AAHL4AElSmiI
         XuhzXcej3mP/qZgB3XHsGbTfB/yNKw6cCUUIAPQ+5Nz8QE6P37CaiJAF1juYEdwzcQ7x
         KCBBLQdzMFyQAH/huuHEICl517WeOf9evlQYRM6ra2qmGObt90NYEQrc2g3Hrh2Z96nu
         KDGoR5r30ngur4PCtV8FhCZSZwFtTuDq2bAvEGOaEF6xs7+I2IMBDgXvMsOlYXQ02UbB
         3XrvtA2d2QJxWudzhOEkOmMrqZS8v6TJDdTbi1eDdq4ek8o80TJA5b2A6NTjpOCVITJa
         5I0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=//FfBrFJF4GgHRR+yYGohW47iWmsEIpsgR4o2CfLEaI=;
        b=hfaTR1vzgphwVn6hdXoEj/GShs7F79j7pjSuEbfGM0gmjJ+BuNatvWp4BZ73Vfm+Gb
         +eo8s+KqXX9znsawUk+x0Hfq3sCsEcCK4wfl2Nb6yBdt02do74G1RirxRkACsZ5WIymp
         /ppHweWs2Rqvj1EcLSPoxWC7ifyDnQpHE5cUB1Te/y03jewmiYxU4IMi17U7NdPkMyWm
         OlYiFjz0AyDjblFAalUw5ctc4+KkD8WNHW4xKfw4O6Npl4BCC5y1HF4dBgiT1v56uDKD
         vfHKPtfGgelsH8TQa2llZyEhD7VLgMj8BFkdMEFgpl9fc+qT2u4cNrTR9gTWdNbfkkQ7
         egLg==
X-Gm-Message-State: APjAAAW7hk7vP68T9Lp2TtZPj4wG2JZ5b7s6P8vS3COkcXcQ2VxbJ5zs
	UEgbu46btqV2yGFsXHABrZQ=
X-Google-Smtp-Source: APXvYqzT/0PLSkZoDJi/ZIzWxvm8QO/lLOlBRLMJ5/ogboYNq/cgR98nTHd4GJwrVGgRFe2BKV9BHg==
X-Received: by 2002:a17:902:b604:: with SMTP id b4mr15581107pls.94.1565574657032;
        Sun, 11 Aug 2019 18:50:57 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id j20sm100062363pfr.113.2019.08.11.18.50.56
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 18:50:56 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 1/2] mm/gup: introduce FOLL_PIN flag for get_user_pages()
Date: Sun, 11 Aug 2019 18:50:43 -0700
Message-Id: <20190812015044.26176-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190812015044.26176-1-jhubbard@nvidia.com>
References: <20190812015044.26176-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

FOLL_PIN is set by vaddr_pin_pages(). This is different than
FOLL_LONGTERM, because even short term page pins need a new kind
of tracking, if those pinned pages' data is going to potentially
be modified.

This situation is described in more detail in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

FOLL_PIN is added now, rather than waiting until there is code that
takes action based on FOLL_PIN. That's because having FOLL_PIN in
the code helps to highlight the differences between:

    a) get_user_pages(): soon to be deprecated. Used to pin pages,
       but without awareness of file systems that might use those
       pages,

    b) The original vaddr_pin_pages(): intended only for
       FOLL_LONGTERM and DAX use cases. This assumes direct IO
       and therefore is not applicable the most of the other
       callers of get_user_pages(), and

    c) The new vaddr_pin_pages(), which provides the correct
       get_user_pages() flags for all cases, by setting FOLL_PIN.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h | 1 +
 mm/gup.c           | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 90c5802866df..61b616cd9243 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2663,6 +2663,7 @@ struct page *follow_page(struct vm_area_struct *vma=
, unsigned long address,
 #define FOLL_ANON	0x8000	/* don't do file mappings */
 #define FOLL_LONGTERM	0x10000	/* mapping lifetime is indefinite: see bel=
ow */
 #define FOLL_SPLIT_PMD	0x20000	/* split huge pmd before returning */
+#define FOLL_PIN	0x40000	/* pages must be released via put_user_page() *=
/
=20
 /*
  * NOTE on FOLL_LONGTERM:
diff --git a/mm/gup.c b/mm/gup.c
index 58f008a3c153..85f09958fbdc 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2494,6 +2494,9 @@ EXPORT_SYMBOL_GPL(get_user_pages_fast);
  * being made against.  Usually "current->mm".
  *
  * Expects mmap_sem to be read locked.
+ *
+ * Implementation note: this sets FOLL_PIN, which means that the pages m=
ust
+ * ultimately be released by put_user_page().
  */
 long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
 		     unsigned int gup_flags, struct page **pages,
@@ -2501,7 +2504,7 @@ long vaddr_pin_pages(unsigned long addr, unsigned l=
ong nr_pages,
 {
 	long ret;
=20
-	gup_flags |=3D FOLL_LONGTERM;
+	gup_flags |=3D FOLL_LONGTERM | FOLL_PIN;
=20
 	if (!vaddr_pin || (!vaddr_pin->mm && !vaddr_pin->f_owner))
 		return -EINVAL;
--=20
2.22.0


