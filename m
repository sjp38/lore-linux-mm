Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 446956B0038
	for <linux-mm@kvack.org>; Sun, 16 Mar 2014 22:07:43 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so4055640wes.11
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 19:07:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l14si8694622wjq.66.2014.03.16.19.07.40
        for <linux-mm@kvack.org>;
        Sun, 16 Mar 2014 19:07:41 -0700 (PDT)
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140218094920.GB29660@quack.suse.cz> <53034C66.90707@linux.vnet.ibm.com>
From: Madper Xie <cxie@redhat.com>
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu and limit readahead pages
In-reply-to: <53034C66.90707@linux.vnet.ibm.com>
Date: Mon, 17 Mar 2014 10:07:23 +0800
Message-ID: <871ty1zig4.fsf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> writes:

> On 02/18/2014 03:19 PM, Jan Kara wrote:
>> On Tue 18-02-14 12:55:38, Raghavendra K T wrote:
>>> Currently max_sane_readahead() returns zero on the cpu having no local memory node
>>> which leads to readahead failure. Fix the readahead failure by returning
>>> minimum of (requested pages, 512). Users running application on a memory-less cpu
>>> which needs readahead such as streaming application see considerable boost in the
>>> performance.
>>>
>>> Result:
>>> fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
>>> with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.
>>>
>>> fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
>>> 32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
>>> NUMA cases w/ patch.
>>    Can you try one more thing please? Compare startup time of some big
>> executable (Firefox or LibreOffice come to my mind) for the patched and
>> normal kernel on a machine which wasn't hit by this NUMA issue. And don't
>> forget to do "echo 3 >/proc/sys/vm/drop_caches" before each test to flush
>> the caches. If this doesn't show significant differences, I'm OK with the
>> patch.
>>
>
> Thanks Honza, I checked with firefox (starting to particular point)..
> I do not see any difference. Both the case took around 14sec.
>
>   ( some time it is even faster.. may be because we do not do free page 
> calculation?. )
Hi. Just a concern. Will the performance reduce on some special storage
backend? E.g. tape.
The existent applications may using readahead for userspace I/O schedule
to decrease seeking time.
-- 
Thanks,
Madper

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
