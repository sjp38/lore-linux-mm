Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 262946B0275
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:48:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so388222379pfb.0
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 08:48:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id cu10si25652039pad.250.2016.09.26.08.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 08:48:08 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8QFlMT2115320
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:48:07 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25q5674c4e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 11:48:07 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 26 Sep 2016 09:48:06 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 4/5] powerpc/mm: restore top-down allocation when using movable_node
In-Reply-To: <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com> <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
Date: Mon, 26 Sep 2016 21:17:43 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <8760piacio.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

Reza Arbab <arbab@linux.vnet.ibm.com> writes:

> At boot, the movable_node option sets bottom-up memblock allocation.
>
> This reduces the chance that, in the window before movable memory has
> been identified, an allocation for the kernel might come from a movable
> node. By going bottom-up, early allocations will most likely come from
> the same node as the kernel image, which is necessarily in a nonmovable
> node.
>
> Then, once any known hotplug memory has been marked, allocation can be
> reset back to top-down. On x86, this is done in numa_init(). This patch
> does the same on power, in numa initmem_init().
>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/numa.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index d7ac419..fdf1e69 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -945,6 +945,9 @@ void __init initmem_init(void)
>  	max_low_pfn = memblock_end_of_DRAM() >> PAGE_SHIFT;
>  	max_pfn = max_low_pfn;
>
> +	/* bottom-up allocation may have been set by movable_node */
> +	memblock_set_bottom_up(false);
> +

By then we have done few memblock allocation right ? IMHO, we should do
this early enough in prom.c after we do parse_early_param, with a
comment there explaining that, we don't really support hotplug memblock
and when we do that, this should be moved to a place where we can handle
memblock allocation such that we avoid spreading memblock allocation to
movable node.


>  	if (parse_numa_properties())
>  		setup_nonnuma();
>  	else
> -- 
> 1.8.3.1

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
