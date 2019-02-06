Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A53C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 07:24:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC1742175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 07:24:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC1742175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35CEF8E00AF; Wed,  6 Feb 2019 02:24:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30D478E00AB; Wed,  6 Feb 2019 02:24:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D5528E00AF; Wed,  6 Feb 2019 02:24:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C55938E00AB
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 02:24:50 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so4010981pgv.23
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 23:24:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Wxh8f3s6UwQEJGcy/EOXTQw99b5N4/nV0hHaHZTvNgo=;
        b=Rn5Frb+Qf9K/wudhCL+pt0S0cjp3BrZqy5cqKQt7N2OeMaFSVvX58/JOFTNeU7lVxm
         hQrBfAQoczPwrvZlDeAxF547bR8PUh6n3sXUUudKnKyYL3qTZmjXCY2+RB9v2qJqUGwJ
         akJBkOOrb8wn7yBunEP39bPqZB+6nnjO9m91bUv51Bi5LY2HXg0Cnx7J9USrA065r1i2
         9LuGHzZFfqrxr7uQ9uNdFnkwPExfXeR57hdUiR+Hc586zGXr2WZbOd0LspQP4jLV1ygM
         23IhBG9N2DHFFd0mW1+uQoG6AJpy/VSnr+GNUAeNwl45ufjcEVx3X/9/B/Yuthx+06B/
         RcaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZKh2jXKR7BXB9jgF8R+MLjWzyInxmLsXo6e4e0wSN66taQGDQk
	2a6jy+sVJKKvN+qYFv5c5fKZSZAyds2WeOBHFgMUkVFWIZXp4QETz4PxjQ252WPM0s1/D6fZvR0
	jA7igUTQNWNFzTQCMuD+lf2PQ66MYxNANPeublPoRKErZt4thaS7UjO1UesdQzkPhkQ==
X-Received: by 2002:a62:68c5:: with SMTP id d188mr9430376pfc.194.1549437890429;
        Tue, 05 Feb 2019 23:24:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY7DCyZSfcRAmQr5anom2OpTO4N6O5LvqlBh2K6L9mUihV4DKSwOZCCqvrivgiO8OYO6jyT
X-Received: by 2002:a62:68c5:: with SMTP id d188mr9430323pfc.194.1549437889570;
        Tue, 05 Feb 2019 23:24:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549437889; cv=none;
        d=google.com; s=arc-20160816;
        b=bOL4hQZD13ejSBPBu5T3QYYGPHUsM8tmZggcP4v9P9x0unwuJAn4dtHKUMKF807mBf
         7JSgn4N62Amc50mPqhWBn03mVbf3UoJAZyIYwsxV0s372HPlDgzk0DPOsikOqdwPvXWU
         VHov28S+oVFwDEGQChAmmYOu1l1Cj41Hcjy+eIsxu7MaQuppZOps6do+Us3jEC09P4YK
         WV9h75EGAPd51QGg0kGOw3AAtb9a8khH4ioe96sYWC7OZ909Xw3ak0u+Wlf+6qOqY039
         8bDTKuKGJ77XDAMNsss8KyGGchL7oVwb2K7IiJgZonAq8Koewk5UeoBrxqBrsTDixjl4
         3dNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=Wxh8f3s6UwQEJGcy/EOXTQw99b5N4/nV0hHaHZTvNgo=;
        b=G7In0Z3UmkhMAV24I/jxV6H27Umr5iJ+IubZ11dd+MdL/C2rVqeYRxNT0nEdS142hJ
         U0J1cp9y3esov6gzfDnrOCOjiPrm+83pjSL01HHr48gFk2d3jCPOppRXqGtZcr8LWQFU
         LLuF7Opk8Vwkuvzv5hlPAmr64E0iqIQeXNrbRS1wzlbynpYyuRl6Fa6TGZN2whDRaxNY
         fwfSPCIApjxYcQy3f2OkY2XGETWHK9d4ilMhAnNgmLC8Zu62pYdaiPQ0eLnr3IWb5sn/
         QZzj9j0Di3J5GQQk3QB4lMoGD3Z198ZkY59NPCjpf4Xy5YxAsjxWMpxmWmkyVK6EWYu7
         YRUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b9si1355530plr.66.2019.02.05.23.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 23:24:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 23:24:48 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,339,1544515200"; 
   d="scan'208";a="141953069"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga004.fm.intel.com with ESMTP; 05 Feb 2019 23:24:47 -0800
Subject: [PATCH 1/2] mm/shuffle: Fix shuffle enable
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, keescook@chromium.org, linux-kernel@vger.kernel.org
Date: Tue, 05 Feb 2019 23:12:10 -0800
Message-ID: <154943713038.3858443.4125180191382062871.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154943712485.3858443.4491117952728936852.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154943712485.3858443.4491117952728936852.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The removal of shuffle_store() in v10 of the patch series was prompted
by the review feedback to convert page_alloc_shuffle() to __memint. I
obviously booted a stale kernel build in my tests because
shuffle_store() is indeed required:

 BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
 #PF error: [INSTR]
 PGD 0 P4D 0
 Oops: 0010 [#1] SMP PTI
 CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc1+ #2867
 Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS ?-20180531_142017-buildhw-08.phx2.fedoraproject.org-1.fc28 04/01/2014
 RIP: 0010:          (null)
 Code: Bad RIP value.
 RSP: 0000:ffffffff82603e78 EFLAGS: 00010046
 RAX: 0000000000000000 RBX: 0000000000000000 RCX: cccccccccccccccd
 RDX: ffffffff8261d7c0 RSI: ffffffff8244c010 RDI: ffff88843ffe1aaa
 RBP: ffff88843ffe1aac R08: ffffffff83486978 R09: 0000000000000000
 R10: ffffffff82603e80 R11: 0000000000000048 R12: ffff88843ffe1a97
 R13: ffff88843ffe1aaa R14: ffffffff8244c010 R15: 000000000000016d
 FS:  0000000000000000(0000) GS:ffff88811be00000(0000) knlGS:0000000000000000
 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 CR2: ffffffffffffffd6 CR3: 0000000002614000 CR4: 00000000000606b0
 Call Trace:
  ? parse_args+0x170/0x360
  ? set_init_arg+0x55/0x55
  ? start_kernel+0x1d8/0x4c4
  ? set_init_arg+0x55/0x55
  ? secondary_startup_64+0xa4/0xb0

Reintroduce it and mark it __meminit. Given the sysfs attribute is not
writable it will never be called after init.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/shuffle.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/shuffle.c b/mm/shuffle.c
index 19bbf3e37fb6..3ce12481b1dc 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -38,7 +38,21 @@ extern int shuffle_show(char *buffer, const struct kernel_param *kp)
 	return sprintf(buffer, "%c\n", test_bit(SHUFFLE_ENABLE, &shuffle_state)
 			? 'Y' : 'N');
 }
-module_param_call(shuffle, NULL, shuffle_show, &shuffle_param, 0400);
+
+static __meminit int shuffle_store(const char *val,
+		const struct kernel_param *kp)
+{
+	int rc = param_set_bool(val, kp);
+
+	if (rc < 0)
+		return rc;
+	if (shuffle_param)
+		page_alloc_shuffle(SHUFFLE_ENABLE);
+	else
+		page_alloc_shuffle(SHUFFLE_FORCE_DISABLE);
+	return 0;
+}
+module_param_call(shuffle, shuffle_store, shuffle_show, &shuffle_param, 0400);
 
 /*
  * For two pages to be swapped in the shuffle, they must be free (on a

