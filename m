Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE956B0099
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 15:03:05 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so4286872wes.36
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 12:03:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id co10si13101227wib.42.2014.06.09.12.03.03
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 12:03:04 -0700 (PDT)
Date: Mon, 9 Jun 2014 14:43:55 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
Message-ID: <20140609144355.63a91968@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1406081524580.21744@chino.kir.corp.google.com>
References: <20140608181436.17de69ac@redhat.com>
 <alpine.DEB.2.02.1406081524580.21744@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Sun, 8 Jun 2014 15:25:50 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Sun, 8 Jun 2014, Luiz Capitulino wrote:
> 
> > diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
> > index 4064aca..01b493e 100644
> > --- a/arch/x86/include/asm/numa.h
> > +++ b/arch/x86/include/asm/numa.h
> > @@ -9,7 +9,6 @@
> >  #ifdef CONFIG_NUMA
> >  
> >  #define NR_NODE_MEMBLKS		(MAX_NUMNODES*2)
> > -#define ZONE_ALIGN (1UL << (MAX_ORDER+PAGE_SHIFT))
> >  
> >  /*
> >   * Too small node sizes may confuse the VM badly. Usually they
> > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > index 1d045f9..69f6362 100644
> > --- a/arch/x86/mm/numa.c
> > +++ b/arch/x86/mm/numa.c
> > @@ -200,8 +200,6 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
> >  	if (end && (end - start) < NODE_MIN_SIZE)
> >  		return;
> >  
> > -	start = roundup(start, ZONE_ALIGN);
> > -
> >  	printk(KERN_INFO "Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
> >  	       nid, start, end - 1);
> >  
> 
> What ensures this start address is page aligned from the BIOS?

To which start address do you refer to? The start address passed to
setup_node_data() comes from memblks registered when the SRAT table is parsed.
Those memblks get some transformations between the parsing of the SRAT table
and this point. I haven't checked them in detail to see if they are aligned
at some point. But no alignment is enforced in the code that adds the memblks
read from the SRAT table, which is acpi_numa_memory_affinity_init().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
