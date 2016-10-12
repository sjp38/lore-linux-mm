Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5AE6B0253
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:24:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so35954236pfg.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:24:50 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id l1si6773548pay.187.2016.10.12.01.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 01:24:49 -0700 (PDT)
Subject: Re: OOM in v4.8
References: <20161012065423.GA16092@aaronlu.sh.intel.com>
 <20161012074411.GA9523@dhcp22.suse.cz>
 <20161012080022.GA17128@dhcp22.suse.cz>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <24ea68df-8b6c-5319-a8ef-9c4f237cfc2a@intel.com>
Date: Wed, 12 Oct 2016 16:24:47 +0800
MIME-Version: 1.0
In-Reply-To: <20161012080022.GA17128@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, lkp@01.org, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/12/2016 04:00 PM, Michal Hocko wrote:
> On Wed 12-10-16 09:44:11, Michal Hocko wrote:
>> [Let's CC Vlastimil]
>>
>> On Wed 12-10-16 14:54:23, Aaron Lu wrote:
>>> Hello,
>>>
>>> There is a chromeswap test case:
>>> https://chromium.googlesource.com/chromiumos/third_party/autotest/+/master/client/site_tests/platform_CompressedSwapPerf
>>>
>>> We have done small changes and ported it to our LKP environment:
>>> https://github.com/aaronlu/chromeswap
>>>
>>> The test starts nr_procs processes and let them each allocate some
>>> memory equally with realloc, so anonymous pages are used. When the
>>> pre-specified swap_target is reached, the allocation will stop. The
>>> total allocation size is: MemFree + swap_target * SwapTotal.
>>> After allocation, a random process is selected to touch its memory to
>>> trigger swap in/out.
>>>
>>> For this test, nr_procs is 50 and swap_target is 50%.
>>> The test box has 8G memory where 4G is used as a pmem block device and
>>> created as the swap partition.
>>>
>>> There is OOM occured for this test recently so I did more tests:
>>> on v4.6, 10 tests all pass;
>>> on v4.7, 2 tests OOMed out of 10 tests;
>>> on v4.8, 6 tests OOMed out of 10 tests;
>>> on 101105b1717f, which is yersterday's Linus' master branch head,
>>> 1 test OOMed out of 10 tests.
>>
>> Could you try to retest with the current linux-next please?
> 
> And I am obviously blind because you have already tested with
> 101105b1717f which contains the Andrew patchbomb and so all the relevant
> changes. Now that I am lookinig into your log for that kernel there
> doesn't seem to be any OOM killer invocation. There is only
> kern  :warn  : [  177.175954] perf: page allocation failure: order:2, mode:0x208c020(GFP_ATOMIC|__GFP_COMP|__GFP_ZERO)

Oh right, perf may fail but that shouldn't make the test be terminated.
I'll need to check why OOM is marked for that test.

Another possibility is, OOM occurred later when the chromeswap test is
requesting memory but for some reason, the log isn't properly saved.

> 
> which is an atomic high order request that failed which is not all that
> unexpected when the system is low on memory. The allocation failure
> report is hard to read because of unexpected end-of-lines but I suspect

Sorry about that, I'll try to find out why dmesg is saved so ugly on
that test box.

> that again we are not able to allocate because of the CMA standing in
> the way. I wouldn't call the above failure critical though.
 
I'll test that commit and v4.8 again with cma=0 added to cmdline.

Thanks for taking a look at this.

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
