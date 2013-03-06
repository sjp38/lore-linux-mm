Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6CC0D6B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 23:02:06 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 6 Mar 2013 09:28:35 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 2355C394004F
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 09:32:00 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2641u6U31391980
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 09:31:57 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2641xF6005036
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 15:01:59 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 06/24] powerpc: Reduce PTE table memory wastage
In-Reply-To: <1362440204.21357.20.camel@pasglop>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304045853.GB27523@drongo> <874ngr2zz1.fsf@linux.vnet.ibm.com> <1362440204.21357.20.camel@pasglop>
Date: Wed, 06 Mar 2013 09:31:58 +0530
Message-ID: <87ip5589c9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Benjamin Herrenschmidt <benh@kernel.crashing.org> writes:

> On Mon, 2013-03-04 at 16:28 +0530, Aneesh Kumar K.V wrote:
>> I added the below comment when initializing the list.
>> 
>> +#ifdef CONFIG_PPC_64K_PAGES
>> +       /*
>> +        * Used to support 4K PTE fragment. The pages are added to list,
>> +        * when we have free framents in the page. We track the whether
>> +        * a page frament is available using page._mapcount. A value of
>> +        * zero indicate none of the fragments are used and page can be
>> +        * freed. A value of FRAG_MASK indicate all the fragments are used
>> +        * and hence the page will be removed from the below list.
>> +        */
>> +       INIT_LIST_HEAD(&init_mm.context.pgtable_list);
>> +#endif
>> 
>> I am not sure about why you say there is no consistent rule. Can you
>> elaborate on that ?
>
> Do you really need that list ? I assume it's meant to allow you to find
> free frags when allocating but my worry is that you'll end up losing
> quite a bit of node locality of PTE pages....
>
> It may or may not work but can you investigate doing things differently
> here ? The idea I want you to consider is to always allocate a full
> page, but make the relationship of the fragments to PTE pages fixed. IE.
> the fragment in the page is a function of the VA.
>
> Basically, the algorithm for allocation is roughly:
>
>  - Walk the tree down to the PMD ptr (* that can be improved with a
> generic change, see below)
>
>  - Check if any of the neighbouring PMDs is populated. If yes, you have
> your page and pick the appropriate fragment based on the VA
>
>  - If not, allocate and populate
>
> On free, similarly, you checked if all neighbouring PMDs have been
> cleared, in which case you can fire off the page for RCU freeing.
>
> (*) By changing pte_alloc_one to take the PMD ptr (which the call side
> has right at hand) you can avoid the tree lookup.
>

Will try this.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
