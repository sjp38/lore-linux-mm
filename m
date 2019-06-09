Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 688B1C28EBD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 14:53:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ECDE20833
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 14:53:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TW4V5sXz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ECDE20833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A28EE6B026A; Sun,  9 Jun 2019 10:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D7E96B026B; Sun,  9 Jun 2019 10:53:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A0626B026C; Sun,  9 Jun 2019 10:53:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 382F96B026A
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 10:53:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s7so10892042edb.19
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 07:53:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1qNdnBxzQ1sxPLfepsayWvIRtgHis1fEHl61OHimm90=;
        b=pDZlalgmZ7hEsRQvTfY/0pyl6uSDcXkXOadfEo/xrSqYtx0no66doRzd5fbr9Njlo7
         xYn72mHiMLDxgVgAnBsz4le6RCzFBfwJRSdPV2Qof6ZUA61HNhzeu57dNRWw2zt1uxoI
         xa1cm0kHdKs5WUFgolejEDA6LIxu3e3Fur2btqJ7OinH0RBwJtuFtARv1Df9VNqt+D+x
         I/z67j7V+ePKEpzsUw5pssss/6LeI5h+t2sij2uMiObRDCSLBRb8hw46iHgPKyE2N6By
         JTMB0Auw5DbKq92rv64xN2QM7VYptwCXkHZRE/QACG70EhhISOSmeWhRmFBpcabdOztz
         mVwA==
X-Gm-Message-State: APjAAAUSB+twkIKpLNHZ+iQ6DuMhjWuyXNJZW9RtNUDth/pyadQc5iFl
	hKBRSou5axNjrE+6fxVA4mSShPD6UjahhYnl7Vf7soDqPdp/j7Fkg+dfPWSsl4oObC4qKgqJwq+
	b8KUPEDPsUqefFbFhxEbZDTThPbCjmQsvdnj+7yl2gmxpZKugfLD2i82G98gDgbHu9g==
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr36892681ejr.277.1560092018580;
        Sun, 09 Jun 2019 07:53:38 -0700 (PDT)
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr36892651ejr.277.1560092017748;
        Sun, 09 Jun 2019 07:53:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560092017; cv=none;
        d=google.com; s=arc-20160816;
        b=dq/X2T3Y9ZvBffImvIIuzrC7753ZDp0r1P8g3SwxBRZdNGUqY1GnnWQ5z9DnCdMIuc
         KSfsj/YJDPK1us4jVSm187AQtem+Z8CqqNuWccKFxBcEHKfvBIRn/NuhxAhrjChgkODW
         AtHAXPhqgLuv90LHHry18IJF/gFKlvGHXlGrVrZddMXiaO7wDxZCgR4ptqu+TOMCFV8U
         k3yWhvnyGV2UFdnC3N7Pt5LsAAuVdiFL6a1uoFciFK7BMpE1ave9+Nwfo/Nk2jTStK2a
         O6CUeauCNBUr1YzJfI4o+jmUEh24MPsNedFYa9/WvFikqY7l7d3esTH/JrIpFc8Q51eX
         9p+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=1qNdnBxzQ1sxPLfepsayWvIRtgHis1fEHl61OHimm90=;
        b=ORhwS/ebTxkzvh8EjccFV+GWah7COEHFKuQA/Vzc6E+xwEgqQjsmQiBDTlH1f3IBYn
         lSaDkl8aU/jS0u9PHi+P03re7aYiJmiqDZMZBhX46GYx93CgHvfbTmPUPFVYpSxuS1np
         WTaWXUKWbL+THHg19SJKxZlccapFYgkwpAAqACei2OGRg35uWY0/H9D+DUGucDIcUJvt
         Kqt+Q6Ofi3b6pZ4xoqDoFu3OBLBaml+nauAT2KMsIoZplTURZAezsagrG3XsIXImAZN3
         OIorlUu4+nLVzpB8lRaHJK0rTI+qGftii5lg1JbgcIobmfXV9F0o42NHX0GntA0uuc8b
         NQTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TW4V5sXz;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor2162566ejc.37.2019.06.09.07.53.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 07:53:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TW4V5sXz;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1qNdnBxzQ1sxPLfepsayWvIRtgHis1fEHl61OHimm90=;
        b=TW4V5sXzdBVgH5DT3NU7dehMs7b9QS54DmeQvAWdt7RcWFRca8ZYHjqYYm8Z4gxzrT
         qkMe7MjtwR5yj158Llt6gg9NPtkyL5EXV3lFx0thDKbEdEZjjYf4/iuI5KKImi9iuBfJ
         qaBANa+HUY8ZtO4fhNyPGW9atPAR9xPuklJOMTim1DYPWYhzmqubIGQOIymVFKu0RXyG
         rxV6uc/0v73XKetD8Ca6M7FFRRhpYahmSym6XD5JJJoKSo+z7dP8OUadbag28tEQeLGM
         GCXWmAEiBBaUU7PaED6QGBk69ILS3dI5UYzuro79KWFCpmm2VqCFsIke2Z/fBMtq79Fz
         Ljlw==
X-Google-Smtp-Source: APXvYqx5Bvmblo5CLoyi+ttNFMxoRY0Kzk8ncfNmEkFAOwQxlxqMMwxKuHs3lo+Eaxy342sAj5E03g==
X-Received: by 2002:a17:906:ca9:: with SMTP id k9mr49364733ejh.4.1560092017397;
        Sun, 09 Jun 2019 07:53:37 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id t54sm2193349edd.17.2019.06.09.07.53.36
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 09 Jun 2019 07:53:36 -0700 (PDT)
Date: Sun, 9 Jun 2019 14:53:35 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: ChenGang <cg.chen@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz,
	osalvador@suse.de, pavel.tatashin@microsoft.com,
	mgorman@techsingularity.net, rppt@linux.ibm.com,
	richard.weiyang@gmail.com, alexander.h.duyck@linux.intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: align up min_free_kbytes to multipy of 4
Message-ID: <20190609145335.yzx4irt4mczmlvno@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1560071428-24267-1-git-send-email-cg.chen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560071428-24267-1-git-send-email-cg.chen@huawei.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 05:10:28PM +0800, ChenGang wrote:
>Usually the value of min_free_kbytes is multiply of 4,
>and in this case ,the right shift is ok.
>But if it's not, the right-shifting operation will lose the low 2 bits,

But PAGE_SHIFT is not always 12.

>and this cause kernel don't reserve enough memory.
>So it's necessary to align the value of min_free_kbytes to multiply of 4.
>For example, if min_free_kbytes is 64, then should keep 16 pages,
>but if min_free_kbytes is 65 or 66, then should keep 17 pages.
>
>Signed-off-by: ChenGang <cg.chen@huawei.com>
>---
> mm/page_alloc.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index d66bc8a..1baeeba 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -7611,7 +7611,8 @@ static void setup_per_zone_lowmem_reserve(void)
> 
> static void __setup_per_zone_wmarks(void)
> {
>-	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
>+	unsigned long pages_min =
>+		(PAGE_ALIGN(min_free_kbytes * 1024) / 1024) >> (PAGE_SHIFT - 10);

In my mind, pages_min is an estimated value. Do we need to be so precise?

> 	unsigned long lowmem_pages = 0;
> 	struct zone *zone;
> 	unsigned long flags;
>-- 
>1.8.5.6

-- 
Wei Yang
Help you, Help me

