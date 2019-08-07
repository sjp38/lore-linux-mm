Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAD35C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E44821873
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AIcFK2y1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E44821873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F776B0003; Wed,  7 Aug 2019 17:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359426B0006; Wed,  7 Aug 2019 17:27:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 218896B0007; Wed,  7 Aug 2019 17:27:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E40156B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:27:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l12so9654353pgt.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0HtIh6mV9FoZgQgOFWiGcPyLv0hKPbDbJkSgISG1d/k=;
        b=kIajoIFCzeN0wtSJy+g81WqU046cduMrolQHmGqz4ophp19sQ7UA12sFBgHBBuHPA3
         Ihe3g6nlOreHgLYD0OS58E8ypZK+8UDrLr/DvrJV7JljM3CMEOKtsTffy6hWMGeLV/KQ
         TWo2aKwyrIUPoMe5smMbZlG9+puYxiavYxsvVtGO37Y3ERibam/b0r/ldOpsARga+8db
         lYW3BEbTGDSpYIJFNmxZlKUnz5JMZhMlwP0G1I1iDcD/AjATdh9KyNqWPlpyFhCNBxck
         6Vb7J4Ut9OdVBJ6V38uBOJkswmecaRkdTWqM/dMpVlzLJ5D69ZOMIixBRvHlfcCwQmm5
         VC2A==
X-Gm-Message-State: APjAAAXoPCCR73+g0NeaHdndgBjIt0XdPXy69Fu+c05Da/nu2+peTVux
	GLpdj6bUZJd+i3ZLKzygm/oMZtiF9gGfS4pcu1LeKgBG5DfYipNmy8Vy5Hckb1+nFwzdOTC9HDs
	0kuqSWQyHph4NIqaGbiYhRbxUNCiFXLUFsYFH99aZiiSs7R583k80ETlwiN4CeGBMTA==
X-Received: by 2002:aa7:90c9:: with SMTP id k9mr11136367pfk.171.1565213277574;
        Wed, 07 Aug 2019 14:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/vUCe2zi26hYlk4M/+Y+7Tm/CvAfF0nIdEmafaItLXiiBUBXkNV2/jOx+sup5gkYG1EI0
X-Received: by 2002:aa7:90c9:: with SMTP id k9mr11136320pfk.171.1565213276848;
        Wed, 07 Aug 2019 14:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565213276; cv=none;
        d=google.com; s=arc-20160816;
        b=BKyrZZ1br+BR5YkVEZHm17plzvzLXsYOPAnYZhpScD6nE06EK+qDHuiY3VlZYNFJDs
         IFcWltFCG5650TnT+1lsPRyaTtPZhhGCFnJJML6871Orb86ABjR1rGS1jSzBbAv10RV8
         oGUpWoMF0fmXjzY3X4NRQCPONy5b8SST9YMU6tWCsiQoaCKOnK7WswQybIxT6fYw7R4x
         s+XbjV65I0Tn2xxzOIEwCoP0jEF1AFAO1po0N7LM+RTjyB4QIKpzKfLcIlm+HJHrUor6
         O/nT4/iJlhZGjVf3OR0pJv3DJkVOsubZ0vFhsL4CiGxGY4tHl1+u1k/mXoRgjbFxtPbP
         z/Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0HtIh6mV9FoZgQgOFWiGcPyLv0hKPbDbJkSgISG1d/k=;
        b=Foe7TwdOPF6rsjwL40EdnI5O5VXtTXgb4KbeqyQJtfc+EAOEfsMo7zCJ+MSd2+TatM
         bWOL/wmBv4E6RSt4/cFWBsy/zn9yumeJf1z2qmwubH5SWSA5jDdQSFnXRJYqT7Yf6jrO
         3QqcJdgQ4YsMo/C5eV8Ci64xOcXmQaoYBX4vz/TETrVSYD/7odiF/20ZMs7OiGTUQWnX
         FkpZ6ici1m/Eo75xoXNS1qspn77GS6Z4R7PA5/jmXn/risvXt8HRuBWyLLlgS8xitNOJ
         iBJ+VrsekyRJlycv1f1ubY2WL1GxM3zfgDKKx3zunwkR6y+jdGuURvGMw0rqzZa9fLZC
         m9iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AIcFK2y1;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t7si44847695plr.27.2019.08.07.14.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 14:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AIcFK2y1;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 144D72186A;
	Wed,  7 Aug 2019 21:27:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565213276;
	bh=qIsPVmF/GYciT+NXgQsfrCXseiH7rATJnnCGWlARXqc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=AIcFK2y1KC2COaKg8q00+EtU7rcA7lCc14vce0BDJl8xmLhIW6r5LbH+3Zv2Pv/3j
	 WVfoBD75OJLsRFw6EiWVo0BxzknBHxyclusqg23eBADyu2zVJQzfFXqwNTkXTv3W1W
	 SsUqR83tfhecM6wOyVuqpfow5IqRJgP9gY8j/X3s=
Date: Wed, 7 Aug 2019 14:27:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Song Liu <songliubraving@fb.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell
 <sfr@canb.auug.org.au>, Linux Next Mailing List
 <linux-next@vger.kernel.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Message-Id: <20190807142755.8211d58d5ecec8082587b073@linux-foundation.org>
In-Reply-To: <BB7412DE-A88E-41A4-9796-5ECEADE31571@fb.com>
References: <20190807183606.372ca1a4@canb.auug.org.au>
	<c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
	<DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
	<20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
	<BB7412DE-A88E-41A4-9796-5ECEADE31571@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 21:00:04 +0000 Song Liu <songliubraving@fb.com> wrote:

> >> 
> >> Shall I resend the patch, or shall I send fix on top of current patch?
> > 
> > Either is OK.  If the difference is small I will turn it into an
> > incremental patch so that I (and others) can see what changed.
> 
> Please find the patch to fix this at the end of this email. It applies 
> right on top of "khugepaged: enable collapse pmd for pte-mapped THP". 
> It may conflict a little with the "Enable THP for text section of 
> non-shmem files" set, which renames function khugepaged_scan_shmem(). 
> 
> Also, I found v3 of the set in linux-next. The latest is v4:
> 
> https://lkml.org/lkml/2019/8/2/1587
> https://lkml.org/lkml/2019/8/2/1588
> https://lkml.org/lkml/2019/8/2/1589

It's all a bit confusing.  I'll drop 

mm-move-memcmp_pages-and-pages_identical.patch
uprobe-use-original-page-when-all-uprobes-are-removed.patch
uprobe-use-original-page-when-all-uprobes-are-removed-v2.patch
mm-thp-introduce-foll_split_pmd.patch
mm-thp-introduce-foll_split_pmd-v11.patch
uprobe-use-foll_split_pmd-instead-of-foll_split.patch
khugepaged-enable-collapse-pmd-for-pte-mapped-thp.patch
uprobe-collapse-thp-pmd-after-removing-all-uprobes.patch

Please resolve Oleg's review comments and resend everything.

