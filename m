Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C48BEC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75E492173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:13:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TMFjcZ4v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75E492173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 115C26B0007; Thu,  8 Aug 2019 19:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09E246B0008; Thu,  8 Aug 2019 19:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA7496B000A; Thu,  8 Aug 2019 19:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFF2A6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:13:52 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id u202so41176437vku.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=wId29/KRlL3T3iL7X0HyROciU3enoTeQrmaI3uDvplM=;
        b=sxlSSYaLEqBtTkchpI+hf/a93RHXd548kaP80ukL3Ti+U22wgX6nDWFlBHoIOBY8DP
         W0SmvADvDKAkGBupdUC4vsNIu2l+1X2CSgrBe/tAwokqgv8u+5yJz2mtjmupcs6+bGIY
         TeQKaVCvOHP3E4D8PrvU9neC/pUoSMzkRlkyj15fjFYRrFizemLpD8dVhvLCnebhXVrh
         8pXazHAXwUZqX+h8OCJh3LrLGFxJhhYpuZP7fZsdBMv/beC3jUeu7eOV39qqXSuPzsQh
         h/Xu9QVGASKB2HSWLmFqwzrxvHBVb7e3wJqI6EztRakAlld2gtkvQ4P7PNlgzk/KW9+M
         w46Q==
X-Gm-Message-State: APjAAAXYRt1KECMeuW6dapduWExKPlNVo+XJZt1P1R04Sg3l29IX/mXv
	rbfW+QmtcZcb8EN/UWOmaPmlr+jFRDMkD0G/nktgLFl+mOPwEPAn7kFHyM6r39Ou4Wkqb73RECp
	cylHqJSGAYmla2iuNduKtPjQ6+UBOW4qOnpOVOatvZohCNIone67IXPjAp5W+Q6JARg==
X-Received: by 2002:a67:6282:: with SMTP id w124mr11485133vsb.4.1565306032417;
        Thu, 08 Aug 2019 16:13:52 -0700 (PDT)
