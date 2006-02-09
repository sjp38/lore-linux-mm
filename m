Received: by uproxy.gmail.com with SMTP id m3so35030uge
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 19:38:43 -0800 (PST)
Message-ID: <aec7e5c30602081938w1d593309h5422abcef597f4bf@mail.gmail.com>
Date: Thu, 9 Feb 2006 12:38:43 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <43EAB395.6000603@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1139381183.22509.186.camel@localhost>
	 <43EAA0F4.2060208@jp.fujitsu.com>
	 <aec7e5c30602081857t65e58eb7l58299dcde36e6949@mail.gmail.com>
	 <43EAB395.6000603@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

On 2/9/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Magnus Damm wrote:
> > Hi Kamezawa-san,
> >
> > On 2/9/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> Magnus Damm wrote:
> >>> [RFC] Removing page-flags
> >>>
> >>> Moving type A bits:
> >>>
> >>> Instead of keeping the bits together, we spread them out and store a
> >>> pointer to them from pg_data_t.
> >>>
> >> This will annoy people who has a job to look into crash-dump's vmcore..like me ;)
> >> so, I don't like this idea.
> >
> > Hehe, gotcha. =) I also wonder how well it would work with your zone patches.
> >
> My layout-free-zone patches are not affected by this if you use pgdat/section to
> preserve page-flags.

Ok, good.

> To be honest, I'd like to do this
> ==
> struct zone *page_zone(struct page *page)
> {
>         return page->zone;
> }
> ==
> But this increases size of memmap awfully ;( and I can't.
> Current zone-indexing in page-flags is well saving memory space, I think.

With my proposal (Removing type B bits), if you can guarantee that all
your zones have a start address and a size that is aligned to (1 <<
(PAGE_SHIFT * 2)), then the following code should be possible:

struct zone *page_zone(struct page *page)
{
  struct page *parent = virt_to_page(page);

  return (struct zone *)parent->mapping;
}

This assumes that the first entry in mem_map is aligned to PAGE_SIZE,
and that some code has setup parent->mapping to point to the correct
zone. =)

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
