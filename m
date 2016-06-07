Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1F6828E1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:19:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 4so24060103wmz.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:19:49 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id nh6si905138wjb.224.2016.06.07.04.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 04:19:48 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id m124so22214038wme.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:19:48 -0700 (PDT)
Date: Tue, 7 Jun 2016 13:19:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: pages are not freed from lru_add_pvecs after process
 termination
Message-ID: <20160607111946.GJ12305@dhcp22.suse.cz>
References: <5720F2A8.6070406@intel.com>
 <20160428143710.GC31496@dhcp22.suse.cz>
 <20160502130006.GD25265@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C182F@IRSMSX103.ger.corp.intel.com>
 <20160504203643.GI21490@dhcp22.suse.cz>
 <20160505072122.GA4386@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023C402E@IRSMSX103.ger.corp.intel.com>
 <572CC092.5020702@intel.com>
 <20160511075313.GE16677@dhcp22.suse.cz>
 <D6EDEBF1F91015459DB866AC4EE162CC023F84C9@IRSMSX103.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D6EDEBF1F91015459DB866AC4EE162CC023F84C9@IRSMSX103.ger.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Odzioba, Lukasz" <lukasz.odzioba@intel.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>

On Tue 07-06-16 09:02:02, Odzioba, Lukasz wrote:
[...]
> //compile with: gcc bench.c -o bench_2M -fopenmp
> //compile with: gcc -D SMALL_PAGES bench.c -o bench_4K -fopenmp
> #include <stdio.h>
> #include <sys/mman.h>
> #include <omp.h>
> 
> #define MAP_HUGE_SHIFT  26
> #define MAP_HUGE_2MB    (21 << MAP_HUGE_SHIFT)
> 
> #ifndef SMALL_PAGES
> #define PAGE_SIZE (1024*1024*2)
> #define MAP_PARAM (MAP_HUGE_2MB)

Isn't MAP_HUGE_2MB ignored for !hugetlb pages?

> #else
> #define PAGE_SIZE (1024*4)
> #define MAP_PARAM (0)
> #endif
> 
> void main() {
>         size_t size = ((60 * 1000 * 1000) / 288) * 1000; // 60GBs of memory 288 CPUs
>         #pragma omp parallel
>         {
>         unsigned int k;
>         for (k = 0; k < 10; k++) {
>                 void *p = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON | MAP_PARAM, -1, 0);

I guess you want something like posix_memalign or start faulting in from
an aligned address to guarantee you will fault 2MB pages. Also note that
the default behavior for THP during the fault has changed recently (see
444eb2a449ef ("mm: thp: set THP defrag by default to madvise and add a
stall-free defrag option") so you might need MADV_HUGEPAGE.

Besides that I am really suspicious that this will be measurable at all.
I would just go and spin a patch assuming you are still able to trigger
OOM with the vanilla kernel. The bug fix is more important...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
