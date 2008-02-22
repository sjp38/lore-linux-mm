Date: Fri, 22 Feb 2008 12:00:03 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BEAEA9.10801@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0802221144210.379@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp>
 <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802220916290.18145@blonde.site> <47BEAEA9.10801@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008, Balbir Singh wrote:
> 
> I've been looking through the code time and again, looking for races. I will try

Well worth doing.

> and build a sketch of all the functions and dependencies tonight. One thing that
> struck me was that making page_get_page_cgroup() call lock_page_cgroup()
> internally might potentially fix a lot of racy call sites. I was thinking of
> splitting page_get_page_cgroup into __page_get_page_cgroup() <--> just get the
> pc without lock and page_get_page_cgroup(), that holds the lock and then returns pc.

I don't think that would help.  One of the problems with what's there
(before my patches) is how, for example, clear_page_cgroup takes the
lock itself - forcing you into dropping the lock before calling it
(you contemplate keeping an __ which doesn't take the lock, but then
I cannot see the point).

What's there after the patches looks fairly tidy and straightforward
to me, but emphasize "fairly".  (Often I think there's a race against
page->page_cgroup going NULL, but then realize that pc->page remains
stable and there's no such race.)

> 
> Of course, this is just a thought process. I am yet to write the code and look
> at the results.

I'd hoped to send out my series last night, but was unable to get
quite that far, sorry, and haven't tested the page migration paths yet.
The total is not unlike what I already showed, but plus Hirokazu-san's
patch and minus shmem's NULL page and minus my rearrangement of
mem_cgroup_charge_common.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
