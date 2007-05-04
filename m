From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] change global zonelist order v4 [0/2]
Date: Fri, 4 May 2007 08:26:23 -0700
References: <20070427144530.ae42ee25.kamezawa.hiroyu@jp.fujitsu.com> <20070503224730.3bc6f8a8.akpm@linux-foundation.org>
In-Reply-To: <20070503224730.3bc6f8a8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705040826.23687.jbarnes@virtuousgeek.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thursday, May 03, 2007, Andrew Morton wrote:
> On Fri, 27 Apr 2007 14:45:30 +0900 KAMEZAWA Hiroyuki 
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Hi, this is version 4. including Lee Schermerhon's good rework.
> > and automatic configuration at boot time.
>
> hm, this adds rather a lot of code.  Have we established that it's worth
> it?
>
> And it's complex - how do poor users know what to do with this new
> control?
>
>
> This:
>
> + *	= "[dD]efault | "0"	- default, automatic configuration.
> + *	= "[nN]ode"|"1" 	- order by node locality,
> + *         			  then zone within node.
> + *	= "[zZ]one"|"2" - order by zone, then by locality within zone
>
> seems a bit excessive.  I think just the 0/1/2 plus documentation would
> suffice?
>
>
> I haven't followed this discussion very closely I'm afraid.  If we came
> up with a good reason why Linux needs this feature then could someone
> please (re)describe it?

I think the idea is to avoid exhausting ZONE_DMA on some NUMA boxes by 
ordering the fallback list first by zone, then by node distance (e.g. 
ZONE_NORMAL of local node, then ZONE_NORMAL of next nearest node etc., 
followed by ZONE_DMA of local node, ZONE_DMA of next nearest node, etc.).

As for documentation, it would be good if the "default" behavior was 
described as well (it's mostly by node first, then by zone iirc, but has a 
few other tweaks).

Another option would be to make this behavior automatic if both ZONE_DMA 
and ZONE_NORMAL had pages.  I initially wrote this stuff with the idea 
that machines that really needed it would have all their memory in 
ZONE_DMA, but obviously that's not the case, so some more smarts are 
needed.

Jesse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
