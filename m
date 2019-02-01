Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FB23C4151A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:27:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0D7E20863
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 05:27:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0D7E20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F2B18E0002; Fri,  1 Feb 2019 00:27:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A14A8E0001; Fri,  1 Feb 2019 00:27:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B7568E0002; Fri,  1 Feb 2019 00:27:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC6A8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 00:27:52 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o9so3873285pgv.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:27:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=PMsVRXsDJmzNONQaRNWRjzU9vOFLaKsgwjfK3oDoeN8=;
        b=M0Zf4JCsA/mMHQpLEyeVm9iWMXv8PvonUsfoY0ux9KFP0GcvbUR/rB/FlCPDRIFU/A
         dt73gQ3Y4/4TPF0neDbPyKtFd+UQyRzK2HYzuWs7jwwnqnuXTc2IcF5YcDtMIvibVeS8
         x5sdIX+KHZp8b4fRoF2unIuEfAa4L4eD0RL2pi451I+HSE4G2L15C8VrC5z6fRWbMBG/
         bQY7rN7xfg2n2wg8Xqgt6E/D0IylWzhjbx2hWkbS0pM486aK9k4tSiPVTbFktwCJD84l
         RsC3k7uSWuDdX5V9ZOzXRPX5B84ZM056vEn/pbHKx4PUJs6E2VSdMnkfoRqvXM+ZRud3
         wdLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcrJ4p3709D3i6YbpUEOECjma+G13d5jZDgKUtBF6Nv+l0SOphY
	I6DADTh3krz1a3UCFcON5Yz9GzlDcJdgsMS7ToBiIEpnKHxhWMxrgrYKz/Z47hYmGCffhb2aien
	jMMFpo44Se8CbPuk1hau0UUmvDWDnbwN1gkl575se7E/fCbt38XbBd45Fy7WBaNnVMg==
X-Received: by 2002:a63:2054:: with SMTP id r20mr33936314pgm.328.1548998871637;
        Thu, 31 Jan 2019 21:27:51 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7zyf1gCO+Bx6LgD9xhKBIH4OVSKGGhrzyrB3VozAPhfIQ/4PpMGwf2LTC2noFqwk+NazyI
X-Received: by 2002:a63:2054:: with SMTP id r20mr33936283pgm.328.1548998870736;
        Thu, 31 Jan 2019 21:27:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548998870; cv=none;
        d=google.com; s=arc-20160816;
        b=zvhXL08PHeyyBC7uj6RVRf9Fg7c0b9p1Ie7MvvS9BAmNUxIpBHMT3fMgV+cUz3iPz2
         6zpG3Ibp7KXU8XcLQ1Fg6fhoiyRpTEszbx0XorCEV+BZ796kOkxa5dHP+DGddvte50d7
         3lTNZWam/iTwc/82OyXcsGHHu8tW+dxKdxeRhDJ5EKDfjtP4a3cw0hTRfZQGJfmOuD0M
         KzzcGTC3LEbRMoTlQQN52q44m2nTAHZ0/JLHd3TFDqZUIrAlKlAlyza+VN4eHePIrxbE
         UHa7SOl96lA8M1ucMOLgjGhjEfDUMtbk8eI3HTsmM6zGxrYsCyh6twmZcaEHjqgMy+Ps
         X3bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=PMsVRXsDJmzNONQaRNWRjzU9vOFLaKsgwjfK3oDoeN8=;
        b=F0UCaL7BwZ7NUyxRzwDaTg84dKm4bj5cHP8xzvGRzck7QnCbUmeQU0Zr7XCg9z89VG
         SAP2ZPECctt5+usWKgM8BRYxx3jZVJVasM9CqxX7xvfM8vDndiSnpxyWNiuR7Tf32uin
         sWaufNDPzdP/8vE6F9CPKokKbHaAKT1p6ETU3I8S3md0yEIEcPCnZnvSgyG13vJp76I1
         7pWILaUZxociLbfhERgriYRz73qOQYbhD0syibh5yEUd9Sum6mwk7s5y9InuM/1/HAEH
         UCw9D2E9dw1exKlOOiVQ9ujh943UlSInIP7R2gsn4HwxKMLmAXZch5TeqmRS7sk+xKUw
         GnUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u11si7171094plm.8.2019.01.31.21.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 21:27:50 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jan 2019 21:27:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,547,1539673200"; 
   d="scan'208";a="134968239"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001.jf.intel.com with ESMTP; 31 Jan 2019 21:27:49 -0800
Subject: [PATCH v10 0/3] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>,
 Kees Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, keith.busch@intel.com
Date: Thu, 31 Jan 2019 21:15:12 -0800
Message-ID: <154899811208.3165233.17623209031065121886.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes since v9:
* Drop the include of "shuffle.h" in mm/memblock.c. This was a missed
  leftover from the cleanup afforded by the move to
  page_alloc_init_late() (Mike)
* Drop reference to deferred_init_memmap() in the changelog, no longer
  relevant (Michal)
* Clarify mm_shuffle_ctl naming with a code comment (Michal)
* Replace per-freearea rand state tracking with global state (Michal)
* Move shuffle.h from include/linux/ to mm/. (Andrew)
* Mark page_alloc_shuffle() __memint (Andrew)
* Drop shuffle_store() since the module parameter is not writable.
* Reflow and clarify comments (Andrew)
* Make add_to_free_area_random() stub a static inline. (Andrew)
* Fix compilation errors on trying to use pfn_valid() as a pfn_present()
  replacement. Unfortunately this requires a #define rather than a
  static inline due to header include dependencies (0day kbuild robot)

[1]: https://lkml.kernel.org/r/154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com

---

Hi Andrew,

This addresses all your comments except reworking the shuffling to be
dynamically enabled at runtime. I do think that could be useful, but I
think it needs to be driven via memory hot-unplug/replug to avoid
confusion with the shuffled state of memory relative to existing
allocations. I don't think I can turn that around in time for the v5.1
merge window.

Otherwise, if you disagree with my "shuffled state relative to active
allocations" concern it should be simple enough to enable a best effort
shuffle of the current free memory state. Again, though, I'm not sure
how useful that is since it can lead to pockets of in-order allocated
memory.

I went ahead and moved shuffle.h in-tact to mm/. The declaration of
page_alloc_shuffle() will eventually need to move to a public location.
I expect Keith will take care of that when he hooks up this shuffling
with his work-in-progress ACPI HMAT enabling.

0day has been chewing on this version for a few hours with no reports
so I think its clean from a build perspective.

---

Dan Williams (3):
      mm: Shuffle initial free memory to improve memory-side-cache utilization
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 Documentation/admin-guide/kernel-parameters.txt |   10 +
 include/linux/list.h                            |   17 ++
 include/linux/mm.h                              |    3 
 include/linux/mm_types.h                        |    3 
 include/linux/mmzone.h                          |   59 +++++++
 init/Kconfig                                    |   23 +++
 mm/Makefile                                     |    7 +
 mm/compaction.c                                 |    4 
 mm/memory_hotplug.c                             |    3 
 mm/page_alloc.c                                 |   85 +++++-----
 mm/shuffle.c                                    |  193 +++++++++++++++++++++++
 mm/shuffle.h                                    |   64 ++++++++
 12 files changed, 421 insertions(+), 50 deletions(-)
 create mode 100644 mm/shuffle.c
 create mode 100644 mm/shuffle.h

