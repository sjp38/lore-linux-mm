Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D18F06B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:23:00 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g86so80284iod.14
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:23:00 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id z4si10646928itc.107.2017.06.20.15.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 15:22:59 -0700 (PDT)
Received: by mail-io0-x22e.google.com with SMTP id k93so147007ioi.2
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:22:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <06bde73d-ca3c-8f91-0142-ddf3af99875e@redhat.com>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-23-git-send-email-keescook@chromium.org> <06bde73d-ca3c-8f91-0142-ddf3af99875e@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 20 Jun 2017 15:22:58 -0700
Message-ID: <CAGXu5jKBB8TF7e74QkuxOu0iy6TZe3Q_0Fs21tbyq23Js3v3Mw@mail.gmail.com>
Subject: Re: [PATCH 22/23] usercopy: split user-controlled slabs to separate caches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jun 20, 2017 at 1:24 PM, Laura Abbott <labbott@redhat.com> wrote:
> On 06/19/2017 04:36 PM, Kees Cook wrote:
>> From: David Windsor <dave@nullcore.net>
>>
>> Some userspace APIs (e.g. ipc, seq_file) provide precise control over
>> the size of kernel kmallocs, which provides a trivial way to perform
>> heap overflow attacks where the attacker must control neighboring
>> allocations of a specific size. Instead, move these APIs into their own
>> cache so they cannot interfere with standard kmallocs. This is enabled
>> with CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC.
>>
>> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY_SLABS
>> code in the last public patch of grsecurity/PaX based on my understanding
>> of the code. Changes or omissions from the original code are mine and
>> don't reflect the original grsecurity/PaX code.
>>
>> Signed-off-by: David Windsor <dave@nullcore.net>
>> [kees: added SLAB_NO_MERGE flag to allow split of future no-merge Kconfig]
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>
> I just did a quick test of kspp/usercopy-whitelist/lateston my arm64 machine and got some spew:
>
> [   21.818719] Unexpected gfp: 0x4000000 (0x4000000). Fixing up to gfp: 0x14000c0 (GFP_KERNEL). Fix your code!
> [   21.828427] CPU: 7 PID: 652 Comm: irqbalance Tainted: G        W       4.12.0-rc5-whitelist+ #236
> [   21.837259] Hardware name: AppliedMicro X-Gene Mustang Board/X-Gene Mustang Board, BIOS 3.06.12 Aug 12 2016
> [   21.846955] Call trace:
> [   21.849396] [<ffff000008089b18>] dump_backtrace+0x0/0x210
> [   21.854770] [<ffff000008089d4c>] show_stack+0x24/0x30
> [   21.859798] [<ffff00000845b7bc>] dump_stack+0x90/0xb4
> [   21.864827] [<ffff00000826ff40>] new_slab+0x88/0x90
> [   21.869681] [<ffff000008272218>] ___slab_alloc+0x428/0x6b0
> [   21.875141] [<ffff0000082724f0>] __slab_alloc+0x50/0x68
> [   21.880341] [<ffff000008273208>] __kmalloc_node+0xd0/0x348
> [   21.885800] [<ffff000008223af0>] kvmalloc_node+0xa0/0xb8
> [   21.891088] [<ffff0000082bb400>] single_open_size+0x40/0xb0
> [   21.896636] [<ffff000008315a9c>] stat_open+0x54/0x60
> [   21.901576] [<ffff00000830adf8>] proc_reg_open+0x90/0x168
> [   21.906950] [<ffff00000828def4>] do_dentry_open+0x1c4/0x328
> [   21.912496] [<ffff00000828f470>] vfs_open+0x58/0x88
> [   21.917351] [<ffff0000082a1f14>] do_last+0x3d4/0x770
> [   21.922292] [<ffff0000082a233c>] path_openat+0x8c/0x2e8
> [   21.927492] [<ffff0000082a3888>] do_filp_open+0x70/0xe8
> [   21.932692] [<ffff00000828f940>] do_sys_open+0x178/0x208
> [   21.937977] [<ffff00000828fa54>] SyS_openat+0x3c/0x50
> [   21.943005] [<ffff0000080835f0>] el0_svc_naked+0x24/0x28
>
>
> I don't think 7e7844226f10 ("lockdep: allow to disable reclaim lockup detection")
> is correct after new flags are added because we will still need space
> for another bit even if lockdep is disabled. That might need to
> be fixed separately.

Err... that commit has "___GFP_NOLOCKDEP       0x4000000u", but my
tree shows it as 0x2000000u? Hmm, looks like 1bde33e05123
("include/linux/gfp.h: fix ___GFP_NOLOCKDEP value") fixed that? Oh, or
I have misread it. It looks like new GFP flags need to be added
_above_ GFP_NOLOCKDEP and have to bump GFP_NOLOCKDEP's value too? Like
this:

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index ff4f4a698ad0..deb8ac39fba5 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -40,12 +40,12 @@ struct vm_area_struct;
 #define ___GFP_DIRECT_RECLAIM  0x400000u
 #define ___GFP_WRITE           0x800000u
 #define ___GFP_KSWAPD_RECLAIM  0x1000000u
+#define ___GFP_USERCOPY                0x2000000u
 #ifdef CONFIG_LOCKDEP
-#define ___GFP_NOLOCKDEP       0x2000000u
+#define ___GFP_NOLOCKDEP       0x4000000u
 #else
 #define ___GFP_NOLOCKDEP       0
 #endif
-#define ___GFP_USERCOPY                0x4000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */


> I'm really not a fan the GFP approach though since the flags tend
> to be a little bit fragile to manage. If we're going to have to
> add something to callsites anyway, maybe we could just have an
> alternate function (kmalloc_user?) instead of a GFP flag.

This would mean building out *_user() versions for all the various
*alloc() functions, though. That gets kind of long/ugly.

The other reason to use a GFP flag is to be able to interrogate a
cache later, which will be handy for doing things like %p and kernel
symbol censorship (this is what grsecurity does with their HIDESYM
logic). "If this would write to a usercopy-whitelisted object, censor
it" etc. Though now that I go double-check, it looks like grsecurity
uses cache->usersize as an indicator of censorship-need on slab
caches, not the GFP flag, which is only used to use the split kmalloc
cache. (Though as far as flags go, there is also VM_USERCOPY for what
are now the kvmalloc*() cases.)

Perhaps this should be named GFP_USERSIZED or so?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
