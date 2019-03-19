Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE637C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 03:20:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F9E520854
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 03:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="diKdXIom"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F9E520854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13E866B0007; Mon, 18 Mar 2019 23:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C8526B0008; Mon, 18 Mar 2019 23:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EABCD6B000A; Mon, 18 Mar 2019 23:20:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5B486B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 23:20:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o4so20949471pgl.6
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 20:20:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/V7IAbYs1Yh2i9HUpcwUEqrMPRSzKDvNnL8WwA2sS9Q=;
        b=ZxJXu7BgBnMA9H5uJaLjbrzkXCNq58T6Wcz/XWGNek0xmcv2oijp0BW4wfqrAjNn9Z
         lhel7+tSlv3aoOqwdLn+ozmlXc+DadkElN+L8NDTrYt/7JcIAbAlEVERwdRMsFOQ5Ff0
         pXVIm//jfFfofKBtetU8IWtlkacxaT1hAveQX03z15/+CdZtqC+Lm6VQkynxh9ZVlf/7
         vPx8xYe2cXlzN3zHC0wiKWDk6z5pZ1nDhd81Ff5RgcihMLtK+F2V0zotrHug7HG9+JA0
         r+i0IV0ScWN1bV+7cRcO50WSpsKO8k/r7ukqcwiF2YfGK3mbl+VD8+0KM3OApdpaNs6/
         5j0Q==
X-Gm-Message-State: APjAAAWljiKgQNbK6It4GZaBM63XhfxaYke8TLE9lLaWILIM8cuwm/o3
	jXV6hYGg/eH2swsHms3LH113A9eacQ1nyokTUJen3oRjkuBRou1L32TijwTE5C8ohT0HtzkgmsX
	z12HVtqyo/CBumoCp60xhr2fMGFHTPGGvQa6aH03cLE3hUkH8HYS3/cz6kFLAebQx5w==
X-Received: by 2002:aa7:8102:: with SMTP id b2mr19158815pfi.69.1552965626255;
        Mon, 18 Mar 2019 20:20:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNQVXZ20WE5S50EKuE9jM1cvbu4PZTjw+586ssjpaYdtqqhWYBkXoVG/art7FXJBvOPj4i
X-Received: by 2002:aa7:8102:: with SMTP id b2mr19158753pfi.69.1552965625258;
        Mon, 18 Mar 2019 20:20:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552965625; cv=none;
        d=google.com; s=arc-20160816;
        b=rPpMcJNXhNiPRbYRSISRzauDKLIZ1Lr3MgZCAgyjNdmoowb+kNNp41N9ZbMKsStHek
         EHgCxitVL0uUUmwK7jxuxj58VOCdEGLaPh0tUfM5/cvXAwVNB1LpdHXkZ3W5vYj+rr7Q
         zdUI4keQCmrnrzVO16qzTHNMBXuMV51mcxktbop1K8gsqItAbaSp+nX2BarI4x2tt/pb
         el363INKMAZ/NED4ah4ttyGoeDHjsK6xlihKpk8xtrTiqAyfac3EpqBKJferiehN23Xh
         gzCVtQ34SnNXecY8sM/pAXPzvwnhr+o8o5cn/G5TThLol9tg3CXq4UTxztlMfImIs6U4
         MwSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/V7IAbYs1Yh2i9HUpcwUEqrMPRSzKDvNnL8WwA2sS9Q=;
        b=w3UyVHild1hwbKgBe0DCbtrI8gJ+gww4BXRGTJVtMfiGjk7J5rTONOv6hN3LjwrvOG
         BQoRjqMlory8KpoJpPcRU520t8yhl217Gran4xra34YIE+Wu40ySO/5HSTL1Tg/3ZmK3
         HMMW9jP6H7vXaAHm0cJuhEfcpS98niNphTR1o7txfmOoIUUfEz2zlqfxWs7QbfIWJOjo
         ESr5QYXkdMC9QWJ2AEpwJJoGi2Sdq13YgZvaryc85r/K906IZsDrG4Mvi1oOvnY+ozbS
         q8LdBarXMFd3S8z6avcX8Wkii6LJ7JXgzKzp8en0VuiBPuVNxfXiOq+vgTgd50JCgrfs
         ccsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=diKdXIom;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g9si11452798plm.157.2019.03.18.20.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Mar 2019 20:20:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=diKdXIom;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=/V7IAbYs1Yh2i9HUpcwUEqrMPRSzKDvNnL8WwA2sS9Q=; b=diKdXIomRcK/MjVVBMPSDUVLJ
	fiYD8KISs+PEOWjhv83leujDYK1nIwnSyVaBlyK2CygG8WPFIHbRLRCI4ndQCjHltj5CsZsoPopoU
	4h7b/QRN5XCnpV8KNWlbWxg0L03iKUpPF0IUBYYjafdz5wThvBcAJJ2eQqsPrAXnPrQyw4yZ3v4e4
	j5NoSpiptMa9XuC7oDtIoOFObHYak88+nfPqekzX8gVdegCD64PQkbaCg55yVPpbBt3Uz+1FagmQQ
	rKhLkgFrcoeQXZkX1SoxE4bxKW6Q+PRmmiOa15oPKR1nmFAWwuBilHV5MEsRkWUuhCAv5T1corBb8
	WLTTiWKKQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h65Ic-00074L-LW; Tue, 19 Mar 2019 03:20:22 +0000
Date: Mon, 18 Mar 2019 20:20:22 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-sparse@vger.kernel.org
Subject: Re: [PATCH] include/linux/hugetlb.h: Convert to use vm_fault_t
Message-ID: <20190319032022.GR19508@bombadil.infradead.org>
References: <20190318162604.GA31553@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190318162604.GA31553@jordon-HP-15-Notebook-PC>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 09:56:05PM +0530, Souptick Joarder wrote:
> >> mm/memory.c:3968:21: sparse: incorrect type in assignment (different
> >> base types) @@    expected restricted vm_fault_t [usertype] ret @@
> >> got e] ret @@
>    mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
>    mm/memory.c:3968:21:    got int

I think this may be a sparse bug.

Compare:

+++ b/mm/memory.c
@@ -3964,6 +3964,9 @@ vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
        if (flags & FAULT_FLAG_USER)
                mem_cgroup_enter_user_fault();
 
+       ret = 0;
+       ret = ({ BUG(); 0; });
+       ret = 1;
        if (unlikely(is_vm_hugetlb_page(vma)))
                ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
        else

../mm/memory.c:3968:13: sparse: warning: incorrect type in assignment (different base types)
../mm/memory.c:3968:13: sparse:    expected restricted vm_fault_t [assigned] [usertype] ret
../mm/memory.c:3968:13: sparse:    got int
../mm/memory.c:3969:13: sparse: warning: incorrect type in assignment (different base types)
../mm/memory.c:3969:13: sparse:    expected restricted vm_fault_t [assigned] [usertype] ret
../mm/memory.c:3969:13: sparse:    got int

vm_fault_t is __bitwise:

include/linux/mm_types.h:typedef __bitwise unsigned int vm_fault_t;

so simply assigning 0 to ret should work (and does on line 3967), but
sparse doesn't seem to like it as part of a ({ .. }) expression.

