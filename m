Message-ID: <425C2190.20704@engr.sgi.com>
Date: Tue, 12 Apr 2005 14:29:20 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: question on page-migration code
References: <4255B13E.8080809@engr.sgi.com>	<20050407180858.GB19449@logos.cnet>	<425AC268.4090704@engr.sgi.com> <20050412.084143.41655902.taka@valinux.co.jp>
In-Reply-To: <20050412.084143.41655902.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:

> 
> I understand what happened on your machine.
> 
> PG_private is a filesystem specific flag, setting some filesystem
> depending data in page->private. When the flag is set on a page,
> only the local filesystem on which the page depends can handle it. 
> 
> Most of the filesystems uses page->private to manage buffers while
> others may use it for different purposes. Each filesystem can
> implement migrate_page method to handles page->private.
> At this moment, only ext2 and ext3 have this method, which migrates
> buffers without any I/Os.
> 
> If the method isn't implemented for the page, the migration code
> calls pageout() and try_to_release_page() to release page->private
> instead. 
> 
> Which filesystem are you using? I guess it might be XFS which
> doesn't have the method yet.
> 
> Thank you,
> Hirokazu Takahashi.
> 

Hi Hirakazu,

Just to make sure, I re-ran my test case with the test program's
home directory (and hence where its mapped files reside) on an
ext3 file system instead of on XFS.  In this case, the
migrations are all fast; however, there are still significant
number of page I/O's occuring (135 MB worth, I am migrating
138 MB).  So it doesn't appear that an I/O-less migration is
going on here either.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
