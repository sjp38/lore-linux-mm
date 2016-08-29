Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F15A583102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 11:07:07 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so99959735lfb.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:07:07 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id p184si12167126wmp.85.2016.08.29.08.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 08:07:06 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id o80so96990092wme.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:07:06 -0700 (PDT)
Date: Mon, 29 Aug 2016 17:07:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160829150703.GH2968@dhcp22.suse.cz>
References: <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
 <20160825071103.GC4230@dhcp22.suse.cz>
 <20160825071728.GA3169@aepfle.de>
 <20160829145203.GA30660@aepfle.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160829145203.GA30660@aepfle.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olaf Hering <olaf@aepfle.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 29-08-16 16:52:03, Olaf Hering wrote:
> On Thu, Aug 25, Olaf Hering wrote:
> 
> > On Thu, Aug 25, Michal Hocko wrote:
> > 
> > > Any luck with the testing of this patch?
> 
> I ran rc3 for a few hours on Friday amd FireFox was not killed.
> Now rc3 is running for a day with the usual workload and FireFox is
> still running.

Is the patch
(http://lkml.kernel.org/r/20160823074339.GB23577@dhcp22.suse.cz) applied?

> Today I noticed the nfsserver was disabled, probably since months already.
> Starting it gives a OOM, not sure if this is new with 4.7+.
> Full dmesg attached.
> [93348.306369] modprobe: page allocation failure: order:4, mode:0x26040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK)

ok so order-4 (COSTLY allocation) has failed because

[...]
> [93348.313778] Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15908kB
> [93348.313803] Node 0 DMA32: 13633*4kB (UME) 8035*8kB (UME) 890*16kB (UME) 10*32kB (U) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 133372kB
> [93348.313822] Node 0 Normal: 14003*4kB (UME) 25*8kB (UME) 2*16kB (UM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 56244kB

the memory is too fragmented for such a large allocation. Failing
order-4 requests is not so severe because we do not invoke the oom
killer if they fail. Especially without GFP_REPEAT we do not even try
too hard. Recent oom detection changes shouldn't change this behavior.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
