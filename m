Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7776B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 16:42:51 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so6081086pad.13
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 13:42:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id rp15si12307361pab.235.2014.06.17.13.42.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 13:42:50 -0700 (PDT)
Message-ID: <53A0A5E7.60908@oracle.com>
Date: Tue, 17 Jun 2014 16:32:39 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shm: hang in shmem_fallocate
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1406151921070.2850@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 06/15/2014 10:29 PM, Hugh Dickins wrote:
> On Thu, 12 Jun 2014, Sasha Levin wrote:
>> > On 02/09/2014 08:41 PM, Sasha Levin wrote:
>>> > > On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>>>> > >> Would trinity be likely to have a thread or process repeatedly faulting
>>>> > >> in pages from the hole while it is being punched?
>>> > > 
>>> > > I can see how trinity would do that, but just to be certain - Cc davej.
>>> > > 
>>> > > On 02/08/2014 10:25 PM, Hugh Dickins wrote:
>>>> > >> Does this happen with other holepunch filesystems?  If it does not,
>>>> > >> I'd suppose it's because the tmpfs fault-in-newly-created-page path
>>>> > >> is lighter than a consistent disk-based filesystem's has to be.
>>>> > >> But we don't want to make the tmpfs path heavier to match them.
>>> > > 
>>> > > No, this is strictly limited to tmpfs, and AFAIK trinity tests hole
>>> > > punching in other filesystems and I make sure to get a bunch of those
>>> > > mounted before starting testing.
>> > 
>> > Just pinging this one again. I still see hangs in -next where the hang
>> > location looks same as before:
>> > 
> Please give this patch a try.  It fixes what I can reproduce, but given
> your unexplained page_mapped() BUG in this area, we know there's more
> yet to be understood, so perhaps this patch won't do enough for you.
> 
> 
> [PATCH] shmem: fix faulting into a hole while it's punched
> 
> Trinity finds that mmap access to a hole while it's punched from shmem
> can prevent the madvise(MADV_REMOVE) or fallocate(FALLOC_FL_PUNCH_HOLE)
> from completing, until the reader chooses to stop; with the puncher's
> hold on i_mutex locking out all other writers until it can complete.
> 
> It appears that the tmpfs fault path is too light in comparison with
> its hole-punching path, lacking an i_data_sem to obstruct it; but we
> don't want to slow down the common case.
> 
> Extend shmem_fallocate()'s existing range notification mechanism, so
> shmem_fault() can refrain from faulting pages into the hole while it's
> punched, waiting instead on i_mutex (when safe to sleep; or repeatedly
> faulting when not).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

No shmem_fallocate issues observed in the past day, works for me. Thanks Hugh!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
