Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0C78C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E71120818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:00:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E71120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BF0B8E00E0; Wed,  6 Feb 2019 13:00:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2460E8E00D1; Wed,  6 Feb 2019 13:00:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E68B8E00E0; Wed,  6 Feb 2019 13:00:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7D408E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:00:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so5741647pfi.23
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:00:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=wU8FwZG9yY2wRLtcShDLZa6XfDYKvbHRhM7KDFrxauA=;
        b=or1Ar2p/2JGyalswVHSm0w+CMvL+pJoL5RHjOk82ut2+NEKD+h/kSiZWQZkkbWn+PK
         6cKG/lu/UXQHHY4BCYOQf061hTpvtWhUWt+FKCL6w+vQdGiHDiSXEfkwbmURMTWQs6Dj
         tIIekUHQFP012NlDTgZLqaSKC7O2O+mHFitb5vRP22sYaj0FKncvuWhSXF8zJ731+i+2
         SbDjxm5ht+SDLZ/MEe4cY5MyqnFvSW0CmQqQ83FI/OVPzIUCTE534LK+AJ6JmNp1u1kL
         azfSyqhcMN7YwHZ0BSbQISI/Y/uS1yyuMi87HGF/Z0B89zvZRsNZBxSq2UtGPRZK7ReP
         zWVw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAub99Krpb8tMJL0tZIF7O8zEQLG+P5tuSyMnaKwxjvAyU++J+dWe
	y29eyBd142YpK+cfR/vai0eBC78W36fvZqs0Gf/hoJt40waCK66cDhjr0IPVJToYB+nPgBEdrbf
	Sq+tfrJIrqavdAIOfCA/WPI9QyvtR5o4v4IyKKv7Zetxvq4EvgozIju/r37j9PQ0=
X-Received: by 2002:a17:902:4d46:: with SMTP id o6mr11523144plh.302.1549476000399;
        Wed, 06 Feb 2019 10:00:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZluljy0qCBKEoxWO+tsY6aE9uljjJO68lIsxjrdG8iWlulKuTk+WFzgSZLH5qHmtkaAnhB
X-Received: by 2002:a17:902:4d46:: with SMTP id o6mr11523096plh.302.1549475999531;
        Wed, 06 Feb 2019 09:59:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549475999; cv=none;
        d=google.com; s=arc-20160816;
        b=EdTmGPBERYfCIZ/IKGD386r1zdYYjPCHRRuX3qlO/qBpsWTp9igWL9OadZlm0eQERr
         QccJ9c9BJFEsI6grxes2VsW2t6i0Fry//LYzSjRrKyG6gYnZKEPST0ZCI/Pb3hGpjkIu
         rQXaEsGJc4aPpkMP7ZPSN3LjP/6dOlql4z+rGeGLGDOS7tpTo8Vbm4RyWGExbJ7OIxvt
         mHNSgw6yMCoAk/Gc8+U1yG2cnbr5xJTTVqCHbxGmT/7X+QFZSx6kJnpgdTrBKTU9Uj5i
         grKCS0Ra8myWMJdzEHo+P1cP5EOi11zqTbm89ObOnKfiYiHAQUBNkGKAPjhAVO8TCCVr
         346A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=wU8FwZG9yY2wRLtcShDLZa6XfDYKvbHRhM7KDFrxauA=;
        b=fztGMEp0Ik+fBJB3qlUTwHW4uyZJ8saH0R1BWQfTkSdbFRI1fr60/F9xGqYMRjd2Ce
         6W+I0h2N89zSrQJvt3ZI+1/Uufy6ztklJ4dUzMbFyjXi13mXBotFsjwx2iBCgPqtuiWd
         y9NtW/wbTXiZWvuukfuJ+r458VjhRhH3wQENNhAABmF3tWz+da9QCr14KHHCnfIGfuOG
         goyo8Mb05KyJ0i3rOg0wqV+GMkI76C31dM7N308COwOvE4Gx7Kku0dvJBp40O1HX52PI
         3nYMY7z5j+AtFqJ8TTo6gjU2L2+cnx8IBL/ZvQZKSyul0L7mdv2eIGbNTMbF0G54wOo/
         kM/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id p7si4319082pll.301.2019.02.06.09.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:59:59 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.221.5 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 18:59:57 +0100
