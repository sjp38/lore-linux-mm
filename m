Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40CC86B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 12:37:11 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id z16-v6so2126336ljh.5
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 09:37:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r8-v6sor3392738ljb.23.2018.10.24.09.37.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 09:37:09 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Wed, 24 Oct 2018 18:36:58 +0200
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181024163658.ojar7gvstaycn2wz@pc636>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023152640.GD20085@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Shuah Khan <shuah@kernel.org>, Michal Hocko <mhocko@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Tue, Oct 23, 2018 at 08:26:40AM -0700, Matthew Wilcox wrote:
> On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
> > Hi Michal,
> > 
> > On 10/23/2018 01:23 AM, Michal Hocko wrote:
> > > Hi Shuah,
> > > 
> > > On Mon 22-10-18 18:52:53, Uladzislau Rezki wrote:
> > >> On Mon, Oct 22, 2018 at 02:51:42PM +0200, Michal Hocko wrote:
> > >>> Hi,
> > >>> I haven't read through the implementation yet but I have say that I
> > >>> really love this cover letter. It is clear on intetion, it covers design
> > >>> from high level enough to start discussion and provides a very nice
> > >>> testing coverage. Nice work!
> > >>>
> > >>> I also think that we need a better performing vmalloc implementation
> > >>> long term because of the increasing number of kvmalloc users.
> > >>>
> > >>> I just have two mostly workflow specific comments.
> > >>>
> > >>>> A test-suite patch you can find here, it is based on 4.18 kernel.
> > >>>> ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch
> > >>>
> > >>> Can you fit this stress test into the standard self test machinery?
> > >>>
> > >> If you mean "tools/testing/selftests", then i can fit that as a kernel module.
> > >> But not all the tests i can trigger from kernel module, because 3 of 8 tests
> > >> use __vmalloc_node_range() function that is not marked as EXPORT_SYMBOL.
> > > 
> > > Is there any way to conditionally export these internal symbols just for
> > > kselftests? Or is there any other standard way how to test internal
> > > functionality that is not exported to modules?
> > > 
> > 
> > The way it can be handled is by adding a test module under lib. test_kmod,
> > test_sysctl, test_user_copy etc.
> 
> The problem is that said module can only invoke functions which are
> exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
> which I don't think we're willing to pay, purely to get test coverage.
> 
> Based on my own experience with the IDA & XArray test suites, I would
> like to propose a solution which does not require exporting all of
> these symbols:
> 
> Create a new kernel module in mm/test_vmalloc.c
> 
> Towards the top of that file,
> 
> #include <linux/export.h>
> #undef EXPORT_SYMBOL
> #define EXPORT_SYMBOL(x)	/* */
> #include "vmalloc.c"
> 
> Now you can invoke even static functions from your test harness.
I see your point. But i also think that it would not be so easy to go.

<snip>
#undef CONFIG_HAVE_ARCH_HUGE_VMAP
#undef CONFIG_PROC_FS

#include "../hikey_linux.git/mm/vmalloc.c"
#include <linux/random.h>
<snip>

<snip>
  LD [M]  /mnt/coding/vmalloc_performance_test/vmalloc_test.o
  Building modules, stage 2.
  MODPOST 1 modules
WARNING: "__pud_alloc" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "__sync_icache_dcache" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "warn_alloc" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "pmd_clear_bad" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "pgd_clear_bad" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "swapper_pg_dir" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "__pmd_alloc" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "pud_clear_bad" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
WARNING: "__pte_alloc_kernel" [/mnt/coding/vmalloc_performance_test/vmalloc_test.ko] undefined!
 LD [M]  /mnt/coding/vmalloc_performance_test/vmalloc_test.ko
<snip>

i.e. i will need either link with objects where those functions are or
wrap them up somehow. 

Thanks!

--
Vlad Rezki
