Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6EF2C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B40D21871
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:30:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c1vU6F8r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B40D21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 179356B0003; Wed,  7 Aug 2019 17:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12C096B0006; Wed,  7 Aug 2019 17:30:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0D026B0007; Wed,  7 Aug 2019 17:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B91036B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:30:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n4so53653745plp.4
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:30:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PbeeDf/GkbDllO5vIZWwH/vN3+gHBbe2/YYojgAimx0=;
        b=SyR+YeAgoY8viN0ycSHxeCKUOBz+WdMFq6C4xkxCV9raa/N0DNOxzP6Y9Ny3GvKdPp
         z4jVCZyKrbpQwwNLeJOD6KOCZO2wbdj1IUcOdo1sHhR0qC/KzrTtVUyH/t4A8+fCCrRn
         jS/GMdPpWKcvAWpTvKr8tIknv3iJO4mLvADmKMAiChxiDsXjNULTCQTfRlBwnzsbyybQ
         OmMRN8nCummOZGDEUTYBrkY4eagYuA3m9I/YK36HLxzSVor/BspbD6IZp6IoNb7QKnIY
         s/nTBI9hGa1TU+YpI8q1EfNiDIis38FHs08Gg+Q97n+vi7HbvxiWCdOHJ5iAunW0C8um
         SFQw==
X-Gm-Message-State: APjAAAUdtv2CoOzD7Np4ipNmJt1QzyF0QiSzQwhjTtdcDQ3MuJt6MSIm
	35+vKFcXzA9/QYjiC3ivE7LV2fZsIFxSd45AdvVSogBakSpAwkW/mDWlfcqg8oGPdli1Y+CT7g7
	CEbvCFmxRmWbKKBkmQBBXi4+ACYvdnIyOvccvt1+vAC/75uK0wLxdzNoGj/MioXiN0A==
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr9934339pln.311.1565213452386;
        Wed, 07 Aug 2019 14:30:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyE7YxuOuNZmj/phNm9FkgXjr/JLsD8SxWUFl87Cogie33Q9BgJHxkmGWNSPfJS1igiYHde
X-Received: by 2002:a17:902:6847:: with SMTP id f7mr9934285pln.311.1565213451753;
        Wed, 07 Aug 2019 14:30:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565213451; cv=none;
        d=google.com; s=arc-20160816;
        b=ToPEzjlzMMkXvt05YbOMjG6oQZ9xh9IvnrKBTWLwrCOgiRykQfeUEN61egiDbHfZ3x
         KTfPMNMILV001YUA2gBb1pyQrucmMB4oAyL8J9DmbadJgjcf5xeiiTdhvs6zOoOCtB8o
         cZLSvoOCGC+LGePoi2j3S/anc3nzPnVuWLn9kw4epK4plCKttPBWNvWiz1kC+yTrOM1n
         uEstJ15b9UB5Ini1YhPHy2Meso/xhEtYRQ8GO+aVpshMjPhzQ6IU2mA30ejHp6m5+xsQ
         ByyOVaHUsBPQPRtl9y3FLTj+HwcJ9HCMfYcNTptbjo0DgKbI+YYfcEc7t1f1FaAzXCNL
         K7mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=PbeeDf/GkbDllO5vIZWwH/vN3+gHBbe2/YYojgAimx0=;
        b=mabZWWPMiFWRXAaCEFdWJ3Zt+n6/H0je993CSM6VgExqTKfs+O9XRRdwhrvP05Ks8I
         yqJT5jRJSnlL6gWr9Y53XJsahLlh07aKYBHqiGaLpsaAHybCH978l/IRQVYizBkW81Pq
         qXavZOmh0mf3CrHgujgCj0MHEXBNLk/z6yElhavOEFku+GZ5olzHShbKksjFuOvIS1x9
         1mXcWca3KrR8awqD/Ol8CvgfsDMoohm3lowEdM4j4rnh7fGEgadCXNIU3IXFhpno98QP
         mH/XtTOkepTCeF39zIa/KvRSq+LsJT8SrHKFoGffvdNDHLQ1LUdDr9RbJlSDXIfcx0a0
         YE/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c1vU6F8r;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x6si33354247pgq.473.2019.08.07.14.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 14:30:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=c1vU6F8r;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=PbeeDf/GkbDllO5vIZWwH/vN3+gHBbe2/YYojgAimx0=; b=c1vU6F8rZNn+E3ApTlYjsvg1P
	Ug4PoVhpJ6YWH6IEnG7+O7qR1NIUhBCqAySSXTzxbt5hvW9DtMLOoyCUzUrY4WwIwVsh9H/Ueojp4
	6xGNrTEAoO2LcDdtWlRLRwgSWR2Eptx/O3w2c5wf9JC4HyCgeSJ/VVRUXP7hZlMpsZSdSD51+2bXg
	bvhUYBtIFDXPkAAWOT0ZUDCp2VSLsrKMertexpLx9gT8tIUBVeiFAzn9/tLZDCXwuClStkXHPajGO
	ck5MvJ8MnbVvObac5sJ6W6f1YbrobQWfaergG4OR+FEeBbcsRR7aKBXZwoXDZ291YZ2rweUV1labv
	U32+ixQuQ==;
