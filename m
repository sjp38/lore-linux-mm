Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32194C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0E9A206BF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0E9A206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3882A6B0005; Thu, 16 May 2019 05:42:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 312C66B0006; Thu, 16 May 2019 05:42:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2030A6B0007; Thu, 16 May 2019 05:42:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4A696B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 05:42:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u3so870899wro.2
        for <linux-mm@kvack.org>; Thu, 16 May 2019 02:42:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=gHm+iD7rZdl8yaphKTxHy2bQe/5CXij6G4rlYG4YYfI=;
        b=o0U9xaJgGhow+HzS4DKCSBa4SWot+TpN1FbiN84bnxyX95FnWMc3ZRov2IUfTxjYZG
         Yd2TiXgH9WwRkiRbBF3auE3oe1ohwMJ5bTrOEVku2owDBrCcG6S/J68C2auxUgXFwNNV
         VTai0rhlMVa9pTtCMN7RsxdPZVAVKWImKp8M/8jldkWhAjDuo7m1NU8iWU37sE30WXAv
         dXjLV8p2XUWOiCbgjeOmAyW5LGxHwUnU53rO6ahCHXZLmTF0Jaafr2nM+qtikUmD5JHb
         iuiId8k494/E4awz1dyNFW3snEMzWzV06S5Hmv4djQquEUlUiz8GNHDTBrnVHVN7fhub
         pIwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUy1ak9ZTcvl9hNvpFGeQweuh4dMB58q7oPDn+A/qRkr4+gvnWB
	ju6zZ7DRMtJAMrvI+dtT9ySviocrVJGprqF9COsQOzEdtfYZLFZCFafHpZk7eYzdmaM7QVKqGV8
	Bf36ZaoCmAqRNlJO7o2jpENIkztDNGuTEEE8g5wdihY1AjnyDlaY3kSjKaQmyB5wo6Q==
X-Received: by 2002:a1c:3c2:: with SMTP id 185mr9025152wmd.91.1557999758184;
        Thu, 16 May 2019 02:42:38 -0700 (PDT)
X-Received: by 2002:a1c:3c2:: with SMTP id 185mr9025090wmd.91.1557999757093;
        Thu, 16 May 2019 02:42:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557999757; cv=none;
        d=google.com; s=arc-20160816;
        b=m9zY69rQBwmV/+Ba/KFcxpSLWGK5SVQoDGgvu52zLRMkXtMI52YhWOWFx/6MgVgIWK
         v+uyD6LPfBQxYvQ5t5qDO4IyKclvZCCXDbTGxy2ukOWAWN7Zkt5HCCTvchWwdNIe/wEV
         1hVBXYaXiOCT1Pl5UfjRTKTERBwaZzreHqOKLolcbCHo52hyM6sxwflmyLIeKe89z6Dx
         cltArUCxz80NGA5r6qNDRCu8/+XxMWp6v8mCU2abs5ELZC+3MwW6D97vafuNbx39WJfz
         tG7GIuhXYmRoxTKgkrLOa34qOLWxDDwrcRgahIFWbNyqA4Xy0JvzTnohvPcQOlkCutS3
         EWlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=gHm+iD7rZdl8yaphKTxHy2bQe/5CXij6G4rlYG4YYfI=;
        b=t4k7kR0ZsrB0mRpj1ftnAlKmQqj29WdwpIWD5ZfhPd1PR16oDh8EPvI7lv66RPK1l0
         B+qohgUXyFBwJsWn2Ba7iTd6huymLciOmHvukcSnnOYf4uZOpK1P9SZK2Sp629x9RHb6
         6TVLxzf6I+TqqzolLh221HTI1bRj5gfoM1euuxyL9xah590ZIdlpQnw/3BKX4NiqNEfi
         KOF2mGrJ2g8CBG+3cQXkkNkRy5dN+oSKE6/7dopvmnHuT4ItfJp/Ya7ra2nAi8l8n52J
         UDTt1lOZcG/PXHQIl/z9JYLWcsa9uHU82yZX7eHNfdA9XKt/1qaG9KGUGnwGAaoqmbQ5
         FXSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11sor2966603wmi.6.2019.05.16.02.42.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 02:42:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqywEZzpwr5DVxyQ7iBWpgzDQ3CVPDqgyLNgDwPWzSeCwIJ01Zq+QHt2fwTtyY5wN7IHt5QUxA==
