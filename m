Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id ED45C6B004D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:38:34 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 13:24:53 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A2CEA3578051
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 13:38:30 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7R3cJuS60555330
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 13:38:19 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7R3cTn8030983
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 13:38:30 +1000
Date: Tue, 27 Aug 2013 11:38:27 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Message-ID: <20130827033827.GA17397@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Naoya,
On Mon, Aug 26, 2013 at 11:28:16PM -0400, Naoya Horiguchi wrote:
>On Tue, Aug 27, 2013 at 10:39:31AM +0800, Wanpeng Li wrote:
>> The return value outside for loop is always zero which means madvise_hwpoison 
>> return success, however, this is not truth for soft_offline_page w/ failure
>> return value.
>
>I don't understand what you want to do for what reason. Could you clarify
>those?

int ret is defined in two place in madvise_hwpoison. One is out of for
loop and its value is always zero(zero means success for madvise), the 
other one is in for loop. The soft_offline_page function maybe return 
-EBUSY and break, however, the ret out of for loop is return which means 
madvise_hwpoison success. 

Regards,
Wanpeng Li 

>
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/madvise.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index a20764c..19b71e4 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -359,7 +359,7 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
>>  				page_to_pfn(p), start);
>>  			ret = soft_offline_page(p, MF_COUNT_INCREASED);
>>  			if (ret)
>> -				break;
>> +				return ret;
>>  			continue;
>>  		}
>>  		pr_info("Injecting memory failure for page %#lx at %#lx\n",
>
>This seems to introduce no behavioral change.
>
>Thanks,
>Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
