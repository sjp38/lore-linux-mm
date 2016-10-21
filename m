Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA5CD6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:23:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i85so44774335pfa.5
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:23:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c66si1178929pga.265.2016.10.20.23.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 23:23:03 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9L6IVZD084097
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:23:03 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2675yfytkg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:23:03 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <apopple@au1.ibm.com>;
	Fri, 21 Oct 2016 16:23:00 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id CD89C2BB005B
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 17:22:57 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9L6MvYF18022496
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 17:22:57 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9L6MuPV016833
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 17:22:57 +1100
From: Alistair Popple <apopple@au1.ibm.com>
Subject: Re: [PATCH v4 2/5] drivers/of: do not add memory for unavailable nodes
Date: Fri, 21 Oct 2016 17:22:54 +1100
In-Reply-To: <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com> <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2344394.NlaWgtFOqB@new-mexico>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Stewart Smith <stewart@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>

Hi Reza,

On Thu, 6 Oct 2016 01:36:32 PM Reza Arbab wrote:
> Respect the standard dt "status" property when scanning memory nodes in
> early_init_dt_scan_memory(), so that if the node is unavailable, no
> memory will be added.

What happens if a kernel without this patch is booted on a system with some 
status="disabled" device-nodes? Do older kernels just ignore this memory or do 
they try to use it?

>From what I can tell it seems that kernels without this patch will try and use 
this memory even if it is marked in the device-tree as status="disabled" which 
could lead to problems for older kernels when we start exporting this property 
from firmware.

Arguably this might not be such a problem in practice as we probably don't 
have many (if any) existing kernels that will boot on hardware exporting these 
properties. However given this patch seems fairly independent perhaps it is 
worth sending as a separate fix if it is not going to make it into this 
release?

Regards,

Alistair

> The use case at hand is accelerator or device memory, which may be
> unusable until post-boot initialization of the memory link. Such a node
> can be described in the dt as any other, given its status is "disabled".
> Per the device tree specification,
> 
> "disabled"
> 	Indicates that the device is not presently operational, but it
> 	might become operational in the future (for example, something
> 	is not plugged in, or switched off).
> 
> Once such memory is made operational, it can then be hotplugged.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  drivers/of/fdt.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index b138efb..08e5d94 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -1056,6 +1056,9 @@ int __init early_init_dt_scan_memory(unsigned long 
node, const char *uname,
>  	} else if (strcmp(type, "memory") != 0)
>  		return 0;
>  
> +	if (!of_flat_dt_device_is_available(node))
> +		return 0;
> +
>  	reg = of_get_flat_dt_prop(node, "linux,usable-memory", &l);
>  	if (reg == NULL)
>  		reg = of_get_flat_dt_prop(node, "reg", &l);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