X-Received: by 2002:a1c:e702:: with SMTP id e2mr13277260wmh.38.1557999756483;
        Thu, 16 May 2019 02:42:36 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id h11sm5900942wrr.44.2019.05.16.02.42.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 02:42:35 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH RFC 0/5] mm/ksm, proc: introduce remote madvise
Date: Thu, 16 May 2019 11:42:29 +0200
Message-Id: <20190516094234.9116-1-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It all began with the fact that KSM works only on memory that is marked
by madvise(). And the only way to get around that is to either:

  * use LD_PRELOAD; or
  * patch the kernel with something like UKSM or PKSM.

(i skip ptrace can of worms here intentionally)

To overcome this restriction, lets implement a per-process /proc knob,
which allows calling madvise remotely. This can be used manually on a
task in question or by some small userspace helper daemon that will do
auto-KSM job for us.

Also, following the discussions from the previous submissions [2] and
[3], make the interface more generic, so that it can be used for other
madvise hints in the future. At this point, I'd like Android people to
speak up, for instance, and clarify in which form they need page
granularity or other things I've missed or have never heard about.

So, I think of three major consumers of this interface:

  * hosts, that run containers, especially similar ones and especially in
    a trusted environment, sharing the same runtime like Node.js;

  * heavy applications, that can be run in multiple instances, not
    limited to opensource ones like Firefox, but also those that cannot be
	modified since they are binary-only and, maybe, statically linked;

  * Android environment that wants to do tricks with
    MADV_WILLNEED/DONTNEED or something similar.

On to the actual implementation. The per-process knob is named "madvise",
and it is write-only. It accepts a madvise hint name to be executed.
Currently, only KSM hints are implemented:

* to mark all the eligible VMAs as mergeable, use:

   # echo merge > /proc/<pid>/madvise

* to unmerge all the VMAs, use:

   # echo unmerge > /proc/<pid>/madvise

I've implemented address space level granularity instead of VMA/page
granularity intentionally for simplicity. If the discussion goes in
other directions, this can be re-implemented to act on a specific VMA
(via map_files?) or page-wise.

Speaking of statistics, more numbers can be found in the very first
submission, that is related to this one [1]. For my current setup with
two Firefox instances I get 100 to 200 MiB saved for the second instance
depending on the amount of tabs.

1 FF instance with 15 tabs:

   $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
   410

2 FF instances, second one has 12 tabs (all the tabs are different):

   $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
   592

At the very moment I do not have specific numbers for containerised
workload, but those should be comparable in case the containers share
similar/same runtime.

The history of this patchset:

  * [2] was based on Timofey's submission [1], but it didn't use a
    dedicated kthread to walk through the list of tasks/VMAs. Instead,
	do_anonymous_page() was amended to implement fully automatic mode,
	but this approach was incorrect due to improper locking and not
	desired due to excessive complexity and being KSM-specific;
  * [3] implemented KSM-specific madvise hints via sysfs, leaving
    traversing /proc to userspace if needed. The approach was not
	desired due to the fact that sysfs shouldn't implement any
	per-process API. Also, the interface was not generic enough to
	extend it for other users.

I drop all the "Reviewed-by" tags from previous submissions because of
code changes and because the objective of this series is now somewhat
different.

Please comment!

Thanks.

[1] https://lore.kernel.org/patchwork/patch/1012142/
[2] http://lkml.iu.edu/hypermail/linux/kernel/1905.1/02417.html
[3] http://lkml.iu.edu/hypermail/linux/kernel/1905.1/05076.html

Oleksandr Natalenko (5):
  proc: introduce madvise placeholder
  mm/ksm: introduce ksm_madvise_merge() helper
  mm/ksm: introduce ksm_madvise_unmerge() helper
  mm/ksm, proc: introduce remote merge
  mm/ksm, proc: add remote madvise documentation

 Documentation/filesystems/proc.txt | 13 +++++
 fs/proc/base.c                     | 70 +++++++++++++++++++++++
 include/linux/ksm.h                |  4 ++
 mm/ksm.c                           | 92 +++++++++++++++++++-----------
 4 files changed, 145 insertions(+), 34 deletions(-)

-- 
2.21.0

