Date: Thu, 31 Oct 2002 08:54:43 +0100
From: Henrik =?iso-8859-1?Q?St=F8rner?= <henrik@hswn.dk>
Subject: Re: [FIX] Re: 2.5.42-mm2 hangs system
Message-ID: <20021031075443.GA32455@hswn.dk>
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk> <20021016185908.GA863@hswn.dk> <20021030151846.D2613@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021030151846.D2613@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maneesh Soni <maneesh@in.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Maneesh,

On Wed, Oct 30, 2002 at 03:18:46PM +0530, Maneesh Soni wrote:
> Hello Henrik,
> 
> I hope the following patch should solve your problem. The patch is made
> over 2.5.44-mm6 kernel. The problem was due to anonymous dentries getting
> connected with DCACHE_UNHASHED flag set.

the patch does fix the sudden halts that I was seeing with
2.5.42-mm2. The system has now survived about 10 successive kernel
compiles and it is still running.

There are a couple of odd things going on, though - but I don't know
for sure if they are related to the mm patch or not. I am seeing these
messages regularly - disk activity seems to provoke them.

Oct 30 23:14:44 osiris kernel: bad: scheduling while atomic!
Oct 30 23:14:44 osiris kernel: Call Trace:
Oct 30 23:14:44 osiris kernel:  [do_schedule+763/768] do_schedule+0x2fb/0x300
Oct 30 23:14:44 osiris kernel:  [<c011973b>] do_schedule+0x2fb/0x300
Oct 30 23:14:44 osiris kernel:  [kswapd+236/284] kswapd+0xec/0x11c
Oct 30 23:14:44 osiris kernel:  [<c013bd9c>] kswapd+0xec/0x11c
Oct 30 23:14:44 osiris kernel:  [autoremove_wake_function+0/80] autoremove_wake_function+0x0/0x50
Oct 30 23:14:44 osiris kernel:  [<c011ae70>] autoremove_wake_function+0x0/0x50
Oct 30 23:14:44 osiris kernel:  [preempt_schedule+54/80] preempt_schedule+0x36/0x50
Oct 30 23:14:44 osiris kernel:  [<c0119776>] preempt_schedule+0x36/0x50
Oct 30 23:14:44 osiris kernel:  [autoremove_wake_function+0/80] autoremove_wake_function+0x0/0x50
Oct 30 23:14:44 osiris kernel:  [<c011ae70>] autoremove_wake_function+0x0/0x50
Oct 30 23:14:44 osiris kernel:  [kswapd+0/284] kswapd+0x0/0x11c
Oct 30 23:14:44 osiris kernel:  [<c013bcb0>] kswapd+0x0/0x11c
Oct 30 23:14:44 osiris kernel:  [kernel_thread_helper+5/24] kernel_thread_helper+0x5/0x18
Oct 30 23:14:44 osiris kernel:  [<c01074cd>] kernel_thread_helper+0x5/0x18
Oct 30 23:14:44 osiris kernel: 

And one full blown Oops apparently when I tried to login to an X
session (I use KDE for the desktop):

Oct 31 08:38:11 osiris kernel: Unable to handle kernel paging request at virtual address 4172f058
Oct 31 08:38:11 osiris kernel:  printing eip:
Oct 31 08:38:11 osiris kernel: 083b80d4
Oct 31 08:38:11 osiris kernel: *pde = 06437067
Oct 31 08:38:11 osiris kernel: *pte = 00000000
Oct 31 08:38:11 osiris kernel: Oops: 0006
Oct 31 08:38:11 osiris kernel: eepro100 mii sb sb_lib uart401 sound soundcore  
Oct 31 08:38:11 osiris kernel: CPU:    0
Oct 31 08:38:11 osiris kernel: EIP:    0023:[serport_exit+138115172/-1072695408]    Not tainted
Oct 31 08:38:11 osiris kernel: EIP:    0023:[<083b80d4>]    Not tainted
Oct 31 08:38:11 osiris kernel: EFLAGS: 00013206
Oct 31 08:38:11 osiris kernel: eax: 0021449c   ebx: 4172f058   ecx: 00000000   edx: 00000000
Oct 31 08:38:11 osiris kdm[8787]: Server for display :0 terminated unexpectedly
Oct 31 08:38:11 osiris kernel: esi: 088674dc   edi: 0021449c   ebp: 00000002   esp: bffff58c
Oct 31 08:38:12 osiris kernel: ds: 002b   es: 002b   ss: 002b
Oct 31 08:38:12 osiris kernel: Process X (pid: 25678, threadinfo=d1f54000 task=d675cce0)
Oct 31 08:38:12 osiris kernel:  <6>note: X[25678] exited with preempt_count 2
Oct 31 08:38:12 osiris kernel: Debug: sleeping function called from illegal context at include/asm/semaphore.h:119
Oct 31 08:38:12 osiris kernel: Call Trace:
Oct 31 08:38:12 osiris kernel:  [shm_close+48/192] shm_close+0x30/0xc0
Oct 31 08:38:12 osiris kernel:  [<c0200190>] shm_close+0x30/0xc0
Oct 31 08:38:12 osiris kernel:  [exit_mmap+214/224] exit_mmap+0xd6/0xe0
Oct 31 08:38:12 osiris kernel:  [<c0133146>] exit_mmap+0xd6/0xe0
Oct 31 08:38:12 osiris kernel:  [mmput+78/160] mmput+0x4e/0xa0
Oct 31 08:38:12 osiris kernel:  [<c011b10e>] mmput+0x4e/0xa0
Oct 31 08:38:12 osiris kernel:  [do_exit+197/688] do_exit+0xc5/0x2b0
Oct 31 08:38:12 osiris kernel:  [<c0120aa5>] do_exit+0xc5/0x2b0
Oct 31 08:38:12 osiris kernel:  [die+134/144] die+0x86/0x90
Oct 31 08:38:12 osiris kernel:  [<c010a456>] die+0x86/0x90
Oct 31 08:38:12 osiris kernel:  [do_page_fault+358/1268] do_page_fault+0x166/0x4f4
Oct 31 08:38:12 osiris kernel:  [<c0118006>] do_page_fault+0x166/0x4f4
Oct 31 08:38:12 osiris kernel:  [vfs_read+230/320] vfs_read+0xe6/0x140
Oct 31 08:38:12 osiris kernel:  [<c0149cf6>] vfs_read+0xe6/0x140
Oct 31 08:38:12 osiris kernel:  [sys_setitimer+86/192] sys_setitimer+0x56/0x160
Oct 31 08:38:12 osiris kernel:  [<c0121c16>] sys_setitimer+0x56/0x160
Oct 31 08:38:12 osiris kernel:  [sys_read+69/96] sys_read+0x45/0x60
Oct 31 08:38:12 osiris kernel:  [<c0149f95>] sys_read+0x45/0x60
Oct 31 08:38:12 osiris kernel:  [do_page_fault+0/1268] do_page_fault+0x0/0x4f4
Oct 31 08:38:12 osiris kernel:  [<c0117ea0>] do_page_fault+0x0/0x4f4
Oct 31 08:38:12 osiris kernel:  [error_code+45/56] error_code+0x2d/0x38
Oct 31 08:38:12 osiris kernel:  [<c0109e75>] error_code+0x2d/0x38
Oct 31 08:38:12 osiris kernel: 

-- 
Henrik Storner <henrik@hswn.dk> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
