Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32B8CC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 15:14:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D852921872
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 15:14:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="GR6uaQ00"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D852921872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 846F38E0003; Fri,  1 Feb 2019 10:14:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CF278E0001; Fri,  1 Feb 2019 10:14:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 697008E0003; Fri,  1 Feb 2019 10:14:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFC68E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 10:14:57 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id w68so3681008ith.0
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 07:14:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0/w0VcgBYTyY12yo9kpfyfqwFxGA5uutLsI2xQpEdHs=;
        b=ewVsobrO/OPmpnS+39xyjBs5ar3hOmvyc0H5KUGAvvS3PKb1GVPudtYocphA4oQowB
         kwbBWfE+BJzM+56wqH4tsY8r2R6o8VD3Rk3TeNr7+3sdQ9/JUyjk0eaTacaE+OffwkQs
         /mxfKGSa72PUNuvP0l5GzEp9mVDI/tRKBfx12D59IxobDW797ZFMn8m8FTVVLws+2Z+g
         oRPfJ1XRfsK8crTLvACkaup4G9U1KEMQKLuc7wxTSslMab+5bh670pk9l1qpEH56KlzE
         rlsdPDIHMvY2DaiRasYNeB6luMDHQ1+bapwGO5BC8yWnSLC4cNloEMhcubu6REvy1gid
         DOSQ==
X-Gm-Message-State: AHQUAuZN+yV9BnWf7HAX8vIN68X27qiSYkcrbToRHUcqMDBTi02iy0vy
	3fP0Y4J3jwnzPTETaMsGR99T8aFsKC48vVhwzWH4/5JOU48VhdFKBknq7+nmVLhIiy3u2DH6DmL
	EGaTNEG0nci7UsX2j7bPgPGNRb/0LzqVG7LJzZMdeMhfjdTv1HJ6Fb+xxl13roHcq2tPCkbkW7f
	Hc/T6HrNpjitXsfz3jFfdzsuDMomt7HE9FLcTiq4pZUzK4KSEWyMPhahT8g2gCfUlrIseOBPVry
	YIWOTFbYLtk9D8kJ42dQ1bBSiVqHOU+y1kXfsYtU543xNIH9ulRMYzUuKShpFdpAw4+olZnxN4o
	W+ldJSxBeKZQBaPz8NevnlnO16HLXIPFLCGBHTMXPqciECgj6J8fQtKDygdxVjjRGudntkP+vTE
	2
X-Received: by 2002:a24:2f82:: with SMTP id j124mr1525782itj.166.1549034096942;
        Fri, 01 Feb 2019 07:14:56 -0800 (PST)
