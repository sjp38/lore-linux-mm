Subject: Re: [patch 05/19] split LRU lists into anon & file sets
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108210002.638347207@redhat.com>
	 <20080130121152.1AF1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 30 Jan 2008 09:29:42 -0500
Message-Id: <1201703382.5459.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-30 at 17:57 +0900, KOSAKI Motohiro wrote:
> Hi Rik, Lee
> 
> I found number of scan pages calculation bug.
> 
> 1. wrong calculation order
> 
> 	ap *= rotate_sum / (zone->recent_rotated_anon + 1);
> 
>    when recent_rotated_anon = 100 and recent_rotated_file = 0,
>    
>      rotate_sum / (zone->recent_rotated_anon + 1)
>    = 100 / 101
>    = 0
> 
>    at that time, ap become 0.
> 
> 2. wrong fraction omission
> 
> 	nr[l] = zone->nr_scan[l] * percent[file] / 100;
> 
> 	when percent is very small,
> 	nr[l] become 0.
> 
> Test Result:
> (1) $ ./hackbench 150 process 1000
> (2) # sync; echo 3 > /proc/sys/vm/drop_caches
>     $ dd if=tmp10G of=/dev/null
>     $ ./hackbench 150 process 1000
> 
> rvr-split-lru + revert patch of previous mail
>  	(1) 83.014
> 	(2) 717.009
> 
> rvr-split-lru + revert patch of previous mail + below patch
> 	(1) 61.965
> 	(2) 85.444 !!
> 
> 
> Now, We got 1000% performance improvement against 2.6.24-rc8-mm1 :)
> 
> 
> 
> - kosaki
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

<snip>

Kosaki-san:

Rik is currently out on holiday and I've been traveling.  Just getting
back to rebasing to 24-rc8-mm1.  Thank you for your efforts in testing
and tracking down the regressions.  I will add your fixes into my tree
and try them out and let you know.  Rik mentioned to me that he has a
fix for the "get_scan_ratio()" calculation that is causing us to OOM
kill prematurely--i.e., when we still have lots of swap space to evict
swappable anon.  I don't know if it's similar to what you have posted.
Have to wait and see what he says.  Meantime, we'll try your patches.

Again, thank you.

Regards,
Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
