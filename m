Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 24DEC6B0002
	for <linux-mm@kvack.org>; Sun,  3 Mar 2013 21:25:00 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so2790394pbc.36
        for <linux-mm@kvack.org>; Sun, 03 Mar 2013 18:24:59 -0800 (PST)
Date: Mon, 4 Mar 2013 10:25:08 +0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/1] mm: Export split_page().
Message-ID: <20130304022508.GA8638@kroah.com>
References: <1362364075-14564-1-git-send-email-kys@microsoft.com>
 <20130304020747.GA8265@kroah.com>
 <3a362e994ab64efda79ae3c80342db95@SN2PR03MB061.namprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a362e994ab64efda79ae3c80342db95@SN2PR03MB061.namprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KY Srinivasan <kys@microsoft.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 04, 2013 at 02:14:02AM +0000, KY Srinivasan wrote:
> 
> 
> > -----Original Message-----
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > Sent: Sunday, March 03, 2013 9:08 PM
> > To: KY Srinivasan
> > Cc: linux-kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> > apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linux-
> > mm@kvack.org
> > Subject: Re: [PATCH 1/1] mm: Export split_page().
> > 
> > On Sun, Mar 03, 2013 at 06:27:55PM -0800, K. Y. Srinivasan wrote:
> > > The split_page() function will be very useful for balloon drivers. On Hyper-V,
> > > it will be very efficient to use 2M allocations in the guest as this (a) makes
> > > the ballooning protocol with the host that much more efficient and (b) moving
> > > memory in 2M chunks minimizes fragmentation in the host. Export the
> > split_page()
> > > function to let the guest allocations be in 2M chunks while the host is free to
> > > return this memory at arbitrary granularity.
> > >
> > >
> > > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > > ---
> > >  mm/page_alloc.c |    1 +
> > >  1 files changed, 1 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 6cacfee..7e0ead6 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1404,6 +1404,7 @@ void split_page(struct page *page, unsigned int order)
> > >  	for (i = 1; i < (1 << order); i++)
> > >  		set_page_refcounted(page + i);
> > >  }
> > > +EXPORT_SYMBOL_GPL(split_page);
> > 
> > When you export a symbol, you also need to post the code that is going
> > to use that symbol, otherwise people don't really know how to judge this
> > request.
> > 
> > Can you just make this a part of your balloon driver update patch series
> > instead?
> 
> Fair enough; I was hoping to see how inclined the mm folks were with regards to
> exporting this symbol before I went ahead and modified the balloon driver code to
> leverage this. Looking at the Windows guests on Hyper-V, I am convinced 2M balloon
> allocations in the Linux (Hyper-V) balloon driver will make significant difference. As you
> suggest, I will post this patch as part of the balloon driver changes that use this exported
> symbol. I am still hoping to get some feedback from the mm guys on this.

I guess the most obvious question about exporting this symbol is, "Why
doesn't any of the other hypervisor balloon drivers need this?  What is
so special about hyper-v?"

Or can those other drivers also need/use it as well, and they were just
too chicken to be asking for the export?  :)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
