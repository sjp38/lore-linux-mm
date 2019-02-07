Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD8DC169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 01:32:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADB7C217F9
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 01:32:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADB7C217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stgolabs.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49E608E000E; Wed,  6 Feb 2019 20:32:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 449368E0002; Wed,  6 Feb 2019 20:32:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33AB08E000E; Wed,  6 Feb 2019 20:32:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF8D18E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 20:32:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m11so210872edq.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 17:32:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IZe+5zDMpwy+VeAKv/jmgUnsq/9GgHud2PTBFKt9Hjc=;
        b=q3QW2SfZQo4M/h+ZI+O+mdgRBcGlHqghKRuQfDXffJPGEwtOLHHeJwGyXEkp2TP5I4
         ANeOjc3xwnftzVBZKgSI6jkfwrsdj0BDpQrq0BEJixhIVZgWqf8r9UTDrO+iYfR5VOUG
         ju0VCDbOqjaIjPrZFSBpaiKXBOo1GSuPdL1V5+PGZFEA9YoSyngZZzi9qpkxhMh6xWLS
         brOzaeVF+ld9tFxByVBjNgdvr3rDVkZLktwsmXxNd4Ukv/ixvCquQy41iHnh48DPqVqk
         D57vO8Ylg/QXrVINF4aW12r+Ok1tf9gXxHLHCL7jPgeG5kKY3JAcHnnn8rvSNtScI1Vk
         RkgA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Gm-Message-State: AHQUAuYuMu1pFBFInqgYomyQNEIIiaHh8NiLXsMB0wT0xFWYGXaS9GVj
	OzemjKFnF9It94C/I1AzdCMWI3DavpAwPZhLTLOMq3ZOBPl9aYptPVM9vdmRYGYZOK5D6s6tEi3
	X0O7hwkUQ4EHZQudvplB/ylLywOek0mJr5G0CcIH25TSdCPUBJZJY1L83PMyrfyw=
X-Received: by 2002:a17:906:35d5:: with SMTP id p21mr9289133ejb.229.1549503130299;
        Wed, 06 Feb 2019 17:32:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaMcXSzIT3KGmmLWlZ/sdU6A3OWEu7SaoucW5WYXjq/53b/iJ/W7CDrfNSyNZAGY1koOo0o
X-Received: by 2002:a17:906:35d5:: with SMTP id p21mr9289092ejb.229.1549503129449;
        Wed, 06 Feb 2019 17:32:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549503129; cv=none;
        d=google.com; s=arc-20160816;
        b=H70sKWhRZ9KaitqI3pKfhn/bKjMQ5kO4YXL7Hes5hsOBPEr9FCCuRW2w2SVq2djK+p
         jXhIHhewyu+KVdofKX5ZAFVfhFwXD/WQKSrcBryQBMjOi9ILu9MqEtxPZfuoLI4Gjk7P
         jZzJWtzdT6Xq9dgW5dDwlXnO086p0ugGfjRhGz940ZeSujJ1w1olS0NiY2XvSg5VNO8b
         PO45SLOQ4z76MH6uqXbYsS8j0jS0OuEAItf0sABLKDGAX4gbsZNYgr2g5hpfmbOYGPzp
         YDjfjIVFJUVdeVRKmKzS9i7jDFccDsOjyoUSq1tj1IQx+Lyhv5UynNrVgU0kctICLwj7
         dZ9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=IZe+5zDMpwy+VeAKv/jmgUnsq/9GgHud2PTBFKt9Hjc=;
        b=y1yQecb+LONkA9CCEYxtw39BqXE/y/sK2bqnj51VeGYwxM7Jn+FxB/s71Ehdzm/r7+
         Iuz0onr6xSSXeuoABJnboIpvWVO/dHW+lx+a4HLaziaecXHkA6mQgGLrBDZOhUphw1rf
         GuLe7L5u2r9O7REMMQe9pkZ582imhVzT15m+AjIhz9JaRWu2sryn8vVltd0wL3P+3Rx4
         AH5DoIwSV0bMi8hClBM4rfZYy05wf++F0ChxhWjeE5W/aPv0fuMr/3VbCyzmYSXsELq8
         DSp+yiYUI4OytfFP2BWNv48DAUcMs6LaKVOJbvfGF6Uks0NDS9b3zP+kzTs+x9HY3C52
         7Wyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q47si7207094edd.98.2019.02.06.17.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 17:32:09 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning dave@stgolabs.net does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=dave@stgolabs.net
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2EEAAAFA8;
	Thu,  7 Feb 2019 01:32:06 +0000 (UTC)
Date: Wed, 6 Feb 2019 17:31:55 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
To: jgg@ziepe.ca, akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, jack@suse.cz,
	willy@infradead.org, ira.weiny@intel.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 7/6] Documentation/infiniband: update from locked to pinned_vm
Message-ID: <20190207013155.lq5diwqc2svyt3t3@linux-r8p5>
Mail-Followup-To: jgg@ziepe.ca, akpm@linux-foundation.org,
	dledford@redhat.com, jgg@mellanox.com, jack@suse.cz,
	willy@infradead.org, ira.weiny@intel.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
References: <20190206175920.31082-1-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
User-Agent: NeoMutt/20180323
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We are really talking about pinned_vm here.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 Documentation/infiniband/user_verbs.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/infiniband/user_verbs.txt b/Documentation/infiniband/user_verbs.txt
index df049b9f5b6e..47ebf2f80b2b 100644
--- a/Documentation/infiniband/user_verbs.txt
+++ b/Documentation/infiniband/user_verbs.txt
@@ -46,11 +46,11 @@ Memory pinning
   I/O targets be kept resident at the same physical address.  The
   ib_uverbs module manages pinning and unpinning memory regions via
   get_user_pages() and put_page() calls.  It also accounts for the
-  amount of memory pinned in the process's locked_vm, and checks that
+  amount of memory pinned in the process's pinned_vm, and checks that
   unprivileged processes do not exceed their RLIMIT_MEMLOCK limit.
 
   Pages that are pinned multiple times are counted each time they are
-  pinned, so the value of locked_vm may be an overestimate of the
+  pinned, so the value of pinned_vm may be an overestimate of the
   number of pages pinned by a process.
 
 /dev files
-- 
2.16.4

