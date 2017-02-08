Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDD2B28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 13:19:35 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id z143so172170618ywz.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 10:19:35 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id 76si2253667ybe.201.2017.02.08.10.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 10:19:35 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id u68so12493323ywg.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 10:19:35 -0800 (PST)
Date: Wed, 8 Feb 2017 13:19:32 -0500
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH]
 mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages-fix
Message-ID: <20170208181932.GA25826@htj.duckdns.org>
References: <20170207202755.24571-1-mhocko@kernel.org>
 <201702080524.R4RBmup3%fengguang.wu@intel.com>
 <20170207141420.ab4de727ed05ddd41602f73f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207141420.ab4de727ed05ddd41602f73f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, Michal Hocko <mhocko@kernel.org>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hello, Andrew.

On Tue, Feb 07, 2017 at 02:14:20PM -0800, Andrew Morton wrote:
> >      extern __PCPU_DUMMY_ATTRS char __pcpu_unique_##name;  \
> >                                     ^
> 
> huh, yes.  The DEFINE_PER_CPU() macro is broken.

Yeah, that was the trade off I had to take with percpu vars to force
s390 and alpha to generate long references (GOT based addressing) for
percpu variables; otherwise, they generate memory deref which is too
limited to access the special percpu addresses.  It's explained in
include/linux/percpu-defs.h.

> If you do
> 
> foo()
> {
> 	static DEFINE_PER_CPU(int, bar);
> }
> 
> then it won't compile, as described here.  It should.
> 
> And if you do
> 
> static DEFINE_PER_CPU(int, bar);
> 
> then you still get global symbols (__pcpu_unique_bar).
> 
> The kernel does the above thing in, umm, 466 places and afaict they're
> all broken.  If two code sites ever use the same identifier, they'll
> get linkage errors.

So, we have CONFIG_DEBUG_FORCE_WEAK_PER_CPU to catch those cases on
archs other than s390 or alpha.

> huh.  Seems hard to fix.

This was the only way I could come up with to support alpha and s390.
All the restrictions are there to ensure that.  If we can do s390 and
alpha w/o the global weak reference, neither restriction is necessary.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
