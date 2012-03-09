Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 318A66B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 21:33:51 -0500 (EST)
Received: by iajr24 with SMTP id r24so2116112iaj.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 18:33:50 -0800 (PST)
Date: Thu, 8 Mar 2012 18:33:14 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
In-Reply-To: <20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1203081816170.18242@eggly.anvils>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri, 9 Mar 2012, KAMEZAWA Hiroyuki wrote:
> > +
> > +	page = pmd_page(pmd);
> > +	VM_BUG_ON(!page || !PageHead(page));
> > +	if (!move_anon() || page_mapcount(page) != 1)
> > +		return 0;
> 
> Could you add this ?
> ==
> static bool move_check_shared_map(struct page *page)
> {
>   /*
>    * Handling of shared pages between processes is a big trouble in memcg.
>    * Now, we never move shared-mapped pages between memcg at 'task' moving because
>    * we have no hint which task the page is really belongs to. For example, 
>    * When a task does "fork()-> move to the child other group -> exec()", the charges
>    * should be stay in the original cgroup. 
>    * So, check mapcount to determine we can move or not.
>    */
>    return page_mapcount(page) != 1;
> }

That's a helpful elucidation, thank you.  However...

That is not how it has actually been behaving for the last 18 months
(because of the "> 2" bug), so in practice you are asking for a change
in behaviour there.

And it's not how it has been and continues to behave with file pages.

Isn't getting that behaviour in fork-move-exec just a good reason not
to set move_charge_at_immigrate?

I think there are other scenarios where you do want all the pages to
move if move_charge_at_immigrate: and that's certainly easier to
describe and to understand and to code.

But if you do insist on not moving the shared, then it needs to involve
something like mem_cgroup_count_swap_user() on PageSwapCache pages,
rather than just the bare page_mapcount().

I'd rather delete than add code here!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
