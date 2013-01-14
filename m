Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4D0076B0044
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 13:57:49 -0500 (EST)
Date: Mon, 14 Jan 2013 20:57:43 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: qemu-kvm hangs at start up under 3.8.0-rc3-00074-gb719f43 (works
 with CONFIG_LOCKDEP)
Message-ID: <20130114185743.GC12489@redhat.com>
References: <20130113222958.64840242@omega.digital-domain.net>
 <20130114132736.GA12489@redhat.com>
 <20130114182449.5a163101@omega.digital-domain.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130114182449.5a163101@omega.digital-domain.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Clayton <andrew@digital-domain.net>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Copying linux-mm.

On Mon, Jan 14, 2013 at 06:24:49PM +0000, Andrew Clayton wrote:
> On Mon, 14 Jan 2013 15:27:36 +0200, Gleb Natapov wrote:
> 
> > On Sun, Jan 13, 2013 at 10:29:58PM +0000, Andrew Clayton wrote:
> > > When running qemu-kvm under 64but Fedora 16 under current 3.8, it
> > > just hangs at start up. Dong a ps -ef hangs the process at the
> > > point where it would display the qemu process (trying to list the
> > > qemu-kvm /proc pid directory contents just hangs ls).
> > > 
> > > I also noticed some other weirdness at this point like Firefox
> > > hanging for many seconds at a time and increasing load average.
> > > 
> > > The qemu command I was trying to run was
> > > 
> > > $ qemu-kvm -m 512 -smp 2 -vga vmware -k en-gb -drive
> > > file=/home/andrew/machines/qemu/f16-i386.img,if=virtio
> > > 
> > > Here's the last few lines of a strace on it at start up.
> > > 
> > > open("/home/andrew/machines/qemu/f16-i386.img",
> > > O_RDWR|O_DSYNC|O_CLOEXEC) = 8 lseek(8, 0,
> > > SEEK_END)                   = 9100722176 pread(8,
> > > "QFI\373\0\0\0\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\20\0\0\0\2\200\0\0\0"...,
> > > 512, 0) = 512 pread(8,
> > > "\200\0\0\0\0\4\0\0\200\0\0\0\0\10\0\0\200\0\0\0\2\210\0\0\200\0\0\0\2\233\0\0"...,
> > > 512, 65536) = 512 brk(0)                                  =
> > > 0x7faf12db0000 brk(0x7faf12ddd000
> > > 
> > > It's hanging in that brk syscall. The load average also then starts
> > > to increase.
> > > 
> > > 
> > > However. I can make it run fine, if I enable CONFIG_LOCKDEP. But
> > > the only thing in dmesg I get is the usual.
> > > 
> > > kvm: SMP vm created on host with unstable TSC; guest TSC will not
> > > be reliable
> > > 
> > > I've attached both working and non-working .configs. The only
> > > difference being the lock checking enabled in config.good.
> > > 
> > > The most recent kernel I had it working in was 3.7.0
> > > 
> > > System is a Quad Core Intel running 64bit Fedora 16.
> > > 
> > Can you run "echo t > /proc/sysrq-trigger" and see where it hangs?
> 
> Here you go, here's the bash process, qemu and a kvm bit. (From the
> above command)
> 
> bash            S ffff88013b2b0d00     0  3203   3133 0x00000000
>  ffff880114dabe58 0000000000000082 8000000113558065 ffff880114dabfd8
>  ffff880114dabfd8 0000000000004000 ffff88013b0c5b00 ffff88013b2b0d00
>  ffff880114dabd88 ffffffff8109067d ffffea0004536670 ffffea0004536640
> Call Trace:
>  [<ffffffff8109067d>] ? default_wake_function+0xd/0x10
>  [<ffffffff8108a315>] ? atomic_notifier_call_chain+0x15/0x20
>  [<ffffffff8133d84f>] ? tty_get_pgrp+0x3f/0x50
>  [<ffffffff810819ac>] ? pid_vnr+0x2c/0x30
>  [<ffffffff8133fe54>] ? tty_ioctl+0x7b4/0xbd0
>  [<ffffffff8106bf62>] ? wait_consider_task+0x102/0xaf0
>  [<ffffffff815c00e4>] schedule+0x24/0x70
>  [<ffffffff8106cb24>] do_wait+0x1d4/0x200
>  [<ffffffff8106d9cb>] sys_wait4+0x9b/0xf0
>  [<ffffffff8106b9f0>] ? task_stopped_code+0x50/0x50
>  [<ffffffff815c1ad2>] system_call_fastpath+0x16/0x1b
> 
> qemu-kvm        D ffff88011ab8c8b8     0  3345   3203 0x00000000
>  ffff880112129cd8 0000000000000082 ffff880112129c50 ffff880112129fd8
>  ffff880112129fd8 0000000000004000 ffff88013b04ce00 ffff880139da1a00
>  0000000000000000 00000000000280da ffff880112129d38 ffffffff810d3300
> Call Trace:
>  [<ffffffff810d3300>] ? __alloc_pages_nodemask+0xf0/0x7c0
>  [<ffffffff811273c6>] ? touch_atime+0x66/0x170
>  [<ffffffff810cdabf>] ? generic_file_aio_read+0x5bf/0x730
>  [<ffffffff815c00e4>] schedule+0x24/0x70
>  [<ffffffff815c0cdd>] rwsem_down_failed_common+0xbd/0x150
>  [<ffffffff815c0da3>] rwsem_down_write_failed+0x13/0x15
>  [<ffffffff812d1be3>] call_rwsem_down_write_failed+0x13/0x20
>  [<ffffffff815bf4dd>] ? down_write+0x2d/0x34
>  [<ffffffff810f0724>] vma_adjust+0xe4/0x610
>  [<ffffffff810f0fa4>] vma_merge+0x1b4/0x270
>  [<ffffffff810f1fa6>] do_brk+0x196/0x330
>  [<ffffffff810f2217>] sys_brk+0xd7/0x130
>  [<ffffffff815c1ad2>] system_call_fastpath+0x16/0x1b
> kvm-pit/3345    S 0000000000000000     0  3346      2 0x00000000
>  ffff880112149e68 0000000000000046 ffff88013fd91340 ffff880112149fd8
>  ffff880112149fd8 0000000000004000 ffff88013b04ce00 ffff88013b2b6e80
>  ffff880112149ea8 ffffffff815bfb6c ffff880112149db8 ffff880112149fd8
> Call Trace:
>  [<ffffffff815bfb6c>] ? __schedule+0x2dc/0x830
>  [<ffffffff810904be>] ? try_to_wake_up+0xbe/0x270
>  [<ffffffff8109067d>] ? default_wake_function+0xd/0x10
>  [<ffffffff815c00e4>] schedule+0x24/0x70
>  [<ffffffff81084975>] kthread_worker_fn+0xb5/0x110
>  [<ffffffff810848c0>] ? __init_kthread_worker+0x20/0x20
>  [<ffffffff810842fb>] kthread+0xbb/0xc0
>  [<ffffffff81084240>] ? __kthread_parkme+0x80/0x80
>  [<ffffffff815c1a2c>] ret_from_fork+0x7c/0xb0
>  [<ffffffff81084240>] ? __kthread_parkme+0x80/0x80
> 
> Cheers,
> Andrew

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
