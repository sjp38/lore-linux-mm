Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA916B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 13:25:11 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id wp4so4485810obc.6
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 10:25:10 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id sd1si29525566obb.208.2014.04.21.10.25.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 10:25:10 -0700 (PDT)
Message-ID: <1398101106.2623.6.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 21 Apr 2014 10:25:06 -0700
In-Reply-To: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Mon, 2014-04-21 at 16:26 +0200, Manfred Spraul wrote:
> Hi all,
> 
> the increase of SHMMAX/SHMALL is now a 4 patch series.
> I don't have ideas how to improve it further.

Manfred, is there any difference between this set and the one you sent a
couple of days ago?

> 
> The change itself is trivial, the only problem are interger overflows.
> The overflows are not new, but if we make huge values the default,
> then the code should be free from overflows.
> 
> SHMMAX:
> 
> - shmmem_file_setup places a hard limit on the segment size:
>   MAX_LFS_FILESIZE.
> 
>   On 32-bit, the limit is > 1 TB, i.e. 4 GB-1 byte segments are
>   possible. Rounded up to full pages the actual allocated size
>   is 0. --> must be fixed, patch 3
> 
> - shmat:
>   - find_vma_intersection does not handle overflows properly.
>     --> must be fixed, patch 1
> 
>   - the rest is fine, do_mmap_pgoff limits mappings to TASK_SIZE
>     and checks for overflows (i.e.: map 2 GB, starting from
>     addr=2.5GB fails).
> 
> SHMALL:
> - after creating 8192 segments size (1L<<63)-1, shm_tot overflows and
>   returns 0.  --> must be fixed, patch 2.
> 
> User space:
> - Obviuosly, there could be overflows in user space. There is nothing
>   we can do, only use values smaller than ULONG_MAX.
>   I ended with "ULONG_MAX - 1L<<24":
> 
>   - TASK_SIZE cannot be used because it is the size of the current
>     task. Could be 4G if it's a 32-bit task on a 64-bit kernel.
> 
>   - The maximum size is not standardized across archs:
>     I found TASK_MAX_SIZE, TASK_SIZE_MAX and TASK_SIZE_64.
> 
>   - Just in case some arch revives a 4G/4G split, nearly
>     ULONG_MAX is a valid segment size.
> 
>   - Using "0" as a magic value for infinity is even worse, because
>     right now 0 means 0, i.e. fail all allocations.

Sorry but I don't quite get this. Using 0 eliminates the need for all
these patches, no? I mean overflows have existed since forever, and
taking this route would naturally solve the problem. 0 allocations are a
no no anyways.

I do agree with the series iff we endup taking this 'increase the limit
size approach'. But I just don't see the need.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
