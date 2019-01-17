Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4FFF8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:20:12 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so9682083qtk.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:20:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o44si808697qtc.134.2019.01.17.09.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:20:11 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
	<x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
	<20190117164736.GC31543@localhost.localdomain>
Date: Thu, 17 Jan 2019 12:20:06 -0500
In-Reply-To: <20190117164736.GC31543@localhost.localdomain> (Keith Busch's
	message of "Thu, 17 Jan 2019 09:47:37 -0700")
Message-ID: <x49pnsv8am1.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, thomas.lendacky@amd.com, fengguang.wu@intel.com, dave@sr71.net, linux-nvdimm@lists.01.org, tiwai@suse.de, zwisler@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, ying.huang@intel.com, bhelgaas@google.com, akpm@linux-foundation.org, bp@suse.de

Keith Busch <keith.busch@intel.com> writes:

> On Thu, Jan 17, 2019 at 11:29:10AM -0500, Jeff Moyer wrote:
>> Dave Hansen <dave.hansen@linux.intel.com> writes:
>> > Persistent memory is cool.  But, currently, you have to rewrite
>> > your applications to use it.  Wouldn't it be cool if you could
>> > just have it show up in your system like normal RAM and get to
>> > it like a slow blob of memory?  Well... have I got the patch
>> > series for you!
>> 
>> So, isn't that what memory mode is for?
>>   https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
>> 
>> Why do we need this code in the kernel?
>
> I don't think those are the same thing. The "memory mode" in the link
> refers to platforms that sequester DRAM to side cache memory access, where
> this series doesn't have that platform dependency nor hides faster DRAM.

OK, so you are making two arguments, here.  1) platforms may not support
memory mode, and 2) this series allows for performance differentiated
memory (even though applications may not modified to make use of
that...).

With this patch set, an unmodified application would either use:

1) whatever memory it happened to get
2) only the faster dram (via numactl --membind=)
3) only the slower pmem (again, via numactl --membind1)
4) preferentially one or the other (numactl --preferred=)

The other options are:
- as mentioned above, memory mode, which uses DRAM as a cache for the
  slower persistent memory.  Note that it isn't all or nothing--you can
  configure your system with both memory mode and appdirect.  The
  limitation, of course, is that your platform has to support this.

  This seems like the obvious solution if you want to make use of the
  larger pmem capacity as regular volatile memory (and your platform
  supports it).  But maybe there is some other limitation that motivated
  this work?

- libmemkind or pmdk.  These options typically* require application
  modifications, but allow those applications to actively decide which
  data lives in fast versus slow media.

  This seems like the obvious answer for applications that care about
  access latency.

* you could override the system malloc, but some libraries/application
  stacks already do that, so it isn't a universal solution.

Listing something like this in the headers of these patch series would
considerably reduce the head-scratching for reviewers.

Keith, you seem to be implying that there are platforms that won't
support memory mode.  Do you also have some insight into how customers
want to use this, beyond my speculation?  It's really frustrating to see
patch sets like this go by without any real use cases provided.

Cheers,
Jeff
