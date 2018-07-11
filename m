Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21F126B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:36:30 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id x13-v6so7910233uad.18
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:36:30 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m17-v6si8874455uae.43.2018.07.11.14.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:36:29 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: remove gigantic page support for HIGHMEM
References: <20180711195913.1294-1-mike.kravetz@oracle.com>
 <20180711205702.d4xeu552xgxjbse3@linux-r8p5>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c42f0174-f74f-8b3f-8b69-4885d10d3e15@oracle.com>
Date: Wed, 11 Jul 2018 14:36:16 -0700
MIME-Version: 1.0
In-Reply-To: <20180711205702.d4xeu552xgxjbse3@linux-r8p5>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@kernel.org>, Cannon Matthews <cannonmatthews@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 07/11/2018 01:57 PM, Davidlohr Bueso wrote:
> On Wed, 11 Jul 2018, Mike Kravetz wrote:
> 
>> This reverts commit ee8f248d266e ("hugetlb: add phys addr to struct
>> huge_bootmem_page")
>>
>> At one time powerpc used this field and supporting code. However that
>> was removed with commit 79cc38ded1e1 ("powerpc/mm/hugetlb: Add support
>> for reserving gigantic huge pages via kernel command line").
>>
>> There are no users of this field and supporting code, so remove it.
> 
> Considering the title, don't you wanna also get rid of try_to_free_low()
> and something like the following, which I'm sure can be done fancier, and
> perhaps also thp?

Not really.  The intention is to only remove gigantic huge page support for
HIGHMEN systems.  Non-gigantic huge pages on HIGHMEN systems should still
work/be supported.  So, we do not want to make the config change or get
rid of try_to_free_low().

Actually, I simply wanted to revert the specific patch which enabled gigantic
huge pages on HIGHMEM systems.  I did see that check in try_to_free_low(),

	if (hstate_is_gigantic(h))
		return;

and considered for a minute turning that into a VM_BUG or WARN, but decided
to leave it as is.

Do you think the title should be changed to simply 'revert commit
ee8f248d266e'?

-- 
Mike Kravetz

> diff --git a/fs/Kconfig b/fs/Kconfig
> index ac474a61be37..849da70e35d6 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -192,8 +192,8 @@ config TMPFS_XATTR
> 
> config HUGETLBFS
>        bool "HugeTLB file system support"
> -       depends on X86 || IA64 || SPARC64 || (S390 && 64BIT) || \
> -                  SYS_SUPPORTS_HUGETLBFS || BROKEN
> +       depends on !HIGHMEM && (X86 || IA64 || SPARC64 || (S390 && 64BIT) || \
> +                  SYS_SUPPORTS_HUGETLBFS || BROKEN)
>        help
>          hugetlbfs is a filesystem backing for HugeTLB pages, based on
>          ramfs. For architectures that support it, say Y here and read
> 
> Thanks,
> Davidlohr
