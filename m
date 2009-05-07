Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8743F6B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 16:50:10 -0400 (EDT)
Date: Thu, 7 May 2009 13:44:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class citizen
Message-Id: <20090507134410.0618b308.akpm@linux-foundation.org>
In-Reply-To: <20090507151039.GA2413@cmpxchg.org>
References: <20090430174536.d0f438dd.akpm@linux-foundation.org>
	<20090430205936.0f8b29fc@riellaptop.surriel.com>
	<20090430181340.6f07421d.akpm@linux-foundation.org>
	<20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: fengguang.wu@intel.com, peterz@infradead.org, riel@redhat.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 May 2009 17:10:39 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> > +++ linux/mm/nommu.c
> > @@ -1224,6 +1224,8 @@ unsigned long do_mmap_pgoff(struct file 
> >  			added_exe_file_vma(current->mm);
> >  			vma->vm_mm = current->mm;
> >  		}
> > +		if (vm_flags & VM_EXEC)
> > +			set_bit(AS_EXEC, &file->f_mapping->flags);
> >  	}
> 
> I find it a bit ugly that it applies an attribute of the memory area
> (per mm) to the page cache mapping (shared).  Because this in turn
> means that the reference through a non-executable vma might get the
> pages rotated just because there is/was an executable mmap around.

Yes, it's not good.  That AS_EXEC bit will hang around for arbitrarily
long periods in the inode cache.  So we'll have AS_EXEC set on an
entire file because someone mapped some of it with PROT_EXEC half an
hour ago.  Where's the sense in that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
