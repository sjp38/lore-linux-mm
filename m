Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5D36B6F37
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:50:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b29-v6so2511414pfm.1
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:50:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v23-v6si22801904plo.19.2018.09.04.12.50.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 12:50:01 -0700 (PDT)
Date: Tue, 4 Sep 2018 12:50:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Hugepages mixed with stacks in process address space
Message-Id: <20180904125000.e2dd2c5403a965bb249b0a02@linux-foundation.org>
In-Reply-To: <ptihjzjmxbrcpgbmabkt@xekh>
References: <ptihjzjmxbrcpgbmabkt@xekh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacek Tomaka <Jacek.Tomaka@poczta.fm>
Cc: kirill.shutemov@linux.intel.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(cc linux-mm).

And thanks.

On Tue, 04 Sep 2018 17:08:34 +0200 Jacek Tomaka <Jacek.Tomaka@poczta.fm> wrote:

> Hello, 
> 
> I was trying to track down the performance differences of one of my applications 
> between running it on kernel used in Centos 7.4 and the latest 4.x version. 
> On 4.x kernels its performance depended on the run and the variability 
> was more than 30%. 
> 
> Bisecting showed that my issue  was introduced by : 
> fd8526ad14c182605e42b64646344b95befd9f94 :x86/mm: Implement ASLR for 
> hugetlb mappings
> 
> But it was not the ASLR aspect of that commit that created the issue but the 
> change from bottom-up to top-down unmapped area lookup when allocating 
> huge pages. 
> 
> After that change, the huge page allocations could become intertwined with 
> stacks. Before, the stacks and huge pages were on the other side of the process 
> address space. 
> 
> The machine i am seeing it on is Knights Landing 7250, with 68 cores x 4 
> hyper-threads. 
> 
> My application spawns 272 threads and each thread allocates its memory - a 
> couple of 2MB huge pages and does some computation, dominated by memory 
> accesses. 
> 
> My theory is that because KNL has 8-way 2MB TLB,  when the huge pages are 
> exactly 8 pages apart they collide.  And this is where the variability comes from, 
> if the stacks come in between, they increase chances of them colliding. 
> 
> I do realise that the application is (I am ) doing a few things dubiously:  it
> allocates memory on each thread and each huge page separately.  But i thought
> you might want to know about this behaviour change. 
> 
> When i allocate all my memory before i start threads, the problem goes away. 
> 
> /proc/PID/maps: 
> After change: 
> 7f5e06a00000-7f5e06c00000 rw-p 00000000 00:0f 31809                      /anon_hugepage (deleted)
> 7f5e06c00000-7f5e06e00000 rw-p 00000000 00:0f 29767                      /anon_hugepage (deleted)
> 7f5e06e00000-7f5e07000000 rw-p 00000000 00:0f 30787                      /anon_hugepage (deleted)
> 7f5e07000000-7f5e07200000 rw-p 00000000 00:0f 30786                      /anon_hugepage (deleted)
> 7f5e07200000-7f5e07400000 rw-p 00000000 00:0f 28744                      /anon_hugepage (deleted)
> 7f5e075ff000-7f5e07600000 ---p 00000000 00:00 0 
> 7f5e07600000-7f5e07e00000 rw-p 00000000 00:00 0 
> 7f5e07e00000-7f5e08000000 rw-p 00000000 00:0f 30785                      /anon_hugepage (deleted)
> 7f5e08000000-7f5e08021000 rw-p 00000000 00:00 0 
> 7f5e08021000-7f5e0c000000 ---p 00000000 00:00 0 
> 7f5e0c000000-7f5e0c021000 rw-p 00000000 00:00 0 
> 7f5e0c021000-7f5e10000000 ---p 00000000 00:00 0 
> 7f5e10000000-7f5e10021000 rw-p 00000000 00:00 0 
> 7f5e10021000-7f5e14000000 ---p 00000000 00:00 0 
> 7f5e14200000-7f5e14400000 rw-p 00000000 00:0f 29765                      /anon_hugepage (deleted)
> 7f5e14400000-7f5e14600000 rw-p 00000000 00:0f 28743                      /anon_hugepage (deleted)
> 7f5e14600000-7f5e14800000 rw-p 00000000 00:0f 29764                      /anon_hugepage (deleted)
> (...)
> 
> Before change: 
> 2aaaaac00000-2aaaaae00000 rw-p 00000000 00:0f 25582                      /anon_hugepage (deleted)
> 2aaaaae00000-2aaaab000000 rw-p 00000000 00:0f 25583                      /anon_hugepage (deleted)
> 2aaaab000000-2aaaab200000 rw-p 00000000 00:0f 25584                      /anon_hugepage (deleted)
> 2aaaab200000-2aaaab400000 rw-p 00000000 00:0f 25585                      /anon_hugepage (deleted)
> 2aaaab400000-2aaaab600000 rw-p 00000000 00:0f 25601                      /anon_hugepage (deleted)
> 2aaaab600000-2aaaab800000 rw-p 00000000 00:0f 25599                      /anon_hugepage (deleted)
> 2aaaab800000-2aaaaba00000 rw-p 00000000 00:0f 25602                      /anon_hugepage (deleted)
> 2aaaaba00000-2aaaabc00000 rw-p 00000000 00:0f 26652                      /anon_hugepage (deleted)
> (...)
> 7fc4f0021000-7fc4f4000000 ---p 00000000 00:00 0 
> 7fc4f4000000-7fc4f4021000 rw-p 00000000 00:00 0 
> 7fc4f4021000-7fc4f8000000 ---p 00000000 00:00 0 
> 7fc4f8000000-7fc4f8021000 rw-p 00000000 00:00 0 
> 7fc4f8021000-7fc4fc000000 ---p 00000000 00:00 0 
> 7fc4fc000000-7fc4fc021000 rw-p 00000000 00:00 0 
> 7fc4fc021000-7fc500000000 ---p 00000000 00:00 0 
> 7fc500000000-7fc500021000 rw-p 00000000 00:00 0 
> 7fc500021000-7fc504000000 ---p 00000000 00:00 0 
> 7fc504000000-7fc504021000 rw-p 00000000 00:00 0 
> 7fc504021000-7fc508000000 ---p 00000000 00:00 0 
> 7fc508000000-7fc508021000 rw-p 00000000 00:00 0 
> 7fc508021000-7fc50c000000 ---p 00000000 00:00 0 
> (...)
> 
> I was wondering if this intertwined stacks and hugepages is an expected 
> feature of ASLR? If not, maybe mmap's MAP_STACK flag could finally start 
> to be used by the kernel to keep all the stacks together in process address 
> space?
> 
> Or should users just not allocate huge pages on separate threads?
> 
> MAP_STACK could also be used to mark a VMA as a mapping for stack, 
> (if there are flags left) to re-implement: 
> 65376df582174ffcec9e6471bf5b0dd79ba05e4a proc: revert /proc/<pid>/maps [stack:TID] annotation
> correctly, as having these pieces of information in place would greatly 
> simplify my investigation. 
> 
> Regards.
> Jacek Tomaka