Received: from linux-r8p5.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Wed, 06 Feb 2019 17:59:34 +0000
From: Davidlohr Bueso <dave@stgolabs.net>
To: jgg@ziepe.ca,
	akpm@linux-foundation.org
Cc: dledford@redhat.com,
	jgg@mellanox.com,
	jack@suse.cz,
	willy@infradead.org,
	ira.weiny@intel.com,
	linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	dave@stgolabs.net
Subject: [PATCH v3 0/6] mm: make pinned_vm atomic and simplify users
Date: Wed,  6 Feb 2019 09:59:14 -0800
Message-Id: <20190206175920.31082-1-dave@stgolabs.net>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes from v2 (https://patchwork.kernel.org/cover/10774255/):
 - Added more reviews for patch 1 and also fixed mm/debug.c to
   use llx insted of lx so gcc doesn't complain.

 - Re did patch 3 (qib rdma) such that we still have to take
   mmap_sem as it now uses gup_longterm(). gup_fast() conversion
   remains for patch 2 which is not infiniband.

 - Rebased for rdma tree.
 
Changes from v1 (https://patchwork.kernel.org/cover/10764923/):
 - Converted pinned_vm to atomic64 instead of atomic_long such that
   infiniband need not worry about overflows.

 - Rebased patch 1 and added Ira's reviews as well as Parvi's review
   for patch 5 (thanks!).
   
--------

Hi,

The following patches aim to provide cleanups to users that pin pages
(mostly infiniband) by converting the counter to atomic -- note that
Daniel Jordan also has patches[1] for the locked_vm counterpart and vfio.

Apart from removing a source of mmap_sem writer, we benefit in that
we can get rid of a lot of code that defers work when the lock cannot
be acquired, as well as drivers avoiding mmap_sem altogether by also
converting gup to gup_fast() and letting the mm handle it. Users
that do the gup_longterm() remain of course under at least reader mmap_sem.

Everything has been compile-tested _only_ so I hope I didn't do anything
too stupid. Please consider for v5.1.

On a similar topic and potential follow up, it would be nice to resurrect
Peter's VM_PINNED idea in that the broken semantics that occurred after
bc3e53f682 ("mm: distinguish between mlocked and pinned pages") are still
present. Also encapsulating internal mm logic via mm[un]pin() instead of
drivers having to know about internals and playing nice with compaction are
all wins.

Applies against rdma's for-next branch.

Thanks!

[1] https://lkml.org/lkml/2018/11/5/854

Davidlohr Bueso (6):
  mm: make mm->pinned_vm an atomic64 counter
  drivers/mic/scif: do not use mmap_sem
  drivers/IB,qib: optimize mmap_sem usage
  drivers/IB,hfi1: do not se mmap_sem
  drivers/IB,usnic: reduce scope of mmap_sem
  drivers/IB,core: reduce scope of mmap_sem

 drivers/infiniband/core/umem.c              | 47 ++----------------
 drivers/infiniband/hw/hfi1/user_pages.c     | 12 ++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 75 +++++++++++------------------
 drivers/infiniband/hw/usnic/usnic_ib_main.c |  2 -
 drivers/infiniband/hw/usnic/usnic_uiom.c    | 60 +++--------------------
 drivers/infiniband/hw/usnic/usnic_uiom.h    |  1 -
 drivers/misc/mic/scif/scif_rma.c            | 38 +++++----------
 fs/proc/task_mmu.c                          |  2 +-
 include/linux/mm_types.h                    |  2 +-
 kernel/events/core.c                        |  8 +--
 kernel/fork.c                               |  2 +-
 mm/debug.c                                  |  5 +-
 12 files changed, 65 insertions(+), 189 deletions(-)

-- 
2.16.4

