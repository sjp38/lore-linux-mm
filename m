Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A84A66B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 10:04:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v78so1717576pgb.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 07:04:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l124si817921pgl.128.2017.10.04.07.04.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 07:04:14 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:04:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 08/12] mm: zero reserved and unavailable struct pages
Message-ID: <20171004140410.2w2zf2gbutdxunir@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-9-pasha.tatashin@oracle.com>
 <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
 <691dba28-718c-e9a9-d006-88505eb5cd7e@oracle.com>
 <20171004085636.w2rnwf5xxhahzuy7@dhcp22.suse.cz>
 <9198a33d-cd40-dd70-4823-7f70c57ef9a2@oracle.com>
 <20171004125743.fm6mf2artbga76et@dhcp22.suse.cz>
 <d743668c-6b7e-1775-a5b8-d6e997537990@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d743668c-6b7e-1775-a5b8-d6e997537990@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Wed 04-10-17 09:28:55, Pasha Tatashin wrote:
> 
> > I am not really familiar with the trim_low_memory_range code path. I am
> > not even sure we have to care about it because nobody should be walking
> > pfns outside of any zone.
> 
> According to commit comments first 4K belongs to BIOS, so I think the memory
> exists but BIOS may or may not report it to Linux. So, reserve it to make
> sure we never touch it.

Yes and that memory should be outside of any zones, no?

> > I am worried that this patch adds a code which
> > is not really used and it will just stay that way for ever because
> > nobody will dare to change it as it is too obscure and not explained
> > very well.
> 
> I could explain mine code better. Perhaps add more comments, and explain
> when it can be removed?

More explanation would be definitely helpful

> > trim_low_memory_range is a good example of this. Why do we
> > even reserve this range from the memory block allocator? The memory
> > shouldn't be backed by any real memory and thus not in the allocator in
> > the first place, no?
> > 
> 
> Since it is not enforced in memblock that everything in reserved list must
> be part of memory list, we can have it, and we need to make sure kernel does
> not panic. Otherwise, it is very hard to detect such bugs.

So, should we report such a memblock reservation API (ab)use to the log?
Are you actually sure that trim_low_memory_range is doing a sane and
really needed thing? In other words do we have a zone which contains
this no-memory backed pfns?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
