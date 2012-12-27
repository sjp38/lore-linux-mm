Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 8224D6B005A
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 09:53:37 -0500 (EST)
Date: Thu, 27 Dec 2012 15:53:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Linux 3.3+ and memory cgroup kernel panics
Message-ID: <20121227145334.GB21267@dhcp22.suse.cz>
References: <CAKz8sYXcY9kP=QPVAWdP4a-6Nuq-04yDJNuvBojDTfKbvj=x9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKz8sYXcY9kP=QPVAWdP4a-6Nuq-04yDJNuvBojDTfKbvj=x9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Strauss <david@davidstrauss.net>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

[Adding linux-mm to CC]

On Fri 21-12-12 18:44:23, David Strauss wrote:
> The kernel seemed to replace the cgroups memory "charging" mechanism
> in 3.3 with a more efficient implementation [1], but we think it may
> be broken under Xen virtualization and load.

What are the steps to reproduce this?

> We do not see any issue in Linux 3.2 and earlier.
> 
> We have documented panics for Fedora kernels 3.3.4-5.fc17.x86_64,
> 3.3.5-2.fc16.x86_64, and 3.6.10-2.fc16.x86_64 but *not* on Fedora
> kernels 3.1.0-7.fc16.x86_64 or 3.2.6-3.fc16.x86_64.

Are you able to reproduce with the vanilla kernel as well? Ideally with
the current Linus tree?

> Many of our services use MemoryLimit= and similar systemd options that
> create a memory cgroup for the service. This correlates with kernel
> panics under the following call path (full listing here [2]):
> 
> [20488075.457394]  [<ffffffff811825e7>] ? mem_cgroup_charge_statistics+0x17/0x60
> [20488075.457403]  [<ffffffff81184ade>] __mem_cgroup_uncharge_common+0xfe/0x330
> [20488075.457410]  [<ffffffff8100632d>] ? xen_pte_val+0x1d/0x40
> [20488075.457417]  [<ffffffff81188457>] mem_cgroup_uncharge_page+0x37/0x40
> [20488075.457424]  [<ffffffff8115e6d1>] page_remove_rmap+0xb1/0x140
> 
> It culminates in this failure:
> 
> [20488075.457183] kernel BUG at arch/x86/mm/fault.c:396!
> [20488075.457189] invalid opcode: 0000 [#1] SMP
> 
> There are also reports of similar failures [3] unrelated to systemd
> use and on non-Fedora kernels.
> 
> It appears to be an issue with re-attributing the charge for a page to
> a different cgroup. Any ideas why we would be seeing this with Linux
> 3.3+? I can generally reproduce the issue (often minutes after
> booting) on any heavily loaded machine in order to collect any
> additional data to help troubleshooting.
> 
> [1] https://lwn.net/Articles/443241/
> [2] https://gist.github.com/raw/70afc901a73e427a0a71
> [3] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1073238/comments/6
> 
> --
> David Strauss
>    | david@davidstrauss.net
>    | +1 512 577 5827 [mobile]
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
