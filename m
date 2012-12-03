Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <50BC13EB.1050009@cn.fujitsu.com>
Date: Mon, 03 Dec 2012 10:52:27 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com> <20121129153930.477e9709.akpm@linux-foundation.org> <50B82B0D.8010206@cn.fujitsu.com> <20121129215749.acfd872a.akpm@linux-foundation.org> <50B859C6.3020707@cn.fujitsu.com> <20121129235502.05223586.akpm@linux-foundation.org> <20121130110059.GD8218@suse.de>
In-Reply-To: <20121130110059.GD8218@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/30/2012 07:00 PM, Mel Gorman wrote:
>>
>> Well, that's a fairly low-level implementation detail.  A more typical
>> approach would be to add a new get_user_pages_non_movable() or such. 
>> That would probably have the same signature as get_user_pages(), with
>> one additional argument.  Then get_user_pages() becomes a one-line
>> wrapper which passes in a particular value of that argument.
>>
> 
> That is going in the direction that all pinned pages become MIGRATE_UNMOVABLE
> allocations.  That will impact THP availability by increasing the number
> of MIGRATE_UNMOVABLE blocks that exist and it would hit every user --
> not just those that care about ZONE_MOVABLE.
> 
> I'm likely to NAK such a patch if it's only about node hot-remove because
> it's much more of a corner case than wanting to use THP.
> 
> I would prefer if get_user_pages() checked if the page it was about to
> pin was in ZONE_MOVABLE and if so, migrate it at that point before it's
> pinned. It'll be expensive but will guarantee ZONE_MOVABLE availability
> if that's what they want. The CMA people might also want to take
> advantage of this if the page happened to be in the MIGRATE_CMA
> pageblock.
> 
hi Mel,

Thanks for your suggestion. 
My initial idea is also to restrict the impact as little as possible so 
migrate such pages as we need. 
But even to such "going to pin pages", most of them are going to be released 
soon, so deal with them all in the same way is really *expensive*. 

May be we do have to find another way that makes everybody happy :)

Thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
