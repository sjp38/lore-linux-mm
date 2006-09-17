Date: Sun, 17 Sep 2006 04:17:07 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917041707.28171868.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
	<Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David wrote:
> In 2G container:
> 	10599 __cpuset_zone_allowed			50.4714
> 	 3521 mwait_idle				45.1410
> 	 1149 clear_page				20.1579
>        ....
>
> In 2G cpuset with Christoph's patch:
> 	  9232 __cpuset_zone_allowed                     43.9619
> 	  2083 mwait_idle                                26.7051
> 	   973 clear_page                                17.0702

There happened to be fewer calls to __cpuset_zone_allowed in the
second test (thanks for doing this!).  If I divide that out, to
get the cost per call, it's
  original test:    10599/50.4714 == 210.00011
  christoph patch:   9232/43.9619 == 210.00002

That's -extremely- close.

Aha - notice the following code in kernel/cpuset.c:

int __cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
{
        int node;                       /* node that zone z is on */
        ...
        node = z->zone_pgdat->node_id;

Looks like an open coded zone_to_nid() invocation that wasn't
addressed by Christoph's patch.

Tsk tsk ... shame on whomever open coded that one ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
