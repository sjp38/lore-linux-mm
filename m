Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 9277B6B004A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 01:58:36 -0400 (EDT)
Received: by lbbgp10 with SMTP id gp10so3765648lbb.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 22:58:34 -0700 (PDT)
Message-ID: <4F8E5807.6080909@openvz.org>
Date: Wed, 18 Apr 2012 09:58:31 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH linux-next] mm/hugetlb: fix warning in alloc_huge_page/dequeue_huge_page_vma
References: <20120417122819.7438.26117.stgit@zurg> <20120417135726.05de2546.akpm@linux-foundation.org>
In-Reply-To: <20120417135726.05de2546.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Andrew Morton wrote:
> On Tue, 17 Apr 2012 16:28:19 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This patch fixes gcc warning (and bug?) introduced in linux-next commit cc9a6c877
>> ("cpuset: mm: reduce large amounts of memory barrier related damage v3")
>>
>> Local variable "page" can be uninitialized if nodemask from vma policy does not
>> intersects with nodemask from cpuset. Even if it wouldn't happens it's better to
>> initialize this variable explicitly than to introduce kernel oops on weird corner case.
>>
>> mm/hugetlb.c: In function ___alloc_huge_page___:
>> mm/hugetlb.c:1135:5: warning: ___page___ may be used uninitialized in this function
>>
>> ...
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -532,7 +532,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>>   				struct vm_area_struct *vma,
>>   				unsigned long address, int avoid_reserve)
>>   {
>> -	struct page *page;
>> +	struct page *page = NULL;
>>   	struct mempolicy *mpol;
>>   	nodemask_t *nodemask;
>>   	struct zonelist *zonelist;
>
> hm, that's a pretty blatant use-uninitialised bug.  I wonder why so few
> gcc versions report it.  Mine doesn't.

I'm using latest gcc-4.7

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
