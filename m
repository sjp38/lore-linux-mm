Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 461E9900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 15:10:47 -0400 (EDT)
Received: by wghl18 with SMTP id l18so11422241wgh.11
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 12:10:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qa2si18829938wic.10.2015.03.11.12.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 12:10:45 -0700 (PDT)
Message-ID: <5500932F.6030107@suse.cz>
Date: Wed, 11 Mar 2015 20:10:39 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz>	<1424958666-18241-3-git-send-email-vbabka@suse.cz> <CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com>
In-Reply-To: <CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

On 03/11/2015 01:30 PM, Konstantin Khlebnikov wrote:
> On Thu, Feb 26, 2015 at 4:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-backed
>> mappings, even if the mapped portion does contain pages that were swapped out.
>> This is because unlike private anonymous mappings, shmem does not change pte
>> to swap entry, but pte_none when swapping the page out. In the smaps page
>> walk, such page thus looks like it was never faulted in.
>
> Maybe just add count of swap entries allocated by mapped shmem into
> swap usage of this vma? That's isn't exactly correct for partially
> mapped shmem but this is something weird anyway.

Yeah for next version I want to add a patch optimizing for the 
(hopefully) common cases:

1. SHMEM_I(inode)->swapped is 0 - no need to consult radix tree
2. shmem inode is mapped fully (I hope it's ok to just compare its size 
and mapping size) - just use the value of SHMEM_I(inode)->swapped like 
you suggest



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
