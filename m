Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D5A376B0255
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 12:38:28 -0500 (EST)
Received: by igcto18 with SMTP id to18so18906527igc.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 09:38:28 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0077.outbound.protection.outlook.com. [157.55.234.77])
        by mx.google.com with ESMTPS id l23si25851452iod.19.2015.11.17.09.38.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Nov 2015 09:38:27 -0800 (PST)
Subject: Re: [PATCH] mm: fix incorrect behavior when process virtual address
 space limit is exceeded
References: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20151117161928.GA9611@redhat.com>
From: Chris Metcalf <cmetcalf@ezchip.com>
Message-ID: <564B6605.8080808@ezchip.com>
Date: Tue, 17 Nov 2015 12:38:13 -0500
MIME-Version: 1.0
In-Reply-To: <20151117161928.GA9611@redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/17/2015 11:19 AM, Oleg Nesterov wrote:
> On 11/16, Piotr Kwapulinski wrote:
>> @@ -1551,7 +1552,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>>   		 * MAP_FIXED may remove pages of mappings that intersects with
>>   		 * requested mapping. Account for the pages it would unmap.
>>   		 */
>> -		if (!(vm_flags & MAP_FIXED))
>> +		if (!(flags & MAP_FIXED))
>>   			return -ENOMEM;
> And afaics arch/tile/mm/elf.c can use do_mmap(MAP_FIXED ...) rather than
> mmap_region(), it can be changed by a separate patch. In this case we can
> unexport mmap_region().

The problem is that we are mapping a region of virtual address space that
the chip provides for setting up interrupt handlers (at 0xfc000000) but that
is above the TASK_SIZE cutoff, so do_mmap() would fail the call in
get_unmapped_area().

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
