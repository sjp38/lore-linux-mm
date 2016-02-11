Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 940226B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:22:30 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 128so32831624wmz.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:22:30 -0800 (PST)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id w188si5806901wma.0.2016.02.11.10.22.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 10:22:29 -0800 (PST)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 11 Feb 2016 18:22:28 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 947AF1B08061
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 18:22:40 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1BIMQA814549158
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 18:22:26 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1BIMP9n021312
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:22:26 -0700
Date: Thu, 11 Feb 2016 19:22:23 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [BUG] random kernel crashes after THP rework on s390 (maybe also on
 PowerPC and ARM)
Message-ID: <20160211192223.4b517057@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

Hi,

Sebastian Ott reported random kernel crashes beginning with v4.5-rc1 and
he also bisected this to commit 61f5d698 "mm: re-enable THP". Further
review of the THP rework patches, which cannot be bisected, revealed
commit fecffad "s390, thp: remove infrastructure for handling splitting PMDs"
(and also similar commits for other archs).

This commit removes the THP splitting bit and also the architecture
implementation of pmdp_splitting_flush(), which took care of the IPI for
fast_gup serialization. The commit message says

    pmdp_splitting_flush() is not needed too: on splitting PMD we will do
    pmdp_clear_flush() + set_pte_at().  pmdp_clear_flush() will do IPI as
    needed for fast_gup

The assumption that a TLB flush will also produce an IPI is wrong on s390,
and maybe also on other architectures, and I thought that this was actually
the main reason for having an arch-specific pmdp_splitting_flush().

At least PowerPC and ARM also had an individual implementation of
pmdp_splitting_flush() that used kick_all_cpus_sync() instead of a TLB
flush to send the IPI, and those were also removed. Putting the arch
maintainers and mailing lists on cc to verify.

On s390 this will break the IPI serialization against fast_gup, which
would certainly explain the random kernel crashes, please revert or fix
the pmdp_splitting_flush() removal.

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
