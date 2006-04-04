Date: Tue, 4 Apr 2006 08:20:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] mm: speculative get_page
In-Reply-To: <20060219020159.9923.94877.sendpatchset@linux.site>
Message-ID: <Pine.LNX.4.64.0604040814140.26807@schroedinger.engr.sgi.com>
References: <20060219020140.9923.43378.sendpatchset@linux.site>
 <20060219020159.9923.94877.sendpatchset@linux.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Looks like the NoNewRefs flag is mostly == 
spin_is_locked(mapping->tree_lock)? Would it not be better to check the 
tree_lock?


> --- linux-2.6.orig/mm/migrate.c
> +++ linux-2.6/mm/migrate.c
>  
> +	SetPageNoNewRefs(page);
>  	write_lock_irq(&mapping->tree_lock);

A dream come true! If this is really working as it sounds then we can 
move the SetPageNoNewRefs up and avoid the final check under 
mapping->tree_lock. Then keep SetPageNoNewRefs until the page has been 
copied. It would basically play the same role as locking the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
