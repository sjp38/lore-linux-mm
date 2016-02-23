Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6046F6B0254
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:22:29 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so117795656pfb.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:22:29 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 4si49324550pfn.180.2016.02.23.12.22.28
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 12:22:28 -0800 (PST)
Date: Tue, 23 Feb 2016 20:22:33 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160223202233.GE27281@arm.com>
References: <20160211192223.4b517057@thinkpad>
 <20160211190942.GA10244@node.shutemov.name>
 <20160211205702.24f0d17a@thinkpad>
 <20160212154116.GA15142@node.shutemov.name>
 <56BE00E7.1010303@de.ibm.com>
 <20160212181640.4eabb85f@thinkpad>
 <20160223103221.GA1418@node.shutemov.name>
 <20160223191907.25719a4d@thinkpad>
 <20160223193345.GC21820@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223193345.GC21820@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Tue, Feb 23, 2016 at 10:33:45PM +0300, Kirill A. Shutemov wrote:
> On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
> > I'll check with Martin, maybe it is actually trivial, then we can
> > do a quick test it to rule that one out.
> 
> Oh. I found a bug in __split_huge_pmd_locked(). Although, not sure if it's
> _the_ bug.
> 
> pmdp_invalidate() is called for the wrong address :-/
> I guess that can be destructive on the architecture, right?

FWIW, arm64 ignores the address parameter for set_pmd_at, so this would
only result in the TLBI nuking the wrong entries, which is going to be
tricky to observe in practice given that we install a table entry
immediately afterwards that maps the same pages. If s390 does more here
(I see some magic asm using the address), that could be the answer...

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
