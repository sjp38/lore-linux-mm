Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9D8D831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 09:19:14 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id p85so24862647vkd.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 06:19:14 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 65si7929732uaa.201.2017.05.22.06.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 06:19:13 -0700 (PDT)
Subject: Re: [v4 1/1] mm: Adaptive hash table scaling
References: <1495300013-653283-1-git-send-email-pasha.tatashin@oracle.com>
 <1495300013-653283-2-git-send-email-pasha.tatashin@oracle.com>
 <20170522092910.GD8509@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <f6585e67-1640-daa3-370c-f37562cb5245@oracle.com>
Date: Mon, 22 May 2017 09:18:58 -0400
MIME-Version: 1.0
In-Reply-To: <20170522092910.GD8509@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>

> 
> I have only noticed this email today because my incoming emails stopped
> syncing since Friday. But this is _definitely_ not the right approachh.
> 64G for 32b systems is _way_ off. We have only ~1G for the kernel. I've
> already proposed scaling up to 32M for 32b systems and Andi seems to be
> suggesting the same. So can we fold or apply the following instead?

Hi Michal,

Thank you for your suggestion. I will update the patch.

64G base for 32bit systems is not meant to be ever used, as the adaptive 
scaling for 32bit system is just not needed. 32M and 64G are going to be 
exactly the same on such systems.

Here is theoretical limit for the max hash size of entries (dentry cache 
example):

size of bucket: sizeof(struct hlist_bl_head) = 4 bytes
numentries:  (1 << 32) / PAGE_SIZE  = 1048576 (for 4K pages)
hash size: 4b * 1048576 = 4M

In practice it is going to be an order smaller, as number of kernel 
pages is less then (1<<32).

However, I will apply your suggestions as there seems to be a problem of 
overflowing in comparing ul vs. ull as reported by Michael Ellerman, and 
having a large base on 32bit systems will solve this issue. I will 
revert back to "ul" all the quantities.

Another approach is to make it a 64 bit only macro like this:

#if __BITS_PER_LONG > 32

#define ADAPT_SCALE_BASE     (64ull << 30)
#define ADAPT_SCALE_SHIFT    2
#define ADAPT_SCALE_NPAGES   (ADAPT_SCALE_BASE >> PAGE_SHIFT)

#define adapt_scale(high_limit, numentries, scalep)
       if (!(high_limit)) {                                    \
               unsigned long adapt;                            \
               for (adapt = ADAPT_SCALE_NPAGES; adapt <        \
                    (numentries); adapt <<= ADAPT_SCALE_SHIFT) \
                       (*(scalep))++;                          \
       }
#else
#define adapt_scale(high_limit, numentries scalep)
#endif

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
