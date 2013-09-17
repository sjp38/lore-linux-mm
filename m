From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v5 3/4] mm/vmalloc: revert "mm/vmalloc.c: check
 VM_UNINITIALIZED flag in s_show instead of show_numa_info"
Date: Tue, 17 Sep 2013 14:06:37 +0800
Message-ID: <34632.5877974325$1379398019@news.gmane.org>
References: <1379202342-23140-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1379202342-23140-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <523776D4.4070402@jp.fujitsu.com>
 <52379fe8.c250e00a.63fd.ffff8ccdSMTPIN_ADDED_BROKEN@mx.google.com>
 <CAHGf_=oqB-WfYansyoGb3E+Rs9z4aK2N7+m8jTyobgRUoD=LpA@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VLoR0-00049J-4r
	for glkm-linux-mm-2@m.gmane.org; Tue, 17 Sep 2013 08:06:50 +0200
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 442716B0037
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 02:06:48 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 16:06:45 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id F3F842CE8051
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 16:06:42 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8H5oAB360752028
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:50:13 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8H66dbV026832
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 16:06:40 +1000
Content-Disposition: inline
In-Reply-To: <CAHGf_=oqB-WfYansyoGb3E+Rs9z4aK2N7+m8jTyobgRUoD=LpA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "iamjoonsoo.kim" <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, zhangyanfei@cn.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi KOSAKI,
On Tue, Sep 17, 2013 at 01:44:04AM -0400, KOSAKI Motohiro wrote:
>On Mon, Sep 16, 2013 at 8:18 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> Hi KOSAKI,
>> On Mon, Sep 16, 2013 at 05:23:32PM -0400, KOSAKI Motohiro wrote:
>>>On 9/14/2013 7:45 PM, Wanpeng Li wrote:
>>>> Changelog:
>>>>  *v2 -> v3: revert commit d157a558 directly
>>>>
>>>> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
>>>> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
>>>> accessing the pages field with unallocated page when show_numa_info() is
>>>> called. This patch move the check just before show_numa_info in order that
>>>> some messages still can be dumped via /proc/vmallocinfo. This patch revert
>>>> commit d157a558 (mm/vmalloc.c: check VM_UNINITIALIZED flag in s_show instead
>>>> of show_numa_info);
>>>
>>>Both d157a558 and your patch don't explain why your one is better. Yes, some
>>>messages _can_ be dumped. But why should we do so?
>>
>> More messages can be dumped and original commit f5252e00(mm: avoid null pointer
>> access in vm_struct via /proc/vmallocinfo) do that.
>>
>>>And No. __get_vm_area_node() doesn't use __GFP_ZERO for allocating vm_area_struct.
>>>dumped partial dump is not only partial, but also may be garbage.
>>
>> vm_struct is allocated by kzalloc_node.
>
>Oops, you are right. Then, your code _intentionally_ show amazing
>zero. Heh, nice.
>More message is pointless. zero is just zero. It doesn't have any information.
>

After PATCH 4/4 applied, there is a check: 

if (!(va->flags & VM_VM_AREA))
	return 0;

- show vm_struct information between insert_vmap_area and setup_vmalloc_vm.

  Nothing will be dumped since the check mentioned above. 

- show vm_struct information between setup_vmalloc_vm and vm_struct
  fully populated.

  The fields initialized in setup_vmalloc_vm will be dumped correctly and 
  other uninitialized fields of vm_struct won't be dumped instead of dump 
  zero as you mentioned since there is check like v->caller, v->nr_pages 
  in s_show.

Regards,
Wanpeng Li 

>
>>>I wonder why we need to call setup_vmalloc_vm() _after_ insert_vmap_area.
>>
>> I think it's another topic.
>
>Why?
>
>
>> Fill vm_struct and set VM_VM_AREA flag. If I misunderstand your
>> question?
>
>VM_VM_AREA doesn't help. we have race between insert_vmap_area and
>setup_vmalloc_vm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
