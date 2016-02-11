Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B8F996B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:09:45 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id 128so34436006wmz.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:09:45 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id in5si13823436wjb.155.2016.02.11.11.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 11:09:44 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id c200so87726602wme.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:09:44 -0800 (PST)
Date: Thu, 11 Feb 2016 21:09:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
Message-ID: <20160211190942.GA10244@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160211192223.4b517057@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thu, Feb 11, 2016 at 07:22:23PM +0100, Gerald Schaefer wrote:
> Hi,
> 
> Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
> he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
> review of the THP rework patches, which cannot be bisected, revealed
> commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
> (and also similar commits for other archs).
> 
> This commit removes the THP splitting bit and also the architecture
> implementation of pmdp_splitting_flush(), which took care of the IPI for
> fast_gup serialization. The commit message says
> 
>     pmdp_splitting_flush() is not needed too: on splitting PMD we will do
>     pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
>     needed for fast_gup
> 
> The assumption that a TLB flush will also produce an IPI is wrong on s390,
> and maybe also on other architectures, and I thought that this was actually
> the main reason for having an arch-specific pmdp_splitting_flush().
> 
> At least PowerPC and ARM also had an individual implementation of
> pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
> flush to send the IPI, and those were also removed. Putting the arch
> maintainers and mailing lists on cc to verify.
> 
> On s390 this will break the IPI serialization against fast_gup, which
> would certainly explain the random kernel crashes, please revert or fix
> the pmdp_splitting_flush() removal.

Sorry for that.

I believe, the problem was already addressed for PowerPC:

http://lkml.kernel.org/g/454980831-16631-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com

I think kick_all_cpus_sync() in arch-specific pmdp_invalidate() would do
the trick, right?

If yes, I'll prepare patch tomorrow (some sleep required).

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
