Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4D6B36B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 05:28:04 -0400 (EDT)
Message-ID: <COL115-W22347A02D3AD5F81F16D2D9FFF0@phx.gbl>
From: Bo Liu <bo-liu@hotmail.com>
Subject: RE: [PATCH] mv clear node_load[] to __build_all_zonelists()
Date: Tue, 18 Aug 2009 17:28:09 +0800
In-Reply-To: <20090818091203.20341635.kamezawa.hiroyu@jp.fujitsu.com>
References: <COL115-W869FC30815A7D5B7A63339F0A0@phx.gbl>
	<20090806195037.06e768f5.kamezawa.hiroyu@jp.fujitsu.com>
 	<20090817143447.b1ecf5c6.akpm@linux-foundation.org>
 <20090818091203.20341635.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>


 
On Tue, 18 Aug 2009 09:12:03 +0900
KAMEZAWA Hiroyuki wrote:
>
> On Mon, 17 Aug 2009 14:34:47 -0700
> Andrew Morton wrote:
>
>> On Thu, 6 Aug 2009 19:50:37 +0900
>> KAMEZAWA Hiroyuki wrote:
>>
>>> On Thu, 6 Aug 2009 18:44:40 +0800
>>> Bo Liu wrote:
>>>
>>>>
>>>> If node_load[] is cleared everytime build_zonelists() is called,node_load[]
>>>> will have no help to find the next node that should appear in the given node's
>>>> fallback list.
>>>> Signed-off-by: Bob Liu
>>>
>>> nice catch. (my old bug...sorry
>>>
>>> Reviewed-by: KAMEZAWA Hiroyuki 
>>>
>>> BTW, do you have special reasons to hide your mail address in commit log ?
>>>
>>> I added proper CC: list.
>>> Hmm, I think it's necessary to do total review/rewrite this function again..
>>>
>>>
>>>> ---
>>>> mm/page_alloc.c | 2 +-
>>>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index d052abb..72f7345 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -2544,7 +2544,6 @@ static void build_zonelists(pg_data_t *pgdat)
>>>> prev_node = local_node;
>>>> nodes_clear(used_mask);
>>>>
>>>> - memset(node_load, 0, sizeof(node_load));
>>>> memset(node_order, 0, sizeof(node_order));
>>>> j = 0;
>>>>
>>>> @@ -2653,6 +2652,7 @@ static int __build_all_zonelists(void *dummy)
>>>> {
>>>> int nid;
>>>>
>>>> + memset(node_load, 0, sizeof(node_load));
>>>> for_each_online_node(nid) {
>>>> pg_data_t *pgdat = NODE_DATA(nid);
>>
>> What are the consequences of this bug?
>>
>> Is the fix needed in 2.6.31? Earlier?
>>
> I think this should be on fast-track as bugfix.
>
> By this bug, zonelist's node_order is not calculated as expected.
> This bug affects on big machine, which has asynmetric node distance.
>
> [synmetric NUMA's node distance]
> 0 1 2
> 0 10 12 12
> 1 12 10 12
> 2 12 12 10
>
> [asynmetric NUMA's node distance]
> 0 1 2
> 0 10 12 20
> 1 12 10 14
> 2 20 14 10
>
 
Thanks for your explanations.
Actually,
When I submited this patch I didn't think so clearly about the consequences.
I just knew the node_load[] will be nouse because of the memset() clear it every time.

>
> This (my bug) is very old..but no one have reported this for a long time.
> Maybe because the number of asynmetric NUMA is very small and they use cpuset
> for customizing node memory allocation fallback.
 
 
 
_________________________________________________________________
With Windows Live, you can organize, edit, and share your photos.
http://www.microsoft.com/middleeast/windows/windowslive/products/photo-gallery-edit.aspx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
