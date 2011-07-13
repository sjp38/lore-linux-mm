Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D17A19000C2
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 20:34:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C3AFF3EE0C1
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:34:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A67BC45DEB6
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:34:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8182245DEB4
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:34:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 721621DB8038
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:34:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E0821DB803C
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 09:34:33 +0900 (JST)
Message-ID: <4E1CE820.1040908@jp.fujitsu.com>
Date: Wed, 13 Jul 2011 09:34:40 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: vmscan: Do use use PF_SWAPWRITE from zone_reclaim
References: <1310389274-13995-1-git-send-email-mgorman@suse.de> <1310389274-13995-2-git-send-email-mgorman@suse.de> <CAEwNFnATXiQsmbfuvZNEtcpcVZkyZKRFB1SKbkEREaCW4S-aUg@mail.gmail.com> <4E1C1684.4090706@jp.fujitsu.com> <20110712101400.GC7529@suse.de>
In-Reply-To: <20110712101400.GC7529@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

(2011/07/12 19:14), Mel Gorman wrote:
> On Tue, Jul 12, 2011 at 06:40:20PM +0900, KOSAKI Motohiro wrote:
>> (2011/07/12 18:27), Minchan Kim wrote:
>>> Hi Mel,
>>>
>>> On Mon, Jul 11, 2011 at 10:01 PM, Mel Gorman <mgorman@suse.de> wrote:
>>>> Zone reclaim is similar to direct reclaim in a number of respects.
>>>> PF_SWAPWRITE is used by kswapd to avoid a write-congestion check
>>>> but it's set also set for zone_reclaim which is inappropriate.
>>>> Setting it potentially allows zone_reclaim users to cause large IO
>>>> stalls which is worse than remote memory accesses.
>>>
>>> As I read zone_reclaim_mode in vm.txt, I think it's intentional.
>>> It has meaning of throttle the process which are writing large amounts
>>> of data. The point is to prevent use of remote node's free memory.
>>>
>>> And we has still the comment. If you're right, you should remove comment.
>>> "         * and we also need to be able to write out pages for RECLAIM_WRITE
>>>          * and RECLAIM_SWAP."
>>>
>>>
>>> And at least, we should Cc Christoph and KOSAKI.
>>
>> Of course, I'll take full ack this. Do you remember I posted the same patch
>> about one year ago.
> 
> Nope, I didn't remember it at all :) . I'll revive your signed-off
> and sorry about that.

No. Not sorry.I think my explanation was not enough. And I couldn't show
the performance result. At that time, I didn't access large NUMA machine.

Thank you for paying attention the latency issue. I'm really glad.


> 
>> At that time, Mel disagreed me and I'm glad to see he changed
>> the mind. :)
>>
> 
> Did I disagree because of this?
> 
> 	Simply that I believe the intention of PF_SWAPWRITE here was
> 	to allow zone_reclaim() to aggressively reclaim memory if the
> 	reclaim_mode allowed it as it was a statement that off-node
> 	accesses are really not desired.
> 
> Or was some other problem brought up that I'm not thinking of now?

To be honest, My brain is volatile memory and my remember is unclear.
As far as remember is, yes, it is only problem.


> I'm no longer think the level of aggression is appropriate after seeing
> how seeing how zone_reclaim can stall when just copying large amounts
> of data on recent x86-64 NUMA machines. In the same mail, I said
> 
> 	Ok. I am not fully convinced but I'll not block it either if
> 	believe it's necessary. My current understanding is that this
> 	patch only makes a difference if the server is IO congested in
> 	which case the system is struggling anyway and an off-node
> 	access is going to be relatively small penalty overall.
> 	Conceivably, having PF_SWAPWRITE set makes things worse in
> 	that situation and the patch makes some sense.
> 
> While I still think this situation is hard to trigger, zone_reclaim
> can cause significant stalls *without* IO and there is little point
> making the situation even worse.

And, again, I'm fully agree your [0/3] description.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
