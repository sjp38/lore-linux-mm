Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D6BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 803CA2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:13:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 803CA2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B76E6B0003; Wed, 20 Mar 2019 06:13:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 067B66B0006; Wed, 20 Mar 2019 06:13:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E987B6B0007; Wed, 20 Mar 2019 06:13:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C97266B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:13:23 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d131so7181568qkc.18
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:13:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uP6lLr9iJ298pqfpF2PkO31qT9njcHSUGQ4R0G0+01I=;
        b=m5oikYoUIihukrMfW00SSrkaQGAPoIP0KDYAAML74IVuGaZXGjrwPFq1zZAD5ptwsC
         rcjOmWZPLyEs7nAfEnzrcNqmooJnwu9aErtIvyOSN9W3Zsfih/k2hFhGmT8/1cvBXUqr
         M5ath8bcb0Gq9tn804N7zplcf1YGFYY010egShtY/u8fUK6ihyfIe+CUefnLz1a4tuGE
         BryG8UR1BW2ftFgtx5wPf6lGva7UvNZnJn6VA67whmvlCZzrmTlwThV3+LyPg809aXpt
         /YtvPgJNbS3PyOSNb9pqOiDmCcijkdT95+kc0edxl61EbOu5BvwS0ERQU7o8kbYIauPy
         fU3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXALdJrZxvvXzELdT9LxSSXe7HV6XkHWytvHR5C4TtEqwU9Xku5
	eyCJJq7L30jBhAftiLaRTrytd04i/wfujHVuNB+pQnpx74p4CsSPYvvFBQH1DlnBu0lxyjd9iJw
	LYyC/BzHlksDgdUydwe4UV7QSjulo3FhwOnINcZlktzlTnRssQENfS+347Xc89MLeNg==
X-Received: by 2002:a37:4ec2:: with SMTP id c185mr6042687qkb.244.1553076803554;
        Wed, 20 Mar 2019 03:13:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVwzXhnat4KLe3hqiUds425ZdmU/0eZU5a7qGghgIggmqfkvdsMVG74CXwKbeJVEB86jIe
X-Received: by 2002:a37:4ec2:: with SMTP id c185mr6042642qkb.244.1553076802865;
        Wed, 20 Mar 2019 03:13:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553076802; cv=none;
        d=google.com; s=arc-20160816;
        b=rd2TQCPRHQpgXRY263FVkV0jsPQszclMW5UZLUOp6eUv17AgqMmFFPwIqvaf/TQoTa
         nOk81Dg7i4+zKY5a0S78KnkKr3QWSpw+FPcxOtD6xcU0G0aRX9DI6ehtqp5gtwM8atux
         kuMjaN6jep70x9Keu0LtxeD9cX4I7zqi40dZzvg9kYOSK8yxLySxc6A4Z38/6XesRqga
         q8KS+WLxD1z7N0moRC53Zj010w5+AYin5nkNjd14R2QC+Ju0xehWudCkL1nm//66gVvO
         /giMaXajog7fP5TLZfFNDiyEQboqZBDhnskm4Kp0xrfc/J4XHd/jqdM+evUKqwXd4CNQ
         aKhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uP6lLr9iJ298pqfpF2PkO31qT9njcHSUGQ4R0G0+01I=;
        b=ptjeZRiV10UHN1Hz5p3WHLS6xpdDK2RJvEaK5+MtqHlO8PSDAO7AUFq80V94XDD7b9
         1hACG1SbTHfURiHpEStJitb4gI7fkZAEWTkBzZmgGCa1u8ECYaq1sFxacT4xrWf7L+t5
         rQVuvxqNBb4zqOEs79NJR/MW6ax4fXRwDg3xLNTzxDEevky/e+JQWGRwIP3MxZtIu3PO
         mAcpFj9sny/mfmiBrSmxXpJSCkjgV810lWx3xfVcDnzZtQdrF8hPa181xP2cuN1y9n8x
         cTTT/DbCsnGLsZY/Z2seyBiJxLbs2XOtQ5yt/wRESPGH950xJY5FB47aSGcSR5kwMDE4
         Bkcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e7si87709qkb.189.2019.03.20.03.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 03:13:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CDF302D7E0;
	Wed, 20 Mar 2019 10:13:21 +0000 (UTC)
Received: from localhost (ovpn-12-38.pek2.redhat.com [10.72.12.38])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 243D35D71C;
	Wed, 20 Mar 2019 10:13:20 +0000 (UTC)
Date: Wed, 20 Mar 2019 18:13:18 +0800
From: Baoquan He <bhe@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	pasha.tatashin@oracle.com, mhocko@suse.com, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190320101318.GP18740@MiWiFi-R3L-srv>
References: <20190320073540.12866-1-bhe@redhat.com>
 <20190320073540.12866-2-bhe@redhat.com>
 <20190320075649.GC13626@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320075649.GC13626@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 20 Mar 2019 10:13:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On 03/20/19 at 09:56am, Mike Rapoport wrote:
 > @@ -697,16 +697,17 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> >  	ret = sparse_index_init(section_nr, nid);
> >  	if (ret < 0 && ret != -EEXIST)
> >  		return ret;
> > -	ret = 0;
> > -	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > -	if (!memmap)
> > -		return -ENOMEM;
> > +
> >  	usemap = __kmalloc_section_usemap();
> > -	if (!usemap) {
> > -		__kfree_section_memmap(memmap, altmap);
> > +	if (!usemap)
> > +		return -ENOMEM;
> > +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
> > +	if (!memmap) {
> > +		kfree(usemap);
> 
> If you are anyway changing this why not to switch to goto's for error
> handling?

I update code change as below, could you check if it's OK to you?

Thanks
Baoquan

From 39b679b6f34f6acbc05351be8569d23bae3c0458 Mon Sep 17 00:00:00 2001
From: Baoquan He <bhe@redhat.com>
Date: Fri, 15 Mar 2019 16:03:52 +0800
Subject: [PATCH] mm/sparse: Optimize sparse_add_one_section()

Reorder the allocation of usemap and memmap since usemap allocation
is much smaller and simpler. Otherwise hard work is done to make
memmap ready, then have to rollback just because of usemap allocation
failure.

Meanwhile update the error handler to cover usemap allocation failure
too.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index a99e0b253927..0e842b924be6 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -699,20 +699,21 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
-	if (!memmap)
-		return -ENOMEM;
+
 	usemap = __kmalloc_section_usemap();
-	if (!usemap) {
-		__kfree_section_memmap(memmap, altmap);
+	if (!usemap)
 		return -ENOMEM;
+	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	if (!memmap) {
+		ret = -ENOMEM;
+		goto out2;
 	}
 
+	ret = 0;
 	ms = __pfn_to_section(start_pfn);
 	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
 		ret = -EEXIST;
-		goto out;
+		goto out2;
 	}
 
 	/*
@@ -724,11 +725,11 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	section_mark_present(ms);
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
+	return ret;
 out:
-	if (ret < 0) {
-		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
-	}
+	__kfree_section_memmap(memmap, altmap);
+out2:
+	kfree(usemap);
 	return ret;
 }
 
-- 
2.17.2

