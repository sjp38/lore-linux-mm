Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8216B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 06:03:24 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n186so112759674wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:03:24 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id q133si24664454wmb.22.2015.12.14.03.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 03:03:22 -0800 (PST)
Received: by wmpp66 with SMTP id p66so55545705wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 03:03:22 -0800 (PST)
Date: Mon, 14 Dec 2015 12:03:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: !PageLocked from shmem charge path hits VM_BUG_ON with 4.4-rc4
Message-ID: <20151214110320.GB9544@dhcp22.suse.cz>
References: <20151214100156.GA4540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214100156.GA4540@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Daniel Vetter <daniel.vetter@intel.com>, David Airlie <airlied@linux.ie>, Mika Westerber <mika.westerberg@intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

JFYI: Andrey Ryabinin has noticed that this might be related to
http://lkml.kernel.org/r/CAPAsAGzrOQAABhOta_o-MzocnikjPtwJLfEKQJ3n5mbBm0T7Bw@mail.gmail.com

and indeed if somebody with pending signals would do wait_on_page_locked
then it could race AFAIU. So far I am not able to reproduce the issue
but if this is really the case then rc5 should be fixed.

On Mon 14-12-15 11:01:56, Michal Hocko wrote:
> Hi,
> This is the second time I have experienced X server hang with 4.4-rc4
> kernel. The first time (on last Friday) I thought I just crashed my machine
> because I was playing with systemtap so I haven't really looked closer
> but today I've noticed this again without any nasty things going on and
> it was actually
> VM_BUG_ON(!PageLocked(page), page)
> hit from mem_cgroup_try_charge when charging shmem page. The full
> backtrace is:
> [26189.033106] page:ffffea000401a140 count:3 mapcount:0 mapping:          (null) index:0x0
> [26189.033110] flags: 0x8000000000048008(uptodate|swapcache|swapbacked)
> [26189.033115] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> [26189.033130] ------------[ cut here ]------------
> [26189.033156] kernel BUG at mm/memcontrol.c:5270!
> [26189.033176] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
> [26189.033207] Modules linked in: binfmt_misc coretemp arc4 hwmon x86_pkg_temp_thermal kvm_intel kvm i915 irqbypass i2c_i801 iwldvm snd_hda_codec_hdmi mac80211 fbcon uvcvideo bitblit softcursor font videobuf2_vmalloc i2c_algo_bit videobuf2_memops videobuf2_v4l2 videobuf2_core v4l2_common drm_kms_helper videodev cfbfillrect media syscopyarea cfbimgblt sdhci_pci sdhci iwlwifi mmc_core sysfillrect sysimgblt fb_sys_fops cfg80211 snd_hda_codec_idt cfbcopyarea snd_hda_codec_generic snd_hda_intel drm snd_hda_codec snd_hda_core snd_pcm_oss i2c_core snd_mixer_oss fb fbdev snd_pcm video backlight snd_timer snd
> [26189.033487] CPU: 0 PID: 3429 Comm: Xorg Not tainted 4.4.0-rc4 #738
> [26189.033512] Hardware name: Dell Inc. Latitude E6320/09PHH9, BIOS A08 10/18/2011
> [26189.033542] task: ffff8800c4951c80 ti: ffff8800c4e38000 task.ti: ffff8800c4e38000
> [26189.033572] RIP: 0010:[<ffffffff8114e707>]  [<ffffffff8114e707>] mem_cgroup_try_charge+0x4e/0x21b
> [26189.033611] RSP: 0018:ffff8800c4e3b998  EFLAGS: 00010246
> [26189.033634] RAX: 0000000000000036 RBX: ffff8800c355e930 RCX: 0000000000000007
> [26189.033662] RDX: 0000000080000000 RSI: 0000000000000000 RDI: ffffffff8108a4b8
> [26189.033691] RBP: ffff8800c4e3b9c8 R08: 0000000000000002 R09: 00000000fffffffe
> [26189.033719] R10: 0000000000000000 R11: ffffffff81c5b32d R12: ffffea000401a140
> [26189.033747] R13: ffff8800c4e3ba40 R14: 0000000000006b85 R15: 0000000000021292
> [26189.033776] FS:  00007f6f7287aa00(0000) GS:ffff88012d400000(0000) knlGS:0000000000000000
> [26189.033808] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [26189.033830] CR2: 00007f24137a3c20 CR3: 00000000c353b000 CR4: 00000000000406f0
> [26189.033859] Stack:
> [26189.033868]  ffff8800c56bf000 ffff8800c355e930 0000000000006b85 0000000000000001
> [26189.033902]  0000000000006b85 00000000ffffffef ffff8800c4e3ba78 ffffffff8110fe0c
> [26189.033936]  ffff8800c4951c80 ffff8800c4951c80 ffff8800c4951c80 000000003d055000
> [26189.033971] Call Trace:
> [26189.033985]  [<ffffffff8110fe0c>] shmem_getpage_gfp+0x260/0x6e0
> [26189.034010]  [<ffffffff8111038a>] shmem_read_mapping_page_gfp+0x30/0x4b
> [26189.034056]  [<ffffffffa03f12fd>] i915_gem_object_get_pages_gtt+0xf2/0x37e [i915]
> [26189.034100]  [<ffffffffa03f2519>] i915_gem_object_get_pages+0x6b/0xb1 [i915]
> [26189.034142]  [<ffffffffa03f5d94>] i915_gem_object_do_pin+0x3c9/0x7f8 [i915]
> [26189.034181]  [<ffffffffa03f61fd>] i915_gem_object_pin+0x3a/0x3c [i915]
> [26189.034219]  [<ffffffffa03e8714>] i915_gem_execbuffer_reserve_vma.isra.4+0x91/0x13d [i915]
> [26189.034261]  [<ffffffffa03e8a25>] i915_gem_execbuffer_reserve.isra.5+0x265/0x2f4 [i915]
> [26189.034304]  [<ffffffffa03e91de>] i915_gem_do_execbuffer.isra.6+0x72a/0xf9d [i915]
> [26189.034336]  [<ffffffff810fd2ca>] ? __probe_kernel_read+0x3d/0x85
> [26189.034371]  [<ffffffffa03ea5c0>] i915_gem_execbuffer2+0x14b/0x1bb [i915]
> [26189.034406]  [<ffffffffa00e7a36>] drm_ioctl+0x255/0x385 [drm]
> [26189.034439]  [<ffffffffa03ea475>] ? i915_gem_execbuffer+0x275/0x275 [i915]
> [26189.034468]  [<ffffffff8106979f>] ? preempt_count_sub+0xc3/0xcf
> [26189.034493]  [<ffffffff81160e89>] do_vfs_ioctl+0x3a8/0x41b
> [26189.034517]  [<ffffffff811691b6>] ? __fget+0x77/0x83
> [26189.034538]  [<ffffffff81160f3f>] SyS_ioctl+0x43/0x61
> [26189.034560]  [<ffffffff8156a9d7>] entry_SYSCALL_64_fastpath+0x12/0x6a
> 
> $ addr2line -a ffffffff8110fe0c  -e vmlinux-4.4.0-rc4 
> 0xffffffff8110fe0c
> /home/miso/devel/linux-tree/linus-tree/mm/shmem.c:1141
> 
> So this seems to be:
> 		/* We have to do this with page locked to prevent races */
> 		lock_page(page);
> 		if (!PageSwapCache(page) || page_private(page) != swap.val ||
> 		    !shmem_confirm_swap(mapping, index, swap)) {
> 			error = -EEXIST;	/* try again */
> 			goto unlock;
> 		}
> 		if (!PageUptodate(page)) {
> 			error = -EIO;
> 			goto failed;
> 		}
> 		wait_on_page_writeback(page);
> 
>                 if (shmem_should_replace_page(page, gfp)) {
>                         error = shmem_replace_page(&page, gfp, info, index);
>                         if (error)
>                                 goto failed;
>                 }
> 
>                 error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg);
>                 if (!error) {
>                         error = shmem_add_to_page_cache(page, mapping, index,
>                                                 swp_to_radix_entry(swap));
> 
> So we are explicitly locking the page and shmem_replace_page locks
> the new page as well. It seems like the page got unlocked while we
> were waiting for the writeback or something like that. So far I do not
> suspect i915.  But it is worth mentioning that the BUG_ON was hit there
> twice with the exactly same code path so who knows. Maybe this is just
> because it is the only major user of shmem on my system...
> 
> I didn't get to investigate any further or try to reproduce it again yet
> but I will go on debugging.  Maybe this ring bells.
> 
> Config is attached.
> 
> I am currently running with the following on top of rc4 to see whether
> this is really related to waiting on the writeback.
> ---
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2afcdbbdb685..d5d524eb6c9d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -1129,6 +1129,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  			error = -EIO;
>  			goto failed;
>  		}
> +		if (!PageLocked(page))
> +			dump_page(page, "Page not locked");
>  		wait_on_page_writeback(page);
>  
>  		if (shmem_should_replace_page(page, gfp)) {
> 
> -- 
> Michal Hocko
> SUSE Labs
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
