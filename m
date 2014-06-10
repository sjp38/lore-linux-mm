Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id AAFC56B0109
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 18:10:04 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so2600906ier.2
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:10:04 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id q6si39669784ich.107.2014.06.10.15.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 15:10:04 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so7359830iec.25
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 15:10:03 -0700 (PDT)
Date: Tue, 10 Jun 2014 15:10:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
In-Reply-To: <20140609231920.08a1b0f9@redhat.com>
Message-ID: <alpine.DEB.2.02.1406101506290.32203@chino.kir.corp.google.com>
References: <20140608181436.17de69ac@redhat.com> <alpine.DEB.2.02.1406081524580.21744@chino.kir.corp.google.com> <20140609144355.63a91968@redhat.com> <alpine.DEB.2.02.1406091453570.5271@chino.kir.corp.google.com> <20140609231920.08a1b0f9@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: akpm@linux-foundation.org, andi@firstfloor.org, riel@redhat.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, 9 Jun 2014, Luiz Capitulino wrote:

> > > > > diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
> > > > > index 4064aca..01b493e 100644
> > > > > --- a/arch/x86/include/asm/numa.h
> > > > > +++ b/arch/x86/include/asm/numa.h
> > > > > @@ -9,7 +9,6 @@
> > > > >  #ifdef CONFIG_NUMA
> > > > >  
> > > > >  #define NR_NODE_MEMBLKS		(MAX_NUMNODES*2)
> > > > > -#define ZONE_ALIGN (1UL << (MAX_ORDER+PAGE_SHIFT))
> > > > >  
> > > > >  /*
> > > > >   * Too small node sizes may confuse the VM badly. Usually they
> > > > > diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> > > > > index 1d045f9..69f6362 100644
> > > > > --- a/arch/x86/mm/numa.c
> > > > > +++ b/arch/x86/mm/numa.c
> > > > > @@ -200,8 +200,6 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
> > > > >  	if (end && (end - start) < NODE_MIN_SIZE)
> > > > >  		return;
> > > > >  
> > > > > -	start = roundup(start, ZONE_ALIGN);
> > > > > -
> > > > >  	printk(KERN_INFO "Initmem setup node %d [mem %#010Lx-%#010Lx]\n",
> > > > >  	       nid, start, end - 1);
> > > > >  
> > > > 
> > > > What ensures this start address is page aligned from the BIOS?
> > > 
> > > To which start address do you refer to?
> > 
> > The start address displayed in the dmesg is not page aligned anymore with 
> > your change, correct?  
> 
> I have to check that but I don't expect this to happen because my
> understanding of the code is that what's rounded up here is just discarded
> in free_area_init_node(). Am I wrong?
> 

NODE_DATA(nid)->node_start_pfn needs to be accurate if 
node_set_online(nid).  Since there is no guarantee about page alignment 
from the ACPI spec, removing the roundup() entirely could cause the 
address shift >> PAGE_SIZE to be off by one.  I, like you, do not see the 
need for the ZONE_ALIGN above, but I think we agree that it should be 
replaced with PAGE_SIZE instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
