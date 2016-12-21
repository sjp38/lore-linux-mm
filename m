Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 017C76B03C5
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:12:49 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o20so61578784lfg.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:12:48 -0800 (PST)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id d5si15367311lfc.359.2016.12.21.10.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:12:47 -0800 (PST)
Date: Wed, 21 Dec 2016 19:12:43 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 02/14] sparc64: add new fields to mmu context for
 shared context support
Message-ID: <20161221181243.GB3311@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
 <20161217073406.GA23567@ravnborg.org>
 <b1c84633-7b4a-98d3-fd60-bcaf64574e4d@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1c84633-7b4a-98d3-fd60-bcaf64574e4d@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

Hi Mike.

On Sun, Dec 18, 2016 at 03:33:59PM -0800, Mike Kravetz wrote:
> On 12/16/2016 11:34 PM, Sam Ravnborg wrote:
> > Hi Mike.
> > 
> > On Fri, Dec 16, 2016 at 10:35:25AM -0800, Mike Kravetz wrote:
> >> Add new fields to the mm_context structure to support shared context.
> >> Instead of a simple context ID, add a pointer to a structure with a
> >> reference count.  This is needed as multiple tasks will share the
> >> context ID.
> > 
> > What are the benefits with the shared_mmu_ctx struct?
> > It does not save any space in mm_context_t, and the CPU only
> > supports one extra context.
> > So it looks like over-engineering with all the extra administration
> > required to handle it with refcount, poitners etc.
> > 
> > what do I miss?
> 
> Multiple tasks will share this same context ID.  The first task to need
> a new shared context will allocate the structure, increment the ref count
> and point to it.  As other tasks join the sharing, they will increment
> the ref count and point to the same structure.  Similarly, when tasks
> no longer use the shared context ID, they will decrement the reference
> count.
> 
> The reference count is important so that we will know when the last
> reference to the shared context ID is dropped.  When the last reference
> is dropped, then the ID can be recycled/given back to the global pool
> of context IDs.
> 
> This seemed to be the most straight forward way to implement this.

This nice explanation clarified it - thanks.
Could you try to include this info in the description
of the struct - so it is obvious what the intention with the
reference counter is.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
