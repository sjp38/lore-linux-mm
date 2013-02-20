Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51249E3E.9070909@gmail.com>
Date: Wed, 20 Feb 2013 17:58:22 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages()
 called get_user_pages_non_movable()
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com> <20130204160624.5c20a8a0.akpm@linux-foundation.org> <20130205115722.GF21389@suse.de> <20130205133244.GH21389@suse.de>
In-Reply-To: <20130205133244.GH21389@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lin Feng <linfeng@cn.fujitsu.com>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, mhocko@suse.cz, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 02/05/2013 09:32 PM, Mel Gorman wrote:
> On Tue, Feb 05, 2013 at 11:57:22AM +0000, Mel Gorman wrote:
>>>> +				migrate_pre_flag = 1;
>>>> +			}
>>>> +
>>>> +			if (!isolate_lru_page(pages[i])) {
>>>> +				inc_zone_page_state(pages[i], NR_ISOLATED_ANON +
>>>> +						 page_is_file_cache(pages[i]));
>>>> +				list_add_tail(&pages[i]->lru, &pagelist);
>>>> +			} else {
>>>> +				isolate_err = 1;
>>>> +				goto put_page;
>>>> +			}
>> isolate_lru_page() takes the LRU lock every time.
> Credit to Michal Hocko for bringing this up but with the number of
> other issues I missed that this is also broken with respect to huge page
> handling. hugetlbfs pages will not be on the LRU so the isolation will mess
> up and the migration has to be handled differently.  Ordinarily hugetlbfs
> pages cannot be allocated from ZONE_MOVABLE but it is possible to configure
> it to be allowed via /proc/sys/vm/hugepages_treat_as_movable. If this
> encounters a hugetlbfs page, it'll just blow up.

As you said, hugetlbfs pages are not in LRU list, then how can encounter 
a hugetlbfs page and blow up?

>
> The other is that this almost certainly broken for transhuge page
> handling. gup returns the head and tail pages and ordinarily this is ok

When need gup thp? in kvm case?

> because the caller only cares about the physical address. Migration will
> also split a hugepage if it receives it but you are potentially adding
> tail pages to a list here and then migrating them. The split of the first
> page will get very confused. I'm not exactly sure what the result will be
> but it won't be pretty.
>
> Was THP enabled when this was tested? Was CONFIG_DEBUG_LIST enabled
> during testing?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
