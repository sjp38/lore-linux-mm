Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9DC6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:30:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v77so32827605pgb.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:30:44 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u16si857252plk.164.2017.08.08.05.30.42
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 05:30:43 -0700 (PDT)
Date: Tue, 8 Aug 2017 13:30:43 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [v6 11/15] arm64/kasan: explicitly zero kasan shadow memory
Message-ID: <20170808123042.GG13355@arm.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-12-git-send-email-pasha.tatashin@oracle.com>
 <20170808090743.GA12887@arm.com>
 <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, catalin.marinas@arm.com, sam@ravnborg.org

On Tue, Aug 08, 2017 at 07:49:22AM -0400, Pasha Tatashin wrote:
> Hi Will,
> 
> Thank you for looking at this change. What you described was in my previous
> iterations of this project.
> 
> See for example here: https://lkml.org/lkml/2017/5/5/369
> 
> I was asked to remove that flag, and only zero memory in place when needed.
> Overall the current approach is better everywhere else in the kernel, but it
> adds a little extra code to kasan initialization.

Damn, I actually prefer the flag :)

But actually, if you look at our implementation of vmemmap_populate, then we
have our own version of vmemmap_populate_basepages that terminates at the
pmd level anyway if ARM64_SWAPPER_USES_SECTION_MAPS. If there's resistance
to do this in the core code, then I'd be inclined to replace our
vmemmap_populate implementation in the arm64 code with a single version that
can terminate at either the PMD or the PTE level, and do zeroing if
required. We're already special-casing it, so we don't really lose anything
imo.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
