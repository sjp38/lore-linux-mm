Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id CFC2D6B009D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 16:32:44 -0500 (EST)
Message-ID: <4F03739F.4080000@ah.jp.nec.com>
Date: Tue, 03 Jan 2012 16:31:11 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] pagemap: avoid splitting thp when reading /proc/pid/pagemap
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com> <4EFD3266.4080701@gmail.com> <4F035FF6.7020206@ah.jp.nec.com> <4F036DD4.2060709@jp.fujitsu.com>
In-Reply-To: <4F036DD4.2060709@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: kosaki.motohiro@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, andi@firstfloor.org, fengguang.wu@intel.com, aarcange@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org

(1/3/2012 16:06), KOSAKI Motohiro wrote:
> On 1/3/2012 3:07 PM, Naoya Horiguchi wrote:
>> On Thu, Dec 29, 2011 at 10:39:18PM -0500, KOSAKI Motohiro wrote:
>> ...
>>>> --- 3.2-rc5.orig/fs/proc/task_mmu.c
>>>> +++ 3.2-rc5/fs/proc/task_mmu.c
>>>> @@ -600,6 +600,9 @@ struct pagemapread {
>>>>   	u64 *buffer;
>>>>   };
>>>>
>>>> +#define PAGEMAP_WALK_SIZE	(PMD_SIZE)
>>>> +#define PAGEMAP_WALK_MASK	(PMD_MASK)
>>>> +
>>>>   #define PM_ENTRY_BYTES      sizeof(u64)
>>>>   #define PM_STATUS_BITS      3
>>>>   #define PM_STATUS_OFFSET    (64 - PM_STATUS_BITS)
>>>> @@ -658,6 +661,22 @@ static u64 pte_to_pagemap_entry(pte_t pte)
>>>>   	return pme;
>>>>   }
>>>>
>>>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>>> +static u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
>>>> +{
>>>> +	u64 pme = 0;
>>>> +	if (pte_present(pte))
>>>
>>> When does pte_present() return 0?
>>
>> It does when the page pointed to by pte is swapped-out, under page migration,
>> or HWPOISONed. But currenly it can't happen on thp because thp will be
>> splitted before these operations are processed.
>> So this if-sentense is not necessary for now, but I think it's not a bad idea
>> to put it now to prepare for future implementation.
> 
> You certainly need to add a comment. otherwise you add *unnecessary* complexity
> and people is going to be puzzled.

OK, I care about that.
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
