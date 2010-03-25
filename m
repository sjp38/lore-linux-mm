Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 975BB6B0219
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 20:43:00 -0400 (EDT)
Date: Thu, 25 Mar 2010 01:42:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [rfc 5/5] mincore: transparent huge page support
Message-ID: <20100325004254.GS10659@random.random>
References: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
 <1269354902-18975-6-git-send-email-hannes@cmpxchg.org>
 <20100324224858.GP10659@random.random>
 <20100325000749.GA27304@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100325000749.GA27304@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 01:07:49AM +0100, Johannes Weiner wrote:
> Stupid me.  I knew that, I just hadn't internalized it enough to do it
> right :)

Never mind ;)

> Btw, unless I miss something else, this is the same in follow_page()?
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 22ee158..6c26042 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1301,18 +1301,14 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  	}
>  	if (pmd_trans_huge(*pmd)) {
>  		spin_lock(&mm->page_table_lock);

follow_page already checked pmd_trans_huge first outside the lock.

> -		if (likely(pmd_trans_huge(*pmd))) {

And then again inside. We have to re-check it inside to be safe,
otherwise we've to /* fall through */

> -			if (unlikely(pmd_trans_splitting(*pmd))) {
> -				spin_unlock(&mm->page_table_lock);
> -				wait_split_huge_page(vma->anon_vma, pmd);
> -			} else {
> -				page = follow_trans_huge_pmd(mm, address,
> -							     pmd, flags);

What I want to do in mincore is to call something like
mincore_trans_huge_pmd() to remove the #ifdef to make everyone happy.

> -				spin_unlock(&mm->page_table_lock);
> -				goto out;
> -			}
> -		} else
> +		if (unlikely(pmd_trans_splitting(*pmd))) {
>  			spin_unlock(&mm->page_table_lock);
> +			wait_split_huge_page(vma->anon_vma, pmd);
> +		} else {
> +			page = follow_trans_huge_pmd(mm, address, pmd, flags);
> +			spin_unlock(&mm->page_table_lock);
> +			goto out;
> +		}

So it would miss one needed check inside the lock and it could lead to
call follow_trans_huge_pmd with a not huge pmd which is invalid.

Also note, touching with C language stuff that can change under you
like we do in the first check outside the lock (and isn't marked
volatile) may have unpredictable results in theory. But in practice we
do stuff like this all the time. Specifically in this case it's just
one bitflag check so it should be safe enough considering that
test_bit is implemented in C on x86 and does the same thing,
spin_is_locked likely is also implemented in C etc... In other cases
like "switch" parameters, gcc can implement it with a jump table, and
if the value changes under gcc it may jump beyond the end of the
table. It's a tradeoff between writing perfect C and having to deal
with asm all the time (or worse slowdown marking pmd volatile). Some
ages ago I guess I proposed to fix this including not assuming that
writes to the ptes are atomic with one instruction if done in C, but
nobody cared and in effect it works reliably also this way and it's a
bit simpler... ;).

> Knock yourself out :-)

As you wish! ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
