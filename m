Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB439C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:16:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A5AD206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 16:16:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A5AD206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058D38E0008; Wed, 31 Jul 2019 12:16:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F23D98E0001; Wed, 31 Jul 2019 12:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB1B8E0008; Wed, 31 Jul 2019 12:16:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0C048E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 12:16:18 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 5so58542451qki.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z45bc0/Hf5snDFXev62GUllh+0OaX0y5/9RK/czu9LA=;
        b=ZlAE4htvcAsFu5kOkamUXwp5FfIK+2fnS+wlVupkAqUzhq2IIx3kIPndcdcdZ3SRQU
         jd79VKRYAWL4d3JNZcrUeYhU0tY2QdIbQTtlIoHzsguystQ5JOoG36Wg2yHQ7FTeFtT3
         MR0/fcaEY8RkgHcxztT5jv0wGYDP11wQdLF8k+5dj8H6kJ4bYXTuVRjItlBaY3AOcNa+
         +aUKTDVWl2e78C0rlLt22M6e46wJEN915oaxmjrcaJKuTVGX/4jCF8/ZzZkHw5YPH3Rt
         lrWZQMFZKdKryk05/4T4+yXfFCgpjZG+GGxlCtlPYmozujOeM8E47M4sOkVwgpqm9Jrd
         ho0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXScnlVPInsrwscrEGGzrdyVqDxWh3/ZR1bQueGEm27SxmPrBI8
	WDYHChHkjaNNHircximodc8niagImA7EZs3Xdj5sOOLXc0qVlgSoQ7VKw2bJWu0rEs9FjOH6yVH
	wVUpx+GUh1xeoI1mflPDzdBBGts0xBmUBvWEBxaN+Cmtky2NTK689tZRgOA02eWERYw==
X-Received: by 2002:ac8:66ce:: with SMTP id m14mr43950881qtp.206.1564589778586;
        Wed, 31 Jul 2019 09:16:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLIp3bDVcK8sOQaVYNhaHE2PPUNAvUpM81pWGIlpU+8tgm73hHHktni1F6LK2ieyD94DPK
X-Received: by 2002:ac8:66ce:: with SMTP id m14mr43950839qtp.206.1564589778065;
        Wed, 31 Jul 2019 09:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564589778; cv=none;
        d=google.com; s=arc-20160816;
        b=bL5t70E0HOQt+C97jTD78OjjVw4+HvDJIPdPnZUmYNU3/Nk4OlcrBbyr7m+Wary//F
         XcxUREMry6bR8XdFbaVptGXw2TiuOiI3TqTXr/5WPcU3QxjSAzmuAuUIT32TMlSxdOZ+
         +3zEH8Vyh3/W5fDL3COPVVujS5Y8LCuFMd8+tqfzJcnkD50M7WWdo+X97067mtv1qFno
         7/2x12F/b8a2xbIgQMIn4helCdmWOcjHs72ucebeL6t2tIDpwdKmB3Nsdu3FIJYQQ/BJ
         RebJCz6U0OQaCu9FmxfiB/OO8wcWDjA/NYWumSOEfUPzpgiL/xdckHFlSAzu36oMEmZM
         xWPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=z45bc0/Hf5snDFXev62GUllh+0OaX0y5/9RK/czu9LA=;
        b=rRDS7/fPT5xuc2jbatW/a5HQTFY2nzROY+usxwIqlftQZ/OV/bb8DGTofahJDdLmIv
         t1mipKsM/CNlm5k+wW1v6j+MlfHSF2c+UGBfusP6h4KDCoId9gUwDEimnQj4Axp3exep
         OuH1Xo7T5a3Agev6sXRPzVxNljDAV00h2seU1dCWmeekPLw5mcJAI9Tm7fpy9r2yiZ+/
         dZyCDm87W78D2BuwMVdN3wRxx1dyGzUiJpa+sDnDR+F7BBvujeC8GpFaG5peazacAP5R
         Ah+uX6akxRx/PFpbU734zOte7T/c2PUqVZVVMJlWODzF3LZazEtvXI6r3ZmG80FjSG07
         T0jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d207si38948303qkc.51.2019.07.31.09.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 09:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 512C730A6986;
	Wed, 31 Jul 2019 16:16:17 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 7B75B60BEC;
	Wed, 31 Jul 2019 16:16:15 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 31 Jul 2019 18:16:17 +0200 (CEST)
Date: Wed, 31 Jul 2019 18:16:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH 2/2] uprobe: collapse THP pmd after removing all uprobes
Message-ID: <20190731161614.GC25078@redhat.com>
References: <20190729054335.3241150-1-songliubraving@fb.com>
 <20190729054335.3241150-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729054335.3241150-3-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 31 Jul 2019 16:16:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/28, Song Liu wrote:
>
> @@ -525,6 +527,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  
>  				/* dec_mm_counter for old_page */
>  				dec_mm_counter(mm, MM_ANONPAGES);
> +
> +				if (PageCompound(orig_page))
> +					orig_page_huge = true;

I am wondering how find_get_page() can return a PageCompound() page...

IIUC, this is only possible if shmem_file(), right?

Oleg.

