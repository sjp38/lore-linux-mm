Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id EBEDE6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 21:20:02 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 21:20:00 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E07DD38C803A
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 21:19:19 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q631JJqj297200
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 21:19:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q631JJwC017759
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 22:19:19 -0300
Date: Tue, 3 Jul 2012 09:19:17 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120703011917.GA8611@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1207020404120.14758@chino.kir.corp.google.com>
 <20120702132832.GA18567@shangw>
 <alpine.DEB.2.00.1207021419150.24806@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207021419150.24806@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, dave@linux.vnet.ibm.com, mhocko@suse.cz, akpm@linux-foundation.org

On Mon, Jul 02, 2012 at 02:19:39PM -0700, David Rientjes wrote:
>On Mon, 2 Jul 2012, Gavin Shan wrote:
>
>> >> diff --git a/mm/sparse.c b/mm/sparse.c
>> >> index 781fa04..a6984d9 100644
>> >> --- a/mm/sparse.c
>> >> +++ b/mm/sparse.c
>> >> @@ -75,6 +75,20 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>> >>  	return section;
>> >>  }
>> >>  
>> >> +static inline void __meminit sparse_index_free(struct mem_section *section)
>> >> +{
>> >> +	unsigned long size = SECTIONS_PER_ROOT *
>> >> +			     sizeof(struct mem_section);
>> >> +
>> >> +	if (!section)
>> >> +		return;
>> >> +
>> >> +	if (slab_is_available())
>> >> +		kfree(section);
>> >> +	else
>> >> +		free_bootmem(virt_to_phys(section), size);
>> >
>> >Eek, does that work?
>> >
>> 
>> David, I think it's working fine. If my understanding is wrong, please
>> correct me. Thanks a lot :-)
>> 
>
>I'm thinking it should be free_bootmem(__pa(section), size);
>

Thanks for pointing it out, David.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
