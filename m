Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3376BC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:25:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 005CB2067C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 15:25:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 005CB2067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7927C6B026B; Mon, 15 Jul 2019 11:25:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7429B6B026C; Mon, 15 Jul 2019 11:25:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 659336B026D; Mon, 15 Jul 2019 11:25:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 465156B026B
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:25:18 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h198so13999205qke.1
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 08:25:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qV+DjMPmDRY6sKYcHA4gdHgQzzk3sFYcuaMN/KcT52Y=;
        b=ti85i1NKG2rueRwPGACXB7Y1T4t+zrJHZnBg+9V2rrYy1taOfzoP76MgYmao/pgurZ
         ueDmT+WSwCo2ki7ZM8p4Hj+pRr9f3sM4O2gTs/gUea2Nc76v+YIStmETUTmKtyxRmUQg
         EzNlgUP/p3XnEoEdwTD+iCZnkUcNhQjXS7iAVkYyRSP3toW5OgGMQH+p5aGvNUNpxBB3
         10PWh0JHXFsSY79mvVVEscx90KIHbhegbVCJDauo6diY4vBFtik5ml6FBmHehw+rUEGd
         eBpWuAOEvGf1e9WagE8QafL/qFawLOhxClY4DUbIFo/hwemWt1uFKI1LnF6Ni4wb6UWV
         P2vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV6s/X6+D9RhEw2utJ1jzPNxgG3/iSbzijLlNKOe+X++wPxHEV+
	bRV/yEQmxiGG4yly1FUdNB9bYJ5L+xOZlSC+nQD7DuK+Ieb/NlwYWBgbRwSsrVNBNo9CiuKrWse
	8cPV58PPbCb1zDrV5A8mTJNR2Tk6zDI7dbx5Xnphh8ooVJ+rWQ0fGYxsdtrUiQm0npA==
X-Received: by 2002:ac8:42d6:: with SMTP id g22mr14594290qtm.10.1563204318092;
        Mon, 15 Jul 2019 08:25:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDN8Xj6pKjmcM1WoE/egW6Je1F5xE2xsAzzHY3KgYu5HzuBbO/wWHr+rQTIW66voLFgBlz
X-Received: by 2002:ac8:42d6:: with SMTP id g22mr14594255qtm.10.1563204317569;
        Mon, 15 Jul 2019 08:25:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563204317; cv=none;
        d=google.com; s=arc-20160816;
        b=JBScNPjumqLbyHg9YdqXnNhLucsK5zAtYAp8z7m1KpksoE1SfGTb/XW7OSCwiVFjTU
         YJRVRPDl8NgZq5vGCnjUIZzYkYRcl/aW0J6hBIIEDbd4pQrBzPRxPUqR5b+C9yZuo6UJ
         Jactj7fawXOfWhLBOD7S8fdfrChcRLzjVreM4vgFkqH2If9tZdyn7BG9wYU8EHNwAL0N
         YUD3snOvFIsYnEjIPNjCKURX24Z04I5DjAPjBhlChuzLcZ0ymUju84iiMRp3ANlDJigr
         Bo+R2ZtzSdxWJkKbaI8rWs3Ji1m00sskRHuHxgtGO+Xzzc+spteFDbFiYXgV4wjYxZlY
         xH6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qV+DjMPmDRY6sKYcHA4gdHgQzzk3sFYcuaMN/KcT52Y=;
        b=NtwxF/37nrjgURLCXUOs2dk+oyJMul2LeEt5B7o0S/TD7g0ao+GpixD5bb23XCtBDb
         wk0czoORTQa4Ov+m0Ra8hymxeYuuF67EHD/qiEIIV3o3UU5gW3oON6H65di3D8O01BJp
         OvOLlM0KlhGfSVHUJfdHf4ynJbndYgbqiNqP4msCz03GRJxTz4dd2OUlXS/h2yJOOd/n
         +I5ZnQV4zCWiPyVwdRV7y1nRMKsjT3uBYBs50SQUQubGV/WNwb+YPOFqbDSMhWAr61NB
         dBL9SyBE8WHTV09ITFW6GmOCWNGZayyY9NUYP/5mS2NIriOgcAVsnSS4TWTKY7Qs4Cpa
         srAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i22si11977130qvh.223.2019.07.15.08.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 08:25:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C825C8666A;
	Mon, 15 Jul 2019 15:25:16 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 0060E1992C;
	Mon, 15 Jul 2019 15:25:14 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon, 15 Jul 2019 17:25:16 +0200 (CEST)
Date: Mon, 15 Jul 2019 17:25:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com,
	peterz@infradead.org, rostedt@goodmis.org, kernel-team@fb.com,
	william.kucharski@oracle.com
Subject: Re: [PATCH v7 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190715152513.GD1222@redhat.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
 <20190625235325.2096441-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190625235325.2096441-3-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 15 Jul 2019 15:25:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/25, Song Liu wrote:
>
> This patch allows uprobe to use original page when possible (all uprobes
> on the page are already removed).

I can't review. I do not understand vm enough.

> +	if (!is_register) {
> +		struct page *orig_page;
> +		pgoff_t index;
> +
> +		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
> +		orig_page = find_get_page(vma->vm_file->f_inode->i_mapping,
> +					  index);
> +
> +		if (orig_page) {
> +			if (pages_identical(new_page, orig_page)) {

Shouldn't we at least check PageUptodate?


and I am a bit surprised there is no simple way to unmap the old page
in this case... 

Oleg.

