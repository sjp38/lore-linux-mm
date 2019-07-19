Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE088C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B659221849
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 19:30:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="f1zyVgL6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B659221849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A0696B0005; Fri, 19 Jul 2019 15:30:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 452446B0006; Fri, 19 Jul 2019 15:30:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 317D98E0001; Fri, 19 Jul 2019 15:30:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15CF36B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 15:30:03 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id f126so25223281ybg.16
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 12:30:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=lzvQpqIVeAPQspf/bNGxauqHX/fDBWVwZY/7PMGCtIU=;
        b=rcXUc38VHPMyDmxKl9NhKtdsdMg1xLm20jiV7jDx7SdNnvvs6yMhvcq3mcS/MZoM9G
         mHa/MXBwxoX2GVQtfRWOGAFQrDaDvt0r7zd8RP25OFDHBP9mo7u/FhpFNCQl6O1WNe2j
         s3J3c9NZKtXOjYMQ4hRYpdyt4AEmkGfHrQD8o3NQrrpw8M9XYiifNf4E5qmk8B7fcH+J
         kbe8PSO9MJQALQlouMAuZorz5b9IMBOqEURaT1DnAoDKLRy7GxQQZkj1E30mNuGG4rFB
         4mwOwZELbjdRnQnlg6+RCsZ+XrTX1aSxB59ce/4mZfWqGILPkX4bLGY9+QoUcM8bC5Fd
         Gj9Q==
X-Gm-Message-State: APjAAAXgcL64TwMH9TuKMLI1h0y61k0jKDGcZ66/lQBqopSL4n4vUMC5
	su7N3v+gorhmmHEX9XLkaJ6XG/kZ622mNZPjp1nhdVPjqXYep2BfLqD0++EMWF+7ElBzleIcf/l
	t4T8IkjfIgQDUoA66O1Xd2kUlgZ9FeT5hI0WYIqt1obGv8lpiQXGtTtZQvfi0qfsKPg==
X-Received: by 2002:a81:4b8d:: with SMTP id y135mr33468742ywa.78.1563564602874;
        Fri, 19 Jul 2019 12:30:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8FpJZEHJGqX8LJk7OXXQTB5eM0Pm6gqlsnV0n8+5QAE+bPVbIfOK2s6+WN+BvKu/Pl4j6
X-Received: by 2002:a81:4b8d:: with SMTP id y135mr33468700ywa.78.1563564602215;
        Fri, 19 Jul 2019 12:30:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563564602; cv=none;
        d=google.com; s=arc-20160816;
        b=MDfEDZIz/Q9ULaMwaDYB2azigjAcuF8fEcnSBiTkHcU1D7s40vkiDd9RZbuyXr4pXc
         2ZSeZK3PvYsfN0Yx82n+EB4ygSsYZtW/cvl0l4sR+qmbR6o2ELetq+aC88az5JXSo4e3
         ZFH4AXsjJkU7SkPfesOUK3W9/SwQXLfy+UFaTT0djD50dq6I+I9hwlKfr+DtHxGVXY77
         cErj/Oc5TqkVYvrpiGpDJiUENe2Xc5Pngs6tt1oHQGf0rWoA05GqYREM8LygyYGW2JG2
         aBit+pBscgaowWmox4/9IyTbsglF0vokGIgXT7lfCcFkeHReYd+Vkw8NaWrotv/cn4V8
         5bQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=lzvQpqIVeAPQspf/bNGxauqHX/fDBWVwZY/7PMGCtIU=;
        b=wVjda6qE5DbVadgKGvNXP752g+ViV+u6E1lIZbbmoAQa5skI0q6s20Tk2VWm/+++qg
         aegRx4hioQj4GHgFAEZ+hiZe3emSBlCHdevsYD7llpcW4oZGbCS5OJ3zDGORA5wvBBHU
         ke2yZHyYknW3EQlell61yIxSt9KvveOxC3YQjBD5D93iYcjNNClf2b+z+NHUcZ2Hebbi
         8+kRh0XzE7YEdR5Z7BTCOFG3THFN1XmItRdQC0VLENapC1kJVbC4WtLL/LdTXhFDdsvP
         mz9SeTumKszLHIO1woWP72ee5MGC1T/VEy5DsRgmiQufnqnqJIUJ+/YtH+DWu4Q6LVmd
         Tckw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=f1zyVgL6;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d22si11739547ywd.42.2019.07.19.12.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 12:30:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=f1zyVgL6;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d321a400000>; Fri, 19 Jul 2019 12:30:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 12:30:01 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 12:30:01 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 19 Jul
 2019 19:30:01 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 19 Jul 2019 19:30:01 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d321a380008>; Fri, 19 Jul 2019 12:30:00 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v2 0/3] mm/hmm: fixes for device private page migration
Date: Fri, 19 Jul 2019 12:29:52 -0700
Message-ID: <20190719192955.30462-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563564608; bh=lzvQpqIVeAPQspf/bNGxauqHX/fDBWVwZY/7PMGCtIU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=f1zyVgL62a6J62vELNsAkF8adZRIJsmhjhNt9ae9hmswAqZgPy7W34pHtD0IjtTCt
	 JEpnm9W+2O2A+ET/L2emFffOjibWenG+ZqkQ5f+ICrC08wFEfGrs8bvTsKn0teCnIK
	 S6Vw/R3nqhKWiviB/BXyi0+pfFyxbpyFuE2Oc+sSxTGJHOZu7cBAtwPdz87YPKgqpO
	 uFEQ/g5xHRvQm++75knbg+2DioQw4unpiDzwwYCe6J2CwZ+f4aoHf/oOTuIbeNCaJM
	 2C7JFDt0xjZcSb7NXI2cJDhSv+2EmmNF2tR2XCrYGTRhBS7yhr6QIl5PLmyUR6B0Zp
	 zVr0JtVpfU3fQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000008, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Testing the latest linux git tree turned up a few bugs with page
migration to and from ZONE_DEVICE private and anonymous pages.
Hopefully it clarifies how ZONE_DEVICE private struct page uses
the same mapping and index fields from the source anonymous page
mapping.

Changes from v1 to v2:

Patch #1 merges ZONE_DEVICE page struct into a union of lru and
a struct for ZONE_DEVICE fields. So, basically a new patch.

Patch #2 updates the code comments for clearing page->mapping as
suggested by John Hubbard.

Patch #3 is unchanged from the previous posting but note that
Andrew Morton has v1 queued in v5.2-mmotm-2019-07-18-16-08.

Ralph Campbell (3):
  mm: document zone device struct page reserved fields
  mm/hmm: fix ZONE_DEVICE anon page mapping reuse
  mm/hmm: Fix bad subpage pointer in try_to_unmap_one

 include/linux/mm_types.h | 9 ++++++++-
 kernel/memremap.c        | 4 ++++
 mm/rmap.c                | 1 +
 3 files changed, 13 insertions(+), 1 deletion(-)

--=20
2.20.1

