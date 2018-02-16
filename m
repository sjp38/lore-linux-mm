Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25FB26B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 16:44:02 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t18so3003167plo.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:44:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si258773plj.456.2018.02.16.13.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Feb 2018 13:44:00 -0800 (PST)
Date: Fri, 16 Feb 2018 13:43:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Message-ID: <20180216214353.GA32655@bombadil.infradead.org>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <87d2edf7-ce5e-c643-f972-1f2538208d86@intel.com>
 <alpine.DEB.2.20.1802161413340.11934@nuc-kabylake>
 <7fcd53ab-ba06-f80e-6cb7-73e87bcbdd20@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fcd53ab-ba06-f80e-6cb7-73e87bcbdd20@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Christopher Lameter <cl@linux.com>, Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Feb 16, 2018 at 01:08:11PM -0800, Dave Hansen wrote:
> On 02/16/2018 12:15 PM, Christopher Lameter wrote:
> >> This has the potential to be really confusing to apps.  If this memory
> >> is now not available to normal apps, they might plow into the invisible
> >> memory limits and get into nasty reclaim scenarios.
> >> Shouldn't this subtract the memory for MemFree and friends?
> > Ok certainly we could do that. But on the other hand the memory is
> > available if those subsystems ask for the right order. Its not clear to me
> > what the right way of handling this is. Right now it adds the reserved
> > pages to the watermarks. But then under some circumstances the memory is
> > available. What is the best solution here?
> 
> There's definitely no perfect solution.
> 
> But, in general, I think we should cater to the dumbest users.  Folks
> doing higher-order allocations are not that.  I say we make the picture
> the most clear for the traditional 4k users.

Your way might be confusing -- if there's a system which is under varying
amounts of jumboframe load and all the 16k pages get gobbled up by the
ethernet driver, MemFree won't change at all, for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
