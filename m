Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F35F46B0272
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:13:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u97so13000912wrc.3
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:13:31 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id r42si2982347eda.155.2017.11.15.06.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:13:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 445811C4475
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 14:13:30 +0000 (GMT)
Date: Wed, 15 Nov 2017 14:13:29 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed, Nov 15, 2017 at 12:55:59PM +0100, Michal Hocko wrote:
> On Wed 15-11-17 08:55:56, Mel Gorman wrote:
> > Yasuaki Ishimatsu reported a premature OOM when trace_buf_size=100m was
> > specified on a machine with many CPUs. The kernel tried to allocate 38.4GB
> > but only 16GB was available due to deferred memory initialisation.
> > 
> > The allocation context is within smp_init() so there are no opportunities
> > to do the deferred meminit earlier. Furthermore, the partial initialisation
> > of memory occurs before the size of the trace buffers is set so there is
> > no opportunity to adjust the amount of memory that is pre-initialised. We
> > could potentially catch when memory is low during system boot and adjust the
> > amount that is initialised serially but it's a little clumsy as it would
> > require a check in the failure path of the page allocator.  Given that
> > deferred meminit is basically a minor optimisation that only benefits very
> > large machines and trace_buf_size is somewhat specialised, it follows that
> > the most straight-forward option is to go back to serialised meminit if
> > trace_buf_size is specified.
> 
> Can we instead do a smaller trace buffer in the early stage and then
> allocate the rest after the whole memory is initialized?

Potentially yes, but it's also unnecessarily complex to setup buffers,
finish init, tear them down, set them back up etc. It's not much of an
improvement to allocate a small buffer and then grow them later.

> The early
> memory init code is quite complex to make it even more so for something
> that looks like a borderline useful usecase.

The additional complexity to memory init is marginal in comparison to
playing games with how the tracing ring buffers are allocated.

> Seriously, who is going
> need 100M trace buffer _per cpu_ during early boot?
> 

I doubt anyone well. Even the original reporter appeared to pick that
particular value just to trigger the OOM.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
