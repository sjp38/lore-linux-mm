Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9524C6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:32:45 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 14:32:44 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7B70EC90062
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:32:40 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6BKWePL422812
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:32:40 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6BKWd7L027173
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:32:40 -0400
Message-ID: <4FFDE2E2.7050901@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 15:32:34 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] zsmalloc: remove x86 dependency
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-2-git-send-email-sjenning@linux.vnet.ibm.com> <4FFDC54F.5030402@vflare.org>
In-Reply-To: <4FFDC54F.5030402@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 01:26 PM, Nitin Gupta wrote:
> On 07/02/2012 02:15 PM, Seth Jennings wrote:
>> This patch replaces the page table assisted object mapping
>> method, which has x86 dependencies, with a arch-independent
>> method that does a simple copy into a temporary per-cpu
>> buffer.
>>
>> While a copy seems like it would be worse than mapping the pages,
>> tests demonstrate the copying is always faster and, in the case of
>> running inside a KVM guest, roughly 4x faster.
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zsmalloc/Kconfig         |    4 --
>>  drivers/staging/zsmalloc/zsmalloc-main.c |   99 +++++++++++++++++++++---------
>>  drivers/staging/zsmalloc/zsmalloc_int.h  |    5 +-
>>  3 files changed, 72 insertions(+), 36 deletions(-)
>>
> 
> 
>>  struct mapping_area {
>> -	struct vm_struct *vm;
>> -	pte_t *vm_ptes[2];
>> -	char *vm_addr;
>> +	char *vm_buf; /* copy buffer for objects that span pages */
>> +	char *vm_addr; /* address of kmap_atomic()'ed pages */
>>  };
>>  
> 
> I think we can reduce the copying overhead by not copying an entire
> compressed object to another (per-cpu) buffer. The basic idea of the
> method below is to:
>  - Copy only the amount of data that spills over into the next page
>  - No need for a separate buffer to copy into
> 
> Currently, we store objects that split across pages as:
> 
> +-Page1-+
> |	|
> |	|
> |-------| <-- obj-1 off: 0
> |<ob1'>	|
> +-------+ <-- obj-1 off: s'
> 
> +-Page2-+ <-- obj-1 off: s'
> |<ob1''>|
> |-------| <-- obj-1 off: obj1_size, obj-2 off: 0
> |<ob2>	|
> |-------| <-- obj-2 off: obj2_size
> +-------+
> 
> But now we would store it as:
> 
> +-Page1-+
> |	|
> |-------| <-- obj-1 off: s''
> |	|
> |<ob1'>	|
> +-------+ <-- obj-1 off: obj1_size
> 
> +-Page2-+ <-- obj-1 off: 0
> |<ob1''>|
> |-------| <-- obj-1 off: s'', obj-2 off: 0
> |<ob2>	|
> |-------| <-- obj-2 off: obj2_size
> +-------+
> 
> When object-1 (ob1) is to be mapped, part (size: s'-0) of object-2 will
> be swapped with ob1'. This swapping can be done in-place using simple
> xor swap algorithm. So, after swap, page-1 and page-2 will look like:
> 
> +-Page1-+
> |	|
> |-------| <-- obj-2 off: 0
> |	|
> |<ob2''>|
> +-------+ <-- obj-2 off: (obj1_size - s'')
> 
> +-Page2-+ <-- obj-1 off: 0
> |	|
> |<ob1>	|
> |-------| <-- obj-1 off: obj1_size, obj-2 off: (obj1_size - s'')
> |<ob2'>	|
> +-------+ <-- obj-2 off: obj2_size
> 
> Now obj-1 lies completely within page-2, so can be kmap'ed as usual. On
> zs_unmap_object() we would just do the reverse and restore objects as in
> figure-1.

Hey Nitin, thanks for the feedback.

Correct me if I'm wrong, but it seems like you wouldn't be able to map
ob2 while ob1 was mapped with this design.  You'd need some sort of
zspage level protection against concurrent object mappings.  The
code for that protection might cancel any benefit you would gain by
doing it this way.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
