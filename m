Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80E326B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 18:34:14 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 34so101177771uac.6
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 15:34:14 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j63si4219649vkb.150.2016.12.18.15.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 15:34:13 -0800 (PST)
Subject: Re: [RFC PATCH 02/14] sparc64: add new fields to mmu context for
 shared context support
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
 <20161217073406.GA23567@ravnborg.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b1c84633-7b4a-98d3-fd60-bcaf64574e4d@oracle.com>
Date: Sun, 18 Dec 2016 15:33:59 -0800
MIME-Version: 1.0
In-Reply-To: <20161217073406.GA23567@ravnborg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/16/2016 11:34 PM, Sam Ravnborg wrote:
> Hi Mike.
> 
> On Fri, Dec 16, 2016 at 10:35:25AM -0800, Mike Kravetz wrote:
>> Add new fields to the mm_context structure to support shared context.
>> Instead of a simple context ID, add a pointer to a structure with a
>> reference count.  This is needed as multiple tasks will share the
>> context ID.
> 
> What are the benefits with the shared_mmu_ctx struct?
> It does not save any space in mm_context_t, and the CPU only
> supports one extra context.
> So it looks like over-engineering with all the extra administration
> required to handle it with refcount, poitners etc.
> 
> what do I miss?

Multiple tasks will share this same context ID.  The first task to need
a new shared context will allocate the structure, increment the ref count
and point to it.  As other tasks join the sharing, they will increment
the ref count and point to the same structure.  Similarly, when tasks
no longer use the shared context ID, they will decrement the reference
count.

The reference count is important so that we will know when the last
reference to the shared context ID is dropped.  When the last reference
is dropped, then the ID can be recycled/given back to the global pool
of context IDs.

This seemed to be the most straight forward way to implement this.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
