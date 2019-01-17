Return-Path: <linux-kernel-owner@vger.kernel.org>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <360f77dc-fe8e-c7c4-84a0-852ef3c4a152@sr71.net>
Date: Thu, 17 Jan 2019 14:43:56 -0800
MIME-Version: 1.0
In-Reply-To: <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Jeff Moyer <jmoyer@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: thomas.lendacky@amd.com, mhocko@suse.com, linux-nvdimm@lists.01.org, tiwai@suse.de, ying.huang@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, baiyaowei@cmss.chinamobile.com, zwisler@kernel.org, bhelgaas@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 1/17/19 8:29 AM, Jeff Moyer wrote:
>> Persistent memory is cool.  But, currently, you have to rewrite
>> your applications to use it.  Wouldn't it be cool if you could
>> just have it show up in your system like normal RAM and get to
>> it like a slow blob of memory?  Well... have I got the patch
>> series for you!
> So, isn't that what memory mode is for?
>   https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
> 
> Why do we need this code in the kernel?

So, my bad for not mentioning memory mode.  This patch set existed
before we could talk about it publicly, so it simply ignores its
existence.  It's a pretty glaring omissions at this point, sorry.

I'll add this to the patches, but here are a few reasons you might want
this instead of memory mode:
1. Memory mode is all-or-nothing.  Either 100% of your persistent memory
   is used for memory mode, or nothing is.  With this set, you can
   (theoretically) have very granular (128MB) assignment of PMEM to
   either volatile or persistent uses.  We have a few practical matters
   to fix to get us down to that 128MB value, but we can get there.
2. The capacity of memory mode is the size of your persistent memory.
   DRAM capacity is "lost" because it is used for cache.  With this,
   you get PMEM+DRAM capacity for memory.
3. DRAM acts as a cache with memory mode, and caches can lead to
   unpredictable latencies.  Since memory mode is all-or-nothing, your
   entire memory space is exposed to these unpredictable latencies.
   This solution lets you guarantee DRAM latencies if you need them.
4. The new "tier" of memory is exposed to software.  That means that you
   can build tiered applications or infrastructure.  A cloud provider
   could sell cheaper VMs that use more PMEM and more expensive ones
   that use DRAM.  That's impossible with memory mode.

Don't take this as criticism of memory mode.  Memory mode is awesome,
and doesn't strictly require *any* software changes (we have software
changes proposed for optimizing it though).  It has tons of other
advantages over *this* approach.  Basically, they are complementary
enough that we think both can live side-by-side.
