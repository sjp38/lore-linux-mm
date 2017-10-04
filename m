Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2306B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 04:56:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v13so17533954pgq.1
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 01:56:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b184si11144278pgc.727.2017.10.04.01.56.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 01:56:38 -0700 (PDT)
Date: Wed, 4 Oct 2017 10:56:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 08/12] mm: zero reserved and unavailable struct pages
Message-ID: <20171004085636.w2rnwf5xxhahzuy7@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-9-pasha.tatashin@oracle.com>
 <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
 <691dba28-718c-e9a9-d006-88505eb5cd7e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <691dba28-718c-e9a9-d006-88505eb5cd7e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Tue 03-10-17 11:29:16, Pasha Tatashin wrote:
> On 10/03/2017 09:18 AM, Michal Hocko wrote:
> > On Wed 20-09-17 16:17:10, Pavel Tatashin wrote:
> > > Some memory is reserved but unavailable: not present in memblock.memory
> > > (because not backed by physical pages), but present in memblock.reserved.
> > > Such memory has backing struct pages, but they are not initialized by going
> > > through __init_single_page().
> > 
> > Could you be more specific where is such a memory reserved?
> > 
> 
> I know of one example: trim_low_memory_range() unconditionally reserves from
> pfn 0, but e820__memblock_setup() might provide the exiting memory from pfn
> 1 (i.e. KVM).

Then just initialize struct pages for that mapping rigth there where a
special API is used.

> But, there could be more based on this comment from linux/page-flags.h:
> 
>  19  * PG_reserved is set for special pages, which can never be swapped out.
> Some
>  20  * of them might not even exist (eg empty_bad_page)...

I have no idea wht empty_bad_page is but a quick grep shows that this is
never used. I might be wrong here but if somebody is reserving a memory
in a special way then we should handle the initialization right there.
E.g. create an API for special memblock reservations.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
