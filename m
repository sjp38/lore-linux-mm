Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 77D4E6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:59:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 13:19:07 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id CBC9FE0058
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 13:29:46 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r837x2Hi45088794
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 13:29:02 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r837x3FI006901
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 13:29:03 +0530
Date: Tue, 3 Sep 2013 15:59:02 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge page
Message-ID: <20130903075902.GA4995@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1378165006-19435-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378165006-19435-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130903031519.GA31018@gchen.bj.intel.com>
 <20130903041858.GA3543@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130903041858.GA3543@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Chen,
On Tue, Sep 03, 2013 at 12:18:58PM +0800, Wanpeng Li wrote:
>On Mon, Sep 02, 2013 at 11:15:19PM -0400, Chen Gong wrote:
>>On Tue, Sep 03, 2013 at 07:36:44AM +0800, Wanpeng Li wrote:
>>> Date: Tue,  3 Sep 2013 07:36:44 +0800
>>> From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>> To: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Andi Kleen <andi@firstfloor.org>, Fengguang Wu
>>>  <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
>>>  Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com,
>>>  linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li
>>>  <liwanp@linux.vnet.ibm.com>
>>> Subject: [PATCH v2 2/4] mm/hwpoison: fix miss catch transparent huge page 
>>> X-Mailer: git-send-email 1.7.5.4
>>> 
>>> Changelog:
>>>  *v1 -> v2: reverse PageTransHuge(page) && !PageHuge(page) check 
>>> 
>>> PageTransHuge() can't guarantee the page is transparent huge page since it 
>>> return true for both transparent huge and hugetlbfs pages. This patch fix 
>>> it by check the page is also !hugetlbfs page.
>>> 
>>> Before patch:
>>> 
>>> [  121.571128] Injecting memory failure at pfn 23a200
>>> [  121.571141] MCE 0x23a200: huge page recovery: Delayed
>>> [  140.355100] MCE: Memory failure is now running on 0x23a200
>>> 
>>> After patch:
>>> 
>>> [   94.290793] Injecting memory failure at pfn 23a000
>>> [   94.290800] MCE 0x23a000: huge page recovery: Delayed
>>> [  105.722303] MCE: Software-unpoisoned page 0x23a000
>>> 
>>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>> ---
>>>  mm/memory-failure.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>> 
>>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>>> index e28ee77..b114570 100644
>>> --- a/mm/memory-failure.c
>>> +++ b/mm/memory-failure.c
>>> @@ -1349,7 +1349,7 @@ int unpoison_memory(unsigned long pfn)
>>>  	 * worked by memory_failure() and the page lock is not held yet.
>>>  	 * In such case, we yield to memory_failure() and make unpoison fail.
>>>  	 */
>>> -	if (PageTransHuge(page)) {
>>> +	if (!PageHuge(page) && PageTransHuge(page)) {
>>>  		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
>>>  			return 0;
>>>  	}
>>
>>Not sure which git tree should be used to apply this patch series? I assume
>>this patch series follows this link: https://lkml.org/lkml/2013/8/26/76.
>>
>
>mmotm tree or linux-next. ;-)
>
>>In unpoison_memory we already have
>>        if (PageHuge(page)) {
>>                ...
>>                return 0;
>>        }
>>so it looks like this patch is redundant.
>
>- Do you aware there is condition before go to this check?
>- Do you also analysis why the check can't catch the hugetlbfs page
>  through the dump information?
>

If I miss something, don't mind to point out. ;-)

Regards,
Wanpeng Li 

>Regards,
>Wanpeng Li 
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
