Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 902F46B0038
	for <linux-mm@kvack.org>; Fri,  8 May 2015 16:03:09 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so58039229pac.1
        for <linux-mm@kvack.org>; Fri, 08 May 2015 13:03:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dl11si2875582pac.23.2015.05.08.13.03.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 13:03:08 -0700 (PDT)
Date: Fri, 8 May 2015 13:03:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time
 allocations
Message-Id: <20150508130307.e9bfedcfc66cbe6e6b009f19@linux-foundation.org>
In-Reply-To: <cover.1431103461.git.tony.luck@intel.com>
References: <cover.1431103461.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 8 May 2015 09:44:21 -0700 Tony Luck <tony.luck@intel.com> wrote:

> Some high end Intel Xeon systems report uncorrectable memory errors
> as a recoverable machine check. Linux has included code for some time
> to process these and just signal the affected processes (or even
> recover completely if the error was in a read only page that can be
> replaced by reading from disk).
> 
> But we have no recovery path for errors encountered during kernel
> code execution. Except for some very specific cases were are unlikely
> to ever be able to recover.
> 
> Enter memory mirroring. Actually 3rd generation of memory mirroing.
> 
> Gen1: All memory is mirrored
> 	Pro: No s/w enabling - h/w just gets good data from other side of the mirror
> 	Con: Halves effective memory capacity available to OS/applications
> Gen2: Partial memory mirror - just mirror memory begind some memory controllers
> 	Pro: Keep more of the capacity
> 	Con: Nightmare to enable. Have to choose between allocating from
> 	     mirrored memory for safety vs. NUMA local memory for performance
> Gen3: Address range partial memory mirror - some mirror on each memory controller
> 	Pro: Can tune the amount of mirror and keep NUMA performance
> 	Con: I have to write memory management code to implement
> 
> The current plan is just to use mirrored memory for kernel allocations. This
> has been broken into two phases:
> 1) This patch series - find the mirrored memory, use it for boot time allocations
> 2) Wade into mm/page_alloc.c and define a ZONE_MIRROR to pick up the unused
>    mirrored memory from mm/memblock.c and only give it out to select kernel
>    allocations (this is still being scoped because page_alloc.c is scary).

Looks good to me.  What happens to these patches while ZONE_MIRROR is
being worked on?


I'm wondering about phase II.  What does "select kernel allocations"
mean?  I assume we can't say "all kernel allocations" because that can
sometimes be "almost all memory".  How are you planning on implementing
this?  A new __GFP_foo flag, then sprinkle that into selected sites?

Will surplus ZONE_MIRROR memory be available for regular old movable
allocations?

I suggest you run the design ideas by Mel before getting into
implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
