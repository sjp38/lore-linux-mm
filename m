Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C32E76B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:45:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so85411800pfx.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 07:45:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qy6si48867129pab.154.2016.08.10.07.45.13
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 07:45:13 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 11/11] mm, THP, swap: Delay splitting THP during swap out
References: <01f101d1f2da$5e943aa0$1bbcafe0$@alibaba-inc.com>
	<01f201d1f2dc$bd43f750$37cbe5f0$@alibaba-inc.com>
	<01f301d1f2dd$78df7660$6a9e6320$@alibaba-inc.com>
Date: Wed, 10 Aug 2016 07:45:05 -0700
In-Reply-To: <01f301d1f2dd$78df7660$6a9e6320$@alibaba-inc.com> (Hillf Danton's
	message of "Wed, 10 Aug 2016 16:01:59 +0800")
Message-ID: <87eg5w3cpa.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Huang Ying' <ying.huang@intel.com>, linux-mm@kvack.org

Hi, Hill,

Thanks for comments!

Hillf Danton <hillf.zj@alibaba-inc.com> writes:

>> 
>> @@ -187,6 +221,14 @@ int add_to_swap(struct page *page, struct list_head *list)
>>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
>> 
>> +	if (unlikely(PageTransHuge(page))) {
>> +		err = add_to_swap_trans_huge(page, list);
>> +		if (err < 0)
>> +			return 0;
>> +		else if (err > 0)
>> +			return err;
>> +		/* fallback to split firstly if return 0 */
>
> switch (err) and add vm event count according to the meaning of err?

Yes.  switch(err) looks better, I will change it.

For vm event, I found for now there are only two vm event for swap:
PSWPIN and PSWPOUT.  There are counted when page and read from or write
to the block device.  So I think we have no existing vm event to count
here.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
