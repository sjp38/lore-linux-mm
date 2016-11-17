Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A50C66B0306
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:41:06 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so105999072pfx.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 23:41:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s21si2047267pfi.53.2016.11.16.23.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 23:41:05 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAH7XiSZ003887
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:41:05 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26s62aw9kb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:41:04 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 17 Nov 2016 17:41:02 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 7E3FA2BB0055
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:40:59 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAH7exYB54591668
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:40:59 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAH7eweL011450
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:40:59 +1100
Subject: Re: [RFC 2/8] mm: Add specialized fallback zonelist for coherent
 device memory nodes
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-3-git-send-email-khandual@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 17 Nov 2016 13:10:50 +0530
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-3-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <582D5F02.6010705@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 10:01 AM, Anshuman Khandual wrote:
> This change is part of the isolation requiring coherent device memory
> node's implementation.
> 
> Isolation seeking coherent memory node requires isolation from implicit
> memory allocations from user space but at the same time there should also
> have an explicit way to do the allocation. Kernel allocation to this memory
> can be prevented by putting the entire memory in ZONE_MOVABLE for example.
> 
> Platform node's both zonelists are fundamental to where the memory comes
> when there is an allocation request. In order to achieve the two objectives
> stated above, zonelists building process has to change as both zonelists
> (FALLBACK and NOFALLBACK) gives access to the node's memory zones during
> any kind of memory allocation. The following changes are implemented in
> this regard.
> 
> (1) Coherent node's zones are not part of any other node's FALLBACK list
> (2) Coherent node's FALLBACK list contains it's own memory zones followed
>     by all system RAM zones in normal order
> (3) Coherent node's zones are part of it's own NOFALLBACK list
> 
> The above changes which will ensure the following which in turn isolates
> the coherent memory node as desired.
> 
> (1) There wont be any implicit allocation ending up in the coherent node
> (2) __GFP_THISNODE marked allocations will come from the coherent node
> (3) Coherent memory can also be allocated through MPOL_BIND interface
> 
> Sample zonelist configuration:
> 
> [NODE (0)]						System RAM node
>         ZONELIST_FALLBACK (0xc00000000140da00)
>                 (0) (node 0) (DMA     0xc00000000140c000)
>                 (1) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc000000001411a10)
>                 (0) (node 0) (DMA     0xc00000000140c000)
> [NODE (1)]						System RAM node
>         ZONELIST_FALLBACK (0xc000000100001a00)
>                 (0) (node 1) (DMA     0xc000000100000000)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>         ZONELIST_NOFALLBACK (0xc000000100005a10)
>                 (0) (node 1) (DMA     0xc000000100000000)
> [NODE (2)]						Coherent memory
>         ZONELIST_FALLBACK (0xc000000001427700)
>                 (0) (node 2) (Movable 0xc000000001427080)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>                 (2) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc00000000142b710)
>                 (0) (node 2) (Movable 0xc000000001427080)
> [NODE (3)]						Coherent memory
>         ZONELIST_FALLBACK (0xc000000001431400)
>                 (0) (node 3) (Movable 0xc000000001430d80)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>                 (2) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc000000001435410)
>                 (0) (node 3) (Movable 0xc000000001430d80)
> [NODE (4)]						Coherent memory
>         ZONELIST_FALLBACK (0xc00000000143b100)
>                 (0) (node 4) (Movable 0xc00000000143aa80)
>                 (1) (node 0) (DMA     0xc00000000140c000)
>                 (2) (node 1) (DMA     0xc000000100000000)
>         ZONELIST_NOFALLBACK (0xc00000000143f110)
>                 (0) (node 4) (Movable 0xc00000000143aa80)
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---

Another way of achieving isolation of the CDM nodes from user space
allocations would be through cpuset changes. Will be sending out
couple of draft patches in this direction. Then we can look into
whether the current method or the cpuset method is a better way to
go forward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
