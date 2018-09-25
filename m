Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51CD18E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 18:14:23 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s7-v6so3749829pgp.3
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:14:23 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d5-v6si3535366pla.439.2018.09.25.15.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 15:14:22 -0700 (PDT)
Subject: Re: [PATCH v5 2/4] mm: Provide kernel parameter to allow disabling
 page init poisoning
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925201921.3576.84239.stgit@localhost.localdomain>
 <13285e05-fb90-b948-6f96-777f94079657@intel.com>
 <8faf3acc-e47e-8ef9-a1a0-c0d6ebfafa1e@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <75dde720-c997-51a4-d2e2-8b08eb201550@intel.com>
Date: Tue, 25 Sep 2018 15:14:21 -0700
MIME-Version: 1.0
In-Reply-To: <8faf3acc-e47e-8ef9-a1a0-c0d6ebfafa1e@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/25/2018 01:38 PM, Alexander Duyck wrote:
> On 9/25/2018 1:26 PM, Dave Hansen wrote:
>> On 09/25/2018 01:20 PM, Alexander Duyck wrote:
>>> +A A A  vm_debug[=options]A A A  [KNL] Available with CONFIG_DEBUG_VM=y.
>>> +A A A A A A A A A A A  May slow down system boot speed, especially when
>>> +A A A A A A A A A A A  enabled on systems with a large amount of memory.
>>> +A A A A A A A A A A A  All options are enabled by default, and this
>>> +A A A A A A A A A A A  interface is meant to allow for selectively
>>> +A A A A A A A A A A A  enabling or disabling specific virtual memory
>>> +A A A A A A A A A A A  debugging features.
>>> +
>>> +A A A A A A A A A A A  Available options are:
>>> +A A A A A A A A A A A A A  PA A A  Enable page structure init time poisoning
>>> +A A A A A A A A A A A A A  -A A A  Disable all of the above options
>>
>> Can we have vm_debug=off for turning things off, please?A  That seems to
>> be pretty standard.
> 
> No. The simple reason for that is that you had requested this work like
> the slub_debug. If we are going to do that then each individual letter
> represents a feature. That is why the "-" represents off. We cannot have
> letters represent flags, and letters put together into words. For
> example slub_debug=OFF would turn on sanity checks and turn off
> debugging for caches that would have causes higher minimum slab orders.

We don't have to have the same letters mean the same things for both
options.  We also can live without 'o' and 'f' being valid.  We can
*also* just say "don't do 'off'" if you want to enable things.

I'd much rather have vm_debug=off do the right thing than have
per-feature enable/disable.  I know I'll *never* remember vm_debug=- and
doing it this way will subject me to innumerable trips to Documentation/
during my few remaining years.

Surely you can make vm_debug=off happen. :)

>> we need to document the defaults.A  I think the default is "all
>> debug options are enabled", but it would be nice to document that.
> 
> In the description I call out "All options are enabled by default, an> this interface is meant to allow for selectively enabling or disabling".

I found "all options are enabled by default" really confusing.  Maybe:

"Control debug features which become available when CONFIG_DEBUG_VM=y.
When this option is not specified, all debug features are enabled.  Use
this option enable a specific subset."

Then, let's actually say what the options do, and what their impact is:

	P	Enable 'struct page' poisoning at initialization.
		(Slows down boot time).
