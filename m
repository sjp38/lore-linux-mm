Date: Tue, 04 Feb 2003 14:15:31 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Broken SCSI code in the BK tree (was: 2.5.59-mm8)
Message-ID: <384960000.1044396931@flay>
In-Reply-To: <20030204001709.5e2942e8.akpm@digeo.com>
References: <20030203233156.39be7770.akpm@digeo.com><167540000.1044346173@[10.10.2.4]> <20030204001709.5e2942e8.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> "Martin J. Bligh" <mbligh@aracnet.com> wrote:
>> 
>> > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm8/
>> 
>> Booted to login prompt, then immediately oopsed 
>> (16-way NUMA-Q, mm6 worked fine). At a wild guess, I'd suspect 
>> irq_balance stuff.
>> 
> 
> There are a lot of scsi updates in Linus's tree.  Can you please
> test just
> 
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm8/broken-out/linus.patch

Yup, the SCSI code in Linus' tree has broken since 2.5.59.
I reproduced this on my 4-way SMP machine (panic from that below), 
so it's not just NUMA-Q wierdness ;-)

M.

Unable to handle kernel NULL pointer dereference at virtual address 0000013c
 printing eip:
c01c1986
*pde = 00000000
Oops: 0002
CPU:    3
EIP:    0060:[<c01c1986>]    Not tainted
EFLAGS: 00010046
EIP is at isp1020_intr_handler+0x1e6/0x290
eax: 00000000   ebx: f7c42080   ecx: 00000000   edx: 00000054
esi: 00000002   edi: 00000013   ebp: 00000000   esp: f7f97efc
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=f7f96000 task=f7f9d240)
Stack: f7c42080 f7c52800 00000002 00000013 f7f97f80 00000003 00000003 f7c5289c 
       f7c52800 c01c1791 00000013 f7c52800 f7f97f80 f7ffe1e0 24000001 c010a815 
       00000013 f7c52800 f7f97f80 c028fa60 00000260 00000013 f7f97f78 c010a9e6 
Call Trace:
 [<c01c1791>] do_isp1020_intr_handler+0x25/0x34
 [<c010a815>] handle_IRQ_event+0x29/0x4c
 [<c010a9e6>] do_IRQ+0x96/0x100
 [<c0106ca0>] default_idle+0x0/0x34
 [<c01094a8>] common_interrupt+0x18/0x20
 [<c0106ca0>] default_idle+0x0/0x34
 [<c0106cc9>] default_idle+0x29/0x34
 [<c0106d53>] cpu_idle+0x37/0x48
 [<c0119d21>] printk+0x149/0x160

Code: 89 85 3c 01 00 00 83 c4 04 eb 0a c7 85 3c 01 00 00 00 00 07 
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
