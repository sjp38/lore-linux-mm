Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 719E36B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 11:02:09 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id r10so10944990pdi.34
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 08:02:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id el2si13630414pac.208.2014.08.11.08.02.08
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 08:02:08 -0700 (PDT)
Date: Mon, 11 Aug 2014 11:02:05 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140811150205.GA6754@linux.intel.com>
References: <20140409205111.GG5727@linux.intel.com>
 <20140409214331.GQ32103@quack.suse.cz>
 <20140729121259.GL6754@linux.intel.com>
 <20140729210457.GA17807@quack.suse.cz>
 <20140729212333.GO6754@linux.intel.com>
 <20140730095229.GA19205@quack.suse.cz>
 <20140809110000.GA32313@linux.intel.com>
 <20140811085147.GB29526@quack.suse.cz>
 <20140811141308.GZ6754@linux.intel.com>
 <20140811143500.GF29526@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140811143500.GF29526@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 11, 2014 at 04:35:00PM +0200, Jan Kara wrote:
> On Mon 11-08-14 10:13:08, Matthew Wilcox wrote:
> > On Mon, Aug 11, 2014 at 10:51:47AM +0200, Jan Kara wrote:
> > > So I'm afraid we'll have to find some other way to synchronize
> > > page faults and truncate / punch hole in DAX.
> > 
> > What if we don't?  If we hit the race (which is vanishingly unlikely with
> > real applications), the consequence is simply that after a truncate, a
> > file may be left with one or two blocks allocated somewhere after i_size.
> > As I understand it, that's not a real problem; they're temporarily
> > unavailable for allocation but will be freed on file removal or the next
> > truncation of that file.
>   You mean if you won't have any locking between page fault and truncate?
> You can have:
> a) extending truncate making forgotten blocks with non-zeros visible
> b) filesystem corruption due to doubly used blocks (block will be freed
> from the truncated file and thus can be reallocated but it will still be
> accessible via mmap from the truncated file).
> 
>   So not a good idea.

Not *no* locking ... just no locking around get_block, like in v7.
So check i_size, call get_block, lock i_mmap_mutex, re-check i_size,
insert mapping if i_size is OK, drop i_mmap_mutex.  As long as get_block()
has enough locking of its own against set_size and concurrent calls
to get_block(), I don't think we can get visible non-zeroes or double
allocation.

> > I'm also still considering the possibility of having truncate-down block
> > until all mmaps that extend after the new i_size have been removed ...
>   Hum, I'm not sure how you would do that with current locking scheme and
> wait for all page faults on that range to finish but maybe you have some
> good idea :)

While it can be blocked with i_dio_count currently, this would be a more
complicated thing to do ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
