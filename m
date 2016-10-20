Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 692566B0253
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 23:31:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so12922963pfa.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 20:31:06 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id y6si21695441pff.4.2016.10.19.20.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 20:31:05 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i85so4151818pfa.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 20:31:05 -0700 (PDT)
Subject: Re: [PATCH v4 3/5] powerpc/mm: allow memory hotplug into a memoryless
 node
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-4-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <872f253d-8a55-246c-2be0-636a588e2dd0@gmail.com>
Date: Thu, 20 Oct 2016 14:30:42 +1100
MIME-Version: 1.0
In-Reply-To: <1475778995-1420-4-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org



On 07/10/16 05:36, Reza Arbab wrote:
> Remove the check which prevents us from hotplugging into an empty node.
> 
> This limitation has been questioned before [1], and judging by the
> response, there doesn't seem to be a reason we can't remove it. No issues
> have been found in light testing.
> 
> [1] http://lkml.kernel.org/r/CAGZKiBrmkSa1yyhbf5hwGxubcjsE5SmkSMY4tpANERMe2UG4bg@mail.gmail.com
>     http://lkml.kernel.org/r/20160511215051.GF22115@arbab-laptop.austin.ibm.com
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
> Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/numa.c | 13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
> 
> diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
> index 75b9cd6..d7ac419 100644
> --- a/arch/powerpc/mm/numa.c
> +++ b/arch/powerpc/mm/numa.c
> @@ -1121,7 +1121,7 @@ static int hot_add_node_scn_to_nid(unsigned long scn_addr)
>  int hot_add_scn_to_nid(unsigned long scn_addr)
>  {
>  	struct device_node *memory = NULL;
> -	int nid, found = 0;
> +	int nid;
>  
>  	if (!numa_enabled || (min_common_depth < 0))
>  		return first_online_node;
> @@ -1137,17 +1137,6 @@ int hot_add_scn_to_nid(unsigned long scn_addr)
>  	if (nid < 0 || !node_online(nid))
>  		nid = first_online_node;
>  
> -	if (NODE_DATA(nid)->node_spanned_pages)
> -		return nid;
> -
> -	for_each_online_node(nid) {
> -		if (NODE_DATA(nid)->node_spanned_pages) {
> -			found = 1;
> -			break;
> -		}
> -	}
> -
> -	BUG_ON(!found);
>  	return nid;

FYI, these checks were temporary to begin with

I found this in git history

b226e462124522f2f23153daff31c311729dfa2f (powerpc: don't add memory to empty node/zone)

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
