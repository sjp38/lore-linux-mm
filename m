Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 856A9C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:55:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325F52083D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 03:55:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325F52083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB2508E0004; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A62FE8E0001; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9871B8E0004; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 736228E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 22:55:53 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id o2so1508885qkb.11
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:55:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LljDv2MZXL/yMAGWVfa5VF3geBWTswI9hAabCpk7E5Q=;
        b=dcb0fQATfBXHiMpoAS9mOqbXGFqnFioco2WqXnR+YW7bAt1NHODiwUyg+2/JJRX2Uh
         kjUs/LrzyNH7vhYKupkPzZ72zOWpPOMZCfqqm34jpVPqhsVv+HXeDR7nmYSY9fqZvkel
         RBtBuou6ceM4xqwGWlVMLLSI6hP8gjmR3thi83VdzrFPy6rfAVadhqH957PUUVbguLgU
         0KkRgcPX+9WMB+5ZhYL6oYaID8JHAfle2yt6NbWTvsO6YrvsjMH8K92zj38urJR6vOgv
         NsO7hMoGtVYMG2ysXDkDBOIi1skw6eJURN7aXXUlrFmXA6VaTvO9mFIQEMO+IpuRGNTf
         o0nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU/gw4ZLEaeqJVHPfYrwIakCGzOkCgL+9HLp9VQPnWA0Cu+88ye
	LMugzB2JCq41tuV+JFNtcDGBjZcMFCdIrRccuCfPetVJPuBAtpyEXUvruIF9orzZ2EbzGhCg0z/
	3FrhhkUNtBoEOLclgtu7K1pJjIaiuNirXpNgnph4Rp2OxwhD+AitJsv3flZ64icCbGg==
X-Received: by 2002:a0c:c127:: with SMTP id f36mr2179707qvh.96.1551412553218;
        Thu, 28 Feb 2019 19:55:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqyb+D1cNzMqOCVzzMJNrdYGMmbzGn/ricHJYhGplgNwE3MYONBumi7E/z0jE1GtHwzwydet
X-Received: by 2002:a0c:c127:: with SMTP id f36mr2179683qvh.96.1551412552379;
        Thu, 28 Feb 2019 19:55:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551412552; cv=none;
        d=google.com; s=arc-20160816;
        b=AKjvOnmKPKhyCl8GPU0nJ8TBe6zKShU6mch/LWbyIpgumped/UZNxXScZiHEr2QVI9
         gmC48bc3au+KAV0AS4tNQrUbXT7NtgeYfK9dFGMg/m+vp8MIH4MTZhdzB0EJXQ/4oGc/
         m9F9kMyO5Dt2k7afz1LofcUxJPByFFk49bpYox6CC4/V9cCgwvPVds8AfU5VjyJu/yrZ
         F4pCGtNSEIEtcFOypy98UZWoAVatmgbh/YbkHaNuSc0yL9fenDPXyGAyhOb9ijqNOfWM
         7utLi1Rrlozmaq20ekyMYKlTZ77+M8+OC3fYRQV5caLdwBfoqGPL6zAKIefcSQoVQEWO
         8xWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LljDv2MZXL/yMAGWVfa5VF3geBWTswI9hAabCpk7E5Q=;
        b=yLTMtwFl3sLYxG2BSjsGVWuO/b8lFLw+vhDpxjOjUhpXMoYvqmWR0xFS5KsLqarIpt
         ScCAHIHb63I/LCtmz5yWv+C/FfMPalqE/O/sn0VYyGVqPCxkk6P+r1beul25zgePDZrW
         EYKfS3Fg3WWslVLw9+iWkp5wazMR+ttYtJ09d3DtfSI+SUqVr8gajJ3KSAZN+76ljrL4
         gFZRUoQn1+7IjneONHs/q4hST69fKk5HSMEF/1Ke3ErwLWrQS0ZSqayfm2zklEIsBx1f
         sBSA4QpUfTamMZHf3CAac/hOC0FAiqoHojuPFgLDZT28BeAngSvIAHCjlADn13Ld+x4w
         317Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si4656375qtn.176.2019.02.28.19.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 19:55:52 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 940A2C075BD7;
	Fri,  1 Mar 2019 03:55:51 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 52CFB57997;
	Fri,  1 Mar 2019 03:55:51 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 1/2] coredump: use READ_ONCE to read mm->flags
Date: Thu, 28 Feb 2019 22:55:49 -0500
Message-Id: <20190301035550.1124-2-aarcange@redhat.com>
In-Reply-To: <20190301035550.1124-1-aarcange@redhat.com>
References: <20190301035550.1124-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 01 Mar 2019 03:55:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mm->flags can still change freely under the coredump using atomic
bitops in proc_coredump_filter_write(). So read the mm->flags with
READ_ONCE for correctness.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/coredump.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index e42e17e55bfd..cc175d52090a 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -560,7 +560,7 @@ void do_coredump(const kernel_siginfo_t *siginfo)
 		 * inconsistency of bit flags, since this flag is not protected
 		 * by any locks.
 		 */
-		.mm_flags = mm->flags,
+		.mm_flags = READ_ONCE(mm->flags),
 	};
 
 	audit_core_dumps(siginfo->si_signo);