X-Received: by 2002:a24:2f82:: with SMTP id j124mr1525749itj.166.1549034096127;
        Fri, 01 Feb 2019 07:14:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549034096; cv=none;
        d=google.com; s=arc-20160816;
        b=kJvRrKPl2goXdXbRpRQ1k7zj10epaAEkMEAlHc5GWKF8grxXAJJAJgH++a/ZgTmXkj
         YcRNkDxCyh/GVb2y7UsZjA6wPcWegcXSneR9NWxNw+jQxCUO+PN84kCNRQHcICyVpoMG
         So8CYLXCESxJkVhZOrqSTwAzOjfASPbDrcxU/RxHmsuvfJBFp+GMlJ7z0fV2g7carYl8
         hjazgbvyCvGzLwzdjieepjbKiD8tHEmmGYhrBMBuSmtlP8OXgUgixI/6Lt5w3LWuVHid
         NQTOs/7ux6IzKeWV+zhGPKC/SxhZlR70diopukjHWHNMcu0hZc2k0e7DmlbVOs2aX7If
         z9+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0/w0VcgBYTyY12yo9kpfyfqwFxGA5uutLsI2xQpEdHs=;
        b=QagNJpx4C2XlB5Id5Ozzij+GCOLarjcJyNwW32ocJrSvD95FuKyYJ5Nac+g1wUfRB9
         wGYPslj6PXjIGQ4Iw+pbmkLAZyTTQp8UjZ+xRMBSAroJiFMtFYRPvqCYg0M7UrMU0ZUQ
         WIWel+KZekTpnSuTlnw6V9eUSpSbR3iBCHePf9qQTz1KK9F97i3FPnOHePRgBz4Mbv1W
         EgnV/DS3OrCWl+vLZ3sr6t7KIm+fwrF6xuLf4P08KRdWsj6S7PfNLpv0XSsdkEyFrwaI
         VtD2fJ6PthBP0M1XhcMecTHf+zoxwPTwCvsulqNnxj9VbmnKdktK2u4ZDENxrZSbO9Ue
         bnaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=GR6uaQ00;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4sor5212048iom.6.2019.02.01.07.14.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Feb 2019 07:14:56 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=GR6uaQ00;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=0/w0VcgBYTyY12yo9kpfyfqwFxGA5uutLsI2xQpEdHs=;
        b=GR6uaQ00pYbPCLRa9KeOVp7EAIVTQLwuVTa4F0eriqXHDAVa2QA7/4h84CbVyQJUNb
         ih1phsb6e/nK3Mjd66ZwOtyGtcm2IyFZasZ8ZHl16VqHQAN6mpba7/4P/Id5BG5qCc1z
         bqzGO8YhoAvBoBFPKjr3dYL0v7P7BhaXzyhNLgyDpBaOTC/WC2wSlxN3l4GqwxEzEFc2
         fnqT91Hn56EbDfmWji6vrguO8WhJh0q84ZEJ0npqldX/u8tUbB3EUKHjI6/rB93zM2R9
         +cEsahcNDaNJKlFGRWEguOpCygiDippzvQf2vtYJ4Xv+y2IgtvSP8opWrU00sih321HJ
         92fw==
X-Google-Smtp-Source: AHgI3IaMUZ1ZEOXtZ9C4Vh8gQ91ZR7MwMuUf6GYs9Kd2nJddUqhf+vQWuKZQDNxSXbgxzxgq4WH8/g==
X-Received: by 2002:a5d:85c5:: with SMTP id e5mr21663233ios.125.1549034095744;
        Fri, 01 Feb 2019 07:14:55 -0800 (PST)
Received: from [192.168.1.158] ([216.160.245.98])
        by smtp.gmail.com with ESMTPSA id 193sm1427312itl.19.2019.02.01.07.14.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 07:14:54 -0800 (PST)
Subject: Re: [PATCH] mm/filemap: pass inclusive 'end_byte' parameter to
 filemap_range_has_page
To: Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>
Cc: zhengbin <zhengbin13@huawei.com>, Goldwyn Rodrigues <rgoldwyn@suse.com>,
 Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, darrick.wong@oracle.com,
 amir73il@gmail.com, david@fromorbit.com, hannes@cmpxchg.org,
 jrdr.linux@gmail.com, hughd@google.com, linux-mm@kvack.org,
 houtao1@huawei.com, yi.zhang@huawei.com
References: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com>
 <20190128201805.GA31437@bombadil.infradead.org>
 <20190201074359.GA15026@lst.de>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <5ef9e569-785f-aca8-20a5-ff08cf8823c3@kernel.dk>
Date: Fri, 1 Feb 2019 08:14:52 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190201074359.GA15026@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/1/19 12:43 AM, Christoph Hellwig wrote:
> On Mon, Jan 28, 2019 at 12:18:05PM -0800, Matthew Wilcox wrote:
>> On Mon, Jan 28, 2019 at 08:31:19PM +0800, zhengbin wrote:
>>> The 'end_byte' parameter of filemap_range_has_page is required to be
>>> inclusive, so follow the rule.
>>
>> Reviewed-by: Matthew Wilcox <willy@infradead.org>
>> Fixes: 6be96d3ad34a ("fs: return if direct I/O will trigger writeback")
>>
>> Adding the people in the sign-off chain to the Cc.
> 
> This looks correct to me:
> 
> Acked-by: Christoph Hellwig <hch@lst.de>

Ditto

> I wish we'd kill these stupid range calling conventions, though - 
> offset + len is a lot more intuitive, and we already use it very
> widely all over the kernel.

Wholeheartedly agree on that, it's a horrible interface that goes
counter to the whole "easy to use, hard to misuse" mantra.

-- 
Jens Axboe

