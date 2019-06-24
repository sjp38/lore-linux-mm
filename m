Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D461CC48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A55DA20663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 16:54:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A55DA20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40C998E0003; Mon, 24 Jun 2019 12:54:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BCAC8E0002; Mon, 24 Jun 2019 12:54:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2ABE78E0003; Mon, 24 Jun 2019 12:54:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E55108E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 12:54:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t2so7631179plo.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:54:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=xNQfDudqIWnqMRWyEsJQ+IQUIlyt9uf8PPAEvRP5kVU=;
        b=A+QZrUOjS80GXWb53Ru96y/69ecjS7Ne+RtPSyLba0IzPNZ33oqNoe14CV5gMFy52n
         SUmeRapKrceUz98Lselx0UeS7DqwFcB6SkD2t5p2xD0mpTtOTPYZeSa76fBmVedF6B2z
         paeoGjjs5uFPtsLiwcBI3It18G2jYsf3iT0DheUL9oWUC73XchVrIZ9LbKB54fC1Ie48
         0M/rv4AEibPFgz2GkQWj+umhfSu/DiNEm2uL5PPhzpD0LxjOGFqK2vwz9RUE79wHFHoX
         DFbzFCuHzWWBxmsKwNqjUNiEFkUGf/wLbdRlNh+GKjZj0ZM5M6uDESmMU0lK0ScTGgwu
         LdmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVzWOtWOEdbCc2xszgU8kqafdWZqmZKlZw8nFdf3BWTu/cdf8WU
	FYWeX9j2DFwQ/XnwFP97pqBKrIfWds0hFKUgdtnOJkvoDNTsatydlLlITISAaRXwQvsb4H5e/i8
	4vayL0FihIAefSl4syHr/dFJd4V9jzCI385XIXmUid6zrTt1Jfo3pyjJc7dbI7+Hc1g==
X-Received: by 2002:a17:902:bb85:: with SMTP id m5mr32256614pls.280.1561395258584;
        Mon, 24 Jun 2019 09:54:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYS0H0epj3GteWZb8kW75tCsaslz7BUK/c967Id3BsyvifVSLVBqt9/giGmvNlBHMk4D2a
X-Received: by 2002:a17:902:bb85:: with SMTP id m5mr32256565pls.280.1561395257918;
        Mon, 24 Jun 2019 09:54:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561395257; cv=none;
        d=google.com; s=arc-20160816;
        b=Pxsk1rYY7eyuf0d08VhO165HDKEymful75CqYfvO6R4/x4L1lsnuU+XShmULzRLKdz
         hkbTdazdZ1Ce98tNKbR7+MWcVapNsIrzN3ZMT6sf6WWUAQVCo2p6gc+m7pPhQmmHQD9a
         +DyyPSSpBYnvv0XUp2MXS27E+URY35JeEIOIadR2QmsCnO9xctko4UAVUiL6jPo8bYxZ
         T/zDuJ2DeOBATrSUVzPawAn9cxogef/p4XGNajOwwMFvXMee5E8QIhq2A4vPCpl72YX4
         VjvYEuEBfOKLAYSvA+4hM9PN0hlaRUc6vAL5JpYLqIziyx+oUgcXh+YBWCk6NLZUUOtN
         mFdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=xNQfDudqIWnqMRWyEsJQ+IQUIlyt9uf8PPAEvRP5kVU=;
        b=O36OKdOHe0dxPh/G6+zafFjcXU0S1eqfpxqfCKR0X8ScIF3apYzh/ltJafZoCX45jf
         4w94CXLEQ+8J8jDOPdyaN8T5YDxQUKf6wjLjGd8yT0i0j6q/85QuZ/ApyWo1PLaWUp16
         sTFzCr8vi3vNzXuSU2ssqeeN+A1JTdzqMsUwGqXWHoPmi8GKYtswiz3C9cnkj91e1j1d
         9MZY1iyzxDfbrp7uEy2nFP4rVKHT/QmWeRTo3Dk8MKeMPnQKzW0x60R1lbRT5kL2lrw0
         MvO13o98/chhzj+2HN5CKj1SHpjEExMc+U7j4uN0MQ5Ekh4DRrjWnL3k60ZUz4jPDLa6
         JHNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id t14si10556291pgh.51.2019.06.24.09.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 09:54:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TV6jVAp_1561395249;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TV6jVAp_1561395249)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 25 Jun 2019 00:54:13 +0800
Subject: Re: [v3 PATCH 2/4] mm: move mem_cgroup_uncharge out of
 __page_cache_release()
From: Yang Shi <yang.shi@linux.alibaba.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190613113943.ahmqpezemdbwgyax@box>
 <2909ce59-86ba-ea0b-479f-756020fb32af@linux.alibaba.com>
Message-ID: <df469474-9b1c-6052-6aaa-be4558f7bd86@linux.alibaba.com>
Date: Mon, 24 Jun 2019 09:54:05 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <2909ce59-86ba-ea0b-479f-756020fb32af@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/13/19 10:13 AM, Yang Shi wrote:
>
>
> On 6/13/19 4:39 AM, Kirill A. Shutemov wrote:
>> On Thu, Jun 13, 2019 at 05:56:47AM +0800, Yang Shi wrote:
>>> The later patch would make THP deferred split shrinker memcg aware, but
>>> it needs page->mem_cgroup information in THP destructor, which is 
>>> called
>>> after mem_cgroup_uncharge() now.
>>>
>>> So, move mem_cgroup_uncharge() from __page_cache_release() to compound
>>> page destructor, which is called by both THP and other compound pages
>>> except HugeTLB.  And call it in __put_single_page() for single order
>>> page.
>>
>> If I read the patch correctly, it will change behaviour for pages with
>> NULL_COMPOUND_DTOR. Have you considered it? Are you sure it will not 
>> break
>> anything?
>

Hi Kirill,

Did this solve your concern? Any more comments on this series?

Thanks,
Yang

> So far a quick search shows NULL_COMPOUND_DTOR is not used by any type 
> of compound page. The HugeTLB code sets destructor to 
> NULL_COMPOUND_DTOR when freeing hugetlb pages via hugetlb specific 
> destructor.
>
> The prep_new_page() would call prep_compound_page() if __GFP_COMP is 
> used, which sets dtor to COMPOUND_PAGE_DTOR by default.  Just hugetlb 
> and THP set their specific dtors.
>
> And, it looks __put_compound_page() doesn't check if dtor is NULL or 
> not at all.
>
>>
>

