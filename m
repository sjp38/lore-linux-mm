Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8842B6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:47:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r83so17910160pfj.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:47:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p20si5500354pfk.425.2017.09.26.04.47.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 04:47:52 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:47:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] A multithread lockless deduplication engine
Message-ID: <20170926114747.tjiyopglxeeudy65@dhcp22.suse.cz>
References: <0d61c58a-8d73-4037-b15d-1f0f25a3ad62.ljy@baibantech.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0d61c58a-8d73-4037-b15d-1f0f25a3ad62.ljy@baibantech.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: XaviLi <ljy@baibantech.com.cn>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

[Let's add some more people and linux-mm to the CC list]

On Wed 20-09-17 11:23:50, XaviLi wrote:
> PageONE (Page Object Non-duplicate Engine) is a multithread kernel page deduplication engine. It is based on a lock-less tree algorithm we currently named as SD (Static and Dynamic) Tree. Normal operations such as insert/query/delete to this tree are block-less. Adding more CPU cores can linearly boost speed as far as we tested. Multithreading gives not only opportunity to work faster. It also allows any CPU to donate spare time for the job. Therefore, it reveals a way to use CPU more efficiently. PPR is from an open source solution named Dynamic VM:
> https://github.com/baibantech/dynamic_vm.git 
> 
> patch can be found here:  https://github.com/baibantech/dynamic_vm/tree/master/dynamic_vm_0.5
> 
> One work thread of PageONE can match the speed of KSM daemon. Adding more CPUs can increase speed linearly. Here we can see a brief test:
> 
> Test environment
> DELL R730
> Intel(R) Xeon(R) E5-2650 v4 (2.20 GHz, of Cores 12, threads 24); 
> 256GB RAM
> Host OS: Ubuntu server 14.04 Host kernel: 4.4.1
> Qemu: 2.9.0
> Guest OS: Ubuntu server 16.04 Guest kernel: 4.4.76
> 
> We ran 12 VMs together. Each create 16GB data in memory. After all data is ready we start dedup-engine and see how host-side used memory amount changes.
> 
> KSM:
> Configuration: sleep_millisecs = 0, pages_to_scan = 1000000
> Starting used memory: 216.8G
> Result: KSM start merging pages immediately after turned on. KSM daemon took 100% of one CPU for 13:16 until used memory was reduced to 79.0GB.
> 
> PageONE:
> Configuration: merge_period(secs) = 20, work threads = 12
> Starting used memory: 207.3G
> (Which means PageONE scans full physical memory in 20 secs period. Pages was merged if not changed in 2 merge_periods.)
> Result: In the first two periods PageONE only observe and identify unchanged pages. Little CPU was used in this time. As the third period begin all 12 threads start using 100% CPU to do real merge job. 00:58 later used memory was reduced to 70.5GB.
> 
> We ran the above test using the data quite easy for red-black tree of KSM. Every difference can be detected by comparing the first 8 bytes. Then we ran another test in which each data was begin with random zero bytes for comparison. The average size of zero data was 128 bytes. Result is shown below:
> 
> KSM:
> Configuration: sleep_millisecs = 0, pages_to_scan = 1000000
> Starting used memory: 216.8G
> Result: 19:49 minutes until used memory was reduced to 78.7GB.
> 
> PageONE:
> Configuration: merge period(secs) = 20, work threads = 12
> Starting used memory: 210.3G
> Result: First 2 periods same as above. 1:09 after merge job start memory was reduced to 72GB.
> 
> PageONE shows little difference in the two tests because SD tree search compare each key bit just once in most cases.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
