Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 025976B0185
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:49:05 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so5062406vbb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:49:05 -0800 (PST)
Message-ID: <4EE6145C.9070606@gmail.com>
Date: Mon, 12 Dec 2011 09:49:00 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: simplify find_vma_prev
References: <1323466526.27746.29.camel@joe2Laptop> <1323470921-12931-1-git-send-email-kosaki.motohiro@gmail.com> <20111212132616.GB15249@tiehlicka.suse.cz>
In-Reply-To: <20111212132616.GB15249@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Shaohua Li <shaohua.li@intel.com>

(12/12/11 8:26 AM), Michal Hocko wrote:
> On Fri 09-12-11 17:48:40, kosaki.motohiro@gmail.com wrote:
>> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>>
>> commit 297c5eee37 (mm: make the vma list be doubly linked) added
>> vm_prev member into vm_area_struct. Therefore we can simplify
>> find_vma_prev() by using it. Also, this change help to improve
>> page fault performance because it has strong locality of reference.
>>
>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>> ---
>>   mm/mmap.c |   36 ++++++++----------------------------
>>   1 files changed, 8 insertions(+), 28 deletions(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index eae90af..b9c0241 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1603,39 +1603,19 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>>
>>   EXPORT_SYMBOL(find_vma);
>>
>> -/* Same as find_vma, but also return a pointer to the previous VMA in *pprev. */
>> +/*
>> + * Same as find_vma, but also return a pointer to the previous VMA in *pprev.
>> + * Note: pprev is set to NULL when return value is NULL.
>> + */
>>   struct vm_area_struct *
>>   find_vma_prev(struct mm_struct *mm, unsigned long addr,
>>   			struct vm_area_struct **pprev)
>>   {
>> -	struct vm_area_struct *vma = NULL, *prev = NULL;
>> -	struct rb_node *rb_node;
>> -	if (!mm)
>> -		goto out;
>> -
>> -	/* Guard against addr being lower than the first VMA */
>> -	vma = mm->mmap;
>
> Why have you removed this guard? Previously we had pprev==NULL and
> returned mm->mmap.
> This seems like a semantic change without any explanation. Could you
> clarify?

IIUC, find_vma_prev() is module unexported and none of known caller use
pprev==NULL. Thus, I thought it can be also simplified. Am I missing 
something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
