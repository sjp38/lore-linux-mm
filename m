Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 19B166B007E
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 02:34:19 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 725A43EE0C3
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:34:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48C1E45DE56
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:34:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 208B445DE4D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:34:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 133C91DB8038
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:34:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B26401DB8040
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 16:34:15 +0900 (JST)
Date: Fri, 9 Mar 2012 16:32:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Message-Id: <20120309163245.d6241d9b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1331267128-4673-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
	<1331267128-4673-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Thu,  8 Mar 2012 23:25:28 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Hi KAMEZAWA-san,
> 
> > On Fri,  2 Mar 2012 15:13:09 -0500
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> ...
> > > +
> > > +	page = pmd_page(pmd);
> > > +	VM_BUG_ON(!page || !PageHead(page));
> > > +	if (!move_anon() || page_mapcount(page) != 1)
> > > +		return 0;
> >
> > Could you add this ?
> > ==
> > static bool move_check_shared_map(struct page *page)
> > {
> >   /*
> >    * Handling of shared pages between processes is a big trouble in memcg.
> >    * Now, we never move shared-mapped pages between memcg at 'task' moving because
> >    * we have no hint which task the page is really belongs to. For example,
> >    * When a task does "fork()-> move to the child other group -> exec()", the charges
> >    * should be stay in the original cgroup.
> >    * So, check mapcount to determine we can move or not.
> >    */
> >    return page_mapcount(page) != 1;
> > }
> > ==
> 
> Thank you.
> 
> We check mapcount only for anonymous pages, so we had better also describe
> that viewpoint?  And this function returns whether the target page of moving
> charge is shared or not, so a name like is_mctgt_shared() looks better to me.
> Moreover, this function explains why we have current implementation, rather
> than why return value is mapcount != 1, so I put the comment above function
> declaration like this:
> 
>   /*
>    * Handling of shared pages between processes is a big trouble in memcg.
>    * Now, we never move shared anonymous pages between memcg at 'task'
>    * moving because we have no hint which task the page is really belongs to.
>    * For example, when a task does "fork() -> move to the child other group
>    * -> exec()", the charges should be stay in the original cgroup.
>    * So, check if a given page is shared or not to determine to move charge.
>    */
>   static bool is_mctgt_shared(struct page *page)
>   {
>      return page_mapcount(page) != 1;
>   }
> 
> As for the difference between anon page and filemapped page, I have no idea
> about current charge moving policy. Is this explained anywhere? (sorry to
> question before researching by myself ...)
> 
> 

Now, I think it's okay to move mapcount check. I posted a patch for reference. 
Please check it.
https://lkml.org/lkml/2012/3/9/40

> > We may be able to support madvise(MOVE_MEMCG) or fadvise(MOVE_MEMCG), if necessary.
> 
> Is this mean moving charge policy can depend on users?
> I feel that's strange because I don't think resouce management should be
> under users' control.
> 
You're right. I 

Hm. I remember some guy suggested 'how about passing prefer memcg as mount option'
or some. Anyway, shared page handling is trouble since memory cgroup was born.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
