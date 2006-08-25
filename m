Date: Fri, 25 Aug 2006 14:07:09 +0200
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: ext3 fsync being starved for a long time by cp and cronjob
Message-ID: <20060825120709.GZ24258@kernel.dk>
References: <200608251353.51748.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200608251353.51748.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Fri, Aug 25 2006, Andi Kleen wrote:
> My vim is right now sitting for over a minute being stalled in a fsync
> (it was several minutes overall):
> 
> vi            D ffff810077879d98     0 13905  13900                     (NOTLB)
>  ffff810077879d98 ffffffff804d1c4e 000000000000008f ffff810009256240
>  ffff81007be8e080 ffff810009256418 0000000000000001 0000000000000246
>  0000000000000003 0000000000000000 000000008022284e ffff81007bd02024
> Call Trace:
>  [<ffffffff804d1c4e>] thread_return+0x0/0xd3
>  [<ffffffff802db658>] log_wait_commit+0xa3/0xf5
>  [<ffffffff8023b05c>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff802d4cee>] journal_stop+0x1d2/0x202
>  [<ffffffff80284f13>] __writeback_single_inode+0x1ec/0x372
>  [<ffffffff8023b05c>] autoremove_wake_function+0x0/0x2e
>  [<ffffffff802850ba>] sync_inode+0x21/0x30
>  [<ffffffff802c5bd9>] ext3_sync_file+0xb1/0xc4
>  [<ffffffff8026763b>] do_fsync+0x4f/0x85
>  [<ffffffff80267694>] __do_fsync+0x23/0x36
>  [<ffffffff802094ee>] system_call+0x7e/0x83
> 
> Background load is a large cp from the same fs to a tmpfs and a cron job
> doing random cron job stuff. All on a single sata disk with a 28G partition.
> 
> While I write this other windows keep stalling too, like my 
> mailer and I have to wait to continue. I'm not sure it did fsync or not.

The problem with fsync() is that it's disconnected from the previously
submitted IO (which was async). The fsync() really wants to say "the IO
I'm submitting now and submitted previously is now sync", but we don't
do that well enough. More than a minute long stall is pretty nasty,
though. Not quite sure what the best way to fix this would be, but it's
certainly on my TODO for things to get done.

Does deadline do better?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
