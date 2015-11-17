Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id C66FC6B0259
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 13:07:56 -0500 (EST)
Received: by ykfs79 with SMTP id s79so20198518ykf.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 10:07:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y206si27547879ywc.240.2015.11.17.10.07.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 10:07:56 -0800 (PST)
Date: Tue, 17 Nov 2015 20:03:50 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: fix incorrect behavior when process virtual
	address space limit is exceeded
Message-ID: <20151117190350.GA9790@redhat.com>
References: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com> <20151117161928.GA9611@redhat.com> <564B6605.8080808@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564B6605.8080808@ezchip.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@ezchip.com>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, akpm@linux-foundation.org, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/17, Chris Metcalf wrote:
>
> On 11/17/2015 11:19 AM, Oleg Nesterov wrote:
>> On 11/16, Piotr Kwapulinski wrote:
>>> @@ -1551,7 +1552,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>>>   		 * MAP_FIXED may remove pages of mappings that intersects with
>>>   		 * requested mapping. Account for the pages it would unmap.
>>>   		 */
>>> -		if (!(vm_flags & MAP_FIXED))
>>> +		if (!(flags & MAP_FIXED))
>>>   			return -ENOMEM;
>> And afaics arch/tile/mm/elf.c can use do_mmap(MAP_FIXED ...) rather than
>> mmap_region(), it can be changed by a separate patch. In this case we can
>> unexport mmap_region().
>
> The problem is that we are mapping a region of virtual address space that
> the chip provides for setting up interrupt handlers (at 0xfc000000) but that
> is above the TASK_SIZE cutoff,

Ah, I didn't bother to read the comment in arch_setup_additional_pages().
Thanks for your explanation.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
