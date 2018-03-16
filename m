Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 603BD6B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:19:32 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id p123so10435218ywh.2
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:19:32 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i187-v6si1227067ybc.531.2018.03.16.09.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 09:19:31 -0700 (PDT)
Subject: Re: [PATCH v3] hugetlbfs: check for pgoff value overflow
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <20180309002726.7248-1-mike.kravetz@oracle.com>
 <20180316101757.GE23100@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <12826dc6-c81e-c22a-2ec1-8e1cf0f07dfc@oracle.com>
Date: Fri, 16 Mar 2018 09:19:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180316101757.GE23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Nic Losby <blurbdust@gmail.com>, Yisheng Xie <xieyisheng1@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 03/16/2018 03:17 AM, Michal Hocko wrote:
> On Thu 08-03-18 16:27:26, Mike Kravetz wrote:
> 
> OK, looks good to me. Hairy but seems to be the easiest way around this.
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
<snip>
>> +/*
>> + * Mask used when checking the page offset value passed in via system
>> + * calls.  This value will be converted to a loff_t which is signed.
>> + * Therefore, we want to check the upper PAGE_SHIFT + 1 bits of the
>> + * value.  The extra bit (- 1 in the shift value) is to take the sign
>> + * bit into account.
>> + */
>> +#define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))

Thanks Michal,

However, kbuild found a problem with this definition on certain configs.
Consider a config where,
BITS_PER_LONG = 32 (32bit config)
PAGE_SHIFT = 16 (64K pages)
This results in the negative shift value.
Not something I would not immediately think of, but a valid config.

The definition has been changed to,
#define PGOFF_LOFFT_MAX \
	(((1UL << (PAGE_SHIFT + 1)) - 1) <<  (BITS_PER_LONG - (PAGE_SHIFT + 1)))

as discussed here,
http://lkml.kernel.org/r/432fb2a3-b729-9c3a-7d60-890b8f9b10dd@oracle.com
-- 
Mike Kravetz
