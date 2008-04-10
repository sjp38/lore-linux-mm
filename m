Date: Thu, 10 Apr 2008 11:33:06 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: max_mapnr config option
Message-ID: <20080410103306.GA29831@shadowen.org>
References: <1207340609.26869.20.camel@nimitz.home.sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1207340609.26869.20.camel@nimitz.home.sr71.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 04, 2008 at 01:23:29PM -0700, Dave Hansen wrote:
> Hey Andy,
> 
> Take a look at include/linux/mm.h:
> 
> #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
> extern unsigned long max_mapnr;
> #endif
> 
> Shouldn't that be #ifdef CONFIG_FLATMEM?
> 
> I don't think it is causing any problems since all references to
> max_mapnr are under FLATMEM ifdefs, but for correctness...

Ok, I did a comprehensive review of all the references, both to max_mapnr
and to mem_map which are both inherently FLATMEM specific variables.
It seems that there are actually a fair number of references which are
under inappropriate defines.  Generally this is the use of !DISCONTIGMEM
on architectures which only support FLATMEM and DISCONTIGMEM.  There are
also a number of unused constructs which can just go.

The biggest offenders of this are the show_mem implementations, but
it seems that Johannes (copied) is sorting that mess out; clearly one
implemenation is needed.  Johannes, I have some changes to that series
which came out of my implementation of the same which I will send your
way separatly.

Following this email is a set of patches which fix the problems I have
found.  Obviously these are all over the architecture map, and so will
probabally need feeding back via those trees individually.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
