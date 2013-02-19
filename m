Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51234C12.4020404@cn.fujitsu.com>
Date: Tue, 19 Feb 2013 17:55:30 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of get_user_pages()
 called get_user_pages_non_movable()
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com> <20130204160624.5c20a8a0.akpm@linux-foundation.org> <20130205115722.GF21389@suse.de> <512203C4.8010608@cn.fujitsu.com> <20130218151716.GL4365@suse.de>
In-Reply-To: <20130218151716.GL4365@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Mel,

On 02/18/2013 11:17 PM, Mel Gorman wrote:
>>> > > <SNIP>
>>> > >
>>> > > result. It's a little clumsy but the memory hot-remove failure message
>>> > > could list what applications have pinned the pages that cannot be removed
>>> > > so the administrator has the option of force-killing the application. It
>>> > > is possible to discover what application is pinning a page from userspace
>>> > > but it would involve an expensive search with /proc/kpagemap
>>> > > 
>>>>> > >>> +	if (migrate_pre_flag && !isolate_err) {
>>>>> > >>> +		ret = migrate_pages(&pagelist, alloc_migrate_target, 1,
>>>>> > >>> +					false, MIGRATE_SYNC, MR_SYSCALL);
>>> > > 
>>> > > The conversion of alloc_migrate_target is a bit problematic. It strips
>>> > > the __GFP_MOVABLE flag and the consequence of this is that it converts
>>> > > those allocation requests to MIGRATE_UNMOVABLE. This potentially is a large
>>> > > number of pages, particularly if the number of get_user_pages_non_movable()
>>> > > increases for short-lived pins like direct IO.
>> >
>> > Sorry, I don't quite understand here neither. If we use the following new 
>> > migration allocation function as you said, the increasing number of 
>> > get_user_pages_non_movable() will also lead to large numbers of MIGRATE_UNMOVABLE
>> > pages. What's the difference, do I miss something?
>> > 
> The replacement function preserves the __GFP_MOVABLE flag. It cannot use
> ZONE_MOVABLE but otherwise the newly allocated page will be grouped with
> other movable pages.

Ah, got it " But GFP_MOVABLE is not only a zone specifier but also an allocation policy.".

Could I clear __GFP_HIGHMEM flag in alloc_migrate_target depending on private parameter so
that we can keep MIGRATE_UNMOVABLE policy also allocate page none movable zones with little
change?

Does that approach work? Otherwise I have to follow your suggestion.

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
