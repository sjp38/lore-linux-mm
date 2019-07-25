Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2242C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5E3D22CB9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:03:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ABdMJ/Mz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5E3D22CB9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62EF86B0007; Thu, 25 Jul 2019 18:03:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DF9A8E0003; Thu, 25 Jul 2019 18:03:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F5C58E0002; Thu, 25 Jul 2019 18:03:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7C46B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:03:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 21so31772367pfu.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:03:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Z6RYngi3cJJjtiTM0pcFs8c1UrVLGOUye1Guqo9Ye98=;
        b=d3R2ug1gXNrYmmi35l3FxXLdWEsf/gsqw2hory13FagIblaixqkNVeGtCbZe7zxrL7
         739TTf61P8toNjnpiR1AfjaxIgMwNZ79jqaMSEMxYPiDH34/qOUBhsjn4wrMDPyrer2Y
         Uhjueh+CHO/FPnasSPAQCLw/MCTL+WAdmA7QbkP1lT/HYsdyuIDotZ+8Uj8vZb8pPkQK
         KzefvR3qz8QvO3QKSjeUD8wRMNm7uChSlLnpMj/6Q1MI3t9KiQjHssHhhj0s3Tp1YTKe
         XfbdUz/ykqazYCgFNa1ojeyVEH0by9MwPs6uF0TscR3LSwTUWYzCbb8lQD7YjKh67Sza
         YCUA==
X-Gm-Message-State: APjAAAVTFO7vcNgtmxrOKlz8DJEm2jFMbXchUWDwvO/txrVusXLq4iGx
	MnSpOYGb3FVLAnnxEmGJqFBao7i6YhRfVzP/4iE/kFnIUiejc0KZYpdWcTJhkGheGLOlPzLrBUZ
	l4G1unsdeIUG1Z+RbP7A4xBtUeeoq2VZQLVWkaPJj88wlmoTX/dFUKfw5DTewvoeRow==
X-Received: by 2002:a17:90a:bf02:: with SMTP id c2mr95538860pjs.73.1564092185743;
        Thu, 25 Jul 2019 15:03:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO9FjX14ZqomS3LpbBNsdOlQzuf++u1RTZpa8A7xMy2ptAIDnl6k0Li12EKdwATeM/gUuK
X-Received: by 2002:a17:90a:bf02:: with SMTP id c2mr95538805pjs.73.1564092185108;
        Thu, 25 Jul 2019 15:03:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564092185; cv=none;
        d=google.com; s=arc-20160816;
        b=kMddWjjKNzk/+wajDZsJwG6aakwbjY6zPu/ljN4uhmFuqrKfCjzD6s461dXwIchwdc
         hbayKdcrMAp5bZXjnDXT4U/C+0J0utWsp6WqdGLzkO70VKXJEaSLTRLAkElkwQdKe+Q0
         mZs6L0mFsY2DR8ocjeDdafyaKacvxudr2r06Zw+D/GNTTeCTKCiJ9JOcwmSf8pWwNcy8
         95C19wo7y6+nOtbqoyRHt6WmggDW+fNeZkmtHItWo20ATSOnfjxl67PqyjthEKHuFVHW
         8Zyr2ZlrY+HynjKxhfSlpl3f2p2KTHHa9aGUT8hylHsK/BG8zMYxfHpzIf34YKx6VpfL
         CgOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=Z6RYngi3cJJjtiTM0pcFs8c1UrVLGOUye1Guqo9Ye98=;
        b=zlgZuIio4JV4z+bF2dBEn32VGGhecdcxSqqll3xi7SOS+HwwH9NOoP6f8x/dfSDBLI
         wIYgMTHlD6PqJQzuCB/n4t7epru5NAGYBQt1Mf87wfBs3YUd+ghefTicpTaz5mgYuHvh
         d4qEbwHJQMS6xbbZ8qVZRAO8q7yGIUzn3rXmmCCZ0a84ONb0nSNJJi+25p7WoWR/0n8Q
         7U3KJKtEqPQ9RdaPO9wOPrUCiVIU+li0DfppFE7RXwiGhL3yCDGtW1A2Sg762aY2lxKs
         BXm8wYI8io1Fu2kaDUk5rSYq2aTzT0dufFj2bDiIpNCiv1qzIb4L5iVkjsUxaceNVYgS
         +7aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="ABdMJ/Mz";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id w21si21102692pgj.153.2019.07.25.15.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 15:03:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="ABdMJ/Mz";
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z6RYngi3cJJjtiTM0pcFs8c1UrVLGOUye1Guqo9Ye98=; b=ABdMJ/MzOxf5WQbmFkAZaxpyi
	odM/o9V2QsyOs2V6Qibnt/LaE7TxI0D+PhKQ/pTCnE33ld5nWtnGgFNaL5wXY/eb6cMCj1cjsvHQ5
	6PYC27o5vuSD7ZLaj02Bt0h66ZeR5ld1OYHiDGCPQmJw7pn6WZPXhDuOxBmk18J11QFBkstHWtT+3
	gB5ZYi5O4tXzUhYb7A2HDVRwaEi6TflhJOGZXOR5/ZIqQLYthI2eoV+aeHn1qOLpV4YX5SRkiGfLU
	cAhHedU6YJgU9qno/BQtQnjP+jf3RDgYsV8DTLA27h4ZKC1LRQuHi0TA0aR5MMBNd9DskpS+wHMru
	Mw5qWtpaA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqlpF-0002UC-Ry; Thu, 25 Jul 2019 22:03:02 +0000
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
To: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 Chris Down <chris@chrisdown.name>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
Date: Thu, 25 Jul 2019 15:02:59 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 9:40 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-07-24-21-39 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (5.x
> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
> 

on i386:

ld: mm/memcontrol.o: in function `mem_cgroup_handle_over_high':
memcontrol.c:(.text+0x6235): undefined reference to `__udivdi3'


-- 
~Randy

