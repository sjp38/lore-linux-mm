From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory hotplug
Date: Tue, 4 Nov 2008 16:35:48 +0100
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz> <200811040954.34969.rjw@sisk.pl> <1225812111.12673.577.camel@nimitz>
In-Reply-To: <1225812111.12673.577.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811041635.49932.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday, 4 of November 2008, Dave Hansen wrote:
> On Tue, 2008-11-04 at 09:54 +0100, Rafael J. Wysocki wrote:
> > To handle this, I need to know two things:
> > 1) what changes of the zones are possible due to memory hotplugging
> > (i.e.    can they grow, shring, change boundaries etc.)
> 
> All of the above. 

OK

If I allocate a page frame corresponding to specific pfn, is it guaranteed to
be associated with the same pfn in future?

> > 2) what kind of locking is needed to prevent zones from changing.
> 
> The amount of locking is pretty minimal.  We depend on some locking in
> sysfs to keep two attempts to online from stepping on the other.
> 
> There is the zone_span_seq*() set of functions.  These are used pretty
> sparsely, but we do use them in page_outside_zone_boundaries() to notice
> when a zone is resized.
> 
> There are also the pgdat_resize*() locks.  Those are more for internal
> use guarding the sparsemem structures and so forth.
> 
> Could you describe a little more why you need to lock down zone
> resizing?  Do you *really* mean zones, or do you mean "the set of memory
> on the system"?

The latter, but our internal data structures are designed with zones in mind.

> Why walk zones instead of pgdats? 

This is a historical thing rather than anything else.  I think we could switch
to pgdats, but that would require a code rewrite that's likely to introduce
bugs, while our image-creating code is really well tested and doesn't change
very often.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
