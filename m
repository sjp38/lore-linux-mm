Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0EC28025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:06:36 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p96so14067872wrb.12
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 02:06:36 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id g93si867510ede.460.2017.11.16.02.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 02:06:34 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 6CBB31C179A
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 10:06:34 +0000 (GMT)
Date: Thu, 16 Nov 2017 10:06:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
 <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
 <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com

On Thu, Nov 16, 2017 at 09:54:33AM +0100, Michal Hocko wrote:
> On Wed 15-11-17 14:17:52, YASUAKI ISHIMATSU wrote:
> > Hi Michal and Mel,
> > 
> > To reproduce the issue, I specified the large trace buffer. The issue also occurs with
> > trace_buf_size=12M and movable_node on 4.14.0.
> 
> This is still 10x more than the default. Why do you need it in the first
> place? You can of course find a size that will not fit into the initial
> memory but I am questioning why do you want something like that during
> early boot in the first place.
> 

This confused me as well. I couldn't think of a sensible use-case for
increasing the buffer other than stuffing trace_printk in multiple places
for debugging purposes. Even in such cases, it would be feasible to disable
the option in Kconfig just to have the large buffer.  Otherwise, just wait
until the system is booted and set if from userspace.

The lack of a sensible use-case is why I took a fairly blunt approach to
the problem. Keep it (relatively) simple and all that.

> The whole deferred struct page allocation operates under assumption
> that there are no large page allocator consumers that early during
> the boot process.

Yes.

> If this assumption is not correct then we probably
> need a generic way to describe this. Add-hoc trace specific thing is
> far from idea, imho. If anything the first approach to disable the
> deferred initialization via kernel command line option sounds much more
> appropriate and simpler to me.

So while the first approach was blunt, there are multiple other options.

1. Parse trace_buf_size in __setup to record the information before
   page alloc init starts. Take that into account in reset_deferred_meminit
   to increase the amount of memory that is serially initialised

2. Have tracing init with a small buffer and then resize it after
   page_alloc_init_late. This modifies tracing a bit but most of the
   helpers that are required are there. It would be more complex but
   it's doable

3. Add a kernel command line parameter that explicitly disables deferred
   meminit. We used to have something like this but it was never merged
   as we should be able to estimate how much memory is needed to boot.

4. Put a check into the page allocator slowpath that triggers serialised
   init if the system is booting and an allocation is about to fail. It
   would be such a cold path that it would never be noticable although it
   would leave dead code in the kernel image once boot had completed

However, it would be preferable by far to have a sensible use-case as to
why trace_buf_size= would be specified with a large buffer. It's hard to
know what level of complexity is justified without it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
