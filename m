Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4233AC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2D99223BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:16:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="M0CVenrM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2D99223BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C3E96B000A; Tue, 23 Jul 2019 04:16:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 374D38E0003; Tue, 23 Jul 2019 04:16:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28B1A8E0002; Tue, 23 Jul 2019 04:16:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA8B26B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:16:54 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id 9so9065554ljp.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OCdChmHdfM6D9uf2VkQAqf8PnxrZ5zOIH6aLjOH+qUU=;
        b=EbRliGmC/eyuqpgxqV0algIUUF/yw2nPOYYbv42AhYpCUncZnU7xcN/U4uOP2uenM3
         8hh4+BUOv2UkNxd6ra2PhHSZLpCa8WCoY3CQ9VjULbyv47EmjzODGt+PMDzYawwIcT8p
         eCt/ucmTXCv0YpKL3X4FaaS/xM/c49xtAvD/oKiZU4til5cyk23dJEzmWrd3ZF8ClRRj
         Eqm2ePUMMBgGrZJFUyawx4BzDjMn06ETKeg4uMefH0Y84ERCcg7EW040C0g62VrsCTAh
         GvdSHZdaaYO8t++ZIhdiw+nL6xjdJBY2m5Lw/46WYo4Sn6797ws4lJs9+ki94qH3E/3+
         QTpw==
X-Gm-Message-State: APjAAAUM/uoyzg39gIV6z3+0ZWnzmk2SjtnSeHTFu+Wc1W6ClzrdmEDD
	l/K9RVGtEqIXECVT64obPknwh6Al644hLbVBzzh4BCoEoeYMr3E8KKg3MeslsC8p+bUpOn9kOp/
	Qeccmavu2dY5Dyscsy1TRTtyDMU2aiJqSCqGdNDJnT0cECBQq/GmtlpXIpbUbUDtr6Q==
X-Received: by 2002:a2e:7315:: with SMTP id o21mr31058556ljc.3.1563869814039;
        Tue, 23 Jul 2019 01:16:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd5V2FHclaW5NOudFWHyFDs9G+cGZotGJbGInW//HGAagac2X4g7hGdPJ/WxB08tJWyRbN
X-Received: by 2002:a2e:7315:: with SMTP id o21mr31058528ljc.3.1563869813303;
        Tue, 23 Jul 2019 01:16:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563869813; cv=none;
        d=google.com; s=arc-20160816;
        b=oKAf8g0V2yaazTB8PTdNxRfXYJ8JZsvWx0kWq4XaO5wEq3rVKN2V/6my4N2xUKfjVa
         Rrys8G0vZX5iWYyWidA2Uev+z9otU75aXUcJ3agpK5Lyx0oCdEf0EUgAXdlo1X8e3g+J
         7oS0DEdjziMDUEOMTcPU1fu+X8ry5D+tmmbIiQgQWMlEZJjT8+FQuXh7ho/kq8cz15pH
         AqDwhl1wPLGe3jcxqYUhxnNtnQI2vZN4/mzkQwuDEu0K9etYMd9eP1Jj4cJHVZkkHmkg
         iuEGfC1K0+jdm7Ao7l8V55X0e3d8aBrjmxlm/dz6gw5pcEzDa+tB2hlJMx5b+QF/tBZS
         jQkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=OCdChmHdfM6D9uf2VkQAqf8PnxrZ5zOIH6aLjOH+qUU=;
        b=z8kwvPDFmCNBDT/CbQzBdWsao29lwh+Xi/V8Rv311pmYACcnG472Oo8W7AQRkvxS80
         1i/u/UMBj3qu76szHgmgDzX6Uw2tNuCEm8A0GmxlxA5PS4Xz7Nk66v9EjTVcLPsYq/Yj
         C0osDSzE3sCOZnUH30I9u0a0saQOnbUR8QX2VFTAwGk8QNOCdrjjqOrFPu2vXTxbzz59
         xi9e63DcuXcYR0r1keU9LVb6oCNx4j/n7t2u6NIfUTMldiUZfwTTNVk4424rHExlGCdK
         7hwbtg1a4zar1hWlsLKDTauvg3F58prCYUABCX4IQvSX3XrCC1D/rZeWTFUXMBCladRq
         p/Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=M0CVenrM;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id x14si33316085ljb.80.2019.07.23.01.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:16:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=M0CVenrM;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 94D392E1485;
	Tue, 23 Jul 2019 11:16:52 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id zrWDbtFrST-GqNCGMan;
	Tue, 23 Jul 2019 11:16:52 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563869812; bh=OCdChmHdfM6D9uf2VkQAqf8PnxrZ5zOIH6aLjOH+qUU=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=M0CVenrM9AC4JpNV2SXPm4QsXi07w0FwQKWvlGVbaH2JKs/RvqeojUHoTdlkMrkb6
	 8CFoIYQtsn4RsPg8zd58p/Jtt/lPbqhJ2HhpLnLHI+NTKbR3m6d3bthLrDf6ZFMmun
	 vcG5SDSMKJo7nRP3Se9wk2sTAFGcYTucOwL1nvjM=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 7w6wmPdkO2-GpAejdNM;
	Tue, 23 Jul 2019 11:16:52 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 1/2] mm/filemap: don't initiate writeback if mapping has
 no dirty pages
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>,
 Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org,
 Jan Kara <jack@suse.cz>
References: <156378816804.1087.8607636317907921438.stgit@buzz>
 <20190722175230.d357d52c3e86dc87efbd4243@linux-foundation.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <bdc6c53d-a7bb-dcc4-20ba-6c7fa5c57dbd@yandex-team.ru>
Date: Tue, 23 Jul 2019 11:16:51 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190722175230.d357d52c3e86dc87efbd4243@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 23.07.2019 3:52, Andrew Morton wrote:
> 
> (cc linux-fsdevel and Jan)
> 
> On Mon, 22 Jul 2019 12:36:08 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> 
>> Functions like filemap_write_and_wait_range() should do nothing if inode
>> has no dirty pages or pages currently under writeback. But they anyway
>> construct struct writeback_control and this does some atomic operations
>> if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
>> updates state of writeback ownership, on slow path might be more work.
>> Current this path is safely avoided only when inode mapping has no pages.
>>
>> For example generic_file_read_iter() calls filemap_write_and_wait_range()
>> at each O_DIRECT read - pretty hot path.
>>
>> This patch skips starting new writeback if mapping has no dirty tags set.
>> If writeback is already in progress filemap_write_and_wait_range() will
>> wait for it.
>>
>> ...
>>
>> --- a/mm/filemap.c
>> +++ b/mm/filemap.c
>> @@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
>>   		.range_end = end,
>>   	};
>>   
>> -	if (!mapping_cap_writeback_dirty(mapping))
>> +	if (!mapping_cap_writeback_dirty(mapping) ||
>> +	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
>>   		return 0;
>>   
>>   	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
> 
> How does this play with tagged_writepages?  We assume that no tagging
> has been performed by any __filemap_fdatawrite_range() caller?
>

Checking also PAGECACHE_TAG_TOWRITE is cheap but seems redundant.

To-write tags are supposed to be a subset of dirty tags:
to-write is set only when dirty is set and cleared after starting writeback.

Special case set_page_writeback_keepwrite() which does not clear to-write
should be for dirty page thus dirty tag is not going to be cleared either.
Ext4 calls it after redirty_page_for_writepage()
XFS even without clear_page_dirty_for_io()

Anyway to-write tag without dirty tag or at clear page is confusing.

