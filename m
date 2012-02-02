Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7A4F16B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 00:23:06 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 2 Feb 2012 06:14:42 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q125JrPx1048582
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 16:19:56 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q125Jraj015183
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 16:19:53 +1100
Message-ID: <4F2A1CF7.9020306@linux.vnet.ibm.com>
Date: Thu, 02 Feb 2012 13:19:51 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] hugetlb: try to search again if it is really needed
References: <4F101904.8090405@linux.vnet.ibm.com> <4F101969.8050601@linux.vnet.ibm.com> <20120201144353.7c75b5b6.akpm@linux-foundation.org>
In-Reply-To: <20120201144353.7c75b5b6.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,

Thanks for your review!

On 02/02/2012 06:43 AM, Andrew Morton wrote:

> On Fri, 13 Jan 2012 19:45:45 +0800
> Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com> wrote:
> 
>> Search again only if some holes may be skipped in the first time
>>
>> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>> ---
>>  arch/x86/mm/hugetlbpage.c |    8 ++++----
>>  1 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
>> index e12debc..6bf5735 100644
>> --- a/arch/x86/mm/hugetlbpage.c
>> +++ b/arch/x86/mm/hugetlbpage.c
>> @@ -309,9 +309,8 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
>>  	struct hstate *h = hstate_file(file);
>>  	struct mm_struct *mm = current->mm;
>>  	struct vm_area_struct *vma;
>> -	unsigned long base = mm->mmap_base, addr = addr0;
>> +	unsigned long base = mm->mmap_base, addr = addr0, start_addr;
> 
> grr.  The multiple-definitions-per-line thing is ugly, makes for more
> patch conflicts and reduces opportunities to add useful comments.


Yes, thanks.

>>  try_again:
>> +	start_addr = mm->free_area_cache;
>> +
>>  	/* make sure it can fit in the remaining address space */
>>  	if (mm->free_area_cache < len)
>>  		goto fail;
>> @@ -357,10 +358,9 @@ fail:
>>  	 * if hint left us with no space for the requested
>>  	 * mapping then try again:
>>  	 */
>> -	if (first_time) {
>> +	if (start_addr != base) {
>>  		mm->free_area_cache = base;
>>  		largest_hole = 0;
>> -		first_time = 0;
>>  		goto try_again;
> 
> The code used to retry a single time.  With this change the retrying is
> potentially infinite.  What is the reason for this change?  What is the
> potential for causing a lockup?
> 

Actually, it is not infinite, after retry, we set "mm->free_area_cache = base",
"start_addr" will set to "base" in the second search, so the condition of
"goto try_again" will be unsatisfied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