Received: from [208.71.200.96] (helo=[172.16.195.104])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvTWD-0004Yw-VZ; Wed, 07 Aug 2019 21:30:50 +0000
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
To: Andrew Morton <akpm@linux-foundation.org>,
 Song Liu <songliubraving@fb.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
 Linux Next Mailing List <linux-next@vger.kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>
References: <20190807183606.372ca1a4@canb.auug.org.au>
 <c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
 <DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
 <20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
 <BB7412DE-A88E-41A4-9796-5ECEADE31571@fb.com>
 <20190807142755.8211d58d5ecec8082587b073@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <abb5daa5-322e-55e8-a08d-4e938375451f@infradead.org>
Date: Wed, 7 Aug 2019 14:30:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190807142755.8211d58d5ecec8082587b073@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 2:27 PM, Andrew Morton wrote:
> On Wed, 7 Aug 2019 21:00:04 +0000 Song Liu <songliubraving@fb.com> wrote:
> 
>>>>
>>>> Shall I resend the patch, or shall I send fix on top of current patch?
>>>
>>> Either is OK.  If the difference is small I will turn it into an
>>> incremental patch so that I (and others) can see what changed.
>>
>> Please find the patch to fix this at the end of this email. It applies 
>> right on top of "khugepaged: enable collapse pmd for pte-mapped THP". 
>> It may conflict a little with the "Enable THP for text section of 
>> non-shmem files" set, which renames function khugepaged_scan_shmem(). 
>>
>> Also, I found v3 of the set in linux-next. The latest is v4:
>>
>> https://lkml.org/lkml/2019/8/2/1587
>> https://lkml.org/lkml/2019/8/2/1588
>> https://lkml.org/lkml/2019/8/2/1589
> 
> It's all a bit confusing.  I'll drop 
> 
> mm-move-memcmp_pages-and-pages_identical.patch
> uprobe-use-original-page-when-all-uprobes-are-removed.patch
> uprobe-use-original-page-when-all-uprobes-are-removed-v2.patch
> mm-thp-introduce-foll_split_pmd.patch
> mm-thp-introduce-foll_split_pmd-v11.patch
> uprobe-use-foll_split_pmd-instead-of-foll_split.patch
> khugepaged-enable-collapse-pmd-for-pte-mapped-thp.patch
> uprobe-collapse-thp-pmd-after-removing-all-uprobes.patch
> 
> Please resolve Oleg's review comments and resend everything.
> 

OK, that will take care of the build error that I am still seeing
when SHMEM is not enabled:

../mm/khugepaged.c:1849:2: note: in expansion of macro ‘BUILD_BUG’
  BUILD_BUG();
  ^~~~~~~~~


-- 
~Randy

