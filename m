Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD738E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:11:00 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so28998547pgc.22
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:11:00 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id u129si33161097pfu.117.2019.01.03.09.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:10:58 -0800 (PST)
Subject: Re: [v4 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190102230054.m5ire5gdhm5fzecq@ca-dmjordan1.us.oracle.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <76d8727a-77b4-d476-af89-9ae1904ec8cd@linux.alibaba.com>
Date: Thu, 3 Jan 2019 09:10:13 -0800
MIME-Version: 1.0
In-Reply-To: <20190102230054.m5ire5gdhm5fzecq@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/2/19 3:00 PM, Daniel Jordan wrote:
> On Sun, Dec 30, 2018 at 12:49:34PM +0800, Yang Shi wrote:
>> The test on my virtual machine with congested HDD shows long tail
>> latency is reduced significantly.
>>
>> Without the patch
>>   page_fault1_thr-1490  [023]   129.311706: funcgraph_entry:      #57377.796 us |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.369103: funcgraph_entry:        5.642us   |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.369119: funcgraph_entry:      #1289.592 us |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.370411: funcgraph_entry:        4.957us   |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.370419: funcgraph_entry:        1.940us   |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.378847: funcgraph_entry:      #1411.385 us |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.380262: funcgraph_entry:        3.916us   |  do_swap_page();
>>   page_fault1_thr-1490  [023]   129.380275: funcgraph_entry:      #4287.751 us |  do_swap_page();
>>
>> With the patch
>>        runtest.py-1417  [020]   301.925911: funcgraph_entry:      #9870.146 us |  do_swap_page();
>>        runtest.py-1417  [020]   301.935785: funcgraph_entry:        9.802us   |  do_swap_page();
>>        runtest.py-1417  [020]   301.935799: funcgraph_entry:        3.551us   |  do_swap_page();
>>        runtest.py-1417  [020]   301.935806: funcgraph_entry:        2.142us   |  do_swap_page();
>>        runtest.py-1417  [020]   301.935853: funcgraph_entry:        6.938us   |  do_swap_page();
>>        runtest.py-1417  [020]   301.935864: funcgraph_entry:        3.765us   |  do_swap_page();
>>        runtest.py-1417  [020]   301.935871: funcgraph_entry:        3.600us   |  do_swap_page();
>>        runtest.py-1417  [020]   301.935878: funcgraph_entry:        7.202us   |  do_swap_page();
> Hi Yang, I guess runtest.py just calls page_fault1_thr?  Being explicit about

Yes, runtest.py is the wrapper script of will-it-scale.

> this may improve the changelog for those unfamiliar with will-it-scale.

Sure.

>
> May also be useful to name will-it-scale and how it was run (#thr, runtime,
> system cpus/memory/swap) for more context.

How about the below description:

The test with page_fault1 of will-it-scale (sometimes tracing may just 
show runtest.py that is the wrapper script of page_fault1), which 
basically launches NR_CPU threads to generate 128MB anonymous pages for 
each thread,  on my virtual machine with congested HDD shows long tail 
latency is reduced significantly.

Without the patch
  page_fault1_thr-1490  [023]   129.311706: funcgraph_entry: #57377.796 
us |  do_swap_page();
  page_fault1_thr-1490  [023]   129.369103: funcgraph_entry: 5.642us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.369119: funcgraph_entry: #1289.592 
us |  do_swap_page();
  page_fault1_thr-1490  [023]   129.370411: funcgraph_entry: 4.957us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.370419: funcgraph_entry: 1.940us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.378847: funcgraph_entry: #1411.385 
us |  do_swap_page();
  page_fault1_thr-1490  [023]   129.380262: funcgraph_entry: 3.916us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.380275: funcgraph_entry: #4287.751 
us |  do_swap_page();

With the patch
       runtest.py-1417  [020]   301.925911: funcgraph_entry: #9870.146 
us |  do_swap_page();
       runtest.py-1417  [020]   301.935785: funcgraph_entry: 9.802us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935799: funcgraph_entry: 3.551us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935806: funcgraph_entry: 2.142us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935853: funcgraph_entry: 6.938us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935864: funcgraph_entry: 3.765us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935871: funcgraph_entry: 3.600us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935878: funcgraph_entry: 7.202us   
|  do_swap_page();


Thanks,
Yang
