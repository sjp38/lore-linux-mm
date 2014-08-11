Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2206B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 10:35:04 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id w61so8610579wes.11
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 07:35:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xs6si26661153wjb.80.2014.08.11.07.35.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 07:35:03 -0700 (PDT)
Date: Mon, 11 Aug 2014 16:35:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140811143500.GF29526@quack.suse.cz>
References: <20140409102758.GM32103@quack.suse.cz>
 <20140409205111.GG5727@linux.intel.com>
 <20140409214331.GQ32103@quack.suse.cz>
 <20140729121259.GL6754@linux.intel.com>
 <20140729210457.GA17807@quack.suse.cz>
 <20140729212333.GO6754@linux.intel.com>
 <20140730095229.GA19205@quack.suse.cz>
 <20140809110000.GA32313@linux.intel.com>
 <20140811085147.GB29526@quack.suse.cz>
 <20140811141308.GZ6754@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140811141308.GZ6754@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 11-08-14 10:13:08, Matthew Wilcox wrote:
> On Mon, Aug 11, 2014 at 10:51:47AM +0200, Jan Kara wrote:
> > So I'm afraid we'll have to find some other way to synchronize
> > page faults and truncate / punch hole in DAX.
> 
> What if we don't?  If we hit the race (which is vanishingly unlikely with
> real applications), the consequence is simply that after a truncate, a
> file may be left with one or two blocks allocated somewhere after i_size.
> As I understand it, that's not a real problem; they're temporarily
> unavailable for allocation but will be freed on file removal or the next
> truncation of that file.
  You mean if you won't have any locking between page fault and truncate?
You can have:
a) extending truncate making forgotten blocks with non-zeros visible
b) filesystem corruption due to doubly used blocks (block will be freed
from the truncated file and thus can be reallocated but it will still be
accessible via mmap from the truncated file).

  So not a good idea.
 
> I'm also still considering the possibility of having truncate-down block
> until all mmaps that extend after the new i_size have been removed ...
  Hum, I'm not sure how you would do that with current locking scheme and
wait for all page faults on that range to finish but maybe you have some
good idea :)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
