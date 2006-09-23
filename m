Subject: Re: [patch 3/9] mm: speculative get page
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20060922172110.22370.33715.sendpatchset@linux.site>
References: <20060922172042.22370.62513.sendpatchset@linux.site>
	 <20060922172110.22370.33715.sendpatchset@linux.site>
Content-Type: text/plain
Date: Sat, 23 Sep 2006 12:01:32 +0200
Message-Id: <1159005692.5196.1.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>  
> @@ -325,16 +328,25 @@ static int migrate_page_move_mapping(str
>  	}
>  #endif
>  
> +	SetPageNoNewRefs(newpage);
>  	radix_tree_replace_slot(pslot, newpage);
>  
> +	write_unlock_irq(&mapping->tree_lock);
> +
> +	page->mapping = NULL;
> +
> +  	write_unlock_irq(&mapping->tree_lock);
> +
> +	smp_wmb();
> +	ClearPageNoNewRefs(page);
> +	ClearPageNoNewRefs(newpage);
> +
>  	/*
>  	 * Drop cache reference from old page.
>  	 * We know this isn't the last reference.
>  	 */
>  	__put_page(page);
>  
> -	write_unlock_irq(&mapping->tree_lock);
> -
>  	return 0;
>  }


2 consecutive write_unlock_irq() calls seem odd ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
