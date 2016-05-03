Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id BAAA06B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 05:14:31 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so18610584pac.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 02:14:31 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fv2si3504978pad.86.2016.05.03.02.14.30
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 02:14:30 -0700 (PDT)
Subject: Re: [RFC PATCH] swap: choose swap device according to numa node
References: <20160429083408.GA20728@aaronlu.sh.intel.com>
 <045D8A5597B93E4EBEDDCBF1FC15F509359EAF8F@fmsmsx104.amr.corp.intel.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <dffa3c90-1b2d-b63e-abd1-b6b959fe23db@intel.com>
Date: Tue, 3 May 2016 17:14:29 +0800
MIME-Version: 1.0
In-Reply-To: <045D8A5597B93E4EBEDDCBF1FC15F509359EAF8F@fmsmsx104.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Chen, Tim C" <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>
Cc: "Huang, Ying" <ying.huang@intel.com>

On 04/30/2016 04:25 AM, Chen, Tim C wrote:
> Wonder if choosing the swap device by numa node is the most
> effective way to spread the pages among the swap devices.

The intent of this patch is not to spread the pages among the swap
devices(thus to reduce lock contention on swap device's radix tree),
it's about speed up the IOs :-)

> The speedup comes from spreading the swap activities among
> equal priority swap devices to reduce contention on swap devices.

For v4.5, yes. And for this patch, it also has speed ups by doing IOs
locally.

> If the activities are mostly confined to 1 node, then we still could
> have contention on a device.  

Indeed, but I suppose that would normally happen if people has played
with numactl themselves? Otherwise, the scheduler would probably spread
the threads evenly.

Ying suggests we use a config for people to turn this off in his reply
and I can of course add that.

> An alternative may be we pick another swap device on each
> pass of shrink_page_list  to try to swap pages.

This can be achieved by setting the two swap devices with equal priority
and then the two swap devices will be used round robin. I have already
used it as a comparing config:
throughput of v4.5(swap device with equal priority)

Thanks for the comments!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
