Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CF3066B004F
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 18:36:58 -0400 (EDT)
Message-ID: <4A57C3D1.7000407@redhat.com>
Date: Sat, 11 Jul 2009 01:42:25 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: KSM: current madvise rollup
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils> <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils> <4A4A5C56.5000109@redhat.com> <Pine.LNX.4.64.0907010057320.4255@sister.anvils> <4A4B317F.4050100@redhat.com> <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>  
>   
Hey Hugh,

I started to hack the code around to make sure i understand everything, 
and in addition i wanted to add few things

One thing that catched my eyes was:
> +
> +/*
> + * cmp_and_merge_page - take a page computes its hash value and check if there
> + * is similar hash value to different page,
> + * in case we find that there is similar hash to different page we call to
> + * try_to_merge_two_pages().
> + *
> + * @page: the page that we are searching identical page to.
> + * @rmap_item: the reverse mapping into the virtual address of this page
> + */
> +static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
> +{
> +	struct page *page2[1];
> +	struct rmap_item *tree_rmap_item;
> +	unsigned int checksum;
> +	int err;
> +
> +	if (in_stable_tree(rmap_item))
> +		remove_rmap_item_from_tree(rmap_item);
> +
>
>   


So when we enter to cmp_and_merge_page, if the page is in_stable_tree() 
we will remove the rmap_item from the stable tree,
And then we have inside:

> + * ksm_do_scan  - the ksm scanner main worker function.
> + * @scan_npages - number of pages we want to scan before we return.
> + */
> +static void ksm_do_scan(unsigned int scan_npages)
> +{
> +	struct rmap_item *rmap_item;
> +	struct page *page;
> +
> +	while (scan_npages--) {
> +		cond_resched();
> +		rmap_item = scan_get_next_rmap_item(&page);
> +		if (!rmap_item)
> +			return;
> +		if (!PageKsm(page) || !in_stable_tree(rmap_item))
> +			cmp_and_merge_page(page, rmap_item);
> +		put_page(page);
> +	}
> +}
>   

So this check for: if (!PageKsm(page) || !in_stable_tree(rmap_item)) 
will be true for !in_stable_tree(rmap_item)

Isnt it mean that we are "stop using the stable tree help" ?
It look like every item that will go into the stable tree will get 
flushed from it in the second run, that will highly increase the ksmd 
cpu usage, and will make it find less pages...
Was this what you wanted to do? or am i missed anything?

Beside this one more thing i noticed while checking this code:
beacuse the new "Ksm shared page" is not File backed page, it isnt count 
in top as a shared page, and i couldnt find a way to see how many pages 
are shared for each application..
This is important for management tools such as a tool that will want to 
know what Virtual Machines it want to migrate from the host into another 
host based on the memory sharing in that specific host (Meaning how much 
ram it really take on that specific host)

So I started to prepre a patch that will show merged pages count inside 
/proc/pid/mergedpages, But then i thought this statics lie:
if we will have 2 applications: application A and application B, that 
share the same page, how should it look like?:

cat /proc/pid_of_A/merged_pages -> 1
cat /proc/pid_of_B/merged_pages -> 1

or:

cat /proc/pid_of_A/merged_pages -> 0 (beacuse this one was shared with 
the page of B)
cat /proc/pid_of_B/merged_pages -> 1

To make the second method thing work as much as reaible as we can we 
would want to break KsmPages that have just one mapping into them...


What do you think about that? witch direction should we take for that?


(Other than this stuff, everything running happy and nice, I think cpu 
is little bit too high beacuse the removing of the stable_tree issue)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
