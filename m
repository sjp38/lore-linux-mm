From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] mm/vmalloc: move VM_UNINITIALIZED just before
 show_numa_info
Date: Tue, 3 Sep 2013 14:00:55 +0800
Message-ID: <45469.4148189903$1378188076@news.gmane.org>
References: <1378177220-26218-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378177220-26218-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <5225765E.8000402@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VGjfm-0005T6-SW
	for glkm-linux-mm-2@m.gmane.org; Tue, 03 Sep 2013 08:01:07 +0200
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id F3CEE6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 02:01:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 11:20:24 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id AEC1B394004D
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 11:30:46 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8360tUM42926228
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 11:30:56 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8360u27010201
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 11:30:57 +0530
Content-Disposition: inline
In-Reply-To: <5225765E.8000402@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 03, 2013 at 01:40:46PM +0800, Zhang Yanfei wrote:
>On 09/03/2013 11:00 AM, Wanpeng Li wrote:
>> The VM_UNINITIALIZED/VM_UNLIST flag introduced by commit f5252e00(mm: avoid
>> null pointer access in vm_struct via /proc/vmallocinfo) is used to avoid
>> accessing the pages field with unallocated page when show_numa_info() is
>> called. This patch move the check just before show_numa_info in order that
>> some messages still can be dumped via /proc/vmallocinfo.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Hmmm, sorry again. Please revert commit
>d157a55815ffff48caec311dfb543ce8a79e283e. That said, we could still
>do the check in show_numa_info like before.
>

Ok.

Regards,
Wanpeng Li 

>> ---
>>  mm/vmalloc.c |   10 +++++-----
>>  1 files changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index e3ec8b4..c4720cd 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -2590,11 +2590,6 @@ static int s_show(struct seq_file *m, void *p)
>>  
>>  	v = va->vm;
>>  
>> -	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
>> -	smp_rmb();
>> -	if (v->flags & VM_UNINITIALIZED)
>> -		return 0;
>> -
>>  	seq_printf(m, "0x%pK-0x%pK %7ld",
>>  		v->addr, v->addr + v->size, v->size);
>>  
>> @@ -2622,6 +2617,11 @@ static int s_show(struct seq_file *m, void *p)
>>  	if (v->flags & VM_VPAGES)
>>  		seq_printf(m, " vpages");
>>  
>> +	/* Pair with smp_wmb() in clear_vm_uninitialized_flag() */
>> +	smp_rmb();
>> +	if (v->flags & VM_UNINITIALIZED)
>> +		return 0;
>> +
>>  	show_numa_info(m, v);
>>  	seq_putc(m, '\n');
>>  	return 0;
>> 
>
>
>-- 
>Thanks.
>Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
