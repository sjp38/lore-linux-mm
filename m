From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Date: Tue, 27 Aug 2013 16:02:29 +0800
Message-ID: <18055.9123204604$1377590756@news.gmane.org>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
 <521c1f3f.813d320a.6ba7.5a17SMTPIN_ADDED_BROKEN@mx.google.com>
 <1377574896-5k1diwl4-mutt-n-horiguchi@ah.jp.nec.com>
 <20130827073701.GA23035@gchen.bj.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VEEHb-0005yb-MD
	for glkm-linux-mm-2@m.gmane.org; Tue, 27 Aug 2013 10:05:47 +0200
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id E2E936B005C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 04:05:45 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 17:58:27 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 147A22BB0055
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:05:41 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7R85UYH8978712
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:05:30 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7R85ecO009154
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 18:05:40 +1000
Content-Disposition: inline
In-Reply-To: <20130827073701.GA23035@gchen.bj.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Chen,
On Tue, Aug 27, 2013 at 03:37:01AM -0400, Chen Gong wrote:
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
