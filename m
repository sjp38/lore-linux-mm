Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7L65mJB019385 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 15:05:48 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7L65mTM010534 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 15:05:48 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail503.fjmail.jp.fujitsu.com (fjmail503-0.fjmail.jp.fujitsu.com [10.59.80.100]) by s1.gw.fujitsu.co.jp (8.12.10)
	id i7L65la0005760 for <linux-mm@kvack.org>; Sat, 21 Aug 2004 15:05:47 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail503.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2S004GD8XMIZ@fjmail503.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Sat, 21 Aug 2004 15:05:47 +0900 (JST)
Date: Sat, 21 Aug 2004 15:10:54 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
In-reply-to: <20040821053735.GV11200@holomorphy.com>
Message-id: <4126E76E.2050403@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <20040821025543.GS11200@holomorphy.com>
 <20040821.135624.74737461.taka@valinux.co.jp>
 <20040821052116.GU11200@holomorphy.com> <4126DFB4.7070404@jp.fujitsu.com>
 <20040821053735.GV11200@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi,

William Lee Irwin III wrote:

> William Lee Irwin III wrote:
> 
>>>In __free_pages_bulk() changing BUG_ON(bad_range(zone, buddy1)) to
>>>if (bad_range(zone, buddy1)) break; should fix this. The start of
>>>the zone must be aligned to MAX_ORDER so buddy2 doesn't need checks.
>>>It may be worthwhile to make a distinction the bounds checks and the
>>>zone check and to BUG_ON() the zone check in isolation and not repeat
>>>the bounds check for the validity check.
> 
> 
> On Sat, Aug 21, 2004 at 02:37:56PM +0900, Hiroyuki KAMEZAWA wrote:
> 
>>Okay, I understand several BUG_ON() are needless.
>>I'll be more carefull to recognize what is checked.
> 
> 
> It's not that it's needless, it's that beforehand the bitmap rounding
> up to an even number ensured the __test_and_change_bit() check would
> prevent the bounds check from ever failing, but after the bitmap is
> eliminated, the bounds check is needed to see if we're even examining
> a valid page structure for whether the page can be merged.
> 
> 
Oh, I said these 2 lines are needless ;) ,sorry for my vagueness.
     buddy2 = base + page_idx;
(*) BUG_ON(bad_range(zone, buddy1));
(*) BUG_ON(bad_range(zone, buddy2));

I understand a test before accessing "buddy1" is necessary.

But as I mentioned in other mail, I'm afraid of memory hole in zone.
This cannot be detected by simple range check.
Is this special case of IA64 ? (I don't know other archs than i386 and IA64)

I think
+ if (!pfn_valid(buddy1))
+     break;
will work enough if pfn_valid() works correctly fot zone with hole.

If ZONE is not MAX_ORDER aligned,
if (bad_range(zone,buddy1))
     break;
will be needed too.


-- KAME

-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
