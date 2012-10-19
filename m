Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 29E256B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 15:15:39 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so928684obc.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 12:15:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508110C4.6030805@jp.fujitsu.com>
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
 <alpine.DEB.2.00.1210181255470.26994@chino.kir.corp.google.com> <508110C4.6030805@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 19 Oct 2012 15:15:18 -0400
Message-ID: <CAHGf_=pBZAZFQm2+4w8ox3uCZ5psgYmtQmHk7aZU5dgY64+4jQ@mail.gmail.com>
Subject: Re: [patch for-3.7 v3] mm, mempolicy: hold task->mempolicy refcount
 while reading numa_maps.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 19, 2012 at 4:35 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/10/19 5:03), David Rientjes wrote:
>>
>> On Thu, 18 Oct 2012, Kamezawa Hiroyuki wrote:
>>>
>>> @@ -132,7 +162,7 @@ static void *m_start(struct seq_file *m, loff_t *pos)
>>>         tail_vma = get_gate_vma(priv->task->mm);
>>>         priv->tail_vma = tail_vma;
>>> -
>>> +       hold_task_mempolicy(priv);
>>>         /* Start with last addr hint */
>>>         vma = find_vma(mm, last_addr);
>>>         if (last_addr && vma) {
>>> @@ -159,6 +189,7 @@ out:
>>>         if (vma)
>>>                 return vma;
>>>   +     release_task_mempolicy(priv);
>>>         /* End of vmas has been reached */
>>>         m->version = (tail_vma != NULL)? 0: -1UL;
>>>         up_read(&mm->mmap_sem);
>>
>>
>> Otherwise looks good, but please remove the two task_lock()'s in
>> show_numa_map() that I added as part of this since you're replacing the
>> need for locking.
>>
> Thank you for your review.
> How about this ?
>
> ==
> From c5849c9034abeec3f26bf30dadccd393b0c5c25e Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Fri, 19 Oct 2012 17:00:55 +0900
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
> V2->v3
>  -  updated comments to be more verbose.
>  -  removed task_lock() in numa_maps code.
> V1->V2
>  -  access task->mempolicy only once and remember it.  Becase kernel/exit.c
>     can overwrite it.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