X-Received: by 2002:a67:6282:: with SMTP id w124mr11485111vsb.4.1565306031681;
        Thu, 08 Aug 2019 16:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565306031; cv=none;
        d=google.com; s=arc-20160816;
        b=Xyic1IUhmuxkpsfEegRbuNwY6fd3tXqyOA6R/1UQl7ryWVSBmcDgpYZrUvV0Sp3PMI
         NMmdFrg5hmEEmuYbDkgVz7JgDAC+83w3M1WCkwRnXK0VzoyrmPuPpugX8xdXLS66LNOr
         ik81hY9ETCmFIl1JhbEIHBe/GxFuE0z1gAJBi+bw+CxJiC4dLfPf2t7Y++loNLSsB1MU
         eWF2Cf8sNqPDf9E7+b1RP0zFgRiV0+eKzMRySaNCUAwlWmzSyrnZBjjgVRRRie4AGIk2
         sLMgumlH6EtyZ88irCHWxow7F37Kn7ZJKLKrb+N9ot7XCAEs4JOH8rfys/N5MFbPDY56
         SxwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=wId29/KRlL3T3iL7X0HyROciU3enoTeQrmaI3uDvplM=;
        b=Opod4V9H39FxEo2S7/cCWt2l2E3GupRIFcu4TmD+kU4zpNDWHweAq5A44W9c9tEG5k
         SLi4ZASHmeanAt9Ds5GZMm0xgPhZakVV/IauhtX4xdtesm4EA4DqB9QgmCgLNc80hgSx
         UKeY/9ghrNj41vJRM8ZM7d8OKod2ToGgad/qvRdaqv2ax7YrNtxdQwlfmMAA0APGhhRy
         TWaCGZG3rF52skyGe0W3soiXjc9lz3A2oOolY0nVZY/wxQdae6KqgMTMT8WfKPi312KU
         msn0FIqKpPYlxioUz9vWPU1e0Ld4xYvk+NC9Dxuvls/WF7cffVeOCfOmGTHG0Gh4xjoT
         Ujrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TMFjcZ4v;
       spf=pass (google.com: domain of 3r6xmxqskccwituiazguqviowwotm.kwutqvcf-uusdiks.wzo@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3r6xMXQsKCCwITUIaZgUQVIOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 82sor1871633vkm.56.2019.08.08.16.13.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 16:13:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3r6xmxqskccwituiazguqviowwotm.kwutqvcf-uusdiks.wzo@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TMFjcZ4v;
       spf=pass (google.com: domain of 3r6xmxqskccwituiazguqviowwotm.kwutqvcf-uusdiks.wzo@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3r6xMXQsKCCwITUIaZgUQVIOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=wId29/KRlL3T3iL7X0HyROciU3enoTeQrmaI3uDvplM=;
        b=TMFjcZ4vhBvh4e7isaMSjyShLhjqgNI9SS84mRQBUZq7giQJNsbMV9xB8o589wPJjG
         ATqzdkESubrtjfyBEvm0HFq7aHibDZTA+VfHQqC1k82g6SeBBy3ZTDPxYWtdtsgA5gb2
         BaRU8mj248iyCd1JsH8c8z3c/1h2TbfYGpCiSAfmctaAa6DGr8+fhUkhzZc2E+FF0zff
         4oqJ0+yopnx6PrZt4GfyCNDb5JdmETVvW4BJCoi29CZ8EgWzd2MoiLzfjPs4BA70d/ap
         1mA4DuppfOGpbfO7bbk50y9t/h43rXMwgeWryuxIKqhcmfIG6gPb9Ygmtl0pwmsfnGk7
         iD5A==
X-Google-Smtp-Source: APXvYqzJjnEQKXMAlqlBk6hL4U4b6xmXEzBX0SnBKAOjCUKuT01y6ae1E3MP3SuI38xxfLnqA1lnQNJFkC1pyxj9Hg==
X-Received: by 2002:a1f:5945:: with SMTP id n66mr6951132vkb.58.1565306031133;
 Thu, 08 Aug 2019 16:13:51 -0700 (PDT)
Date: Thu,  8 Aug 2019 16:13:35 -0700
Message-Id: <20190808231340.53601-1-almasrymina@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [RFC PATCH v2 0/5] hugetlb_cgroup: Add hugetlb_cgroup reservation limits
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Problem:
Currently tasks attempting to allocate more hugetlb memory than is available get
a failure at mmap/shmget time. This is thanks to Hugetlbfs Reservations [1].
However, if a task attempts to allocate hugetlb memory only more than its
hugetlb_cgroup limit allows, the kernel will allow the mmap/shmget call,
but will SIGBUS the task when it attempts to fault the memory in.

We have developers interested in using hugetlb_cgroups, and they have expressed
dissatisfaction regarding this behavior. We'd like to improve this
behavior such that tasks violating the hugetlb_cgroup limits get an error on
mmap/shmget time, rather than getting SIGBUS'd when they try to fault
the excess memory in.

The underlying problem is that today's hugetlb_cgroup accounting happens
at hugetlb memory *fault* time, rather than at *reservation* time.
Thus, enforcing the hugetlb_cgroup limit only happens at fault time, and
the offending task gets SIGBUS'd.

Proposed Solution:
A new page counter named hugetlb.xMB.reservation_[limit|usage]_in_bytes. This
counter has slightly different semantics than
hugetlb.xMB.[limit|usage]_in_bytes:

- While usage_in_bytes tracks all *faulted* hugetlb memory,
reservation_usage_in_bytes tracks all *reserved* hugetlb memory.

- If a task attempts to reserve more memory than limit_in_bytes allows,
the kernel will allow it to do so. But if a task attempts to reserve
more memory than reservation_limit_in_bytes, the kernel will fail this
reservation.

This proposal is implemented in this patch, with tests to verify
functionality and show the usage.

Alternatives considered:
1. A new cgroup, instead of only a new page_counter attached to
   the existing hugetlb_cgroup. Adding a new cgroup seemed like a lot of code
   duplication with hugetlb_cgroup. Keeping hugetlb related page counters under
   hugetlb_cgroup seemed cleaner as well.

2. Instead of adding a new counter, we considered adding a sysctl that modifies
   the behavior of hugetlb.xMB.[limit|usage]_in_bytes, to do accounting at
   reservation time rather than fault time. Adding a new page_counter seems
   better as userspace could, if it wants, choose to enforce different cgroups
   differently: one via limit_in_bytes, and another via
   reservation_limit_in_bytes. This could be very useful if you're
   transitioning how hugetlb memory is partitioned on your system one
   cgroup at a time, for example. Also, someone may find usage for both
   limit_in_bytes and reservation_limit_in_bytes concurrently, and this
   approach gives them the option to do so.

Caveats:
1. This support is implemented for cgroups-v1. I have not tried
   hugetlb_cgroups with cgroups v2, and AFAICT it's not supported yet.
   This is largely because we use cgroups-v1 for now. If required, I
   can add hugetlb_cgroup support to cgroups v2 in this patch or
   a follow up.
2. Most complicated bit of this patch I believe is: where to store the
   pointer to the hugetlb_cgroup to uncharge at unreservation time?
   Normally the cgroup pointers hang off the struct page. But, with
   hugetlb_cgroup reservations, one task can reserve a specific page and another
   task may fault it in (I believe), so storing the pointer in struct
   page is not appropriate. Proposed approach here is to store the pointer in
   the resv_map. See patch for details.

Signed-off-by: Mina Almasry <almasrymina@google.com>

[1]: https://www.kernel.org/doc/html/latest/vm/hugetlbfs_reserv.html

Changes in v2:
- Split the patch into a 5 patch series.
- Fixed patch subject.

Mina Almasry (5):
  hugetlb_cgroup: Add hugetlb_cgroup reservation counter
  hugetlb_cgroup: add interface for charge/uncharge hugetlb reservations
  hugetlb_cgroup: add reservation accounting for private mappings
  hugetlb_cgroup: add accounting for shared mappings
  hugetlb_cgroup: Add hugetlb_cgroup reservation tests

 include/linux/hugetlb.h                       |  10 +-
 include/linux/hugetlb_cgroup.h                |  19 +-
 mm/hugetlb.c                                  | 256 ++++++++--
 mm/hugetlb_cgroup.c                           | 153 +++++-
 tools/testing/selftests/vm/.gitignore         |   1 +
 tools/testing/selftests/vm/Makefile           |   4 +
 .../selftests/vm/charge_reserved_hugetlb.sh   | 438 ++++++++++++++++++
 .../selftests/vm/write_hugetlb_memory.sh      |  22 +
 .../testing/selftests/vm/write_to_hugetlbfs.c | 252 ++++++++++
 9 files changed, 1087 insertions(+), 68 deletions(-)
 create mode 100755 tools/testing/selftests/vm/charge_reserved_hugetlb.sh
 create mode 100644 tools/testing/selftests/vm/write_hugetlb_memory.sh
 create mode 100644 tools/testing/selftests/vm/write_to_hugetlbfs.c

--
2.23.0.rc1.153.gdeed80330f-goog

