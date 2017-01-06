Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5048D6B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:46:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so8153712pgd.7
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:46:17 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s5si75690577pgo.49.2017.01.06.08.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 08:46:16 -0800 (PST)
Subject: Re: [HMM v15 13/16] mm/hmm/migrate: new memory migration helper for
 use with device memory v2
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-14-git-send-email-jglisse@redhat.com>
From: David Nellans <dnellans@nvidia.com>
Message-ID: <d5c4a464-1f17-8517-3646-33dd5bf06ef5@nvidia.com>
Date: Fri, 6 Jan 2017 10:46:09 -0600
MIME-Version: 1.0
In-Reply-To: <1483721203-1678-14-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Anshuman Khandual <khandual@linux.vnet.ibm.com>



On 01/06/2017 10:46 AM, J=C3=A9r=C3=B4me Glisse wrote:
> This patch add a new memory migration helpers, which migrate memory
> backing a range of virtual address of a process to different memory
> (which can be allocated through special allocator). It differs from
> numa migration by working on a range of virtual address and thus by
> doing migration in chunk that can be large enough to use DMA engine
> or special copy offloading engine.
>
> Expected users are any one with heterogeneous memory where different
> memory have different characteristics (latency, bandwidth, ...). As
> an example IBM platform with CAPI bus can make use of this feature
> to migrate between regular memory and CAPI device memory. New CPU
> architecture with a pool of high performance memory not manage as
> cache but presented as regular memory (while being faster and with
> lower latency than DDR) will also be prime user of this patch.
Why should the normal page migration path (where neither src nor dest are
device private), use the hmm_migrate functionality?  11-14 are
replicating a lot of the
normal migration functionality but with special casing for HMM
requirements.  When migrating
THP's or a list of pages (your use case above), normal NUMA migration
is going to want to do this as fast as possible too (see Zi Yan's
patches for multi-threading normal
migrations & prototype of using intel IOAT for transfers, he sees 3-5x
speedup).

If the intention is to provide a common interface hook for migration to
use DMA acceleration
(which is a good idea), it probably shouldn't be special cased inside
HMM functionality.
For example, using the intel IOAT for migration DMA has nothing to do
with HMM
whatsoever. We need a normal migration path interface to allow DMA that
isn't tied
to HMM.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
