From: Wanpeng Li <liwanp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Date: Thu, 11 Apr 2013 15:27:30 +0800
Message-ID: <19056.1182135299$1365665273@news.gmane.org>
References: <20130408090131.GB21654@lge.com> <51628877.5000701@parallels.com>
	<20130409005547.GC21654@lge.com> <20130409012931.GE17758@dastard>
	<20130409020505.GA4218@lge.com> <20130409123008.GM17758@dastard>
	<20130410025115.GA5872@lge.com> <20130410100752.GA10481@dastard>
	<CAAmzW4OMyZ=nVbHK_AiifPK5LVxvhOQUXmsD5NGfo33CBjf=eA@mail.gmail.com>
	<20130411004114.GC10481@dastard>
Reply-To: Wanpeng Li <liwanp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130411004114.GC10481@dastard>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, JoonSoo Kim <js1304-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Linux Memory Management List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wanpeng Li <liwanp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: linux-mm.kvack.org

On Thu, Apr 11, 2013 at 10:41:14AM +1000, Dave Chinner wrote:
>On Wed, Apr 10, 2013 at 11:03:39PM +0900, JoonSoo Kim wrote:
>> Another one what I found is that they don't account "nr_reclaimed" precisely.
>> There is no code which check whether "current->reclaim_state" exist or not,
>> except prune_inode().
>
>That's because prune_inode() can free page cache pages when the
>inode mapping is invalidated. Hence it accounts this in addition
>to the slab objects being freed.
>
>IOWs, if you have a shrinker that frees pages from the page cache,
>you need to do this. Last time I checked, only inode cache reclaim
>caused extra page cache reclaim to occur, so most (all?) other
>shrinkers do not need to do this.
>

If we should account "nr_reclaimed" against huge zero page? There are 
large number(512) of pages reclaimed which can throttle direct or 
kswapd relcaim to avoid reclaim excess pages. I can do this work if 
you think the idea is needed.

Regards,
Wanpeng Li 

>It's just another wart that we need to clean up....
>
>Cheers,
>
>Dave.
>-- 
>Dave Chinner
>david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org
