Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8CFDF6B0044
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 02:51:50 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so165614obc.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 23:51:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507F86BD.7070201@jp.fujitsu.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
 <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com>
 <20121017193229.GC16805@redhat.com> <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
 <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com>
 <507F803A.8000900@jp.fujitsu.com> <507F86BD.7070201@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 19 Oct 2012 02:51:29 -0400
Message-ID: <CAHGf_=r9ynudaetANyEng64OSXOsLqdQ1SXHb0Z9AnAr23ahZw@mail.gmail.com>
Subject: Re: [patch for-3.7 v2] mm, mempolicy: avoid taking mutex inside
 spinlock when reading numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>> Can't we have another way to fix ? like this ? too ugly ?
>> Again, I'm sorry if I misunderstand the points.
>>
> Sorry this patch itself may be buggy. please don't test..
> I missed that kernel/exit.c sets task->mempolicy to be NULL.
> fixed one here.
>
> --
> From 5581c71e68a7f50e52fd67cca00148911023f9f5 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 18 Oct 2012 13:50:29 +0900
>
> Subject: [PATCH] hold task->mempolicy while numa_maps scans.
>
>  /proc/<pid>/numa_maps scans vma and show mempolicy under
>  mmap_sem. It sometimes accesses task->mempolicy which can
>  be freed without mmap_sem and numa_maps can show some
>  garbage while scanning.
>
> This patch tries to take reference count of task->mempolicy at reading
> numa_maps before calling get_vma_policy(). By this, task->mempolicy
> will not be freed until numa_maps reaches its end.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> V1->V2
>  -  access task->mempolicy only once and remember it.  Becase kernel/exit.c
>     can overwrite it.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Ok, this is acceptable to me. go ahead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
