Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD8268E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:15:10 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j15-v6so12436482pfi.10
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:15:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n66-v6sor301846pgn.122.2018.09.25.05.15.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 05:15:09 -0700 (PDT)
Date: Tue, 25 Sep 2018 22:15:04 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v2 5/6] powerpc/powernv: hold device_hotplug_lock when
 calling memtrace_offline_pages()
Message-ID: <20180925121504.GH8537@350D>
References: <20180925091457.28651-1-david@redhat.com>
 <20180925091457.28651-6-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925091457.28651-6-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>

On Tue, Sep 25, 2018 at 11:14:56AM +0200, David Hildenbrand wrote:
> Let's perform all checking + offlining + removing under
> device_hotplug_lock, so nobody can mess with these devices via
> sysfs concurrently.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Rashmica Gupta <rashmica.g@gmail.com>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Michael Neuling <mikey@neuling.org>
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/powerpc/platforms/powernv/memtrace.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
> index fdd48f1a39f7..d84d09c56af9 100644
> --- a/arch/powerpc/platforms/powernv/memtrace.c
> +++ b/arch/powerpc/platforms/powernv/memtrace.c
> @@ -70,6 +70,7 @@ static int change_memblock_state(struct memory_block *mem, void *arg)
>  	return 0;
>  }
>  
> +/* called with device_hotplug_lock held */
>  static bool memtrace_offline_pages(u32 nid, u64 start_pfn, u64 nr_pages)
>  {
>  	u64 end_pfn = start_pfn + nr_pages - 1;
> @@ -111,6 +112,7 @@ static u64 memtrace_alloc_node(u32 nid, u64 size)
>  	end_pfn = round_down(end_pfn - nr_pages, nr_pages);
>  
>  	for (base_pfn = end_pfn; base_pfn > start_pfn; base_pfn -= nr_pages) {
> +		lock_device_hotplug();

Why not grab the lock before the for loop? That way we can avoid bad cases like a
large node being scanned for a small number of pages (nr_pages). Ideally we need
a cond_resched() in the loop, but I guess offline_pages() has one.

Acked-by: Balbir Singh <bsingharora@gmail.com>
