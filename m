Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 99EC5900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 12:31:07 -0400 (EDT)
Received: by lbiz11 with SMTP id z11so10042136lbi.13
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 09:31:06 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id k10si2635067lbs.115.2015.03.11.09.31.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 09:31:05 -0700 (PDT)
Message-ID: <55006DC4.2020002@yandex-team.ru>
Date: Wed, 11 Mar 2015 19:31:00 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz>	<1424958666-18241-3-git-send-email-vbabka@suse.cz> <CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com> <5500592D.4090309@yandex-team.ru> <55005EBA.8080201@redhat.com>
In-Reply-To: <55005EBA.8080201@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

On 11.03.2015 18:26, Jerome Marchand wrote:
> On 03/11/2015 04:03 PM, Konstantin Khlebnikov wrote:
>> On 11.03.2015 15:30, Konstantin Khlebnikov wrote:
>>> On Thu, Feb 26, 2015 at 4:51 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for
>>>> shmem-backed
>>>> mappings, even if the mapped portion does contain pages that were
>>>> swapped out.
>>>> This is because unlike private anonymous mappings, shmem does not
>>>> change pte
>>>> to swap entry, but pte_none when swapping the page out. In the smaps
>>>> page
>>>> walk, such page thus looks like it was never faulted in.
>>>
>>> Maybe just add count of swap entries allocated by mapped shmem into
>>> swap usage of this vma? That's isn't exactly correct for partially
>>> mapped shmem but this is something weird anyway.
>>
>> Something like that (see patch in attachment)
>>
>
> -8<---
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index cf2d0ca010bc..492f78f51fc2 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1363,6 +1363,13 @@ static struct mempolicy *shmem_get_policy(struct
> vm_area_struct *vma,
>   }
>   #endif
>
> +static unsigned long shmem_get_swap_usage(struct vm_area_struct *vma)
> +{
> +	struct inode *inode = file_inode(vma->vm_file);
> +
> +	return SHMEM_I(inode)->swapped;
> +}
> +
>   int shmem_lock(struct file *file, int lock, struct user_struct *user)
>   {
>   	struct inode *inode = file_inode(file);
>
> -8<---
>
> That will not work for shared anonymous mapping since they all share the
> same vm_file (/dev/zero).

Nope. They have different files and inodes.
They're just called "/dev/zero (deleted)".

>
> Jerome
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
