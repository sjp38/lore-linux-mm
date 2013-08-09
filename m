Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id C002B6B0033
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 11:34:23 -0400 (EDT)
Message-ID: <1376062391.10300.245.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug: Verify hotplug memory range
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 09 Aug 2013 09:33:11 -0600
In-Reply-To: <5204838E.1060602@cn.fujitsu.com>
References: <1375980460-28311-1-git-send-email-toshi.kani@hp.com>
	 <5204838E.1060602@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Fri, 2013-08-09 at 13:52 +0800, Tang Chen wrote:
> On 08/09/2013 12:47 AM, Toshi Kani wrote:
> > add_memory() and remove_memory() can only handle a memory range aligned
> > with section.  There are problems when an unaligned range is added and
> > then deleted as follows:
> >
> >   - add_memory() with an unaligned range succeeds, but __add_pages()
> >     called from add_memory() adds a whole section of pages even though
> >     a given memory range is less than the section size.
> >   - remove_memory() to the added unaligned range hits BUG_ON() in
> >     __remove_pages().
> >
> > This patch changes add_memory() and remove_memory() to check if a given
> > memory range is aligned with section at the beginning.  As the result,
> > add_memory() fails with -EINVAL when a given range is unaligned, and
> > does not add such memory range.  This prevents remove_memory() to be
> > called with an unaligned range as well.  Note that remove_memory() has
> > to use BUG_ON() since this function cannot fail.
> >
> > Signed-off-by: Toshi Kani<toshi.kani@hp.com>
> > ---
> >   mm/memory_hotplug.c |   22 ++++++++++++++++++++++
> >   1 file changed, 22 insertions(+)
> >
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index ca1dd3a..ac182de 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1069,6 +1069,22 @@ out:
> >   	return ret;
> >   }
> >
> > +static int check_hotplug_memory_range(u64 start, u64 size)
> > +{
> > +	u64 start_pfn = start>>  PAGE_SHIFT;
> > +	u64 nr_pages = size>>  PAGE_SHIFT;
> > +
> > +	/* Memory range must be aligned with section */
> > +	if ((start_pfn&  ~PAGE_SECTION_MASK) ||
> > +	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
> > +		pr_err("Unsupported hotplug range: start 0x%llx, size 0x%llx\n",
> > +				start, size);
> 
> I think the message here should tell users that only support range aligned
> to section. Others seems OK to me.

OK, I will change the message to something like this:

  pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
                                start, size);

> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>

Thanks!
-Toshi




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
