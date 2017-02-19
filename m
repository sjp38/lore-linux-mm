Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF3646B0038
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 10:00:41 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gh4so14840261wjb.7
        for <linux-mm@kvack.org>; Sun, 19 Feb 2017 07:00:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r1si20619993wra.91.2017.02.19.07.00.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Feb 2017 07:00:40 -0800 (PST)
Date: Sun, 19 Feb 2017 16:00:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Trying to understand OOM killer
Message-ID: <20170219150037.GB24890@dhcp22.suse.cz>
References: <1486907233.6235.29.camel@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486907233.6235.29.camel@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <paulepanter@users.sourceforge.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 12-02-17 14:47:13, Paul Menzel wrote:
> Dear Linux folks,
> 
> 
> since some time, at Linux 4.8, 4.9, and 4.10-rc6, the OOM kicks in on a
> 8 GB machine.
> 
> ```
> Feb 12 08:21:50 asrocke350m1 kernel: updatedb.mlocat invoked oom-killer: gfp_mask=0x16040d0(GFP_TEMPORARY|__GFP_COMP|__GFP_NOTRACK), nodemask=

The output is truncated. Could you send the full oom report? But this
smells like an example of the lowmem exhaustion. This is a lowmem
request on 32b system
[...]
> Feb 12 08:21:53 asrocke350m1 kernel: Node 0 active_anon:479572kB inactive_anon:70712kB active_file:125844kB inactive_file:876364kB unevictable
> Feb 12 08:21:53 asrocke350m1 kernel: DMA free:3840kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:0kB inactiv
> Feb 12 08:21:53 asrocke350m1 kernel: lowmem_reserve[]: 0 763 7663 7663
> Feb 12 08:21:53 asrocke350m1 kernel: Normal free:38764kB min:38828kB low:48532kB high:58236kB active_anon:0kB inactive_anon:0kB active_file:16
> Feb 12 08:21:53 asrocke350m1 kernel: lowmem_reserve[]: 0 0 55201 55201

lowmem is on the min watermark while there is no anonymous memory to be
reclaimed and we cannot really tell how much of the page cache as it is
truncated. We also do not know how large is the request because the
order part is missing. __GFP_COMP would suggest higher order request.

In short it is very likely that the OOM killer is genuine because the
given allocation request cannot be satisfied because the low mem
(~896MB) is depleted. This is an inherent problem of 32b kernels
unfortunately. Maybe there is a larger memory consumer in newer
kernels which changed the picture for you.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
