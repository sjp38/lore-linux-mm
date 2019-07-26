Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA7C6C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 19:42:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C03F22CB8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 19:42:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xb7uiAMY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C03F22CB8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D60436B0003; Fri, 26 Jul 2019 15:42:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0B268E0003; Fri, 26 Jul 2019 15:42:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF9228E0002; Fri, 26 Jul 2019 15:42:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 877616B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:42:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t18so23655031pgu.20
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 12:42:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=LccYF3YyT8jElndL9g3VFRbu964seQMm2G7qLpuIBD0=;
        b=rImc5sOmaiRXJdrgKuyJ3TRbFrtS/gyCWVb83smcCMn+Ss1P0pmHdVws79zWufjTpp
         zqFN3romrm461zfRbAwSlMk5mM9zEqaLr9EELVeNCzl8r+aDx38R6N77rG2dlh3tISyi
         DiyO6E+kNz3B1Xwi25mdoxoVSTZhf7H/G1grAzr9Hk2Bo1Fy8PnVRv31OaE9RV682uFI
         MZCOgm/bo0Ni8UUNOUS1PKIEmqPDYzT0Hb/2OXUlN6+AcjqnRd+CH+Sh8YWbrZ30S7hK
         5iB2ogy7CtJGdXwtPOVs/aKzfoZ2CU8j9H6ctLXzW9oDlMs2YGA1csEtLHCQvBW1mj2Q
         kC9w==
X-Gm-Message-State: APjAAAVPwc9nyOdjfpNKr7Q91wEL5NbYZVtPYzBeg0TuNP10y/CQNbCD
	kkwdFm8LrJEqtKZK8KkWbxFGTNuUvLR9ft+YhAmLHQZn6UxHwzt9S8RlvbjAnQMTtaFLuJ9D5/j
	kencwt/pRaJeYhc0qqYCZdTQgSxUHnBDL7K0Hy3ud4VRIBevn5Mz45g6BOa5RJ9shsQ==
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr100389684plb.158.1564170134145;
        Fri, 26 Jul 2019 12:42:14 -0700 (PDT)
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr100389639plb.158.1564170133276;
        Fri, 26 Jul 2019 12:42:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564170133; cv=none;
        d=google.com; s=arc-20160816;
        b=Ba16wJ2472hQda+FflMwtMuN/g3Yj96TKCQ4AiwE+Xs5aXlgXDrCziby7bFmLAss+S
         kj0smCwDgjjdVhGAefhQMrqTa41eeWiQUHs5z3jzjyLoaELmL8Lr+tZDOKsTf9PfScxD
         qiWH7vmjMR+c1PbVwXAGbxSLJg/qKBSTfg8pKqfGPYnu8Gm6mzesVC3l3idAJhC2kOim
         kGxSaixWcBTp/gzsRMenWLkb1LR7QEF56sW86t9td2rOfAeAmGoXNY2i70ojUf4uvr+D
         zQD2Yr3LZKMyvOhE+fQQCaxWZSl9RkpF1f7vhv5LOEu7x8RsTYIqx326HpCJX7W3iyIK
         MvJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=LccYF3YyT8jElndL9g3VFRbu964seQMm2G7qLpuIBD0=;
        b=XIlGDt8tFIHKstjZb1oZh0zDRzCrrQijaBQTFGcth3aOGWEcTOLpFwyJBlOnOb+SJY
         ky8IMdn0ARCo8th8I2ROTVcNmCSSnJvSpf1kbCUjL5V3N89C+Y4bR4RtxlYR6cTFCCVu
         CwLGAeMVwyg0KA+z7D2GvOhtbO8XaQSc31Wd6QI4waHKhVfPBPDktFBAiuUtVXVA7kmA
         p7oaxEtBEZCveQYVcvLkgZ2bA7zBiTRxCC4snGwdRNWPEmif11NY6EUYDFm17AAxZy/v
         ajlbmbb0qVXRy+ZygT5JVRJb38O6cqp36P/sjSjLXYgaQqRTFZkNz75MALZLAw96ujUP
         /9Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xb7uiAMY;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a21sor33571875pgh.0.2019.07.26.12.42.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 12:42:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xb7uiAMY;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=LccYF3YyT8jElndL9g3VFRbu964seQMm2G7qLpuIBD0=;
        b=Xb7uiAMYaevP+8U/djYvb9TiTim6fNVGFYLLMwH3TQm9FLQMm56swPv7bjjltYFGUh
         1e5YRchOniNKrWT2u84QQhjOFF//tifui4aIq+sLOQ3WqxTKNMB/q/2m5vkd65QOq/Pr
         /Ww+/FVIq0SVBzIHLvo5pqZQbO0eN40dN8BIP+405cli333wnbmP/BvqN6YSAbaL8uMd
         qt56LW6iMaVyXKD1FZOp1QcvsaxuNxNya7shIQHvzMRPZDk7kbFmC35XGoPH2oAS3g6g
         NcY0IzrZuq/ZbH7jizeyGpRF9S+m5qPh7w5E8ppCgTlY4DG5eEop/hvsDtA9k58kE0F5
         heBw==
X-Google-Smtp-Source: APXvYqxD7hMpjBx2zGWbAQfPanVVJhpbkH33uz1mN4dXyB6mZ/MLhVMwQ+aBcGcGS8QM95MErj+LqA==
X-Received: by 2002:a65:60cd:: with SMTP id r13mr66907199pgv.315.1564170132800;
        Fri, 26 Jul 2019 12:42:12 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id v27sm73348910pgn.76.2019.07.26.12.42.11
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Jul 2019 12:42:12 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH v3 0/1] get_user_pages changes
Date: Sat, 27 Jul 2019 01:11:59 +0530
Message-Id: <1564170120-11882-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In this 3rd version of the patch series, I have compressed the patches
of the previous patch series into one patch. This was suggested by Christoph Hellwig.
The suggestion was to remove the pte_lookup functions and use the g
et_user_pages* functions directly instead of the pte_lookup functions.

There is nothing different in this series compared to the previous 
series, It essentially compresses the 3 patches of the original series 
into one patch.

Bharath Vedartham (1):
  sgi-gru: Remove *pte_lookup functions

 drivers/misc/sgi-gru/grufault.c | 114 +++++++++-------------------------------
 1 file changed, 25 insertions(+), 89 deletions(-)

-- 
2.7.4

