Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39A056B005C
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 05:19:22 -0400 (EDT)
Date: Thu, 4 Jun 2009 11:26:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v5
Message-ID: <20090604092634.GW1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184648.2E2131D028F@basil.firstfloor.org> <20090604032441.GC5740@localhost> <20090604051346.GM1065@one.firstfloor.org> <20090604090737.GB18421@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604090737.GB18421@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 05:07:37PM +0800, Wu Fengguang wrote:
> 
> > > > +        * need this to decide if we should kill or just drop the page.
> > > > +        */
> > > > +       mapping = page_mapping(p);
> > > > +       if (!PageDirty(p) && !PageAnon(p) && !PageSwapBacked(p) &&
> > > 
> > > !PageAnon(p) could be removed: the below non-zero mapping check will
> > > do the work implicitly.
> > 
> > You mean !page_mapped?  Ok.
> 
> I mean to do
>                 mapping = page_mapping(p);
>                 if (!PageDirty(p) && !PageSwapBacked(p) && 
>                     mapping && mapping_cap_account_dirty(mapping)) {
> 
> Because for anonymous pages, page_mapping == NULL.

I realized this after pressing send. Anyways the PageAnon is dropped
> 
> --- sound-2.6.orig/mm/memory-failure.c
> +++ sound-2.6/mm/memory-failure.c
> @@ -660,6 +660,10 @@ static void hwpoison_user_mappings(struc
>  			break;
>  		pr_debug("MCE %#lx: try_to_unmap retry needed %d\n", pfn,  ret);
>  	}
> +	if (ret != SWAP_SUCCESS)
> +		printk(KERN_ERR
> +		       "MCE %#lx: failed to unmap page (mapcount=%d)!\n",
> +		       pfn, page_mapcount(p));

Ok.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
