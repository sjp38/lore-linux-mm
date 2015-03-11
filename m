Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id D746B82905
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 16:03:40 -0400 (EDT)
Received: by lbvn10 with SMTP id n10so11372924lbv.11
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:03:39 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id f7si3057752lab.19.2015.03.11.13.03.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 13:03:38 -0700 (PDT)
Received: by labgd6 with SMTP id gd6so11274279lab.6
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 13:03:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5500932F.6030107@suse.cz>
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz>
	<1424958666-18241-3-git-send-email-vbabka@suse.cz>
	<CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com>
	<5500932F.6030107@suse.cz>
Date: Wed, 11 Mar 2015 23:03:37 +0300
Message-ID: <CALYGNiPZFPMTuS_Obe9Ax9i2isS5ucY86JRF6JjGgKuTPuwEvA@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

On Wed, Mar 11, 2015 at 10:10 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 03/11/2015 01:30 PM, Konstantin Khlebnikov wrote:
>>
>> On Thu, Feb 26, 2015 at 4:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
>>> mappings, even if the mapped portion does contain pages that were swapped
>>> out.
>>> This is because unlike private anonymous mappings, shmem does not change
>>> pte
>>> to swap entry, but pte_none when swapping the page out. In the smaps page
>>> walk, such page thus looks like it was never faulted in.
>>
>>
>> Maybe just add count of swap entries allocated by mapped shmem into
>> swap usage of this vma? That's isn't exactly correct for partially
>> mapped shmem but this is something weird anyway.
>
>
> Yeah for next version I want to add a patch optimizing for the (hopefully)
> common cases:
>
> 1. SHMEM_I(inode)->swapped is 0 - no need to consult radix tree
> 2. shmem inode is mapped fully (I hope it's ok to just compare its size and
> mapping size) - just use the value of SHMEM_I(inode)->swapped like you
> suggest
>

BTW using radix tree iterator you can count swap entries without
touching page->count.

Also long time ago I've suggested to mark swap entries in shmem with
one of radix tree tag -- tagged iterator is much faster for sparse trees.
(just for this case it's overkill but these tags can speedup swapoff)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
