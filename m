Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75EFE6B02AF
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 14:35:33 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id a125so3256771ita.8
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 11:35:33 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [69.252.207.42])
        by mx.google.com with ESMTPS id t185si2070316itd.10.2017.11.07.11.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 11:35:32 -0800 (PST)
Date: Tue, 7 Nov 2017 13:34:30 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: WARNING in __check_heap_object
In-Reply-To: <001a114096fec09301055d68d784@google.com>
Message-ID: <alpine.DEB.2.20.1711071331420.20040@nuc-kabylake>
References: <001a114096fec09301055d68d784@google.com>
MIME-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; FORMAT=flowed; DELSP=yes
Content-ID: <alpine.DEB.2.20.1711071331422.20040@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+2357afb48acb76780f3c18867ccfb7aa6fd6c4c9@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, Kees Cook <keescook@chromium.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com

Well that is a security thingamy related to CONFIG_HARDDENED_USERCOPY.
Kees?


----- Offending function

#ifdef CONFIG_HARDENED_USERCOPY
/*
 * Rejects objects that are incorrectly sized.
 *
 * Returns NULL if check passes, otherwise const char * to name of cache
 * to indicate an error.
 */
const char *__check_heap_object(const void *ptr, unsigned long n,
                                struct page *page)
{
        struct kmem_cache *cachep;
        unsigned int objnr;
        unsigned long offset;

        /* Find and validate object. */
        cachep = page->slab_cache;
        objnr = obj_to_index(cachep, page, (void *)ptr);
        BUG_ON(objnr >= cachep->num);

        /* Find offset within object. */
        offset = ptr - index_to_obj(cachep, page, objnr) -
obj_offset(cachep);

        /* Allow address range falling entirely within object size. */
        if (offset <= cachep->object_size && n <= cachep->object_size -
offset)
                return NULL;

        return cachep->name;
}
#endif /* CONFIG_HARDENED_USERCOPY */

On Tue, 7 Nov 2017, syzbot wrote:

> Hello,
>
> syzkaller hit the following crash on 5a3517e009e979f21977d362212b7729c5165d92
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 2994 at mm/slab.c:4434 __check_heap_object+0xbc/0xd0
> mm/slab.c:4433
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 1 PID: 2994 Comm: syzkaller408738 Not tainted 4.14.0-rc7-next-20171103+
> #38
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> 01/01/2011
> Call Trace:
> __dump_stack lib/dump_stack.c:17 [inline]
> dump_stack+0x194/0x257 lib/dump_stack.c:53
> panic+0x1e4/0x41c kernel/panic.c:183
> __warn+0x1c4/0x1e0 kernel/panic.c:546
> report_bug+0x211/0x2d0 lib/bug.c:184
> fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:177
> do_trap_no_signal arch/x86/kernel/traps.c:211 [inline]
> do_trap+0x260/0x390 arch/x86/kernel/traps.c:260
> do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:297
> do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:310
> invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:906
> RIP: 0010:__check_heap_object+0xbc/0xd0 mm/slab.c:4433
> RSP: 0018:ffff8801ce0670d8 EFLAGS: 00010282
> RAX: 000000000000004a RBX: 0000000000000000 RCX: 0000000000000000
> RDX: 000000000000004a RSI: 1ffff10039c0cddb RDI: ffffed0039c0ce0f
> RBP: ffff8801ce0670e0 R08: 0000000000000001 R09: 0000000000000000
> R10: ffff8801ceb0a500 R11: 0000000000000000 R12: ffffea00074a6c80
> R13: ffff8801d29b26b0 R14: 000000000000000b R15: ffffea00074a6c80
> check_heap_object mm/usercopy.c:222 [inline]
> __check_object_size+0x22c/0x4f0 mm/usercopy.c:248
> check_object_size include/linux/thread_info.h:112 [inline]
> check_copy_size include/linux/thread_info.h:143 [inline]
> copy_to_user include/linux/uaccess.h:154 [inline]
> sctp_getsockopt_events net/sctp/socket.c:4972 [inline]
> sctp_getsockopt+0x2b90/0x70b0 net/sctp/socket.c:7012
> sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2924
> SYSC_getsockopt net/socket.c:1882 [inline]
> SyS_getsockopt+0x178/0x340 net/socket.c:1864
> entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x43fca9
> RSP: 002b:00007fff12a2dfa8 EFLAGS: 00000203 ORIG_RAX: 0000000000000037
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043fca9
> RDX: 000000000000000b RSI: 0000000000000084 RDI: 0000000000000003
> RBP: 0000000000000086 R08: 0000000020290000 R09: 0000000000000000
> R10: 000000002099aff5 R11: 0000000000000203 R12: 0000000000401610
> R13: 00000000004016a0 R14: 0000000000000000 R15: 0000000000000000
> Dumping ftrace buffer:
>   (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug report.
> Note: all commands must start from beginning of the line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
