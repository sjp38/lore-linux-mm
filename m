Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 3532C6B0008
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 07:47:18 -0500 (EST)
Date: Mon, 4 Feb 2013 13:47:15 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/6] fs: Take mapping lock in generic read paths
Message-ID: <20130204124715.GF7523@quack.suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
 <1359668994-13433-3-git-send-email-jack@suse.cz>
 <20130131155940.7b1f8e0e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130131155940.7b1f8e0e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 31-01-13 15:59:40, Andrew Morton wrote:
> On Thu, 31 Jan 2013 22:49:50 +0100
> Jan Kara <jack@suse.cz> wrote:
> 
> > Add mapping lock to struct address_space and grab it in all paths
> > creating pages in page cache to read data into them. That means buffered
> > read, readahead, and page fault code.
> 
> Boy, this does look expensive in both speed and space.
  I'm not sure I'll be able to do much with the space cost but hopefully
the CPU cost could be reduced.

> As you pointed out in [0/n], it's 2-3%.  As always with pagecache
> stuff, the cost of filling the page generally swamps any inefficiencies
> in preparing that page.
  Yes, I measured it with with ramdisk backed fs exactly to remove the cost
of filling the page from the picture. But there are systems where IO is CPU
bound (e.g. when you have PCIe attached devices) and although there is the
additional cost of block layer which will further hide the cost of page
cache itself I assume the added 2-3% incurred by page cache itself will be
measurable on such systems. So that's why I'd like to reduce the CPU cost
of range locking.
								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
