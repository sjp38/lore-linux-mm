Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 809356B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 01:44:26 -0400 (EDT)
Received: by mail-ea0-f182.google.com with SMTP id o10so2516552eaj.27
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 22:44:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52379fe8.c250e00a.63fd.ffff8ccdSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <523776D4.4070402@jp.fujitsu.com> <52379fe8.c250e00a.63fd.ffff8ccdSMTPIN_ADDED_BROKEN@mx.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 17 Sep 2013 01:44:04 -0400
Message-ID: <CAHGf_=oqB-WfYansyoGb3E+Rs9z4aK2N7+m8jTyobgRUoD=LpA@mail.gmail.com>
Subject: Re: [RESEND PATCH v5 3/4] mm/vmalloc: revert "mm/vmalloc.c: check
 VM_UNINITIALIZED flag in s_show instead of show_numa_info"
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, zhangyanfei@cn.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 8:18 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> Hi KOSAKI,
> On Mon, Sep 16, 2013 at 05:23:32PM -0400, KOSAKI Motohiro wrote:
>>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>>> Changelog:
>>>  *v2 -> v3: revert commit d157a558 directly
>>>
>>> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
>>> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
>>> accessing the pages field with unallocated page when show_numa_info() is
>>> called. This patch move the check just before show_numa_info in order that
>>> some messages still can be dumped via /proc/vmallocinfo. This patch revert
>>> commit d157a558 (mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead
>>> of show_numa_info);
>>
>>Both d157a558 and your patch don't explain why your one is better. Yes, some
>>messages _can_ be dumped. But why should we do so?
>
> More messages can be dumped and original commit f5252e00(mm: avoid null pointer
> access in vm_struct via /proc/vmallocinfo) do that.
>
>>And No. __get_vm_area_node() doesn't use __GFP_ZERO for allocating vm_area_struct.
>>dumped partial dump is not only partial, but also may be garbage.
>
> vm_struct is allocated by kzalloc_node.

Oops, you are right. Then, your code _intentionally_ show amazing
zero. Heh, nice.
More message is pointless. zero is just zero. It doesn't have any information.


>>I wonder why we need to call setup_vmalloc_vm() _after_ insert_vmap_area.
>
> I think it's another topic.

Why?


> Fill vm_struct and set VM_VM_AREA flag. If I misunderstand your
> question?

VM_VM_AREA doesn't help. we have race between insert_vmap_area and
setup_vmalloc_vm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
