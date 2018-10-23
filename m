Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D85646B0005
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 11:26:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id w64-v6so1085230pfk.2
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 08:26:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d18-v6si1661749plj.82.2018.10.23.08.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 08:26:44 -0700 (PDT)
Date: Tue, 23 Oct 2018 08:26:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181023152640.GD20085@bombadil.infradead.org>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuah@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
> Hi Michal,
> 
> On 10/23/2018 01:23 AM, Michal Hocko wrote:
> > Hi Shuah,
> > 
> > On Mon 22-10-18 18:52:53, Uladzislau Rezki wrote:
> >> On Mon, Oct 22, 2018 at 02:51:42PM +0200, Michal Hocko wrote:
> >>> Hi,
> >>> I haven't read through the implementation yet but I have say that I
> >>> really love this cover letter. It is clear on intetion, it covers design
> >>> from high level enough to start discussion and provides a very nice
> >>> testing coverage. Nice work!
> >>>
> >>> I also think that we need a better performing vmalloc implementation
> >>> long term because of the increasing number of kvmalloc users.
> >>>
> >>> I just have two mostly workflow specific comments.
> >>>
> >>>> A test-suite patch you can find here, it is based on 4.18 kernel.
> >>>> ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch
> >>>
> >>> Can you fit this stress test into the standard self test machinery?
> >>>
> >> If you mean "tools/testing/selftests", then i can fit that as a kernel module.
> >> But not all the tests i can trigger from kernel module, because 3 of 8 tests
> >> use __vmalloc_node_range() function that is not marked as EXPORT_SYMBOL.
> > 
> > Is there any way to conditionally export these internal symbols just for
> > kselftests? Or is there any other standard way how to test internal
> > functionality that is not exported to modules?
> > 
> 
> The way it can be handled is by adding a test module under lib. test_kmod,
> test_sysctl, test_user_copy etc.

The problem is that said module can only invoke functions which are
exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
which I don't think we're willing to pay, purely to get test coverage.

Based on my own experience with the IDA & XArray test suites, I would
like to propose a solution which does not require exporting all of
these symbols:

Create a new kernel module in mm/test_vmalloc.c

Towards the top of that file,

#include <linux/export.h>
#undef EXPORT_SYMBOL
#define EXPORT_SYMBOL(x)	/* */
#include "vmalloc.c"

Now you can invoke even static functions from your test harness.
