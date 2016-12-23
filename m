Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D68866B0304
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 17:26:08 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so43109248wma.2
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 14:26:08 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id m14si4140822wjw.246.2016.12.23.14.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 14:26:07 -0800 (PST)
Date: Fri, 23 Dec 2016 23:26:00 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: [RFC PATCH] mm, memcg: fix (Re: OOM: Better, but still there on)
Message-ID: <20161223222559.GA5568@teela.multi.box>
References: <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
 <20161222191719.GA19898@dhcp22.suse.cz>
 <20161222214611.GA3015@boerne.fritz.box>
 <20161223105157.GB23109@dhcp22.suse.cz>
 <20161223121851.GA27413@ppc-nas.fritz.box>
 <20161223125728.GE23109@dhcp22.suse.cz>
 <20161223144738.GB23117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161223144738.GB23117@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri, Dec 23, 2016 at 03:47:39PM +0100, Michal Hocko wrote:
> 
> Nils, even though this is still highly experimental, could you give it a
> try please?

Yes, no problem! So I kept the very first patch you sent but had to
revert the latest version of the debugging patch (the one in
which you added the "mm_vmscan_inactive_list_is_low" event) because
otherwise the patch you just sent wouldn't apply. Then I rebooted with
memory cgroups enabled again, and the first thing that strikes the eye
is that I get this during boot:

[    1.568174] ------------[ cut here ]------------
[    1.568327] WARNING: CPU: 0 PID: 1 at mm/memcontrol.c:1032 mem_cgroup_update_lru_size+0x118/0x130
[    1.568543] mem_cgroup_update_lru_size(f4406400, 2, 1): lru_size 0 but not empty
[    1.568754] Modules linked in:
[    1.568922] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.9.0-gentoo #6
[    1.569052] Hardware name: Hewlett-Packard Compaq 15 Notebook PC/21F7, BIOS F.22 08/06/2014
[    1.571750]  f44e5b84 c142bdee f44e5bc8 c1b5ade0 f44e5bb4 c103ab1d c1b583e4 f44e5be4
[    1.572262]  00000001 c1b5ade0 00000408 c11603d8 00000408 00000000 c1b5af73 00000001
[    1.572774]  f44e5bd0 c103ab76 00000009 00000000 f44e5bc8 c1b583e4 f44e5be4 f44e5c18
[    1.573285] Call Trace:
[    1.573419]  [<c142bdee>] dump_stack+0x47/0x69
[    1.573551]  [<c103ab1d>] __warn+0xed/0x110
[    1.573681]  [<c11603d8>] ? mem_cgroup_update_lru_size+0x118/0x130
[    1.573812]  [<c103ab76>] warn_slowpath_fmt+0x36/0x40
[    1.573942]  [<c11603d8>] mem_cgroup_update_lru_size+0x118/0x130
[    1.574076]  [<c1111467>] __pagevec_lru_add_fn+0xd7/0x1b0
[    1.574206]  [<c1111390>] ? perf_trace_mm_lru_insertion+0x150/0x150
[    1.574336]  [<c111239d>] pagevec_lru_move_fn+0x4d/0x80
[    1.574465]  [<c1111390>] ? perf_trace_mm_lru_insertion+0x150/0x150
[    1.574595]  [<c11127e5>] __lru_cache_add+0x45/0x60
[    1.574724]  [<c1112848>] lru_cache_add+0x8/0x10
[    1.574852]  [<c1102fc1>] add_to_page_cache_lru+0x61/0xc0
[    1.574982]  [<c110418e>] pagecache_get_page+0xee/0x270
[    1.575111]  [<c11060f0>] grab_cache_page_write_begin+0x20/0x40
[    1.575243]  [<c118b955>] simple_write_begin+0x25/0xd0
[    1.575372]  [<c11061b8>] generic_perform_write+0xa8/0x1a0
[    1.575503]  [<c1106447>] __generic_file_write_iter+0x197/0x1f0
[    1.575634]  [<c110663f>] generic_file_write_iter+0x19f/0x2b0
[    1.575766]  [<c11669c1>] __vfs_write+0xd1/0x140
[    1.575897]  [<c1166bc5>] vfs_write+0x95/0x1b0
[    1.576026]  [<c1166daf>] SyS_write+0x3f/0x90
[    1.576157]  [<c1ce4474>] xwrite+0x1c/0x4b
[    1.576285]  [<c1ce44c5>] do_copy+0x22/0xac
[    1.576413]  [<c1ce42c3>] write_buffer+0x1d/0x2c
[    1.576540]  [<c1ce42f0>] flush_buffer+0x1e/0x70
[    1.576670]  [<c1d0eae8>] unxz+0x149/0x211
[    1.576798]  [<c1d0e99f>] ? unlzo+0x359/0x359
[    1.576926]  [<c1ce4946>] unpack_to_rootfs+0x14f/0x246
[    1.577054]  [<c1ce42d2>] ? write_buffer+0x2c/0x2c
[    1.577183]  [<c1ce4216>] ? initrd_load+0x3b/0x3b
[    1.577312]  [<c1ce4b20>] ? maybe_link.part.3+0xe3/0xe3
[    1.577443]  [<c1ce4b67>] populate_rootfs+0x47/0x8f
[    1.577573]  [<c1000456>] do_one_initcall+0x36/0x150
[    1.577701]  [<c1ce351e>] ? repair_env_string+0x12/0x54
[    1.577832]  [<c1054ded>] ? parse_args+0x25d/0x400
[    1.577962]  [<c1ce3baf>] ? kernel_init_freeable+0x101/0x19e
[    1.578092]  [<c1ce3bcf>] kernel_init_freeable+0x121/0x19e
[    1.578222]  [<c19b0700>] ? rest_init+0x60/0x60
[    1.578350]  [<c19b070b>] kernel_init+0xb/0x100
[    1.578480]  [<c1060c7c>] ? schedule_tail+0xc/0x50
[    1.578608]  [<c19b0700>] ? rest_init+0x60/0x60
[    1.578737]  [<c19b5db7>] ret_from_fork+0x1b/0x28
[    1.578871] ---[ end trace cf6f1adac9dfe60e ]---

The machine then continued to boot just normally, however, so I
started my ordinary tests. And in fact, they were working just fine,
i.e. no OOMing anymore, even during heavy tarball unpacking.

Would it make sense to capture more trace data for you at this point?
As I'm on the go, I don't currently have a second machine for
capturing over the network, but since we're not having OOMs or other
issues now, capturing to file should probably work just fine.

I'll keep the patch applied and see if I notice anything else that
doesn't look normal during day to day usage, especially during my
ordinary Gentoo updates, which consist of a lot of fetching /
unpacking / building, and in the recent past had been very problematic
(in fact, that was where the problem first struck me and the "heavy
tarball unpacking" test was then just what I distilled it down to
in order to manually reproduce this with the least time and effort
possible).

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
