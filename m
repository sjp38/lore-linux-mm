Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04A21C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8C30206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8C30206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 689568E0006; Wed, 31 Jul 2019 02:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6125F8E0001; Wed, 31 Jul 2019 02:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5024C8E0006; Wed, 31 Jul 2019 02:15:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3D008E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:15:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so41721756eds.14
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 23:15:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PiD/EuL14HAFVjnjjDk8zmFntKSZoXRyNd8x4k6cFVM=;
        b=F7rG058Es4FlkXa0zIYQes6b1ddtJEcuM07A6W+yjYdO/piON0r5MREFtHGfRY+1gZ
         eo0C/ZSbfO+Hkb57BKW9TRG1q85HcZ/imvxonYc21rPYNtFyNbKRIqKVdGY890CbMtWP
         BpEG22hFwDoEfbgN7oYnECL26oqKSQRavwzwk6ElOE4Y8yfDxQdtH+DMksIeqKay46z0
         cqtArgJpjXCezTVfw3n1O4QJC2ExRupEqWz0xxgbN+ETcGuq8b/SII7gpgmPT+nxMxgC
         hSLMn23dSyzOWD48P97b2n6N/LB9gw04613pvqj1C998eDVganOMiYnKn3G9Zba1a1Nk
         9RIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAW7lLLH/+MUldCEStlXWc5Uqw1O5DknproUmoQ0VjvzOSlKOEwx
	bcgdlE1l7D7pGbSVyQ9HU6O/SG4hS+KSUjy23Y9yQk/pmad/tr2FMiDMCWpIbIqYx6LOTg9FObm
	FMBiwJCtJhTgx2Ow1KUWzvQD/yAReDcbr1SXGYiM78hMCckVp5CFhEbE0Yv0LZF1p8g==
X-Received: by 2002:a05:6402:397:: with SMTP id o23mr106726105edv.68.1564553739536;
        Tue, 30 Jul 2019 23:15:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLLYQ3nQUL8DgUrm2LQsW2zIqfPMl16ElpsmitgxzjD1TARBaZIvTal2Gi41b0cSW9ZC/d
X-Received: by 2002:a05:6402:397:: with SMTP id o23mr106726079edv.68.1564553738933;
        Tue, 30 Jul 2019 23:15:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564553738; cv=none;
        d=google.com; s=arc-20160816;
        b=C2tF4AA7KPS0h8ZUCumcpRVJY9Y6cHGocz0IEttbK4FtfhvGUdSO/+N4IpdFhV01MO
         0a/izJAR9OK5kUpWrv9MnaCBFBlJ266dECcJbd/5/wr9PVV2NVrbuQS7gc/nCKBNb7vN
         6tYmugS1zvKdB1f6LDjREWscxrqW8QJPtPV+jILmUs+HA7V5m78vkZmRlqH6CgtY3CQe
         EEOq42qn+VsRnM2hF4SUISSHXmcm5AsZB0TZxe/8BNzHBGs++fu4SUqgq7pw+B+yvT+N
         0NFroGFFo6F6XGPsHit/dxq2DQb+I0qaCmQVF4cAUWq9V7lOPXd/rO0sHeyVcimXutVP
         YqVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PiD/EuL14HAFVjnjjDk8zmFntKSZoXRyNd8x4k6cFVM=;
        b=Z73iD4I2anPsLMHk2rhurPwQ6v1R2Nzl9h/wU6zcfgUYd54WRqJ/DKdXm9go8uWIle
         uUOWVdCNCf2dWzW9/cZntMooMJv9YhFF4Gcv3Kmmu1+1SkOvBpZjbeQWTXtKa3cTdAqF
         URR1BUxZj/LS6YNId/Z9iyvHAnVdE40mix/0VGhT73DAjnAiVHnOYY2dR2Y0Vg0XMDua
         LqfjK98HBAyiT6mES0Uxn8kOefOy5SaP3fBcnYqENZ7NKiwmoLmAjqyawukdvO44lAud
         0Wyq2qTF1flJ3W/sJyzldVBLg1ZB6siL+H+RuUSIAb4IFxHgWeVXn9Ja34No5wDzEAZB
         lh4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x54si20871631edd.148.2019.07.30.23.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 23:15:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 05D0CAD1E;
	Wed, 31 Jul 2019 06:15:37 +0000 (UTC)
Subject: Re: [PATCH] xen/gntdev.c: Replace vm_map_pages() with
 vm_map_pages_zero()
To: Souptick Joarder <jrdr.linux@gmail.com>, marmarek@invisiblethingslab.com,
 sstabellini@kernel.org, boris.ostrovsky@oracle.com
Cc: linux@armlinux.org.uk, willy@infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, gregkh@linuxfoundation.org,
 xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
References: <1564511696-4044-1-git-send-email-jrdr.linux@gmail.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <436440f5-0031-5ad5-4a22-2acf218ad727@suse.com>
Date: Wed, 31 Jul 2019 08:15:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1564511696-4044-1-git-send-email-jrdr.linux@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.07.19 20:34, Souptick Joarder wrote:
> 'commit df9bde015a72 ("xen/gntdev.c: convert to use vm_map_pages()")'
> breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages()
> will:
>   - use map->pages starting at vma->vm_pgoff instead of 0
>   - verify map->count against vma_pages()+vma->vm_pgoff instead of just
>     vma_pages().
> 
> In practice, this breaks using a single gntdev FD for mapping multiple
> grants.
> 
> relevant strace output:
> [pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) = 0
> [pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7, 0) =
> 0x777f1211b000
> [pid   857] ioctl(7, IOCTL_GNTDEV_SET_UNMAP_NOTIFY, 0x7ffd3407b710) = 0
> [pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) = 0
> [pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7,
> 0x1000) = -1 ENXIO (No such device or address)
> 
> details here:
> https://github.com/QubesOS/qubes-issues/issues/5199
> 
> The reason is -> ( copying Marek's word from discussion)
> 
> vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
> basically using this parameter for "which grant reference to map".
> map struct returned by gntdev_find_map_index() describes just the pages
> to be mapped. Specifically map->pages[0] should be mapped at
> vma->vm_start, not vma->vm_start+vma->vm_pgoff*PAGE_SIZE.
> 
> When trying to map grant with index (aka vma->vm_pgoff) > 1,
> __vm_map_pages() will refuse to map it because it will expect map->count
> to be at least vma_pages(vma)+vma->vm_pgoff, while it is exactly
> vma_pages(vma).
> 
> Converting vm_map_pages() to use vm_map_pages_zero() will fix the
> problem.
> 
> Marek has tested and confirmed the same.
> 
> Reported-by: Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Tested-by: Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>

Pushed to xen/tip.git for-linus-5.3a


Juergen

