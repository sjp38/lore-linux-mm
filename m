Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB386C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:54:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9419020863
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:54:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9419020863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 224506B0005; Tue, 21 May 2019 02:54:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1604B6B0006; Tue, 21 May 2019 02:54:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04DA26B0007; Tue, 21 May 2019 02:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFC3D6B0005
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:54:15 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d9so11729427pfo.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:54:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=ePIdqvA6JEBzoeNvROqKDpc3NTYkFY1DsqEo0G3vSNk=;
        b=iZBy/SDAP/VMYdopmAMAUtHxLC0AjxBV6gwEgxlZmTvbDuqSTtvx51hPhIBwGitlrY
         aTOy9530AfDXP3/dUKB0QK2j+TWVpbFLqltHQa9WdRszyvzUhDTtARJhhidDYSAG2jSI
         upT5K5y1fAX2e26BVuuqC+VVBM3GjlaxUiiTrN2mAU9Czw3joHkvUgB9aeqttzgoABch
         wxn85KQoDZ6iOE3gi5pNhQxLUm3RhWXoj+LMZqoLBVD0iGV4Huey6IjsPZpoauMKa5Rh
         aeTDF1696GrtahQyTXMXDO1gWkKESEkfE9wbRme+12rrlJu1VRQ8nzR1TNU5xNQ+hL4l
         jNtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU7rI533NbRG465sGzYfpHVQTaiwwluNPgYvzIQQqtFQLexfmnh
	h6uF7ecdjcHPJWISvPKXc40Am+l2eF2IuoNKWshrq66vrjeXbcw3MdPp8/PBORdfLTGKLBjTydL
	H5qNKZ092N0WMbrJyrw8MfHSA24Qi0aLkjttUPfes061duGkNhLIkcLYg/FkGCWmgOQ==
X-Received: by 2002:a63:4ce:: with SMTP id 197mr80639763pge.309.1558421655391;
        Mon, 20 May 2019 23:54:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFbti3hExGLAhiDG8nvR6SP3I2hXDh62yHIPuiLX+k5q2teHFII133qMIZRf5wR8LuLZ/s
X-Received: by 2002:a63:4ce:: with SMTP id 197mr80639720pge.309.1558421654728;
        Mon, 20 May 2019 23:54:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558421654; cv=none;
        d=google.com; s=arc-20160816;
        b=glDUVqijk5kdnshmbZNNcqjR83S8ez8WMPdT7Cgt8MJ9keDs82HlEDFvbODBQYAACI
         pvJpQp4EmXc2C/1hQE2hIWsJMwc9+9lPmbaON2aaRVBqTKbwVhRDmG3x2bR61IjAtmNC
         ZNYUOZ4dDdqSxRecpwl8O00e91IXuEc4J4OajxlMvudIuHrjcOQVz7zJbwNEC/oJ46Jg
         1kAE1QalD8QG141t9TWtac/B+9/7oAWCuuyAUMWz48c5OvWeBLNHgws0MVbc5OK9Ubkr
         y48GrnKJhIhnbmurcUiiVjXhYk/TKFt4UhP4a2foEiCeVROhfWKW/mMmmzXrPhmQd3u5
         /ARA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ePIdqvA6JEBzoeNvROqKDpc3NTYkFY1DsqEo0G3vSNk=;
        b=aQJTZg5W0yVpLqZTQtTc+qPaWjAXkJXjjnrwGHUPWV87/TA+7cFJhSFelHNQRR16nr
         6ND83l7ZWszBhsryD9pZngQJlEMfV0r+xglxb3uEW/YFjUa1VBOhFDE7yySpy5b/vKhW
         kuasInJFo5lrEsFbage2ZDCcqr9wD4g5k7uUt537zi1ywRfOp80tFee3Eh25t6igqhuu
         GSLtHmI/xAeQcGllx/VtYCapV24dINbGy7pHoShIUlnEDjIcxcgEEjPQVpYW98AfJMwd
         yzrV82tntPsfHPveGe1DfMUXnvxLx8I08EMyy/2G0eSIuyklV0mjmjwte6Mr4WYjm029
         xsqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id 1si20465492pgx.176.2019.05.20.23.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:54:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSHoLiE_1558421650;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSHoLiE_1558421650)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 21 May 2019 14:54:11 +0800
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <shy828301@gmail.com>,
 Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>,
 kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>,
 Shakeel Butt <shakeelb@google.com>, william.kucharski@oracle.com,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz>
 <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
 <20190513214503.GB25356@dhcp22.suse.cz>
 <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
 <20190514062039.GB20868@dhcp22.suse.cz>
 <509de066-17bb-e3cf-d492-1daf1cb11494@linux.alibaba.com>
 <20190516151012.GA20038@cmpxchg.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3c2ef3c2-4d39-11c3-acfa-2a809ca72b3c@linux.alibaba.com>
Date: Tue, 21 May 2019 14:54:10 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190516151012.GA20038@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> [ check_move_unevictable_pages() seems weird. It gets a pagevec from
>    find_get_entries(), which, if I understand the THP page cache code
>    correctly, might contain the same compound page over and over. It'll
>    be !unevictable after the first iteration, so will only run once. So
>    it produces incorrect numbers now, but it is probably best to ignore
>    it until we figure out THP cache. Maybe add an XXX comment. ]

The commit 5fd4ca2d84b2 ("mm: page cache: store only head pages in 
i_pages") changed how THP is stored in page cache, but 
find_get_entries() would return base page by calling find_subpage(), so 
check_move_unevictable_pages() should just returns the number of base pages.


