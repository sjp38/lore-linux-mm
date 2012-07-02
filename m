Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 80B2D6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:19:42 -0400 (EDT)
Received: by yenr5 with SMTP id r5so5636632yen.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 14:19:41 -0700 (PDT)
Date: Mon, 2 Jul 2012 14:19:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
In-Reply-To: <20120702132832.GA18567@shangw>
Message-ID: <alpine.DEB.2.00.1207021419150.24806@chino.kir.corp.google.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com> <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com> <alpine.DEB.2.00.1207020404120.14758@chino.kir.corp.google.com> <20120702132832.GA18567@shangw>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dave@linux.vnet.ibm.com, mhocko@suse.cz, akpm@linux-foundation.org

On Mon, 2 Jul 2012, Gavin Shan wrote:

> >> diff --git a/mm/sparse.c b/mm/sparse.c
> >> index 781fa04..a6984d9 100644
> >> --- a/mm/sparse.c
> >> +++ b/mm/sparse.c
> >> @@ -75,6 +75,20 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
> >>  	return section;
> >>  }
> >>  
> >> +static inline void __meminit sparse_index_free(struct mem_section *section)
> >> +{
> >> +	unsigned long size = SECTIONS_PER_ROOT *
> >> +			     sizeof(struct mem_section);
> >> +
> >> +	if (!section)
> >> +		return;
> >> +
> >> +	if (slab_is_available())
> >> +		kfree(section);
> >> +	else
> >> +		free_bootmem(virt_to_phys(section), size);
> >
> >Eek, does that work?
> >
> 
> David, I think it's working fine. If my understanding is wrong, please
> correct me. Thanks a lot :-)
> 

I'm thinking it should be free_bootmem(__pa(section), size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
