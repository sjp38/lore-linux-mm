From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] mm/hwpoison: fix miss catch transparent huge page
Date: Tue, 3 Sep 2013 07:31:39 +0800
Message-ID: <22371.9355919913$1378164725@news.gmane.org>
References: <1378125224-12794-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378125224-12794-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <1378146860-wzqztoop-mutt-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VGdb9-0005x3-Iy
	for glkm-linux-mm-2@m.gmane.org; Tue, 03 Sep 2013 01:31:55 +0200
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5BA1B6B0032
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 19:31:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 3 Sep 2013 04:52:29 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 8D0901258051
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 05:01:40 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r82NVdV939846098
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 05:01:41 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r82NVe42011798
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 05:01:41 +0530
Content-Disposition: inline
In-Reply-To: <1378146860-wzqztoop-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Naoya,
On Mon, Sep 02, 2013 at 02:34:20PM -0400, Naoya Horiguchi wrote:
>On Mon, Sep 02, 2013 at 08:33:42PM +0800, Wanpeng Li wrote:
>> PageTransHuge() can't guarantee the page is transparent huge page since it 
>> return true for both transparent huge and hugetlbfs pages. This patch fix 
>> it by check the page is also !hugetlbfs page.
>> 
>> Before patch:
>> 
>> [  121.571128] Injecting memory failure at pfn 23a200
>> [  121.571141] MCE 0x23a200: huge page recovery: Delayed
>> [  140.355100] MCE: Memory failure is now running on 0x23a200
>> 
>> After patch:
>> 
>> [   94.290793] Injecting memory failure at pfn 23a000
>> [   94.290800] MCE 0x23a000: huge page recovery: Delayed
>> [  105.722303] MCE: Software-unpoisoned page 0x23a000
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>PageTransHuge doesn't care about hugetlbfs at all, assuming that it
>shouldn't be called hugetlbfs context as commented.
>
>  /*                                                                    
>   * PageHuge() only returns true for hugetlbfs pages, but not for      
>   * normal or transparent huge pages.                                  
>   *                                                                    
>   * PageTransHuge() returns true for both transparent huge and         
>   * hugetlbfs pages, but not normal pages. PageTransHuge() can only be 
>   * called only in the core VM paths where hugetlbfs pages can't exist.
>   */
>  static inline int PageTransHuge(struct page *page)
>
>I think it's for the ultra optimization of thp, so we can't change that.
>So we need to follow the pattern whenever possible.
>
>  if (PageHuge) {
>    hugetlb specific code
>  } else if (PageTransHuge) {
>    thp specific code
>  }
>  normal page code / common code
>
>> ---
>>  mm/memory-failure.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index e28ee77..b114570 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -1349,7 +1349,7 @@ int unpoison_memory(unsigned long pfn)
>>  	 * worked by memory_failure() and the page lock is not held yet.
>>  	 * In such case, we yield to memory_failure() and make unpoison fail.
>>  	 */
>> -	if (PageTransHuge(page)) {
>> +	if (PageTransHuge(page) && !PageHuge(page)) {
>>  		pr_info("MCE: Memory failure is now running on %#lx\n", pfn);
>>  			return 0;
>>  	}
>
>I think that we can effectively follow the above pattern by reversing
>these two checks.

Ok, I will do it this way. 
Btw, thanks for your review the patchset. ;-)

Regards,
Wanpeng Li 

>
>Thanks,
>Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
