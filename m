Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79A18C41514
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 19:59:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 402CD21783
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 19:59:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 402CD21783
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D479F6B000C; Sat,  3 Aug 2019 15:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF8066B000D; Sat,  3 Aug 2019 15:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0E486B000E; Sat,  3 Aug 2019 15:59:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0AA6B000C
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 15:59:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id y7so635815pgq.3
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 12:59:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=Gl9UReTPfUbpoDQWOZlbzMwHhU1i9TqoStzRZzVH+7U=;
        b=KT/NPVZPFmKfMhjTs2NTi5fIWdfpsIrkC9uCYDP2a44/M2c5qYeeOZ1Hhdjq10eaZu
         /YkXvUy8jyhL2TUK/jydB/pD6ihCetV8Lq1pUjfQTg6LFaRXPfVYYnj36+zJ9DV0hpj7
         Qfu+9PNL24GrIUl6NaVPamK7QDh02/302RJrKo67kubrIQ9QgGciQAxNwnsD8xWcDh+x
         q6R7KfEPPmgrkrtBtNcpTNMKX8FQlfAhwim6+QIIR8o9pa2OZ3BYr30jXWq+50Qdv38r
         l6fyVDY9pAhw7+Cnh7YJhsr81HFyG8PSqJETmW44WZ1LSNL4GsGBp+WpTYj5DCNrkcvw
         m6JQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVxfV5Aan98DAc2JIhz7DntcegO+6RM7E73/t9hB85Gd242o/QP
	nLw3Z/yR3DLea/fLknOuTBGwuD0k6ROiZ1KD95BAemfpKmgQ8EFzDRlq520+i/72KjB3EPuuZec
	DsSQc3NsBKL6w3KeR09GoMCHAYsI99PtyOoNs0Tu1S/nH6GFqP4vVdJa4fbq8U+u2gA==
X-Received: by 2002:a62:3347:: with SMTP id z68mr67509203pfz.174.1564862379240;
        Sat, 03 Aug 2019 12:59:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx687jn5GSS5743v18c+kDtch9XSlLix71cUbx+YlWsISNLAaK52qFO0jsm4tyH9kfGF9g5
X-Received: by 2002:a62:3347:: with SMTP id z68mr67509181pfz.174.1564862378644;
        Sat, 03 Aug 2019 12:59:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564862378; cv=none;
        d=google.com; s=arc-20160816;
        b=yy59n/cgFR9g/UzQFMFwP9TVTn3C59i1/pk3BSfDaDrl7RBkGfY6/yZZbZUjlwRmEK
         SVY+bOStccPlWW/phA0LyjTy3U6mMM5ZQUwPZ6JVJ9Liwgdh+DC3xxF5IyktZxz0r1L2
         FUpa1X86J80Xr+1ffRjD9n++wWWXxnJ+/BnQ+CvESQPtbENs1n75yw26g+Hl+P9V18nC
         8p6H5TDV0OzuyRtIo+HkxTM1Y57yS6KY/VssoENv4Ccs5Xr0HIgsyAYGNcAWJnCVwA/M
         t/CVNitTPPVW1byzwwRqLpHNsQNLh0IV9nwh8BhtkXoD0tP+2mPtf56MS63tckhXoFtN
         VVEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=Gl9UReTPfUbpoDQWOZlbzMwHhU1i9TqoStzRZzVH+7U=;
        b=IH7h2JOd/zCQMahZYDcfczaUayfSGu0JrKj5RwYtHSfHP56lCeRRyLeeZvKmSCkwX7
         22w0aO8y+4PfUzVmgteugYh3cIfug/uxdFD1zsUM7LdC785aseS2F9WFLg2wTpwysDMB
         6nHAPNplFyv6R9pt+ATASRW9lIHs/qfF9Pe34hJiMqipeYKR+6l71ncs09Ao8NPNxvPC
         JRi+RBxgu/bz6uvdEngqRpFtD2wd/6EGzF/dOq+w/pOYrOCiPV50uNxtCJN85J729XwB
         6UQVbfk//HXAu7ejLDjAWCg8FuxC8R1jWhH6xaE5M6pd+AgHD0cSO6iAjiw1m5dlZTr8
         VA9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id s13si44352891pfe.140.2019.08.03.12.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Aug 2019 12:59:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Sat, 3 Aug 2019 12:59:31 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 8FFB1B27B5;
	Sat,  3 Aug 2019 15:59:30 -0400 (EDT)
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
	<stable@vger.kernel.org>, <akaher@vmware.com>, <srinidhir@vmware.com>,
	<bvikas@vmware.com>, <srivatsab@vmware.com>, <srivatsa@csail.mit.edu>,
	<amakhalov@vmware.com>, <vsirnapalli@vmware.com>
Subject: [PATCH v6 0/3] [v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Sun, 4 Aug 2019 09:29:28 +0530
Message-ID: <1564891168-30016-4-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1564891168-30016-1-git-send-email-akaher@vmware.com>
References: <1564891168-30016-1-git-send-email-akaher@vmware.com>
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

[diff from v5]:
- Recreated [PATCH v6 1/3], to solve patch apply error.

