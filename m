Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 928FFC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A68920879
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A68920879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D02D96B0003; Mon, 25 Mar 2019 10:40:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C89E46B0006; Mon, 25 Mar 2019 10:40:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2BB86B000A; Mon, 25 Mar 2019 10:40:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 865FB6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:16 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b3so10321269qtr.21
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=CpqZZjSbePr1gUT1uEF3XDnq5aeEq0vWDq8hOysRV4s=;
        b=ozOjrrXqi02iK8X/zB1RphLBoErHGoDk6lUE21OKbv/DF4Ds+grbOiH9Ffhuvw1iRD
         76pY+zk7XdQer6yMd6gmJ5hDo1y22qFdn1SMEyjzRxSQXE5S7gy8+itupiAohexTqNCp
         p4W3vkXwx2yMvGupqNB4KkUOZDHZXOwzN2Mn3esf5OQ1EgBhXTGBHdMy1U6TNrAyRm14
         SgTvu8YHULTxUYMk0TGsLfhe+/oGHo+nOuka8mz/0eLz1LdrfFbx9bI+NiDuYO1H24XE
         Ch3xrThx7xSSWHeMktuWQpKzrwNODmKIPeoRCXpYf8w1ng1otrVXq5enxkG8gdhZsn9F
         nMMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXPylsWAAOk/fvj5wekNPM80RuF4hQPaSkV2+rW3m4jY4aey6yZ
	TXShKIbkDbdTX7nglRj9YnUazWBzAba5iUwnfnL3qUcaNiSNHAkCqVBNbBttzDcmF3WXe0QMmjc
	/WKZbcLvIfY22mvH3CIfgmyjuvDbMj9G7NIGCilm9lZsAXxwe/vbXFla+IY+sLhZbJg==
X-Received: by 2002:a37:6748:: with SMTP id b69mr19983981qkc.79.1553524816162;
        Mon, 25 Mar 2019 07:40:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF2vEDh2jykAf8PW6Bzqb+9KE3ah60yLtoSoaI7Lv+BatbeIpbzRLD5EMWzfC8q+WHnC6d
X-Received: by 2002:a37:6748:: with SMTP id b69mr19983880qkc.79.1553524815357;
        Mon, 25 Mar 2019 07:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524815; cv=none;
        d=google.com; s=arc-20160816;
        b=Bk16y03n66ZaInZBZOXKCbDRaUU0LzgeIPUNQf47uE8QaStYi6aZ8IVYmMh0B5F/af
         lSuCEVVh/QLcZgTQGgbiwZQsKqfTgfJTe5Qg9WLOQS2jSFnXpBWhJMcGQLS0xt5twQPW
         /pQ0uFBN7LDnPBfSmCk9a97mQj6QQh3GQn0E6ah4tXm4bkC2elLxpMjwwKFhqhY4GTM2
         gaRzxMZ6uhWR7JJXBSo6ypSjdN2UUf7pVoD0hHrUe5RIP/u3dJOi2fylKX6UMtJ/791g
         z8EeRbUF2LLCpfYRWJPh4ekw8AuUzrwsQ8jwo2du2B+QWqIRew4CESdb1q2dSnzabHDL
         qSQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=CpqZZjSbePr1gUT1uEF3XDnq5aeEq0vWDq8hOysRV4s=;
        b=Ip5SYkuCQeeQLwY45Pw/afyzH8kKZDzewUKHoQc4Jrjgtuot044z1XmnDjM4nAden2
         a7YNIeptNQ5TkwKl4zZFj2BfMbhHNWsgQNizuDHDBdPjaLSB+xoz4YQPurCoIfyAemdx
         vIifFVmDRdfwFRJybc5rHK8uu22ryUcNETK0Oug3TQ7iwFFPnDhO6QyU4t5LEz+bN63P
         0/4UalEYdzFP02O4xmp+zco0yXWSKSAIbqpDNGElbaVccN84bxjF+ctMj5I0G8l1rzZR
         Gfqmx2EaJjrwFJ/VDac1fGrsU4oOLeWMJ/GuM8ZxaXz8pZvaJQ7folrN6HyDjc7KAkCr
         +uOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f50si3033751qte.34.2019.03.25.07.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 72A4530832C5;
	Mon, 25 Mar 2019 14:40:14 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 701451001DC8;
	Mon, 25 Mar 2019 14:40:13 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Balbir Singh <bsingharora@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 00/11] Improve HMM driver API v2
Date: Mon, 25 Mar 2019 10:40:00 -0400
Message-Id: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 25 Mar 2019 14:40:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This patchset improves the HMM driver API and add support for mirroring
virtual address that are mmap of hugetlbfs or of a file in a filesystem
on a DAX block device. You can find a tree with all the patches [1]

This patchset is necessary for converting ODP to HMM and patch to do so
as been posted [2]. All new functions introduced by this patchset are use
by the ODP patch. The ODP patch will be push through the RDMA tree the
release after this patchset is merged.

Moreover all HMM functions are use by the nouveau driver starting in 5.1.

The last patch in the serie add helpers to directly dma map/unmap pages
for virtual addresses that are mirrored on behalf of device driver. This
has been extracted from ODP code as it is is a common pattern accross HMM
device driver. It will be first use by the ODP RDMA code and will latter
get use by nouveau and other driver that are working on including HMM
support.

[1] https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-for-5.1-v2
[2] https://cgit.freedesktop.org/~glisse/linux/log/?h=odp-hmm
[3] https://lkml.org/lkml/2019/1/29/1008

Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>

Jérôme Glisse (11):
  mm/hmm: select mmu notifier when selecting HMM
  mm/hmm: use reference counting for HMM struct v2
  mm/hmm: do not erase snapshot when a range is invalidated
  mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot()
    v2
  mm/hmm: improve and rename hmm_vma_fault() to hmm_range_fault() v2
  mm/hmm: improve driver API to work and wait over a range v2
  mm/hmm: add default fault flags to avoid the need to pre-fill pfns
    arrays.
  mm/hmm: mirror hugetlbfs (snapshoting, faulting and DMA mapping) v2
  mm/hmm: allow to mirror vma of a file on a DAX backed filesystem v2
  mm/hmm: add helpers for driver to safely take the mmap_sem v2
  mm/hmm: add an helper function that fault pages and map them to a
    device v2

 Documentation/vm/hmm.rst |   36 +-
 include/linux/hmm.h      |  290 ++++++++++-
 mm/Kconfig               |    1 +
 mm/hmm.c                 | 1046 +++++++++++++++++++++++++-------------
 4 files changed, 990 insertions(+), 383 deletions(-)

-- 
2.17.2

