Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9E86B00BB
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 23:19:44 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u57so6624652wes.4
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 20:19:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hg9si34502990wjc.7.2014.06.09.20.19.42
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 20:19:43 -0700 (PDT)
Date: Mon, 9 Jun 2014 23:19:20 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
Message-ID: <20140609231920.08a1b0f9@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1406091453570.5271@chino.kir.corp.google.com>
References: <20140608181436.17de69ac@redhat.com>
	<alpine.DEB.2.02.1406081524580.21744@chino.kir.corp.google.com>
	<20140609144355.63a91968@redhat.com>
	<alpine.DEB.2.02.1406091453570.5271@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, 9 Jun 2014 14:57:16 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 9 Jun 2014, Luiz Capitulino wrote:
> 
> > > > diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
> > > > index 4064aca..01b493e 100644
> > > > --- a/arch/x86/include/asm/numa.h
> > > > +++ b/arch/x86/include/asm/numa.h
> > > > @@ -9,7 +9,6 @@
> > > >  #ifdef CONFIG_NUMA
> > > >  
> > > >  #define NR_NODE_MEMBLKS		(MAX_NUMNODES*2)
> > > > -#define ZONE_ALIGN (1UL << (MAX_ORDER+PAGE_SHIFT))
> > > >  
> > > >  /*
> > > >   * Too small node sizes may confuse the VM badly. Usually they
> > > > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > > > index 1d045f9..69f6362 100644
> > > > --- a/arch/x86/mm/numa.c
> > > > +++ b/arch/x86/mm/numa.c
> > > > @@ -200,8 +200,6 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
> > > >  	if (end && (end - start) < NODE_MIN_SIZE)
> > > >  		return;
> > > >  
> > > > -	start = roundup(start, ZONE_ALIGN);
> > > > -
> > > >  	printk(KERN_INFO "Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
> > > >  	       nid, start, end - 1);
> > > >  
> > > 
> > > What ensures this start address is page aligned from the BIOS?
> > 
> > To which start address do you refer to?
> 
> The start address displayed in the dmesg is not page aligned anymore with 
> your change, correct?  

I have to check that but I don't expect this to happen because my
understanding of the code is that what's rounded up here is just discarded
in free_area_init_node(). Am I wrong?

> acpi_parse_memory_affinity() does no 
> transformations on the table, the base address is coming strictly from the 
> SRAT and there is no page alignment requirement in the ACPI specification.  
> NODE_DATA(nid)->node_start_pfn will be correct because it does the shift 
> for you, but it still seems you want to at least align to PAGE_SIZE here. 

I do agree we need to align to PAGE_SIZE, but I'm not sure where we should
do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
