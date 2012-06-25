Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 9C5526B02F9
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 21:09:16 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 24 Jun 2012 19:09:15 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 0A4E2C90052
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 21:09:11 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5P19C7n180188
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 21:09:12 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5P19BED000843
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 19:09:11 -0600
Date: Mon, 25 Jun 2012 09:09:06 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/5] mm/sparse: return 0 if root mem_section exists
Message-ID: <20120625010906.GA4120@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-5-git-send-email-shangw@linux.vnet.ibm.com>
 <CAHGf_=o7CGkJevngH0UGn-FWaEEO1zTkFD+DjWDA_NDeHcVnnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=o7CGkJevngH0UGn-FWaEEO1zTkFD+DjWDA_NDeHcVnnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> Function sparse_index_init() is used to setup memory section descriptors
>> dynamically. zero should be returned while mem_section[root] already has
>> been allocated.
>
>Why?
>

When CONFIG_SPARSEMEM_EXTREME is enabled, the memory section descriptors are
allocated dynamically and stored into "struct mem_section *mem_section[NR_SECTION_ROOTS]".

It's possible for multiple sections (e.g. 0, 1) sharing "mem_section[0]". When setup
the descriptor for section 0, the mem_section descriptor for section 1 should have
been created as well. So we needn't do same thing (actually duplicate) for section 1.

And the function returns "-EEXIST" in sparse_index_init() for section 1, which indicates
errors. Actually, here we need "0".

Does it make sense?

Thanks,
Gavin

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
