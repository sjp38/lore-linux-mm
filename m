Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 977AF6B005A
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 04:05:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 17:54:14 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5F87E2CE804C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:05:35 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7R85Gue41615538
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:05:24 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7R85QHg001034
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:05:27 +1000
Date: Tue, 27 Aug 2013 16:05:23 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Message-ID: <20130827080523.GA22375@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
 <521c1f3f.813d320a.6ba7.5a17SMTPIN_ADDED_BROKEN@mx.google.com>
 <1377574896-5k1diwl4-mutt-n-horiguchi@ah.jp.nec.com>
 <20130827073701.GA23035@gchen.bj.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130827073701.GA23035@gchen.bj.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Chen,
On Tue, Aug 27, 2013 at 03:37:01AM -0400, Chen Gong wrote:
>On Mon, Aug 26, 2013 at 11:41:36PM -0400, Naoya Horiguchi wrote:
>> Date: Mon, 26 Aug 2013 23:41:36 -0400
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen
>>  <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck
>>  <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org,
>>  linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of
>>  madvise_hwpoison
>> User-Agent: Mutt 1.5.21 (2010-09-15)
>> 
>> On Tue, Aug 27, 2013 at 11:38:27AM +0800, Wanpeng Li wrote:
>> > Hi Naoya,
>> > On Mon, Aug 26, 2013 at 11:28:16PM -0400, Naoya Horiguchi wrote:
>> > >On Tue, Aug 27, 2013 at 10:39:31AM +0800, Wanpeng Li wrote:
>> > >> The return value outside for loop is always zero which means madvise_hwpoison 
>> > >> return success, however, this is not truth for soft_offline_page w/ failure
>> > >> return value.
>> > >
>> > >I don't understand what you want to do for what reason. Could you clarify
>> > >those?
>> > 
>> > int ret is defined in two place in madvise_hwpoison. One is out of for
>> > loop and its value is always zero(zero means success for madvise), the 
>> > other one is in for loop. The soft_offline_page function maybe return 
>> > -EBUSY and break, however, the ret out of for loop is return which means 
>> > madvise_hwpoison success. 
>> 
>> Oh, I see. Thanks.
>> 
>I don't think such change is a good idea. The original code is obviously
>easy to confuse people. Why not removing redundant local variable?
>

I think the trick here is get_user_pages_fast will return the number of
pages pinned. It is always 1 in madvise_hwpoison, the return value of
memory_failure is ignored. Therefore we still need to reset ret to 0
before return madvise_hwpoison.

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
