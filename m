Date: Sat, 1 Nov 2008 18:59:24 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.28-rc2: Unable to handle kernel paging request at
 iov_iter_copy_from_user_atomic
In-Reply-To: <a4423d670811010723u3b271fcaxa7d3bdb251a8b246@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0811011837110.20211@blonde.site>
References: <a4423d670811010723u3b271fcaxa7d3bdb251a8b246@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Cc: David Miller <davem@davemloft.net>, LKML <linux-kernel@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 1 Nov 2008, Alexander Beregalov wrote:
>  2.6.28-rc2-00452-gf891caf on sparc64
> 
> How to reproduce: run dbench on tmpfs
> 
> 
> Unable to handle kernel paging request at virtual address fffff80037c1c000
> tsk->{mm,active_mm}->context = 0000000000001ae7
> tsk->{mm,active_mm}->pgd = fffff8000ec8c000
>               \|/ ____ \|/
>               "@'/ .. \`@"
>               /_| \__/ |_\
>                  \__U_/
> dbench(5007): Oops [#1]
> TSTATE: 0000000011009604 TPC: 00000000005acbac TNPC: 00000000005acbb0
> Y: 00000000    Not tainted
> TPC: <__bzero+0x20/0xc0>
> g0: 0000000000000016 g1: 0000000000000000 g2: 0000000000000000 g3:
> 0000000000033ae7
> g4: fffff8000ec9c380 g5: 0000000000000020 g6: fffff8003b834000 g7:
> ffffffffffffe8b1
> o0: fffff80037c1c8b1 o1: 00000000000008b1 o2: 0000000000000000 o3:
> fffff80037c1c8b1
> o4: 0000000000000000 o5: 0000000000034398 sp: fffff8003b836e41 ret_pc:
> 00000000005ae73c
> RPC: <copy_from_user_fixup+0x4c/0x70>
> l0: 0000000000852800 l1: 0000000011009603 l2: 0000000000827ff4 l3:
> 0000000000000400
> l4: 0000000000000000 l5: 0000000000000001 l6: 0000000000000000 l7:
> 0000000000000008
> i0: fffff80037c1e000 i1: 0000000000032398 i2: 00000000000008b1 i3:
> fffff80037c3e398
> i4: fffff80037c1e000 i5: 0000000000000000 i6: fffff8003b836f01 i7:
> 0000000000486f28
> I7: <iov_iter_copy_from_user_atomic+0x90/0xe0>
> Caller[0000000000486f28]: iov_iter_copy_from_user_atomic+0x90/0xe0
> Caller[0000000000488a58]: generic_file_buffered_write+0x108/0x2a8
> Caller[0000000000489140]: __generic_file_aio_write_nolock+0x35c/0x380
> Caller[00000000004899b4]: generic_file_aio_write+0x58/0xc8
> Caller[00000000004b23d4]: do_sync_write+0x90/0xe0
> Caller[00000000004b2ca4]: vfs_write+0x7c/0x11c
> Caller[00000000004b2d98]: sys_pwrite64+0x54/0x80
> Caller[000000000043efa4]: sys32_pwrite64+0x20/0x34
> Caller[0000000000406154]: linux_sparc_syscall32+0x34/0x40
> Caller[00000000f7e8df80]: 0xf7e8df80
> Instruction DUMP: c56a2000  808a2003  02480006 <d42a2000> 90022001
> 808a2003  1247fffd  92226001  808a2007

[ Snipped the rest of it, which is just a consequence of oopsing
  there, then a repeat of this one on a different address ]

Good find!  Though surprising it's not been found before: something
for -stable I suspect.  Please don't take my signoff too seriously,
I cannot test this myself and it needs confirmation from DaveM...


Alexander Beregalov reports oops in __bzero() called from
copy_from_user_fixup() called from iov_iter_copy_from_user_atomic(),
when running dbench on tmpfs on sparc64: its __copy_from_user_inatomic
and __copy_to_user_inatomic should be avoiding, not calling, the fixups.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 arch/sparc/include/asm/uaccess_64.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 2.6.28-rc2/arch/sparc/include/asm/uaccess_64.h	2008-10-09 23:13:53.000000000 +0100
+++ linux/arch/sparc/include/asm/uaccess_64.h	2008-11-01 18:33:59.000000000 +0000
@@ -265,8 +265,8 @@ extern long __strnlen_user(const char __
 
 #define strlen_user __strlen_user
 #define strnlen_user __strnlen_user
-#define __copy_to_user_inatomic __copy_to_user
-#define __copy_from_user_inatomic __copy_from_user
+#define __copy_to_user_inatomic ___copy_to_user
+#define __copy_from_user_inatomic ___copy_from_user
 
 #endif  /* __ASSEMBLY__ */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
