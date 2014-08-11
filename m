Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF7F6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 10:13:12 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so10858580pde.32
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 07:13:11 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ka9si13498135pbb.179.2014.08.11.07.13.10
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 07:13:10 -0700 (PDT)
Date: Mon, 11 Aug 2014 10:13:08 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140811141308.GZ6754@linux.intel.com>
References: <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409102758.GM32103@quack.suse.cz>
 <20140409205111.GG5727@linux.intel.com>
 <20140409214331.GQ32103@quack.suse.cz>
 <20140729121259.GL6754@linux.intel.com>
 <20140729210457.GA17807@quack.suse.cz>
 <20140729212333.GO6754@linux.intel.com>
 <20140730095229.GA19205@quack.suse.cz>
 <20140809110000.GA32313@linux.intel.com>
 <20140811085147.GB29526@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140811085147.GB29526@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 11, 2014 at 10:51:47AM +0200, Jan Kara wrote:
> So I'm afraid we'll have to find some other way to synchronize
> page faults and truncate / punch hole in DAX.

What if we don't?  If we hit the race (which is vanishingly unlikely with
real applications), the consequence is simply that after a truncate, a
file may be left with one or two blocks allocated somewhere after i_size.
As I understand it, that's not a real problem; they're temporarily
unavailable for allocation but will be freed on file removal or the next
truncation of that file.

I'm also still considering the possibility of having truncate-down block
until all mmaps that extend after the new i_size have been removed ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
