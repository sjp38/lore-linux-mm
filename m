Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1C2676B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 19:40:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9SNeesq028002
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Oct 2009 08:40:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D11045DE57
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:40:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CA7745DE51
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:40:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 45F611DB803C
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:40:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E713A1DB8038
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 08:40:39 +0900 (JST)
Date: Thu, 29 Oct 2009 08:38:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove incorrect swap_count() from try_to_unuse()
Message-Id: <20091029083801.c720b9d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910282031470.19885@sister.anvils>
References: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
	<0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
	<dc46d49c0910201825g1b3b3987w8f9002761a64166f@mail.gmail.com>
	<Pine.LNX.4.64.0910282017410.19885@sister.anvils>
	<Pine.LNX.4.64.0910282031470.19885@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <yjfpb04@gmail.com>, Bo Liu <bo-liu@hotmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009 20:34:38 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> From: Bo Liu <bo-liu@hotmail.com>
> 
> In try_to_unuse(), swcount is a local copy of *swap_map, including the
> SWAP_HAS_CACHE bit; but a wrong comparison against swap_count(*swap_map),
> which masks off the SWAP_HAS_CACHE bit, succeeded where it should fail.
> 
Ah, okay...

> That had the effect of resetting the mm from which to start searching
> for the next swap page, to an irrelevant mm instead of to an mm in which
> this swap page had been found: which may increase search time by ~20%.
> But we're used to swapoff being slow, so never noticed the slowdown.
> 
> Remove that one spurious use of swap_count(): Bo Liu thought it merely
> redundant, Hugh rewrote the description since it was measurably wrong.
> 
> Signed-off-by: Bo Liu <bo-liu@hotmail.com>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: stable@kernel.org

Sorry for my misunderstanding.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> 
>  mm/swapfile.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> --- 2.6.32-rc5/mm/swapfile.c	2009-10-05 04:20:31.000000000 +0100
> +++ linux/mm/swapfile.c	2009-10-28 19:31:43.000000000 +0000
> @@ -1151,8 +1151,7 @@ static int try_to_unuse(unsigned int typ
>  				} else
>  					retval = unuse_mm(mm, entry, page);
>  
> -				if (set_start_mm &&
> -				    swap_count(*swap_map) < swcount) {
> +				if (set_start_mm && *swap_map < swcount) {
>  					mmput(new_start_mm);
>  					atomic_inc(&mm->mm_users);
>  					new_start_mm = mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
