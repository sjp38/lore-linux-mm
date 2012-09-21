Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1D0B86B006E
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:35:36 -0400 (EDT)
Date: Fri, 21 Sep 2012 10:35:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] Reduce compaction scanning and lock contention
Message-ID: <20120921093530.GS11266@suse.de>
References: <1348149875-29678-1-git-send-email-mgorman@suse.de>
 <20120921091333.GA32081@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120921091333.GA32081@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 10:13:33AM +0100, Richard Davies wrote:
> Hi Mel,
> 
> Thank you for this series. I have applied on clean 3.6-rc5 and tested, and
> it works well for me - the lock contention is (still) gone and
> isolate_freepages_block is much reduced.
> 

Excellent!

> Here is a typical test with these patches:
> 
> # grep -F '[k]' report | head -8
>     65.20%         qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
>      2.18%         qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
>      1.56%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
>      1.40%         qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
>      1.38%          swapper  [kernel.kallsyms]     [k] default_idle
>      1.35%         qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
>      0.74%             ksmd  [kernel.kallsyms]     [k] memcmp
>      0.72%         qemu-kvm  [kernel.kallsyms]     [k] free_pages_prepare
> 

Ok, so that is more or less acceptable. I would like to reduce the scanning
even further but I'll take this as a start -- largely because I do not have
any new good ideas on how it could be reduced further without incurring
a large cost in the page allocator :)

> I did manage to get a couple which were slightly worse, but nothing like as
> bad as before. Here are the results:
> 
> # grep -F '[k]' report | head -8
>     45.60%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
>     11.26%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
>      3.21%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
>      2.27%           ksmd  [kernel.kallsyms]     [k] memcmp
>      2.02%        swapper  [kernel.kallsyms]     [k] default_idle
>      1.58%       qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
>      1.30%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave
>      1.09%       qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
> 
> # grep -F '[k]' report | head -8
>     61.29%       qemu-kvm  [kernel.kallsyms]     [k] clear_page_c
>      4.52%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave
>      2.64%       qemu-kvm  [kernel.kallsyms]     [k] copy_page_c
>      1.61%        swapper  [kernel.kallsyms]     [k] default_idle
>      1.57%       qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock
>      1.18%       qemu-kvm  [kernel.kallsyms]     [k] get_page_from_freelist
>      1.18%       qemu-kvm  [kernel.kallsyms]     [k] isolate_freepages_block
>      1.11%       qemu-kvm  [kernel.kallsyms]     [k] svm_vcpu_run
> 
> 

Were the boot times acceptable even when these slightly worse figures
were recorded?

> I will follow up with the detailed traces for these three tests.
> 
> Thank you!
> 

Thank you for the detailed reporting and the testing, it's much
appreciated. I've already rebased the patches to Andrew's tree and tested
them overnight and the figures look good on my side. I'll update the
changelog and push them shortly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
