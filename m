Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8004B6B026F
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:09:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g20-v6so16675750pfi.2
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:09:16 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id c1-v6si3281252pfe.29.2018.07.11.10.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 10:09:15 -0700 (PDT)
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for large
 mapping
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711103312.GH20050@dhcp22.suse.cz>
 <20180711111311.hrh5kxdottmpdpn2@kshutemo-mobl1>
 <20180711115332.GM20050@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <4076e0b4-f3a8-6d71-2a98-e7b8cc6986d4@linux.alibaba.com>
Date: Wed, 11 Jul 2018 10:08:52 -0700
MIME-Version: 1.0
In-Reply-To: <20180711115332.GM20050@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/11/18 4:53 AM, Michal Hocko wrote:
> On Wed 11-07-18 14:13:12, Kirill A. Shutemov wrote:
>> On Wed, Jul 11, 2018 at 12:33:12PM +0200, Michal Hocko wrote:
>>> this is not a small change for something that could be achieved
>>> from the userspace trivially (just call madvise before munmap - library
>>> can hide this). Most workloads will even not care about races because
>>> they simply do not play tricks with mmaps and userspace MM. So why do we
>>> want to put the additional complexity into the kernel?
>> As I said before, kernel latency issues have to be addressed in kernel.
>> We cannot rely on userspace being kind here.
> Those who really care and create really large mappings will know how to
> do this properly. Most others just do not care enough. So I am not
> really sure this alone is a sufficient argument.
>
> I personally like the in kernel auto tuning but as I've said the
> changelog should be really clear why all the complications are
> justified. This would be a lot easier to argue about if it was a simple
> 	if (len > THARSHOLD)
> 		do_madvise(DONTNEED)
> 	munmap().

The main difference AFAICS, is it can't deal with the parallel faults 
and those special mappings. Someone may not care about it, but someone may.

Yang

> approach. But if we really have to care about parallel faults and munmap
> consitency this will always be tricky
