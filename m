Message-ID: <43C7EDCF.3050402@kolumbus.fi>
Date: Fri, 13 Jan 2006 20:13:35 +0200
From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] BUG: gfp_zone() not mapping zone modifiers correctly
 and bad ordering of fallback lists
References: <20060113155026.GA4811@skynet.ie>
In-Reply-To: <20060113155026.GA4811@skynet.ie>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

>Hi Andrew,
>
>This patch is divided into two parts and addresses a bug in how zone
>fallback lists are calculated and how __GFP_* zone modifiers are mapped to
>their equivilant ZONE_* type. It applies to 2.6.15-mm3 and has been tested
>on x86 and ppc64. It has been reported by Yasunori Goto that it boots on
>ia64. Details as follows;
>
>build_zonelists() attempts to be smart, and uses highest_zone() so that it
>doesn't attempt to call build_zonelists_node() for empty zones.  However,
>build_zonelists_node() is smart enough to do the right thing by itself and
>build_zonelists() already has the zone index that highest_zone() is meant
>to provide. So, remove the unnecessary function highest_zone().
>
>The helper function gfp_zone() assumes that the bits used in the zone modifier
>of a GFP flag maps directory on to their ZONE_* equivalent and just applies a
>mask. However, the bits do not map directly and the wrong fallback lists can
>be used. If unluckly, the system can go OOM when plenty of suitable memory
>is available. This patch redefines the __GFP_ zone modifier flags to allow
>a simple mapping to their equivilant ZONE_ type.
>
>  
>
What's the exact failure case? Afaik, we loop though all the 
GFP_ZONETYPES, building the appropriate zone lists at 0 - 
GFP_ZONETYPES-1 indexes. So the direct GFP -> ZONE mapping should do the 
right thing.

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
