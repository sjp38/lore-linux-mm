Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E888CC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:15:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B24F920818
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:15:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B24F920818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 500AE6B0006; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E5866B0008; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ECAC6B0007; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17C646B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 11:15:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h69so12018763pfd.21
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 08:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=IBCHpfrUye1da1UXs6F7K9wy3dhqgufMGhBnSii/Kqw=;
        b=rXlvBSuqTQ+bq9fVog4lat3gWw6X+T1hP/SCBaWfNwSBq6IipLf/2b4WX7zmdAIzF3
         6704DYxgYMpxCIGAQVxgww8RqguF47qODcsyOtailyp6UDe2b9ktygxdfXOmRErMA8OG
         8/y4YYZ/gzsnIhosH7B4EHaGaPkwR+Ce88VBuOQkcZiKxY1a8WWl4vAKrVZedmbw9QZQ
         gdKvE5YOaoSxT09BlgG36fK+10C72GaXjKSFeDhnWowF0e5rz0HeaDVueh+kPhvmGz49
         5zcNtswgHVQvUlk9fRBhosM/I0RdZErCS1cX2fKFkpI0K/RGpFw6VTtfDLmQCLE6Ehpo
         +/MA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUd/r6j9p+tjIZVJ/PTQtkMvUXeeehddx1z0fgUyv1i1ds7Uu1T
	ReqruQCcX0tCxxjo6xAAGxJeEe4eR4syWzqQ+LCUXAJnRXGs2AUQtODoPRqRMCB0pnK0kVV5Oci
	P+niE+gGJEmjwvvvZ7eenfT29x2Spl3sefZCJeNpS8BjL3SK8xvoz88chWQQtbV8lDQ==
X-Received: by 2002:a17:902:7247:: with SMTP id c7mr75916475pll.255.1555341330561;
        Mon, 15 Apr 2019 08:15:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh1395BluDJ1GyWsoVs4GWXx6G9q9dAdd3/GNwTc1oL1ohgiQa30Q+LeYQwOq6jox+4q9q
X-Received: by 2002:a17:902:7247:: with SMTP id c7mr75916393pll.255.1555341329741;
        Mon, 15 Apr 2019 08:15:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555341329; cv=none;
        d=google.com; s=arc-20160816;
        b=cZRsJDgwMbsDHGwCLBqOOndgkFKYcILl4KcFP7uvnMwOCAbi+S8yZ8AqNvXbDwuGC4
         Ntp7wUAMvbdXRdM+BJ3IsURmqb8ikyJaVyVMebeo/FqTD84WVrAKIfsHHZAbQMY5LCaT
         BGoPCeiRM2ppFH786As6FeZgvAAM0mQfEyhMOAWNLJ+1Omar96i3nWwrNHwkUvx1LetD
         B8QE4JZhQrfmLPdVpiGnb17/P9L/pvuePgzdNtAXoZfDcEYv3pwb2XmuHOXdKeBB587V
         CwJyUo2EAnspd6CC3ZlNuo60w4rj0K3V5VcNtPZZJBcuJ+6wIE1IFexJe7Cyzj4EOC5T
         aHJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=IBCHpfrUye1da1UXs6F7K9wy3dhqgufMGhBnSii/Kqw=;
        b=gHINMYrQP+uigjPC2YJxocUT3l89VHkgXmVt6/H6KjaXfhb74BYx7W1Y2Gcw4vEZTA
         +JEjkozdhL00scHn9eNEgBvVxWJuJ882pP9GFKAFbrMAIsQTXvTspzjAV1yjRakEHr4D
         oDBuGQXFlxwFOR442rD/igTzfn6Liz6tQYwgcs1ovtq6P0by8evLg4miTTFkdl9bDLOp
         M6chMoO0spjj9DLjdqbj/0NIQksK8NRFRQ7t1ogMp7ELeN9muAKJsMgLMDQp1A1pisKR
         q5Tk/rHqX+snrCZmIuK20xZoxb9W9FzBuS8wbHtvWEiAczSp3YSwpZlG6Je/ralVxLCp
         54fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z72si44535592pgd.401.2019.04.15.08.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 08:15:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Apr 2019 08:15:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,354,1549958400"; 
   d="scan'208";a="149585854"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 15 Apr 2019 08:15:28 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org
Cc: Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 0/2] HMAT memroy hotplug support
Date: Mon, 15 Apr 2019 09:16:52 -0600
Message-Id: <20190415151654.15913-1-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is much the same as the original version, accept there's an initial
patch to add hotplug support for memory caching. The first version only
provided the attributes for locality and performance.

The second patch adds the hotplug support via memory notifier. The
difference from v1 is the added lock, ensuring onlining multiple regions
is single threaded to prevent duplicate hmat registration races.

Keith Busch (2):
  hmat: Register memory-side cache after parsing
  hmat: Register attributes for memory hot add

 drivers/acpi/hmat/hmat.c | 108 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 82 insertions(+), 26 deletions(-)

-- 
2.14.4

