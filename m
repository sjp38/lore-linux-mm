Date: Mon, 14 Oct 2002 00:33:32 +0200
From: Henrik =?iso-8859-1?Q?St=F8rner?= <henrik@hswn.dk>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021013223332.GA870@hswn.dk>
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3DA9CA28.155BA5CB@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 13, 2002 at 12:31:52PM -0700, Andrew Morton wrote:
> Henrik Storner wrote:
> > 
> > I gave 2.5.42-mm2 a test run yesterday, and it hung the box solid
> > while doing a kernel compile. The compile stopped dead in the middle
> > of a file, and there was no response when trying to access another
> > console (no X running). Alt-sysrq worked, so it wasn't completely dead
> > - sync/umount/reboot worked.
> > 
> > Nothing in the logs - no oops or other kernel messages.
> > 
> > Rebooted and repeated the experiment with the same result,
> > so it appears to be reproducible.
> > 
> > Stock 2.5.42 has worked OK for a day now, including kernel
> > compiles - the system has performed flawlessly for a
> > couple of years as my normal workstation.
> > 
> > PII processor, 384 MB RAM, SCSI disk (ncr53c8xx driver),
> > Intel eepro/100 network adapter. Kernel config at
> > http://www.hswn.dk/config-2.5.42-mm2
> 
> Very odd.
> 
> If you have time, could you please enable "load all symbols"
> in the kernel hacking menu and capture a sysrq-T trace?
> Thanks.

Did so - built it again from a fresh kernel tree, just to be sure.
Compiler is gcc 3.2 from Red Hat 8, by the way.

Bug is still there. sysrq-T scrolls off the screen too fast for me to
read, but the last screenful has several processes like this (could
see sh, make, sh, gcc):

Call Trace:
  sys_wait4+0x209/0x4d0
  default_wake_function+0x0/0x40
  default_wake_function+0x0/0x40
  syscall_call+0x7/0xb  

The last two tasks:

cc1  R  d4d74080  20  2232  2231     2233 (NOTLB)
Call Trace:
   work_resched+0x5/0x16

as   R  d3c778c0  24  2233  2231     2232 (NOTLB)
Call Trace:
   pipe_wait+0x98/0xe0
   default_wake_function+0x0/0x40
   default_wake_function+0x0/0x40
   pipe_read+0xf9/0x240
   vfs_read+0xdc/0x150
   sys_mmap2+0x9f/0xe0
   sys_read+0x3e/0x60
   syscall_call+0x7/0xb


I captured the ALT+ScrollLock output also:

Pid 1739, comm: nfsd
EIP 0060:c0160250   CPU:0
EIP is at d_lookup+0x70/0x160
   Eflags: 00000297     Not tainted
Call Trace
   cached_lookup+0x1b/0x70
   lookup_hash+0x72/0xe0
   lookup_one_len+0x5f/0x70
   find_exported_dentry+0x61f/0x730
   reiserfs_delete_solid_item+0xfd/0x2b0
   reiserfs_delete_solid_item+0xfd/0x2b0
   check_journal_end+0x18a/0x2b0
   rcu_check_callbacks+0x59/0x90
   schedule_tick+0x348/0x350
   update_process_times+0x46/0x60
   reiserfs_decode_fh+0xc2/0x100
   nfsd_acceptable+0x0/0xe0
   fh_verify+0x38e/0x570
   nfsd_acceptable+0x0/0xe0
   nsfd_statfs+0x2f/0x70
   nfsd3_proc_fsstat+0x37/0xc0
   nfs3svc_decode_fhandle+0x38/0xb0
   nfsd_dispatch+0xce/0x230
   svc_process+0x3f6+0x5e0
   nfsd+0x13f/0x250
   nfsd+0x0/0x250
   kernel_thread_helper+0x5/0x18


If you need the full sysrq-t output, I'll have to setup a serial
console to capture it.
 
-- 
Henrik Storner <henrik@hswn.dk> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
