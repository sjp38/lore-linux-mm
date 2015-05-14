Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9D09D6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 11:48:51 -0400 (EDT)
Received: by lagv1 with SMTP id v1so73894531lag.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 08:48:50 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id jp4si14788866lab.155.2015.05.14.08.48.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 08:48:49 -0700 (PDT)
Received: by layy10 with SMTP id y10so73823490lay.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 08:48:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150514093304.GS2462@suse.de>
References: <CACgMoiK61mKYFpfhhK51uvkvFHK3k+Dz4peMnbeW7-npDu4XBQ@mail.gmail.com>
	<20150514093304.GS2462@suse.de>
Date: Thu, 14 May 2015 08:48:48 -0700
Message-ID: <CACgMoiKzcDFTd7_howiH1KK2L-ky2S4x99-FTGS9pgO9Bqi0xg@mail.gmail.com>
Subject: Re: mm: BUG_ON with NUMA_BALANCING (kernel BUG at include/linux/swapops.h:131!)
From: Haren Myneni <hmyneni@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Haren Myneni <hbabu@us.ibm.com>, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com

On 5/14/15, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, May 13, 2015 at 01:17:54AM -0700, Haren Myneni wrote:
>> Hi,
>>
>>  I am getting BUG_ON in migration_entry_to_page() with 4.1.0-rc2
>> kernel on powerpc system which has 512 CPUs (64 cores - 16 nodes) and
>> 1.6 TB memory. We can easily recreate this issue with kernel compile
>> (make -j500). But I could not reproduce with numa_balancing=disable.
>>
>
> Is this patched in any way? I ask because line 134 on 4.1.0-rc2 does not
> match up with a BUG_ON. It's close to a PageLocked check but I want to
> be sure there are no other modifications.

Mel, Thanks for your help. I added some printks and dump_page() to get
the page struct and swp_entry information.

>
> Otherwise, when was the last time this worked? Was 4.0 ok? As it can be
> easily reproduced, can the problem be bisected please?

I did not try previous versions other than RHEL kernel (3.10.*). I
will try with previous versions.

In the failure case, also noticed pte and address values are matched
in try_to_unmap_one() and remove_migration_pte(), but entry
(swp_entry_t) value is different. So looks like page strut address in
migration_entry_to_page() is not valid.

try_to_unmap_one()
{

...
        } else if (IS_ENABLED(CONFIG_MIGRATION)) {
                        /*
                         * Store the pfn of the page in a special migration
                         * pte. do_swap_page() will wait until the migration
                         * pte is removed and then restart fault handling.
                         */
                        BUG_ON(!(flags & TTU_MIGRATION));
                        entry = make_migration_entry(page, pte_write(pteval));
                }
                swp_pte = swp_entry_to_pte(entry);
                if (pte_soft_dirty(pteval))
                        swp_pte = pte_swp_mksoft_dirty(swp_pte);
                set_pte_at(mm, address, pte, swp_pte);

                /*pte=0xb16b8d0f80000000 address=0x100008150000
                page=0xf000000513f3e1e0  entry=0x3e0000000ec5ae34 */
...
}

 remove_migration_pte()
{
...
        /* address=0x100008150000 pte=0xb16b8d0f80000000
        *old=0xf000000513f3e1e0 */
        if (!is_migration_entry(entry) ||
        migration_entry_to_page(entry) != old)
        goto unlock;
...
}

 migration_entry_to_page()  {
        pte=0xb16b8d0f80000000  entry=0x3e00000002c5ae34
        page=0xf0000000f3f3e1e0
}


Thanks
Haren

>
> --
> Mel Gorman
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
