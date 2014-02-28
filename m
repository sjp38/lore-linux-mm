Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 182D06B0072
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:51:24 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id w7so550097qcr.22
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 03:51:23 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id t3si782946qar.77.2014.02.28.03.51.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 03:51:20 -0800 (PST)
Message-ID: <1393588254.22449.13.camel@pasglop>
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 28 Feb 2014 22:50:54 +1100
In-Reply-To: <530FBD8F.7090304@linux.intel.com>
References: 
	<1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>
	 <530FB55F.2070106@linux.intel.com>
	 <CA+55aFzUYTHXcVnZL0vTGRPh3oQ8qYGO9+Va1Ch3P1yX+9knDg@mail.gmail.com>
	 <530FBD8F.7090304@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, anton@samba.org, Paul Mackerras <paulus@samba.org>

On Thu, 2014-02-27 at 14:34 -0800, Dave Hansen wrote:
> 
> The question is really whether or not we ever access the mapping that we
> faulted around, though.  If we never access it, then the cost (however
> small it was) is a loss.  That's the mechanism that I'd expect causes
> Kirill's numbers to go up after they hit their minimum at ~order-4.

On the other hand, the cost of our faults on ppc64 is higher. The two hash
lookups by the MMU (generally L2 misses) before it even decides to take the
fault, followed by a generally longer code path before we get to Linux
fault handler.

So there might be a bigger win for us, especially if the "around" pages
get pre-hashed (ie, via update_mmu_cache)

I don't have the bandwidth to play around with that myself at the moment
but I'll try to find somebody who can.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
