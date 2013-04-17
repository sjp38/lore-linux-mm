Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 641E16B0027
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 00:47:21 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id xa7so674311pbc.13
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 21:47:20 -0700 (PDT)
Date: Tue, 16 Apr 2013 21:47:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug fix PATCH v3] Reusing a resource structure allocated by
 bootmem
In-Reply-To: <516E2305.3060705@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1304162144320.3493@chino.kir.corp.google.com>
References: <516DEC34.7040008@jp.fujitsu.com> <alpine.DEB.2.02.1304161733340.14583@chino.kir.corp.google.com> <516E2305.3060705@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hp.com, linuxram@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Apr 2013, Yasuaki Ishimatsu wrote:

> > Why not simply do what generic sparsemem support does by testing
> > PageSlab(virt_to_head_page(res)) and calling kfree() if true and freeing
> > back to bootmem if false?  This should be like a five line patch.
> 
> Is your explanation about free_section_usemap()?
> If so, I don't think we can release resource structure like
> free_section_usemap().

Right, you can't release it like free_section_usemap(), but you're free to 
test for PageSlab(virt_to_head_page(res)) in kernel/resource.c.

> In your explanation case, memmap can be released by put_page_bootmem() in
> free_map_bootmem() since all pages of memmap is used only for memmap.
> But if my understanding is correct, a page of released resource structure
> contain other purpose objects allocated by bootmem. So we cannot
> release resource structure like free_section_usemap().
> 

I'm thinking it would be much easier to just suppress the kfree() if 
!PageSlab.  If you can free an entire page with free_bootmem_late(), 
that would be great, but I'm thinking that will take more work than it's 
worth.  It seems fine to just do free_bootmem() and leave those pages as 
reserved.  How much memory are we talking about?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
