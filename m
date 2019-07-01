Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A9ADC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:33:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD763206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:33:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD763206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D5748E0008; Mon,  1 Jul 2019 06:33:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75E798E0002; Mon,  1 Jul 2019 06:33:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64DEF8E0008; Mon,  1 Jul 2019 06:33:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 29EE98E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:33:08 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id 91so7099008pla.7
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:33:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=aFqYbxQbQDa0aTVunk5cfDQpRBdKo0/mUYpoQguK+3E=;
        b=CcSUEiDNnBvkI9VJCYzKYPyZjCJ65KoqnV+EjUNUSXhO/M0P5ou5r1hZMJsfyyuFpg
         B1Syioyalq9mATDSLAjnG+gMB5WS3peV9Y7ZXUv/faUmf+iHTG1VVSMf6ivE/VXqInFR
         ciasxkWLwLpYdmbAyIjBmHJnXw5Tx/x4sq9lnpSyvBkzup/n/wTSS4VynqnHZeZ5RHJk
         Qxuo1DQWUF6fsX+eA0FfeCLmTuAnwFPo1+00g+EFI0qMc2bRzDTx4Ocj/MDx36pbB8f9
         M3IBQVQsfF9aJc5CMjgXi7/lCLIPMsqlhrYTiCcL6e8yeWSXil0IyVqNiOuyoWSpU0Bi
         tEeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWKfTiu6eGA5is+zl2Cf8sz24Y6AoSI4p5PRlg9E+M9gfMNofjN
	r72QGeUtHqZOu6yQD+opg6CtpRVVjMOLQzFyPHmiOJSeXorxkavLCUqliacZiSEwaB90rL6iWqn
	NEosQmXXROE+jmkwpEtw0UZ+S0SICN+Gd2IJAWZ7vj1bnXIZv8sW3b2x9a6slQAsMEA==
X-Received: by 2002:a17:902:22:: with SMTP id 31mr27457574pla.15.1561977187861;
        Mon, 01 Jul 2019 03:33:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwul5z1Ldb1edY2Gc132z5mWJ5HTm2/7YVoj19IOVJjSOOgOHCdP0JEplX/Xd47EP8kZajv
X-Received: by 2002:a17:902:22:: with SMTP id 31mr27457531pla.15.1561977187369;
        Mon, 01 Jul 2019 03:33:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561977187; cv=none;
        d=google.com; s=arc-20160816;
        b=p+GgAIRWS2cEjRGr1b7QxeW0608B4tsJqlDY+OIsTkxiWliLm+toz26EtXrUuDBId6
         Ap9MzU7W8HasZTjyPFtvpB+zMUnpUrNWyK+f+QohxPHyNreieHFtyhqZCg/vcUSSmG3Y
         ZYga0sBE9InG2XVFIZgweeWHIvEyqBab26T5b2w4NBmsKWGRq+kJFVcRfGuJehvFA9UT
         vlEYJ5NJLoVne0ZnbIwtWN8L5BJgaf8ob4IKVPCYlyK5cDI73nHKQ+neVz8pOrZ/fwmJ
         iuETbjRG3AuPXFJZfUhclr3p7MzJ34zkDYPsjYo0woWLFneErLlkzKztl4Q6E0sxRWwT
         APOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=aFqYbxQbQDa0aTVunk5cfDQpRBdKo0/mUYpoQguK+3E=;
        b=1AscmZs5+6ksczrAR8s3hL4dXFn/+7hNr8w8fYTWYhDC6dLx9gQ7xVB5PMCI+cgs7d
         erVqjlPaAgoAj54qVN06OeX8hLFCRrz0gL7eKVq0Rqbff1qfDorIOrCwlCNWMMBCWNu5
         BlNHtln+sBBY0hQFfN0Z/3ll3Rw0P+VvsTPiXDxG2cTFdGqGYwf9jIkcxj+9Nwf7hCmD
         +F9JAdS8oa3jXRzGmGcvMiiYO61cA+VyZL4FGRYhHLW9SmNA+xpeeNtzNzZRHsAb5NZy
         Ktt304czyaqfR1LCtmRnmSl1MYG1qtiuci6Eu3GXGLgUQe0V3Ul9FkgzNZ5yiC9SfHT7
         Q1ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id q187si11412195pfb.51.2019.07.01.03.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Jul 2019 03:33:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Mon, 1 Jul 2019 03:33:04 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 130BC411F8;
	Mon,  1 Jul 2019 03:32:59 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>, <gregkh@linuxfoundation.org>,
	<torvalds@linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>, <devel@driverdev.osuosl.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<stable@vger.kernel.org>, <akaher@vmware.com>, <srivatsab@vmware.com>,
	<amakhalov@vmware.com>
Subject: [PATCH v5 0/3] [v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Tue, 2 Jul 2019 00:02:08 +0530
Message-ID: <1562005928-1929-4-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1562005928-1929-1-git-send-email-akaher@vmware.com>
References: <1562005928-1929-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: akaher@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

coredump: fix race condition between mmget_not_zero()/get_task_mm()
and core dumping

[PATCH v5 1/3]:
Backporting of commit 04f5866e41fb70690e28397487d8bd8eea7d712a upstream.

[PATCH v5 2/3]:
Extension of commit 04f5866e41fb to fix the race condition between
get_task_mm() and core dumping for IB->mlx4 and IB->mlx5 drivers.

[PATCH v5 3/3]
Backporting of commit 59ea6d06cfa9247b586a695c21f94afa7183af74 upstream.

[diff from v4]:
- Corrected Subject line for [PATCH v5 2/3], [PATCH v5 3/3]

