Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E57AA6B05F7
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:53:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x43so46627642wrb.9
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 05:53:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si4065284wro.287.2017.07.31.05.53.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 05:53:22 -0700 (PDT)
Date: Mon, 31 Jul 2017 14:53:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20170731125319.GA4829@dhcp22.suse.cz>
References: <20170726083333.17754-1-mhocko@kernel.org>
 <20170726210657.GE21717@redhat.com>
 <20170727065652.GE20970@dhcp22.suse.cz>
 <20170728121941.GL2274@dhcp22.suse.cz>
 <20170731143521.5809a6ca@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731143521.5809a6ca@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>

On Mon 31-07-17 14:35:21, Gerald Schaefer wrote:
> On Fri, 28 Jul 2017 14:19:41 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 27-07-17 08:56:52, Michal Hocko wrote:
> > > On Wed 26-07-17 17:06:59, Jerome Glisse wrote:
> > > [...]
> > > > This does not seems to be an opt-in change ie if i am reading patch 3
> > > > correctly if an altmap is not provided to __add_pages() you fallback
> > > > to allocating from begining of zone. This will not work with HMM ie
> > > > device private memory. So at very least i would like to see some way
> > > > to opt-out of this. Maybe a new argument like bool forbid_altmap ?
> > > 
> > > OK, I see! I will think about how to make a sane api for that.
> > 
> > This is what I came up with. s390 guys mentioned that I cannot simply
> > use the new range at this stage yet. This will need probably some other
> > changes but I guess we want an opt-in approach with an arch veto in general.
> > 
> > So what do you think about the following? Only x86 is update now and I
> > will split it into two parts but the idea should be clear at least.
> 
> This looks good, and the kernel will also boot again on s390 when applied
> on top of the other 5 patches (plus adding the s390 part here).

Thanks for testing Gerald! I am still undecided whether the arch code
should veto MHP_RANGE_ACCESSIBLE if it cannot be supported or just set
it when it is supported. My last post did the later but the first one
sounds like a more clear API to me. I will keep thinking about it.

Anyway, did you have any chance to consider mapping the new physical
memory range inside arch_add_memory rather than during online on s390?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
