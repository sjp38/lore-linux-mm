Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 5 Feb 2013 13:32:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130205133244.GH21389@suse.de>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130204160624.5c20a8a0.akpm@linux-foundation.org>
 <20130205115722.GF21389@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130205115722.GF21389@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, mhocko@suse.cz, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 05, 2013 at 11:57:22AM +0000, Mel Gorman wrote:
> 
> > > +				migrate_pre_flag = 1;
> > > +			}
> > > +
> > > +			if (!isolate_lru_page(pages[i])) {
> > > +				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
> > > +						 page_is_file_cache(pages[i]));
> > > +				list_add_tail(&pages[i]->lru, &pagelist);
> > > +			} else {
> > > +				isolate_err = 1;
> > > +				goto put_page;
> > > +			}
> 
> isolate_lru_page() takes the LRU lock every time.

Credit to Michal Hocko for bringing this up but with the number of
other issues I missed that this is also broken with respect to huge page
handling. hugetlbfs pages will not be on the LRU so the isolation will mess
up and the migration has to be handled differently.  Ordinarily hugetlbfs
pages cannot be allocated from ZONE_MOVABLE but it is possible to configure
it to be allowed via /proc/sys/vm/hugepages_treat_as_movable. If this
encounters a hugetlbfs page, it'll just blow up.

The other is that this almost certainly broken for transhuge page
handling. gup returns the head and tail pages and ordinarily this is ok
because the caller only cares about the physical address. Migration will
also split a hugepage if it receives it but you are potentially adding
tail pages to a list here and then migrating them. The split of the first
page will get very confused. I'm not exactly sure what the result will be
but it won't be pretty.

Was THP enabled when this was tested? Was CONFIG_DEBUG_LIST enabled
during testing?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
