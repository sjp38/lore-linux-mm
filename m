Message-ID: <46D60AA9.3070309@redhat.com>
Date: Wed, 29 Aug 2007 20:09:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
References: <20070823041137.GH18788@wotan.suse.de>  <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de>  <1188225247.5952.41.camel@localhost> <20070828000648.GB14109@wotan.suse.de>  <1188312766.5079.77.camel@localhost>  <Pine.LNX.4.64.0708281448440.17464@schroedinger.engr.sgi.com> <1188398451.5121.9.camel@localhost> <Pine.LNX.4.64.0708291035080.21184@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708291035080.21184@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 29 Aug 2007, Lee Schermerhorn wrote:
> 
>>> I think that is the right approach. Do not forget that ramfs and other 
>>> ram based filesystems create unmapped unreclaimable pages.
>> They don't go on the LRU lists now, do they?  The primary function of
>> the noreclaim infrastructure is to hide non-reclaimable pages that would
>> otherwise go on the [in]active lists from vmscan.  So, if pages used by
>> the ram base file systems don't go onto the LRU, we probably don't need
>> to put them on the noreclaim list which is conceptually another LRU
>> list.
> 
> They do go into the LRU. When attempts are made to write them out they are 
> put back onto the active lists via a strange return code 
> AOP_WRITEPAGE_ACTIVATE. So they circle round and round and round...
> 
>>> Right. I posted a patch a week ago that generalized LRU handling and would 
>>> allow the adding of additional lists as needed by such an approach.
>> Which one was that? 
> 
> This one
> 
> [RECLAIM] Use an indexed array for active/inactive variables
> 
> Currently we are defining explicit variables for the inactive and active
> list. An indexed array can be more generic and avoid repeating similar
> code in several places in the reclaim code.

I like it.  This will make the code that has separate lists
for anonymous (and other swap backed) pages a lot nicer.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
