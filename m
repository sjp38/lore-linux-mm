Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 99DC76B014D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:37:58 -0400 (EDT)
Date: Tue, 26 Mar 2013 16:37:44 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364330264-4oj9uxvi-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130326100221.GN2295@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325133644.GY2154@dhcp22.suse.cz>
 <1364281578-4bs50rjv-mutt-n-horiguchi@ah.jp.nec.com>
 <20130326100221.GN2295@dhcp22.suse.cz>
Subject: Re: [PATCH 06/10] migrate: add hugepage migration code to
 move_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Mar 26, 2013 at 11:02:21AM +0100, Michal Hocko wrote:
> On Tue 26-03-13 03:06:18, Naoya Horiguchi wrote:
> > On Mon, Mar 25, 2013 at 02:36:44PM +0100, Michal Hocko wrote:
> > > On Fri 22-03-13 16:23:51, Naoya Horiguchi wrote:
> > > > @@ -1164,6 +1175,12 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
> > > [...]
> > > >  				!migrate_all)
> > > >  			goto put_and_set;
> > > >  
> > > > +		if (PageHuge(page)) {
> > > > +			get_page(page);
> > > > +			list_move_tail(&page->lru, &pagelist);
> > > > +			goto put_and_set;
> > > > +		}
> > > 
> > > Why do you take an additional reference here? You have one from
> > > follow_page already.
> > 
> > For normal pages, follow_page(FOLL_GET) takes a refcount and
> > isolate_lru_page() takes another one, so I think the same should
> > be done for hugepages. Refcounting of this function looks tricky,
> > and I'm not sure why existing code does like that.
> 
> Ohh, I see. But the whole reference is taken just to release it in goto
> put_and_set because isolate_lru_page elevates reference count because
> other users require that. I think you do not have to mimic this behavior
> here and you can drop get_page and use goto set_status.

OK, thanks.
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
