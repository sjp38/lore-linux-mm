From: Artem Savkov <artem.savkov@gmail.com>
Subject: Re: [PATCHv12 14/37] futex, thp: remove special case for THP in
 get_futex_key
Date: Thu, 22 Oct 2015 10:24:33 +0200
Message-ID: <20151022082433.GA29487@littlebeast.usersys.redhat.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-15-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444145044-72349-15-git-send-email-kirill.shutemov@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Tue, Oct 06, 2015 at 06:23:41PM +0300, Kirill A. Shutemov wrote:
> With new THP refcounting, we don't need tricks to stabilize huge page.
> If we've got reference to tail page, it can't split under us.
> 
> This patch effectively reverts a5b338f2b0b1.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Jerome Marchand <jmarchan@redhat.com>
> ---
>  kernel/futex.c | 61 ++++++++++++----------------------------------------------
>  1 file changed, 12 insertions(+), 49 deletions(-)

This patch breaks compound page futexes with the following panic:

[   33.465456] general protection fault: 0000 [#1] SMP 
[   33.465991] CPU: 1 PID: 523 Comm: tst Not tainted 4.3.0-rc6-next-20151022 #139
[   33.466585] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
[   33.467370] task: ffff88007bf13a80 ti: ffff88006bdac000 task.ti: ffff88006bdac000
[   33.467960] RIP: 0010:[<ffffffff81132b3a>]  [<ffffffff81132b3a>] get_futex_key+0x2ba/0x410
[   33.468332] RSP: 0018:ffff88006bdafc18  EFLAGS: 00010202
[   33.468332] RAX: dead000000000000 RBX: ffffea0001a50040 RCX: 0000000000000001
[   33.468332] RDX: ffffea0001a50001 RSI: 0000000000000000 RDI: ffffea0001a50040
[   33.468332] RBP: ffff88006bdafc58 R08: 0000000000000000 R09: 0000000000000000
[   33.468332] R10: 0000000000000000 R11: 0000000000000001 R12: 00007f4983601000
[   33.468332] R13: 0000000000000001 R14: ffff88006bdafd70 R15: 0000000000000000
[   33.468332] FS:  00007f4983fa4700(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000
[   33.468332] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   33.468332] CR2: 00007f4983601000 CR3: 000000007becb000 CR4: 00000000000006a0
[   33.468332] Stack:
[   33.468332]  ffff88006bf2ed00 00000000831169c0 ffffea0001a50040 00007f4983601000
[   33.468332]  ffff88006bdafce8 ffff88006bdafd38 ffff88006bdafd70 ffff88007bf13a80
[   33.468332]  ffff88006bdafcb0 ffffffff8113329a ffff88006bdafd80 0000000000000000
[   33.468332] Call Trace:
[   33.468332]  [<ffffffff8113329a>] futex_wait_setup+0x4a/0x1d0
[   33.468332]  [<ffffffff81133540>] futex_wait+0x120/0x330
[   33.468332]  [<ffffffff8111def0>] ? enqueue_hrtimer+0x50/0x50
[   33.468332]  [<ffffffff8113587e>] do_futex+0x11e/0x1050
[   33.468332]  [<ffffffff810e9825>] ? __lock_acquire+0x8c5/0x2830
[   33.468332]  [<ffffffff8105da35>] ? kvm_clock_read+0x35/0x50
[   33.468332]  [<ffffffff8105da91>] ? kvm_clock_get_cycles+0x11/0x20
[   33.468332]  [<ffffffff81136860>] SyS_futex+0xb0/0x240
[   33.468332]  [<ffffffff81cc3db2>] entry_SYSCALL_64_fastpath+0x12/0x76
[   33.468332] Code: 48 83 05 c9 e2 54 02 01 e9 56 ff ff ff 48 8b 57 20 f6 c2 01 0f 85 43 01 00 00 a8 01 0f 85 d2 00 00 00 41 83 4e 10 01 48 8b 47 08 <48> 8b 10 49 89 56 08 48 8b 07 f6 c4 40 0f 84 82 00 00 00 48 83 
[   33.468332] RIP  [<ffffffff81132b3a>] get_futex_key+0x2ba/0x410
[   33.468332]  RSP <ffff88006bdafc18>
[   33.483135] ---[ end trace 537578e223c13ed1 ]---
[   33.483502] Kernel panic - not syncing: Fatal exception
[   33.484020] Kernel Offset: disabled
[   33.484313] ---[ end Kernel panic - not syncing: Fatal exception

This can be triggered with the following reproducer (based on
futex_wake04 test from ltp):

#include <errno.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <linux/futex.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/time.h>

#define HPGSZ 2097152
int main(int argc, char **argv) {
  long ret = 0;
  void *addr;
  uint32_t *futex;
  int pgsz = getpagesize();

  addr = mmap(NULL, HPGSZ, PROT_WRITE | PROT_READ,
              MAP_SHARED | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
  if (addr == MAP_FAILED) {
    fprintf(stderr, "Failed to alloc hugepage\n");
    return -1;
  }

  futex = (uint32_t *)((char *)addr + pgsz);
  *futex = 0;

  ret = syscall(SYS_futex, futex, FUTEX_WAIT, *futex, NULL, NULL, 0);
  if (ret < 0) {
    perror("Syscall failed");
  }

  munmap(addr, HPGSZ);

  return 0;
}

-- 
Regards,
  Artem
