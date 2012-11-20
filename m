Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 388426B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 12:43:12 -0500 (EST)
Message-ID: <50ABC128.80706@leemhuis.info>
Date: Tue, 20 Nov 2012 18:43:04 +0100
From: Thorsten Leemhuis <fedora@leemhuis.info>
MIME-Version: 1.0
Subject: Re: [PATCH] Revert "mm: remove __GFP_NO_KSWAPD"
References: <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz> <509C84ED.8090605@linux.vnet.ibm.com> <509CB9D1.6060704@redhat.com> <20121109090635.GG8218@suse.de> <509F6C2A.9060502@redhat.com> <20121112113731.GS8218@suse.de> <CA+5PVA75XDJjo45YQ7+8chJp9OEhZxgPMBUpHmnq1ihYFfpOaw@mail.gmail.com> <20121116200616.GK8218@suse.de> <CA+5PVA7__=JcjLAhs5cpVK-WaZbF5bQhp5WojBJsdEt9SnG3cw@mail.gmail.com>
In-Reply-To: <CA+5PVA7__=JcjLAhs5cpVK-WaZbF5bQhp5WojBJsdEt9SnG3cw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Zdenek Kabelac <zkabelac@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, bruno@wolff.to

On 20.11.2012 16:38, Josh Boyer wrote:
> On Fri, Nov 16, 2012 at 3:06 PM, Mel Gorman <mgorman@suse.de> wrote:
>> On Fri, Nov 16, 2012 at 02:14:47PM -0500, Josh Boyer wrote:
>>> On Mon, Nov 12, 2012 at 6:37 AM, Mel Gorman <mgorman@suse.de> wrote:
>>>> With "mm: vmscan: scale number of pages reclaimed by reclaim/compaction
>>>> based on failures" reverted, Zdenek Kabelac reported the following
>>>>
>>>>          Hmm,  so it's just took longer to hit the problem and observe
>>>>          kswapd0 spinning on my CPU again - it's not as endless like before -
>>>>          but still it easily eats minutes - it helps to  turn off  Firefox
>>>>          or TB  (memory hungry apps) so kswapd0 stops soon - and restart
>>>>          those apps again.  (And I still have like >1GB of cached memory)
>>>>
>>>>          kswapd0         R  running task        0    30      2 0x00000000
>>>>           ffff8801331efae8 0000000000000082 0000000000000018 0000000000000246
>>>>           ffff880135b9a340 ffff8801331effd8 ffff8801331effd8 ffff8801331effd8
>>>>           ffff880055dfa340 ffff880135b9a340 00000000331efad8 ffff8801331ee000
>>>>          Call Trace:
>>>>           [<ffffffff81555bf2>] preempt_schedule+0x42/0x60
>>>>           [<ffffffff81557a95>] _raw_spin_unlock+0x55/0x60
>>>>           [<ffffffff81192971>] put_super+0x31/0x40
>>>>           [<ffffffff81192a42>] drop_super+0x22/0x30
>>>>           [<ffffffff81193b89>] prune_super+0x149/0x1b0
>>>>           [<ffffffff81141e2a>] shrink_slab+0xba/0x510
>>>>
>>>> The sysrq+m indicates the system has no swap so it'll never reclaim
>>>> anonymous pages as part of reclaim/compaction. That is one part of the
>>>> problem but not the root cause as file-backed pages could also be reclaimed.
>>>>
>>>> The likely underlying problem is that kswapd is woken up or kept awake
>>>> for each THP allocation request in the page allocator slow path.
>>>>
>>>> If compaction fails for the requesting process then compaction will be
>>>> deferred for a time and direct reclaim is avoided. However, if there
>>>> are a storm of THP requests that are simply rejected, it will still
>>>> be the the case that kswapd is awake for a prolonged period of time
>>>> as pgdat->kswapd_max_order is updated each time. This is noticed by
>>>> the main kswapd() loop and it will not call kswapd_try_to_sleep().
>>>> Instead it will loopp, shrinking a small number of pages and calling
>>>> shrink_slab() on each iteration.
>>>>
>>>> The temptation is to supply a patch that checks if kswapd was woken for
>>>> THP and if so ignore pgdat->kswapd_max_order but it'll be a hack and not
>>>> backed up by proper testing. As 3.7 is very close to release and this is
>>>> not a bug we should release with, a safer path is to revert "mm: remove
>>>> __GFP_NO_KSWAPD" for now and revisit it with the view to ironing out the
>>>> balance_pgdat() logic in general.
>>>>
>>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>>
>>> Does anyone know if this is queued to go into 3.7 somewhere?  I looked
>>> a bit and can't find it in a tree.  We have a few reports of Fedora
>>> rawhide users hitting this.
>>
>> No, because I was waiting to hear if a) it worked and preferably if the
>> alternative "less safe" option worked. This close to release it might be
>> better to just go with the safe option.
>
> We've been tracking it in https://bugzilla.redhat.com/show_bug.cgi?id=866988
> and people say this revert patch doesn't seem to make the issue go away
> fully.  Thorsten has created another kernel with the other patch applied
> for testing.
>
> At least I think that is the latest status from the bug.  Hopefully the
> commenters will chime in.

The short story from my current point of view is:

  * my main machine at home where I initially saw the issue that started 
this thread seems to be running fine with rc6 and the "safe" patch Mel 
posted in https://lkml.org/lkml/2012/11/12/113 Before that I ran a rc5 
kernel with the revert that went into rc6 and the "safe" patch -- that 
worked fine for a few days, too.

  * I have a second machine where I started to use 3.7-rc kernels only 
yesterday (the machine triggered a bug in the radeon driver that seems 
to be fixed in rc6) which showed symptoms like the ones Zdenek Kabelac 
mentions in this thread. I wasn't able to look closer at it, but simply 
tried rc6 with the safe patch, which didn't help. I'm now running rc6 
with the "riskier" patch from https://lkml.org/lkml/2012/11/12/151
I can't yet tell if it helps. If the problems shows up again I'll try to 
capture more debugging data via sysrq -- there wasn't any time for that 
when I was running rc6 with the safe patch, sorry.

Thorsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
