Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED156B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:13:17 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id r20so2017544wiv.4
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 03:13:17 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id n1si1750215wix.100.2015.01.23.03.13.14
        for <linux-mm@kvack.org>;
        Fri, 23 Jan 2015 03:13:14 -0800 (PST)
Date: Fri, 23 Jan 2015 13:13:04 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mmotm 2015-01-22-15-04: qemu failures due to 'mm: account pmd
 page tables to the process'
Message-ID: <20150123111304.GA5975@node.dhcp.inet.fi>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050445.GA22751@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150123050445.GA22751@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Jan 22, 2015 at 09:04:45PM -0800, Guenter Roeck wrote:
> On Thu, Jan 22, 2015 at 03:05:17PM -0800, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2015-01-22-15-04 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> qemu:sh fails to shut down.
> 
> bisect log:
> 
> # bad: [03586ad04b2170ee816e6936981cc7cd2aeba129] pci: test for unexpectedly disabled bridges
> # good: [ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc] Linux 3.19-rc5
> git bisect start 'HEAD' 'v3.19-rc5'
> # bad: [d113ba21d15c7d3615fd88490d1197615bb39fc0] mm: remove lock validation check for MADV_FREE
> git bisect bad d113ba21d15c7d3615fd88490d1197615bb39fc0
> # good: [17351d1625a5030fa16f1346b77064c03b51f107] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
> git bisect good 17351d1625a5030fa16f1346b77064c03b51f107
> # good: [ad18ad1fce6f241a9cbd4adfd6b16c9283181e39] memcg: add BUILD_BUG_ON() for string tables
> git bisect good ad18ad1fce6f241a9cbd4adfd6b16c9283181e39
> # bad: [aa7e7cbfa43b74f6faef04ff730b5098544a4f77] mm/compaction: enhance tracepoint output for compaction begin/end
> git bisect bad aa7e7cbfa43b74f6faef04ff730b5098544a4f77
> # good: [a40d0d2cf21e2714e9a6c842085148c938bf36ab] mm: memcontrol: remove unnecessary soft limit tree node test
> git bisect good a40d0d2cf21e2714e9a6c842085148c938bf36ab
> # good: [4ec4aa2e07c1d6eee61f6cace29401c6febcb6c5] mm: make FIRST_USER_ADDRESS unsigned long on all archs
> git bisect good 4ec4aa2e07c1d6eee61f6cace29401c6febcb6c5
> # bad: [22310c209483224a64436a6e815a86feda681659] mm: account pmd page tables to the process
> git bisect bad 22310c209483224a64436a6e815a86feda681659
> # good: [19a41261b1dcd8d12372d9c57c2035144608a599] arm: define __PAGETABLE_PMD_FOLDED for !LPAE
> git bisect good 19a41261b1dcd8d12372d9c57c2035144608a599
> # first bad commit: [22310c209483224a64436a6e815a86feda681659] mm: account pmd page tables to the process
> 
> ---
> 
> qemu:microblaze generates warnings to the console.
> 
> WARNING: CPU: 0 PID: 32 at mm/mmap.c:2858 exit_mmap+0x184/0x1a4()
> 
> with various call stacks. See
> http://server.roeck-us.net:8010/builders/qemu-microblaze-mmotm/builds/15/steps/qemubuildcommand/logs/stdio
> for details.

Could you try patch below? Completely untested.
