Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id DF2886B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 01:06:47 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so5084682pab.30
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 22:06:47 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id 8si4184499pdk.30.2014.07.31.22.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 22:06:47 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so5103373pab.1
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 22:06:46 -0700 (PDT)
Date: Thu, 31 Jul 2014 22:05:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 4/5] mm, shmem: Add shmem swap memory accounting
In-Reply-To: <1406036632-26552-5-git-send-email-jmarchan@redhat.com>
Message-ID: <alpine.LSU.2.11.1407312204000.3912@eggly.anvils>
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com> <1406036632-26552-5-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux390@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Randy Dunlap <rdunlap@infradead.org>

On Tue, 22 Jul 2014, Jerome Marchand wrote:

> Adds get_mm_shswap() which compute the size of swaped out shmem. It
> does so by pagewalking the mm and using the new shmem_locate() function
> to get the physical location of shmem pages.
> The result is displayed in the new VmShSw line of /proc/<pid>/status.
> Use mm_walk an shmem_locate() to account paged out shmem pages.
> 
> It significantly slows down /proc/<pid>/status acccess speed when
> there is a big shmem mapping. If that is an issue, we can drop this
> patch and only display this counter in the inherently slower
> /proc/<pid>/smaps file (cf. next patch).
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

Definite NAK to this one.  As you guessed yourself, it is always a
mistake to add one potentially very slow-to-gather number to a stats
file showing a group of quickly gathered numbers.

Is there anything you could do instead?  I don't know if it's worth
the (little) extra mm_struct storage and maintenance, but you could
add a VmShmSize, which shows that subset of VmSize (total_vm) which
is occupied by shmem mappings.

It's ambiguous what to deduce when VmShm is less than VmShmSize:
the difference might be swapped out, it might be holes in the sparse
object, it might be instantiated in the object but never faulted
into the mapping: in general it will be a mix of all of those.
So, sometimes useful info, but easy to be misled by it.

As I say, I don't know if VmShmSize would be worth adding, given its
deficiencies; and it could be worked out from /proc/<pid>/maps anyway.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
