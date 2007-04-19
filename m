From: "Vladimir V. Saveliev" <vs@namesys.com>
Subject: Re: dio_get_page() lockdep complaints
Date: Thu, 19 Apr 2007 18:55:57 +0400
References: <20070419073828.GB20928@kernel.dk> <20070419083407.GD20928@kernel.dk> <20070419141510.GG11780@kernel.dk>
In-Reply-To: <20070419141510.GG11780@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="koi8-u"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704191855.57893.vs@namesys.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-aio@kvack.org, reiserfs-dev@namesys.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello

On Thursday 19 April 2007 18:15, Jens Axboe wrote:
> On Thu, Apr 19 2007, Jens Axboe wrote:
> > > Is it possible that fio was changed?  That it was changed to close() the fd
> > > before doing the munmapping whereas it used to hold the file open?
> > 
> > It's been a while since I tested on this box, so I don't really recall.
> > But fio does close() the fd before doing munmap(). This particular test
> > case doesn't use mmap(), though.
> 
> Ah wait, but it does use mmap! Fio sets up a semaphore my mmap'ing a
> file in /tmp (which is reiserfs). Here's a test case that triggers it
> 100% reliably, adjust /tmp to some other location that is reiserfs.
> lockdep from that run attached.
> 
> #include <stdlib.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <sys/mman.h>
> 
> int main(int argc, char *argv[])
> {
> 	char fname[] = "/tmp/some_file";	/* /tmp on reiserfs */
> 	void *p;
> 	int fd;
> 
> 	fd = open(fname, O_RDWR|O_CREAT, 0644);
> 	if (fd < 0) {
> 		perror("open");
> 		return 1;
> 	}
> 
> 	if (ftruncate(fd, 64) < 0) {
> 		perror("ftruncate");
> 		return 1;
> 	}
> 
> 	p = mmap(NULL, 64, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
> 	if (p == MAP_FAILED) {
> 		perror("mmap");
> 		return 1;
> 	}
> 
> 	unlink(fname);
> 	close(fd);
> 	munmap(p, 64);
> 	return 0;
> }
> 
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.21-rc7 #18
> -------------------------------------------------------
> reiser-mmap/9643 is trying to acquire lock:
>  (&inode->i_mutex){--..}, at: [<b038c625>] mutex_lock+0x1c/0x1f
> 
> but task is already holding lock:
>  (&mm->mmap_sem){----}, at: [<b015c6cf>] sys_munmap+0x26/0x42
> 

So, it looks like the problem is that reiserfs_file_release() locks inode's mutex while mm's mmap_sem is locked?


> which lock already depends on the new lock.
> 
> 
> the existing dependency chain (in reverse order) is:
> 
> -> #1 (&mm->mmap_sem){----}:
>        [<b013e3fb>] __lock_acquire+0xdee/0xf9c
>        [<b013e600>] lock_acquire+0x57/0x70
>        [<b0137b92>] down_read+0x3a/0x4c
>        [<b01b6b88>] reiserfs_remount+0x176/0x42a
>        [<b016ba21>] do_remount_sb+0xb9/0x10f
>        [<b017ebe7>] do_mount+0x1b6/0x616
>        [<b017f0b6>] sys_mount+0x6f/0xa9
>        [<b0103f04>] sysenter_past_esp+0x5d/0x99
>        [<ffffffff>] 0xffffffff
> 

> -> #0 (&inode->i_mutex){--..}:
>        [<b013e259>] __lock_acquire+0xc4c/0xf9c
>        [<b013e600>] lock_acquire+0x57/0x70
>        [<b038c3e5>] __mutex_lock_slowpath+0x73/0x297
>        [<b038c625>] mutex_lock+0x1c/0x1f
>        [<b01b17e9>] reiserfs_file_release+0x54/0x447
>        [<b016afe7>] __fput+0x53/0x101
>        [<b016b0ee>] fput+0x19/0x1c
>        [<b015bcd5>] remove_vma+0x3b/0x4d
>        [<b015c659>] do_munmap+0x17f/0x1cf
>        [<b015c6db>] sys_munmap+0x32/0x42
>        [<b0103f04>] sysenter_past_esp+0x5d/0x99
>        [<ffffffff>] 0xffffffff
> 
> other info that might help us debug this:
> 
> 1 lock held by reiser-mmap/9643:
>  #0:  (&mm->mmap_sem){----}, at: [<b015c6cf>] sys_munmap+0x26/0x42
> 
> stack backtrace:
>  [<b0104f54>] show_trace_log_lvl+0x1a/0x30
>  [<b0105626>] show_trace+0x12/0x14
>  [<b01056ad>] dump_stack+0x16/0x18
>  [<b013c48d>] print_circular_bug_tail+0x68/0x71
>  [<b013e259>] __lock_acquire+0xc4c/0xf9c
>  [<b013e600>] lock_acquire+0x57/0x70
>  [<b038c3e5>] __mutex_lock_slowpath+0x73/0x297
>  [<b038c625>] mutex_lock+0x1c/0x1f
>  [<b01b17e9>] reiserfs_file_release+0x54/0x447
>  [<b016afe7>] __fput+0x53/0x101
>  [<b016b0ee>] fput+0x19/0x1c
>  [<b015bcd5>] remove_vma+0x3b/0x4d
>  [<b015c659>] do_munmap+0x17f/0x1cf
>  [<b015c6db>] sys_munmap+0x32/0x42
>  [<b0103f04>] sysenter_past_esp+0x5d/0x99
>  =======================
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
