Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 00F636B00D3
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:49:55 -0400 (EDT)
Date: Tue, 26 Mar 2013 09:49:52 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 02/10] migrate: make core migration code aware of hugepage
Message-ID: <20130326084952.GK2295@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325105701.GS2154@dhcp22.suse.cz>
 <1364272415-zvaphow7-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364272415-zvaphow7-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue 26-03-13 00:33:35, Naoya Horiguchi wrote:
> On Mon, Mar 25, 2013 at 11:57:01AM +0100, Michal Hocko wrote:
> > On Fri 22-03-13 16:23:47, Naoya Horiguchi wrote:
[...]
> > > +int migrate_movable_pages(struct list_head *from, new_page_t get_new_page,
> > > +			unsigned long private,
> > > +			enum migrate_mode mode, int reason)
> > > +{
> > > +	int err = 0;
> > > +
> > > +	if (!list_empty(from)) {
> > > +		err = migrate_pages(from, get_new_page, private, mode, reason);
> > > +		if (err)
> > > +			putback_movable_pages(from);
> > > +	}
> > > +	return err;
> > > +}
> > > +
> >
> > There doesn't seem to be any caller for this function. Please move it to
> > the patch which uses it.
> 
> I would do like that if there's only one user of this function, but I thought
> that it's better to separate this part as changes of common code
> because this function is commonly used by multiple users which are added by
> multiple patches later in this series.

Sure there is no hard rule for this. I just find it much easier to
review if there is a caller of introduced functionality. In this
particular case I found out only later that many migrate_pages callers
were changed to use mograte_movable_pages and made the
putback_movable_pages cleanup inconsistent between the two.

It would help to mention what is the planned future usage of the
introduced function if you prefer to introduce it without users.

> I mean doing like
> 
>   Patch 1: core change
>   Patch 2: user A (depend on patch 1)
>   Patch 3: user B (depend on patch 1)
>   Patch 4: user C (depend on patch 1)
> 
> is a bit cleaner and easier in bisecting than doing like
> 
>   Patch 1: core change + user A
>   Patch 2: user B (depend on patch 1)
>   Patch 3: user C (depend on patch 1)
> 
> . I'm not sure which is standard or well-accepted way.

Whatever makes the review easy ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
