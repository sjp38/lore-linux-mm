Message-ID: <425B5534.30809@engr.sgi.com>
Date: Mon, 11 Apr 2005 23:57:24 -0500
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
> Hi Ray,
> 
> 
> 
  <snip>
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
Yes, I am using XFS.  However, the thing I still don't understand
why the migration is fast the first time I use it, but then the
next time it is slow?  It is the case that swap I/O is apparently
happening for the pages when I see the slowdown, so I agree that
you've probably diagnosed that part of the problem.  (Well, I
would wonder why pageout() followed by try_to_release_page() is
soooo slow.  But hey perhaps we are doing I/O in one page units
or such and that could explain why the I/O takes so long.)

But why does the first migration happen so quickly?  I'm wondering
if the migration process doesn't leave the page in a state that
requires cleaning, whereas the pages as originally found didn't
need to be cleaned.  It would seem to me we would want the page
state after migration to be effectively the same as the page
state before migration.

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
