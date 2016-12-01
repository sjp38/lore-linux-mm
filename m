Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 048A76B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 02:58:57 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so78686235pgd.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 23:58:56 -0800 (PST)
Received: from smtp.gentoo.org (smtp.gentoo.org. [140.211.166.183])
        by mx.google.com with ESMTPS id u64si68219734pgc.175.2016.11.30.23.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 23:58:56 -0800 (PST)
Received: from grubbs.orbis-terrarum.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTPS id 0E3FC3413FD
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 07:58:55 +0000 (UTC)
Date: Thu, 1 Dec 2016 07:58:54 +0000
From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
Message-ID: <robbat2-20161201T074556-337570278Z@orbis-terrarum.net>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <9d6e922b-d853-f24d-353c-25fbac38115b@suse.cz>
 <20161201062142.GA25917@orbis-terrarum.net>
 <48823c64-37b4-7ba4-f206-7cb86a4d5540@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48823c64-37b4-7ba4-f206-7cb86a4d5540@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Robin H. Johnson" <robbat2@gentoo.org>, Michal Hocko <mhocko@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>

On Thu, Dec 01, 2016 at 08:38:15AM +0100, Vlastimil Babka wrote:
> >> By default config this should not be used on x86.
> > What do you mean by that statement?
> 
> I mean that the 16 mbytes for generic CMA area is not a default on x86:
> 
> config CMA_SIZE_MBYTES
>          int "Size in Mega Bytes"
>          depends on !CMA_SIZE_SEL_PERCENTAGE
>          default 0 if X86
>          default 16
d7be003a9d275299f5ee36bbdf156654f59e08e9 (v3.18-2122-gd7be003a9d27)
is there the 0MB if-x86 default was added to the tree. Prior to that, it
was 16MiB, and that's where my system picked up the value from.

I have a record of all my kconfigs, because I use oldconfig each time
(going back 8 years to 2.6.27)

# Added in 3.12.0-00001-g5f258d0
CONFIG_CMA=y 
# Added in 3.16.0-rc6-00042-g67dd8f3
CONFIG_CMA_ALIGNMENT=8
CONFIG_CMA_AREAS=7
CONFIG_CMA_SIZE_MBYTES=16
CONFIG_CMA_SIZE_SEL_MBYTES=y
CONFIG_DMA_CMA=y

So the next question, is why did I pick up CMA in
3.16.0-rc6-00042-g67dd8f3... I'll poke at that.

> > Yes, I'd say if there's a fallback without much penalty, nowarn makes
> > sense. If the fallback just tries multiple addresses until success, then
> > the warning should only be issued when too many attempts have been made.
> On the other hand, if the warnings are correlated with high kernel CPU usage, 
> it's arguably better to be warned.
Keep the rate-limit on the warning for cases like this?

> >> > The rate of the problem starts slow, and also is relatively low on an idle
> >> > system (my screens blank at night, no xscreensaver running), but it still ramps
> >> > up over time (to the point of generating 2.5GB/hour of "(timestamp)
> >> > alloc_contig_range: [83e4d9, 83e4da) PFNs busy"), with various addresses (~100
> >> > unique ranges for a day).
> >> >
> >> > My X workload is ~50 chrome tabs and ~20 terminals (over 3x 24" monitors w/ 9
> >> > virtual desktops per monitor).
> >> So IIUC, except the messages, everything actually works fine?
> > There's high kernel CPU usage that seems to roughly correlate with the
> > messages, but I can't yet tell if that's due to the syslog itself, or
> > repeated alloc_contig_range requests.
> You could try running perf top.
Will do in the morning.

-- 
Robin Hugh Johnson
Gentoo Linux: Dev, Infra Lead, Foundation Trustee & Treasurer
E-Mail   : robbat2@gentoo.org
GnuPG FP : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
GnuPG FP : 7D0B3CEB E9B85B1F 825BCECF EE05E6F6 A48F6136

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
