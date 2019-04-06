Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A986C10F06
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 15:20:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A020A20B1F
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 15:20:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A020A20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAAC86B000E; Sat,  6 Apr 2019 11:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D32DA6B0266; Sat,  6 Apr 2019 11:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BADBD6B0269; Sat,  6 Apr 2019 11:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 964546B000E
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 11:20:42 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g25so7538731qkm.22
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 08:20:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:user-agent:mime-version;
        bh=/vHmpH+rTfN6wWQq9Ei9KPoggm34yeLMw3u0GlMGADA=;
        b=h3jTaMcMlTmpHJZaqc17x87/koHBKyzc0ML1ovwb8f9hNpYQfE6f59/4kTUuUl+Ndg
         iMBiCzngOJrRayOUCV/7QVTOxUttJDUHSPdOi7o8ks5uXgIjIikVI4AElvNxtuQq3Lwj
         0dPBjEciYSJ8bh4kN8+Dj62ekEAw3+HQMEz0QwlxO3r6zJsV7e5t9B1Xg2PdX0oBcN6G
         BkfU8AhW2GubSOKbJtTWzxA0aOU7Cem+bHHSka6ReQl89hmD9QOhsiqxtQCl0n8184GQ
         o3omjGhcT1q+1PZ3pr3R4NvQ05IsJKCqrHsfJX78H3wTLO2QXwyYuxiIcz01ZHMkaNv0
         7SzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWTfC8yyMkmpxDt8MPFt5MyY0GqNTphI5m4jzahdW0vKJx1c1l0
	C+ljJ+1UpTLrbi5SgQDvxUkI/qQV/sXQHFVmo6NaKrHUMOSDViahn4IAVekGMB2Y4wA+puXeOZa
	igyDn12I70/r9jYmNl1X8zMAtzVdSX6cV26HaXF0BbwxHV8Qk4GFrRrGZ9WeWE37Epg==
X-Received: by 2002:a37:7b03:: with SMTP id w3mr15917947qkc.266.1554564042341;
        Sat, 06 Apr 2019 08:20:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/iIEAAR91cPWar5UcurFiJhx5FRzVCnCjo+DbPDhgSkoTpCie4k2hYwd/04DgfpUrRRf7
X-Received: by 2002:a37:7b03:: with SMTP id w3mr15917896qkc.266.1554564041675;
        Sat, 06 Apr 2019 08:20:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554564041; cv=none;
        d=google.com; s=arc-20160816;
        b=L6FryUvoJXFWISlA9plkVk3H1x4a52n/qkA0JEAXI15YOK/1wPvSfeJ520ugJKKnU2
         xSfM5OaPr7YHENAQftmYWXfVlmGbq05tBseQNglkiF/xIgkV9sAvNIWbywmaVPGzXKsZ
         ekHjE2CmEVVAxBq4RRfzBp8dXEGwYKFyqj+e9PCeV+R4RJ10Z5ka2Ls5/ZPxgtaMHM3d
         jaoWOPunWkBW144JUXS0foq+65EzNCGQeJnfguQgPVnOCNnEa5YtcgbVQZMVZLOVObnP
         h7PbV+NG80bosKfmuj6v1wZpkNz5XQLH8gC0tGlgz2FAEH7VbBHDhXSjME+IeR7GZ3RU
         3TIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date;
        bh=/vHmpH+rTfN6wWQq9Ei9KPoggm34yeLMw3u0GlMGADA=;
        b=TYY9Juu3pOP2+Cfh4qJ4JkPN6VueN0YBwe09x23u7tHbWixYbtGLk2Y3xTo5nig5b3
         4kVOlZaY0sdmI2gnTo0ndRJNVOGng2baKfcHSpk3/jty8NL/zty6JeQuV99pBUE36T6J
         m/KqNVtreQuvNeUMuQC6+eUWLdaQZsxAcDTk7VYdBH75/ijC2w16Goe4jsYlyMF3UDBt
         5E5qO5X/GDn8g0A7xjuHk3NwH3Yvo0dx3mhPPBdwh+8YEx0DGNSpD+a7U8PQpE+BWO9U
         ippCcZICj8vMfnBBFYVK0QqrUmG33Q5BfipoVgdV4cwnfH85fkjPPE3YK25DWA4QfDw6
         XQhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j1si258177qte.42.2019.04.06.08.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 08:20:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 61B2EC0AC36A;
	Sat,  6 Apr 2019 15:20:40 +0000 (UTC)
Received: from file01.intranet.prod.int.rdu2.redhat.com (file01.intranet.prod.int.rdu2.redhat.com [10.11.5.7])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A8BFF60F99;
	Sat,  6 Apr 2019 15:20:38 +0000 (UTC)
Received: from file01.intranet.prod.int.rdu2.redhat.com (localhost [127.0.0.1])
	by file01.intranet.prod.int.rdu2.redhat.com (8.14.4/8.14.4) with ESMTP id x36FKb2a014736;
	Sat, 6 Apr 2019 11:20:37 -0400
Received: from localhost (mpatocka@localhost)
	by file01.intranet.prod.int.rdu2.redhat.com (8.14.4/8.14.4/Submit) with ESMTP id x36FKZxC014732;
	Sat, 6 Apr 2019 11:20:36 -0400
X-Authentication-Warning: file01.intranet.prod.int.rdu2.redhat.com: mpatocka owned process doing -bs
Date: Sat, 6 Apr 2019 11:20:35 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
X-X-Sender: mpatocka@file01.intranet.prod.int.rdu2.redhat.com
To: Mel Gorman <mgorman@techsingularity.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Helge Deller <deller@gmx.de>,
        "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        John David Anglin <dave.anglin@bell.net>, linux-parisc@vger.kernel.org,
        linux-mm@kvack.org
cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>,
        Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
Message-ID: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
User-Agent: Alpine 2.02 (LRH 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Sat, 06 Apr 2019 15:20:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

The patch 1c30844d2dfe272d58c8fc000960b835d13aa2ac ("mm: reclaim small 
amounts of memory when an external fragmentation event occurs") breaks 
memory management on parisc.

I have a parisc machine with 7GiB RAM, the chipset maps the physical 
memory to three zones:
	0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
	1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
	2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
(but it is not NUMA)

With the patch 1c30844d2, the kernel will incorrectly reclaim the first 
zone when it fills up, ignoring the fact that there are two completely 
free zones. Basiscally, it limits cache size to 1GiB.

For example, if I run:
# dd if=/dev/sda of=/dev/null bs=1M count=2048

- with the proper kernel, there should be "Buffers - 2GiB" when this 
command finishes. With the patch 1c30844d2, buffers will consume just 1GiB 
or slightly more, because the kernel was incorrectly reclaiming them.

Mikulas

