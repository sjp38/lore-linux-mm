Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 14 Aug 2013 09:08:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/3] Pin page control subsystem
Message-ID: <20130814000850.GB2271@bbox>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
 <1376387202.31048.2.camel@AMDC1943>
 <20130813142338.GD13330@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130813142338.GD13330@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hello Benjamin,

On Tue, Aug 13, 2013 at 10:23:38AM -0400, Benjamin LaHaise wrote:
> On Tue, Aug 13, 2013 at 11:46:42AM +0200, Krzysztof Kozlowski wrote:
> > Hi Minchan,
> > 
> > On wto, 2013-08-13 at 16:04 +0900, Minchan Kim wrote:
> > > patch 2 introduce pinpage control
> > > subsystem. So, subsystems want to control pinpage should implement own
> > > pinpage_xxx functions because each subsystem would have other character
> > > so what kinds of data structure for managing pinpage information depends
> > > on them. Otherwise, they can use general functions defined in pinpage
> > > subsystem. patch 3 hacks migration.c so that migration is
> > > aware of pinpage now and migrate them with pinpage subsystem.
> > 
> > I wonder why don't we use page->mapping and a_ops? Is there any
> > disadvantage of such mapping/a_ops?
> 
> That's what the pending aio patches do, and I think this is a better 
> approach for those use-cases that the technique works for.

I saw your implementation roughly and I think it's not a generic solution.
How could it handle the example mentioned in reply of Krzysztof?

> 
> The biggest problem I see with the pinpage approach is that it's based on a
> single page at a time.  I'd venture a guess that many pinned pages are done 
> in groups of pages, not single ones.

In case of z* family, most of allocation is single but I agree many GUP users
would allocate groups of pages. Then, we can cover it by expanding the API
like this.

int set_pinpage(struct pinpage_system *psys, struct page **pages,
                unsigned long nr_pages, void **privates);

so we can handle it by batch and the subsystem can manage pinpage_info with
interval tree rather than radix tree which is default.
That's why pinpage control subsystem has room for subsystem specific metadata
handling.

> 
> 		-ben
> 
> > Best regards,
> > Krzysztof
> 
> -- 
> "Thought is the essence of where you are now."
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
