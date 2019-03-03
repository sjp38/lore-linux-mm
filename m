Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFDE5C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 07:27:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77F4420857
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 07:27:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77F4420857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 110048E0007; Sun,  3 Mar 2019 02:27:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 095B58E0001; Sun,  3 Mar 2019 02:27:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E78128E0007; Sun,  3 Mar 2019 02:27:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA7768E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 02:27:05 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 35so2126631qty.12
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 23:27:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=QsgjurIyHtrP3K3KuyVQ/FFSWkkG6qz+RIl54GbU7Bw=;
        b=HnCP3ix3iFv8e4F6WuK0BwAb5z+C/1VSJ2F/G9PrfFvZn4BV24KRMRzHvp9JZaeEae
         rnE9i9MFAgN9Qg8B4Xz4DFP9qX8iUhU6k6x9Iz7sYKoNlhfmIIe94WrzWhlSbQaXryrW
         CgxTB2PyV/st0/ZPIrZBGljwwI2m4/8fe88CetHqf7QL+f43gcZs7uEacYl/xcIs5rEE
         VO24UfYAGX+rL4pATzuO9PDuJiO42kpIcRzeQruXgTiAlK8F3AVMqB4Bu8TVRtO9NO3H
         Bfv/fsLRQeqk14ViG6f/NnkrOZYIZ1V47c//YpDP6Osx4FUsOFljfnblqjbET4kbwG2i
         Ybqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUMHHJCe1+DZiqODkaPv6Ib6qbiIWB6cXKgIH+mP5JcxmVx9D7r
	iWMafG5YI6yjNvkz4cCS4m2lqCFuLQmt1900PRfpAS03CpcdJh5YCqO9RUxuerZaLs0lfjOFXj0
	sw3vkYP0uLrdHkjnIQeNas8uEQJJ/8NLUK14iL+moaeGdqTxSUsd6bVFF1ub1/kr7Qw==
X-Received: by 2002:a05:620a:146a:: with SMTP id j10mr9227655qkl.243.1551598025468;
        Sat, 02 Mar 2019 23:27:05 -0800 (PST)
X-Google-Smtp-Source: APXvYqzsVRg+R8+XzPo3+5k1PWvAsd0A40ffeyBkUhc9TKN5c0oROQ/LqHaDOvPSiGNnY7GeTJeN
X-Received: by 2002:a05:620a:146a:: with SMTP id j10mr9227637qkl.243.1551598024789;
        Sat, 02 Mar 2019 23:27:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551598024; cv=none;
        d=google.com; s=arc-20160816;
        b=0rs1tNdx10PeUYYXysY2C4SVSbImd5E4j5E44tNotTFooh42Z7X3Jritdurwny0NOR
         xfC4v1YZxu9I5eOf98mVHi0X/VVCC5ARWxOJ3JZJkLIAZNeBwf/xg2OxuC7fmjkFipKJ
         AsHw2BIy0Yz6mutYfa4sTFgGzoszCjZfZevgdad8gcb0RJv42tJBGPKaFbLEoopCJmHk
         TRO5UYTQiY0T9yGLf7tyv2h/s6mhA0JAeUHfq0IA6jFESdpDij+MWeRNScOCn84Lp8p5
         COweg50UZs+VH6mMJBHpk4m8OcTUg8AOVFar1NoCCk2VwRjg1B+M7+L6ECUII1xlBloT
         4keQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=QsgjurIyHtrP3K3KuyVQ/FFSWkkG6qz+RIl54GbU7Bw=;
        b=zQPirftCczhlfcAKY6dixuJwk7c1Th9ME2kWo++SONHvespBpDlCt5gcetCqzRNKH8
         UZ6/wp9eTWV4hFFTfLcCevBSuV26t0Mu36NKcKpTybIrdJ3R3TP51+RWz60qt5S9t3Q5
         BTJjCBHplw1+JV4Q8gJZJZFxQqTTomFqBtkG/HG1I78VhKNdnD6IGkG+hE4DHRvQN88J
         1BJ/G4qSliF7DYX7WIenHGJ2hCImbTWvcHUvFqJCecd5W1ivYUKiZrVd4jPunQ9VeQ9z
         CdDbVf2/pqHlagZ9Ac9gReaIIDeO4KtIsPtXwGh66FZU/SOCc3a4dYhhPUb40ooQR0Gb
         SDVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j96si1409762qte.111.2019.03.02.23.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 23:27:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C815981F0E;
	Sun,  3 Mar 2019 07:27:03 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7513B5D9CA;
	Sun,  3 Mar 2019 07:27:03 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id BAAAB1819AFE;
	Sun,  3 Mar 2019 07:27:02 +0000 (UTC)
Date: Sun, 3 Mar 2019 02:27:02 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>, peterz@infradead.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, 
	riel@surriel.com, mhocko@suse.com, ying huang <ying.huang@intel.com>, 
	jrdr linux <jrdr.linux@gmail.com>, jglisse@redhat.com, 
	aneesh kumar <aneesh.kumar@linux.ibm.com>, david@redhat.com, 
	raquini@redhat.com, rientjes@google.com, kirill@shutemov.name, 
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Message-ID: <701776300.4537344.1551598022408.JavaMail.zimbra@redhat.com>
In-Reply-To: <20190302185144.GD31083@redhat.com>
References: <20190302171043.GP11592@bombadil.infradead.org> <a5234d11b8cc158352a2f97fc33aa9ad90bb287b.1551550112.git.jstancek@redhat.com> <20190302185144.GD31083@redhat.com>
Subject: Re: [PATCH v2] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.28, 10.4.195.18]
Thread-Topic: mm/memory.c: do_fault: avoid usage of stale vm_area_struct
Thread-Index: pAmRXCN5CetzZ5PIfXitNyEm+tfURQ==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Sun, 03 Mar 2019 07:27:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> Hello Jan,
> 
> On Sat, Mar 02, 2019 at 07:19:39PM +0100, Jan Stancek wrote:
> > +	struct mm_struct *vm_mm = READ_ONCE(vma->vm_mm);
> 
> The vma->vm_mm cannot change under gcc there, so no need of
> READ_ONCE. The release of mmap_sem has release semantics so the
> vma->vm_mm access cannot be reordered after up_read(mmap_sem) either.
> 
> Other than the above detail:
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thank you for review, I dropped READ_ONCE and sent v3 with your
Reviewed-by included. I also successfully re-ran tests over-night.

> Would this not need a corresponding WRITE_ONCE() in vma_init() ?

There's at least 2 context switches between, so I think it wouldn't matter.
My concern was gcc optimizing out vm_mm, and vma->vm_mm access happening only
after do_read_fault().

