Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4710A2803E9
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 09:50:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k190so18577719pge.9
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 06:50:04 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o33si1097754plb.1041.2017.08.04.06.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 06:50:02 -0700 (PDT)
Date: Fri, 4 Aug 2017 16:49:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: A possible bug: Calling mutex_lock while holding spinlock
Message-ID: <20170804134928.l4klfcnqatni7vsc@black.fi.intel.com>
References: <2d442de2-c5d4-ecce-2345-4f8f34314247@amd.com>
 <20170803153902.71ceaa3b435083fc2e112631@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803153902.71ceaa3b435083fc2e112631@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: axie <axie@amd.com>, Alex Deucher <alexander.deucher@amd.com>, "Writer, Tim" <Tim.Writer@amd.com>, linux-mm@kvack.org

On Thu, Aug 03, 2017 at 03:39:02PM -0700, Andrew Morton wrote:
> 
> (cc Kirill)
> 
> On Thu, 3 Aug 2017 12:35:28 -0400 axie <axie@amd.com> wrote:
> 
> > Hi Andrew,
> > 
> > 
> > I got a report yesterday with "BUG: sleeping function called from 
> > invalid context at kernel/locking/mutex.c"
> > 
> > I checked the relevant functions for the issue. Function 
> > page_vma_mapped_walk did acquire spinlock. Later, in MMU notifier, 
> > amdgpu_mn_invalidate_page called function mutex_lock, which triggered 
> > the "bug".
> > 
> > Function page_vma_mapped_walk was introduced recently by you in commit
> > c7ab0d2fdc840266b39db94538f74207ec2afbf6 and 
> > ace71a19cec5eb430207c3269d8a2683f0574306.
> > 
> > Would you advise how to proceed with this bug? Change 
> > page_vma_mapped_walk not to use spinlock? Or change 
> > amdgpu_mn_invalidate_page to use spinlock to meet the change, or 
> > something else?
> > 
> 
> hm, as far as I can tell this was an unintended side-effect of
> c7ab0d2fd ("mm: convert try_to_unmap_one() to use
> page_vma_mapped_walk()").  Before that patch,
> mmu_notifier_invalidate_page() was not called under page_table_lock. 
> After that patch, mmu_notifier_invalidate_page() is called under
> page_table_lock.
> 
> Perhaps Kirill can suggest a fix?

Sorry for this.

What about the patch below?
