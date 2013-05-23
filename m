Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5B1F06B0033
	for <linux-mm@kvack.org>; Wed, 22 May 2013 22:00:32 -0400 (EDT)
Message-ID: <519D7827.80607@oracle.com>
Date: Thu, 23 May 2013 10:00:07 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com> <20130517154837.GN11497@suse.de> <20130519205219.GA3252@cerebellum> <20130520135439.GR11497@suse.de> <20130520154225.GA25536@cerebellum> <20130521081020.GT11497@suse.de>
In-Reply-To: <20130521081020.GT11497@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Mel & Seth,

On 05/21/2013 04:10 PM, Mel Gorman wrote:
> On Mon, May 20, 2013 at 10:42:25AM -0500, Seth Jennings wrote:
>> On Mon, May 20, 2013 at 02:54:39PM +0100, Mel Gorman wrote:
>>> On Sun, May 19, 2013 at 03:52:19PM -0500, Seth Jennings wrote:
>>>> My first guess is that the external fragmentation situation you are referring to
>>>> is a workload in which all pages compress to greater than half a page.  If so,
>>>> then it doesn't matter what NCHUCNKS_ORDER is, there won't be any pages the
>>>> compress enough to fit in the < PAGE_SIZE/2 free space that remains in the
>>>> unbuddied zbud pages.
>>>>
>>>
>>> There are numerous aspects to this, too many to write them all down.
>>> Modelling the external fragmentation one and how it affects swap IO
>>> would be a complete pain in the ass so lets consider the following
>>> example instead as it's a bit clearer.
>>>
>>> Three processes. Process A compresses by 75%, Process B compresses to 15%,
>>> Process C pages compress to 15%. They are all adding to zswap in lockstep.
>>> Lets say that zswap can hold 100 physical pages.
>>>
>>> NCHUNKS == 2
>>> 	All Process A pages get rejected.
>>
>> Ah, I think this is our disconnect.  Process A pages will not be rejected.
>> They will be stored in a zbud page, and that zbud page will be added
>> to the 0th unbuddied list.  This list maintains a list of zbud pages
>> that will never be buddied because there are no free chunks.
>>
> 
> D'oh, good point. Unfortunately, the problem then still exists at the
> writeback end which I didn't bring up in the previous mail. 

What's your opinion if we write back the whole compressed page to swap disk?

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
