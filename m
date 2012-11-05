Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id C9DC26B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 18:04:06 -0500 (EST)
Message-ID: <50984676.1080307@redhat.com>
Date: Mon, 05 Nov 2012 18:06:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/16] mm: add anon_vma_lock to validate_mm()
References: <1352155633-8648-1-git-send-email-walken@google.com> <1352155633-8648-2-git-send-email-walken@google.com>
In-Reply-To: <1352155633-8648-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On 11/05/2012 05:46 PM, Michel Lespinasse wrote:
> Iterate vma->anon_vma_chain without anon_vma_lock may cause NULL ptr deref in
> anon_vma_interval_tree_verify(), because the node in the chain might have been
> removed.
>
> [ 1523.657950] BUG: unable to handle kernel paging request at fffffffffffffff0
> [ 1523.660022] IP: [<ffffffff8122c29c>] anon_vma_interval_tree_verify+0xc/0xa0
> [ 1523.660022] PGD 4e28067 PUD 4e29067 PMD 0
> [ 1523.675725] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 1523.750066] CPU 0
> [ 1523.750066] Pid: 9050, comm: trinity-child64 Tainted: G        W    3.7.0-rc2-next-20121025-sasha-00001-g673f98e-dirty #77
> [ 1523.750066] RIP: 0010:[<ffffffff8122c29c>]  [<ffffffff8122c29c>] anon_vma_interval_tree_verify+0xc/0xa0
> [ 1523.750066] RSP: 0018:ffff880045f81d48  EFLAGS: 00010296
> [ 1523.750066] RAX: 0000000000000000 RBX: fffffffffffffff0 RCX: 0000000000000000
> [ 1523.750066] RDX: 0000000000000000 RSI: 0000000000000001 RDI: fffffffffffffff0
> [ 1523.750066] RBP: ffff880045f81d58 R08: 0000000000000000 R09: 0000000000000f14
> [ 1523.750066] R10: 0000000000000f12 R11: 0000000000000000 R12: ffff8800096c8d70
> [ 1523.750066] R13: ffff8800096c8d00 R14: 0000000000000000 R15: ffff8800095b45e0
> [ 1523.750066] FS:  00007f7a923f3700(0000) GS:ffff880013600000(0000) knlGS:0000000000000000
> [ 1523.750066] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 1523.750066] CR2: fffffffffffffff0 CR3: 000000000969d000 CR4: 00000000000406f0
> [ 1523.750066] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 1523.750066] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 1523.750066] Process trinity-child64 (pid: 9050, threadinfo ffff880045f80000, task ffff880048eb0000)
> [ 1523.750066] Stack:
> [ 1523.750066]  ffff88000d7533f0 fffffffffffffff0 ffff880045f81da8 ffffffff812361d8
> [ 1523.750066]  ffff880045f81d98 ffff880048ee9000 ffff8800095b4580 ffff8800095b4580
> [ 1523.750066]  ffff88001d1cdb00 ffff8800095b45f0 ffff880022a4d630 ffff8800095b45e0
> [ 1523.750066] Call Trace:
> [ 1523.750066]  [<ffffffff812361d8>] validate_mm+0x58/0x1e0
> [ 1523.750066]  [<ffffffff81236aa5>] vma_adjust+0x635/0x6b0
> [ 1523.750066]  [<ffffffff81236c81>] __split_vma.isra.22+0x161/0x220
> [ 1523.750066]  [<ffffffff81237934>] split_vma+0x24/0x30
> [ 1523.750066]  [<ffffffff8122ce6a>] sys_madvise+0x5da/0x7b0
> [ 1523.750066]  [<ffffffff811cd14c>] ? rcu_eqs_exit+0x9c/0xb0
> [ 1523.750066]  [<ffffffff811802cd>] ? trace_hardirqs_on+0xd/0x10
> [ 1523.750066]  [<ffffffff83aee198>] tracesys+0xe1/0xe6
> [ 1523.750066] Code: 4c 09 ff 48 39 ce 77 9e f3 c3 0f 1f 44 00 00 31 c0 c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53
> 48 89 fb 48 83 ec 08 <48> 8b 17 48 8b 8a 90 00 00 00 48 39 4f 40 74 34 80 3d f7 1f 5c
> [ 1523.750066] RIP  [<ffffffff8122c29c>] anon_vma_interval_tree_verify+0xc/0xa0
> [ 1523.750066]  RSP <ffff880045f81d48>
> [ 1523.750066] CR2: fffffffffffffff0
> [ 1523.750066] ---[ end trace e35e5fa49072faf9 ]---
>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Figured-out-by: Bob Liu <lliubbo@gmail.com>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
