Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC236B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 10:21:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m5so76372724pfc.1
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 07:21:17 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0081.outbound.protection.outlook.com. [104.47.32.81])
        by mx.google.com with ESMTPS id k124si23134148pgc.159.2017.06.02.07.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 07:21:16 -0700 (PDT)
Subject: Re: strange PAGE_ALLOC_COSTLY_ORDER usage in xgbe_map_rx_buffer
References: <20170531160422.GW27783@dhcp22.suse.cz>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4b894f15-6876-8598-def5-8113df836750@amd.com>
Date: Fri, 2 Jun 2017 09:20:54 -0500
MIME-Version: 1.0
In-Reply-To: <20170531160422.GW27783@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 5/31/2017 11:04 AM, Michal Hocko wrote:
> Hi Tom,

Hi Michal,

> I have stumbled over the following construct in xgbe_map_rx_buffer
> 	order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
> which looks quite suspicious. Why does it PAGE_ALLOC_COSTLY_ORDER - 1?
> And why do you depend on PAGE_ALLOC_COSTLY_ORDER at all?
> 

The driver tries to allocate a number of pages to be used as receive
buffers.  Based on what I could find in documentation, the value of
PAGE_ALLOC_COSTLY_ORDER is the point at which order allocations
(could) get expensive.  So I decrease by one the order requested. The
max_t test is just to insure that in case PAGE_ALLOC_COSTLY_ORDER ever
gets defined as 0, 0 would be used.

I believe there have been some enhancements relative to speed in
allocating 0-order pages recently that may make this unnecessary. I
haven't run any performance tests yet to determine if I can just go to
a 0-order allocation, though.

Thanks,
Tom

> Thanks!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
