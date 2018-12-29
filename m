Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91DA28E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 20:41:10 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so19459383pll.0
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:41:10 -0800 (PST)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id bg9si36805767plb.317.2018.12.28.17.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 17:41:09 -0800 (PST)
Subject: Re: [v3 PATCH 1/2] mm: swap: check if swap backing device is
 congested or not
References: <1545428420-126557-1-git-send-email-yang.shi@linux.alibaba.com>
 <20181228164246.4867201125a2123c8f6a6f9c@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <453db4f7-cff9-c3ec-4b37-3669ab85016f@linux.alibaba.com>
Date: Fri, 28 Dec 2018 17:41:01 -0800
MIME-Version: 1.0
In-Reply-To: <20181228164246.4867201125a2123c8f6a6f9c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ying.huang@intel.com, tim.c.chen@intel.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/28/18 4:42 PM, Andrew Morton wrote:
> On Sat, 22 Dec 2018 05:40:19 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> Swap readahead would read in a few pages regardless if the underlying
>> device is busy or not.  It may incur long waiting time if the device is
>> congested, and it may also exacerbate the congestion.
>>
>> Use inode_read_congested() to check if the underlying device is busy or
>> not like what file page readahead does.  Get inode from swap_info_struct.
>> Although we can add inode information in swap_address_space
>> (address_space->host), it may lead some unexpected side effect, i.e.
>> it may break mapping_cap_account_dirty().  Using inode from
>> swap_info_struct seems simple and good enough.
>>
>> Just does the check in vma_cluster_readahead() since
>> swap_vma_readahead() is just used for non-rotational device which
>> much less likely has congestion than traditional HDD.
>>
>> Although swap slots may be consecutive on swap partition, it still may be
>> fragmented on swap file. This check would help to reduce excessive stall
>> for such case.
> Some words about the observed effects of the patch would be more than
> appropriate!

Yes, sure. Actually, this could reduce the latency long tail of 
do_swap_page() on a congested system.

The test on my virtual machine with emulated HDD shows:

Without swap congestion check:
page_fault1_thr-1490  [023]   129.311706: funcgraph_entry:      # 
57377.796 us |  do_swap_page();
  page_fault1_thr-1490  [023]   129.369103: funcgraph_entry: 5.642 us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.369119: funcgraph_entry:      # 
1289.592 us |  do_swap_page();
  page_fault1_thr-1490  [023]   129.370411: funcgraph_entry: 4.957 us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.370419: funcgraph_entry: 1.940 us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.378847: funcgraph_entry:      # 
1411.385 us |  do_swap_page();
  page_fault1_thr-1490  [023]   129.380262: funcgraph_entry: 3.916 us   
|  do_swap_page();
  page_fault1_thr-1490  [023]   129.380275: funcgraph_entry:      # 
4287.751 us |  do_swap_page();


With swap congestion check:
       runtest.py-1417  [020]   301.925911: funcgraph_entry:      # 
9870.146 us |  do_swap_page();
       runtest.py-1417  [020]   301.935785: funcgraph_entry: 9.802 us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935799: funcgraph_entry: 3.551 us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935806: funcgraph_entry: 2.142 us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935853: funcgraph_entry: 6.938 us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935864: funcgraph_entry: 3.765 us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935871: funcgraph_entry: 3.600 us   
|  do_swap_page();
       runtest.py-1417  [020]   301.935878: funcgraph_entry: 7.202 us   
|  do_swap_page();


The long tail latency (>1000us) is reduced significantly.

BTW, do you need I resend the patch with the above information appended 
into the commit log?

Thanks,
Yang
