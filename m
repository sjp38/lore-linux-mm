Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D25E28E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 01:59:11 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j15-v6so11749083pfi.10
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 22:59:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31-v6si1436031plj.117.2018.09.24.22.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 22:59:10 -0700 (PDT)
Date: Tue, 25 Sep 2018 07:59:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm/page_alloc: Fix panic caused by passing
 debug_guardpage_minorder or kernelcore to command line
Message-ID: <20180925055904.GM18685@dhcp22.suse.cz>
References: <1537628013-243902-1-git-send-email-zhe.he@windriver.com>
 <20180924142408.GC18685@dhcp22.suse.cz>
 <20180924144217.6cabee9f41d0d0ad1757866a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924144217.6cabee9f41d0d0ad1757866a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: zhe.he@windriver.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, osalvador@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 24-09-18 14:42:17, Andrew Morton wrote:
> On Mon, 24 Sep 2018 16:24:08 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Sat 22-09-18 22:53:32, zhe.he@windriver.com wrote:
> > > From: He Zhe <zhe.he@windriver.com>
> > > 
> > > debug_guardpage_minorder_setup and cmdline_parse_kernelcore do not check
> > > input argument before using it. The argument would be a NULL pointer if
> > > "debug_guardpage_minorder" or "kernelcore", without its value, is set in
> > > command line and thus causes the following panic.
> > > 
> > > PANIC: early exception 0xe3 IP 10:ffffffffa08146f1 error 0 cr2 0x0
> > > [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.19.0-rc4-yocto-standard+ #11
> > > [    0.000000] RIP: 0010:parse_option_str+0x11/0x90
> > > ...
> > > [    0.000000] Call Trace:
> > > [    0.000000]  cmdline_parse_kernelcore+0x19/0x41
> > > [    0.000000]  do_early_param+0x57/0x8e
> > > [    0.000000]  parse_args+0x208/0x320
> > > [    0.000000]  ? rdinit_setup+0x30/0x30
> > > [    0.000000]  parse_early_options+0x29/0x2d
> > > [    0.000000]  ? rdinit_setup+0x30/0x30
> > > [    0.000000]  parse_early_param+0x36/0x4d
> > > [    0.000000]  setup_arch+0x336/0x99e
> > > [    0.000000]  start_kernel+0x6f/0x4ee
> > > [    0.000000]  x86_64_start_reservations+0x24/0x26
> > > [    0.000000]  x86_64_start_kernel+0x6f/0x72
> > > [    0.000000]  secondary_startup_64+0xa4/0xb0
> > > 
> > > This patch adds a check to prevent the panic
> > 
> > Is this something we deeply care about? The kernel command line
> > interface is to be used by admins who know what they are doing.  Using
> > random or wrong values for these parameters can have detrimental effects
> > on the system. This particular case would blow up early, good. At least
> > it is visible immediately. This and many other parameters could have a
> > seemingly valid input (e.g. not a missing value) and subtle runtime
> > effect. You won't blow up immediately but the system is hardly usable
> > and the early checking cannot possible catch all those cases. Take a
> > mem=$N copied from one machine to another with a different memory
> > layout. While 2G can be perfectly fine on one a different machine might
> > result on a completely unusable system because the available RAM is
> > place higher.
> > 
> > So I am really wondering. Do we really want a lot of code to catch
> > kernel command line incorrect inputs? Does it really lead to better
> > quality overall? IMHO, we do have a proper documentation and we should
> > trust those starting the kernel.
> 
> No, it's not very important.  It might help some people understand why
> their kernel went splat in rare circumstances.  And it's __init code so
> the runtime impact is nil.
> 
> It bothers me that there are many other kernel parameters which have
> the same undesirable behaviour.  I'd much prefer a general fixup which
> gave all of them this treatment, but it's unclear how to do this.

If early_param took an additional argument to tell "this really requires
a parameter" then we could do it in the common code.

$ git grep "early_param(\"" | wc -l
251

quite a lot of work for something that hasn't been a problem for years I
guess. But maybe this would allow to remove ad-hoc checks in handlers
and reduce the overal code size (in LOC) in the end.
-- 
Michal Hocko
SUSE Labs
