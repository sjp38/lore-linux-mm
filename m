Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id DDE256B0258
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 09:32:10 -0500 (EST)
Received: by wmuu63 with SMTP id u63so224967426wmu.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:32:10 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id lm2si10323363wjc.94.2015.12.09.06.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 06:32:09 -0800 (PST)
Received: by wmvv187 with SMTP id v187so264686080wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 06:32:09 -0800 (PST)
Date: Wed, 9 Dec 2015 15:32:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: m(un)map kmalloc buffers to userspace
Message-ID: <20151209143207.GF30907@dhcp22.suse.cz>
References: <5667128B.3080704@sigmadesigns.com>
 <20151209135544.GE30907@dhcp22.suse.cz>
 <566835B6.9010605@sigmadesigns.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <566835B6.9010605@sigmadesigns.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Cc: Sebastian Frias <sebastian_frias@sigmadesigns.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 09-12-15 15:07:50, Marc Gonzalez wrote:
> On 09/12/2015 14:55, Michal Hocko wrote:
> > On Tue 08-12-15 18:25:31, Sebastian Frias wrote:
> >> Hi,
> >>
> >> We are porting a driver from Linux 3.4.39+ to 4.1.13+, CPU is Cortex-A9.
> >>
> >> The driver maps kmalloc'ed memory to user space.
> > 
> > This sounds like a terrible idea to me. Why don't you simply use the
> > page allocator directly? Try to imagine what would happen if you mmaped
> > a kmalloc with a size which is not page aligned? mmaped memory uses
> > whole page granularity.
> 
> According to the source code, this kernel module calls
> 
>   kmalloc(1 << 17, GFP_KERNEL | __GFP_REPEAT);

So I guess you are mapping with 32pages granularity? If this is really
needed for internal usage you can use highorder page and map its
subpages directly.

> I suppose kmalloc() would return page-aligned memory?

I do not think there is any guarantee like that. AFAIK you only get
guarantee for the natural word alignment. Slab allocator is allowed
to use larger allocation and put its metadata or whatever before the
returned pointer.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
