Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5190AE4F.4000103@cn.fujitsu.com>
Date: Mon, 13 May 2013 17:11:43 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com> <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com> <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de>
In-Reply-To: <20130206095617.GN21389@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Mel,

On 02/06/2013 05:56 PM, Mel Gorman wrote:
>
> There is the possibility that callbacks could be introduced for
> migrate_unpin() and migrate_pin() that takes a list of PFN pairs
> (old,new). The unpin callback should release the old PFNs and barrier
> against any operations until the migrate_pfn() callback is called with
> the updated pfns to be repinned. Again it would fully depend on subsystems
> implementing it properly.
>
> The callback interface would be more robust but puts a lot more work on
> the driver side where your milage will vary.
>

I'm very interested in the "callback" way you said.

For memory hot-remove case, the aio pages are pined in memory and making
the pages cannot be offlined, furthermore, the pages cannot be removed.

IIUC, you mean implement migrate_unpin() and migrate_pin() callbacks in aio
subsystem, and call them when hot-remove code tries to offline pages, 
right ?

If so, I'm wondering where should we put this callback pointers ?
In struct page ?


It has been a long time since this topic was discussed. But to solve this
problem cleanly for hotplug guys and CMA guys, please give some more 
comments.

Thanks. :)

>
> To guarantee CMA can migrate pages pinned by drivers I think you need
> migrate-related callsbacks to unpin, barrier the driver until migration
> completes and repin.
>
> I do not know, or at least have no heard, of anyone working on such a
> scheme.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
