Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65AA36B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 12:07:10 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y9so1676472qki.23
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 09:07:10 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id h26-v6si1668049qtb.232.2018.04.27.09.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 09:07:09 -0700 (PDT)
Date: Fri, 27 Apr 2018 11:07:07 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
In-Reply-To: <20180427071843.GB17484@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1804271103160.11686@nuc-kabylake>
References: <20180426215406.GB27853@wotan.suse.de> <20180427053556.GB11339@infradead.org> <20180427071843.GB17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, linux-spi@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Fri, 27 Apr 2018, Michal Hocko wrote:

> On Thu 26-04-18 22:35:56, Christoph Hellwig wrote:
> > On Thu, Apr 26, 2018 at 09:54:06PM +0000, Luis R. Rodriguez wrote:
> > > In practice if you don't have a floppy device on x86, you don't need ZONE_DMA,
> >
> > I call BS on that, and you actually explain later why it it BS due
> > to some drivers using it more explicitly.  But even more importantly
> > we have plenty driver using it through dma_alloc_* and a small DMA
> > mask, and they are in use - we actually had a 4.16 regression due to
> > them.
>
> Well, but do we need a zone for that purpose? The idea was to actually
> replace the zone by a CMA pool (at least on x86). With the current
> implementation of the CMA we would move the range [0-16M] pfn range into
> zone_movable so it can be used and we would get rid of all of the
> overhead each zone brings (a bit in page flags, kmalloc caches and who
> knows what else)

Well it looks like what we are using it for is to force allocation from
low physical memory if we fail to obtain proper memory through a normal
channel.  The use of ZONE_DMA is only there for emergency purposes.
I think we could subsitute ZONE_DMA32 on x87 without a problem.

Which means that ZONE_DMA has no purpose anymore.

Can we make ZONE_DMA on x86 refer to the low 32 bit physical addresses
instead and remove ZONE_DMA32?

That would actually improve the fallback because you have more memory for
the old devices.
