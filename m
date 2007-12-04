Date: Tue, 4 Dec 2007 10:33:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [5/8] throttling simultaneous callers of try_to_free_mem_cgroup_pages
Message-Id: <20071204103332.ad4cf9b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203092418.58631593@bree.surriel.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203183921.72005b21.kamezawa.hiroyu@jp.fujitsu.com>
	<20071203092418.58631593@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Dec 2007 09:24:18 -0500
Rik van Riel <riel@redhat.com> wrote:

> On Mon, 3 Dec 2007 18:39:21 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Add throttling direct reclaim.
> > 
> > Trying heavy workload under memory controller, you'll see too much
> > iowait and system seems heavy. (This is not good.... memory controller
> > is usually used for isolating system workload)
> > And too much memory are reclaimed.
> > 
> > This patch adds throttling function for direct reclaim.
> > Currently, num_online_cpus/(4) + 1 threads can do direct memory reclaim
> > under memory controller.
> 
> The same problems are true of global reclaim.
> 
> Now that we're discussing this RFC anyway, I wonder if we
> should think about moving this restriction to the global
> reclaim level...
> 
Hmm, I agree to some extent.
I'd like to add the same level of parameters to memory controller AMAP.

But, IMHO, there are differences basically.

Memory controller's reclaim is much heavier than global LRU because of
increasing footprint , the number of atomic ops....
And memory controller's reclaim policy is simpler than global because
it is not  kicked by memory shortage and almost all gfk_mask is GFP_HIGHUSER_MOVABLE
and order is always 0.
 
I think starting from throttling memory controller is not so bad because 
it's heavy and it's simple. The benefit of this throttoling is clearer than
globals.

Adding this kind of controls to global memory allocator/LRU may cause
unexpected slow down in application's response time. High-response application
users may dislike this. We may need another gfp_flag or sysctl to allow
throttling in global.
For memory controller, the user sets its memory limitation by himself. He can
adjust parameters and the workload. So, I think this throttoling is not so
problematic in memory controller as global.

Of course, we can export "do throttoling or not" control in cgroup interface.


Thanks,
-Kame 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
