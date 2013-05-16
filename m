Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 399026B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 19:46:06 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9DD933EE0C5
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:03 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EB9145DE50
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 040BE45DE4D
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB619E08003
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:02 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A26421DB802F
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:46:02 +0900 (JST)
Message-ID: <51956FA3.6040806@jp.fujitsu.com>
Date: Fri, 17 May 2013 08:45:39 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 4/8] vmalloc: make find_vm_area check in range
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090602.28109.90142.stgit@localhost6.localdomain6> <CAHGf_=q-91cYOMPFfSGLsWWst7STgp6pxX4__9UMYUGh=Ef3oA@mail.gmail.com>
In-Reply-To: <CAHGf_=q-91cYOMPFfSGLsWWst7STgp6pxX4__9UMYUGh=Ef3oA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "riel@redhat.com" <riel@redhat.com>, Hugh Dickins <hughd@google.com>, jingbai.ma@hp.com, kexec@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, lisa.mitchell@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, kumagai-atsushi@mxc.nes.nec.co.jp, "Eric W. Biederman" <ebiederm@xmission.com>, zhangyanfei@cn.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, cpw@sgi.com, vgoyal@redhat.com

(2013/05/16 6:37), KOSAKI Motohiro wrote:
> On Wed, May 15, 2013 at 5:06 AM, HATAYAMA Daisuke
> <d.hatayama@jp.fujitsu.com> wrote:
>> Currently, __find_vmap_area searches for the kernel VM area starting
>> at a given address. This patch changes this behavior so that it
>> searches for the kernel VM area to which the address belongs. This
>> change is needed by remap_vmalloc_range_partial to be introduced in
>> later patch that receives any position of kernel VM area as target
>> address.
>>
>> This patch changes the condition (addr > va->va_start) to the
>> equivalent (addr >= va->va_end) by taking advantage of the fact that
>> each kernel VM area is non-overlapping.
>>
>> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
>> ---
>>
>>   mm/vmalloc.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index d365724..3875fa2 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -292,7 +292,7 @@ static struct vmap_area *__find_vmap_area(unsigned long addr)
>>                  va = rb_entry(n, struct vmap_area, rb_node);
>>                  if (addr < va->va_start)
>>                          n = n->rb_left;
>> -               else if (addr > va->va_start)
>> +               else if (addr >= va->va_end)
>>                          n = n->rb_right;
>
> OK. This is natural definition. Looks good.
>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks for your reviewing. Could you or other someone review the next 
5/8 patch too? It also changes vmalloc and cc people's review is needed.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
