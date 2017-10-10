Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6096B025F
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:56:19 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t134so13677130oih.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:56:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d5si2321606oia.472.2017.10.10.08.56.17
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 08:56:18 -0700 (PDT)
Date: Tue, 10 Oct 2017 16:56:20 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v11 7/9] arm64/kasan: add and use kasan_map_populate()
Message-ID: <20171010155619.GA2517@arm.com>
References: <20171009221931.1481-1-pasha.tatashin@oracle.com>
 <20171009221931.1481-8-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009221931.1481-8-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Pavel,

On Mon, Oct 09, 2017 at 06:19:29PM -0400, Pavel Tatashin wrote:
> During early boot, kasan uses vmemmap_populate() to establish its shadow
> memory. But, that interface is intended for struct pages use.
> 
> Because of the current project, vmemmap won't be zeroed during allocation,
> but kasan expects that memory to be zeroed. We are adding a new
> kasan_map_populate() function to resolve this difference.
> 
> Therefore, we must use a new interface to allocate and map kasan shadow
> memory, that also zeroes memory for us.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  arch/arm64/mm/kasan_init.c | 72 ++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 66 insertions(+), 6 deletions(-)

Thanks for doing this, although I still think we can do better and avoid the
additional walking code altogether, as well as removing the dependence on
vmemmap. Rather than keep messing you about here (sorry about that), I've
written an arm64 patch for you to take on top of this series. Please take
a look below.

Cheers,

Will

--->8
