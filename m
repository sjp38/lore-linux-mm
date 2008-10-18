From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] mm: fix anon_vma races
Date: Sat, 18 Oct 2008 13:35:06 +1100
References: <20081016041033.GB10371@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org> <20081018022541.GA19018@wotan.suse.de>
In-Reply-To: <20081018022541.GA19018@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810181335.06871.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 18 October 2008 13:25, Nick Piggin wrote:

> @@ -171,6 +181,10 @@ static struct anon_vma *page_lock_anon_v
>
>  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>  	spin_lock(&anon_vma->lock);
> +
> +	if (anon_mapping != (unsigned long)page->mapping)
> +		goto out;
> +
>  	return anon_vma;
>  out:
>  	rcu_read_unlock();

Err, that should probably be another check for page_mapped(), because
I think page->mapping probably won't get cleared until after anon_vma
may have been freed and reused...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
