Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDE2D6B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 22:04:50 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id z15so2685148qti.16
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 19:04:50 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f57si931143qtf.153.2018.02.07.19.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 19:04:49 -0800 (PST)
Date: Thu, 8 Feb 2018 05:04:43 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v27 3/4] mm/page_poison: expose page_poisoning_enabled to
 kernel modules
Message-ID: <20180208050337-mutt-send-email-mst@kernel.org>
References: <1517986471-15185-1-git-send-email-wei.w.wang@intel.com>
 <1517986471-15185-4-git-send-email-wei.w.wang@intel.com>
 <20180207203004-mutt-send-email-mst@kernel.org>
 <5A7BAB7D.7070805@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A7BAB7D.7070805@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Thu, Feb 08, 2018 at 09:44:29AM +0800, Wei Wang wrote:
> On 02/08/2018 02:34 AM, Michael S. Tsirkin wrote:
> > On Wed, Feb 07, 2018 at 02:54:30PM +0800, Wei Wang wrote:
> > > In some usages, e.g. virtio-balloon, a kernel module needs to know if
> > > page poisoning is in use. This patch exposes the page_poisoning_enabled
> > > function to kernel modules.
> > > 
> > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Michael S. Tsirkin <mst@redhat.com>
> > > ---
> > >   mm/page_poison.c | 6 ++++++
> > >   1 file changed, 6 insertions(+)
> > > 
> > > diff --git a/mm/page_poison.c b/mm/page_poison.c
> > > index e83fd44..c08d02a 100644
> > > --- a/mm/page_poison.c
> > > +++ b/mm/page_poison.c
> > > @@ -30,6 +30,11 @@ bool page_poisoning_enabled(void)
> > >   		debug_pagealloc_enabled()));
> > >   }
> > > +/**
> > > + * page_poisoning_enabled - check if page poisoning is enabled
> > > + *
> > > + * Return true if page poisoning is enabled, or false if not.
> > > + */
> > >   static void poison_page(struct page *page)
> > >   {
> > >   	void *addr = kmap_atomic(page);
> > > @@ -37,6 +42,7 @@ static void poison_page(struct page *page)
> > >   	memset(addr, PAGE_POISON, PAGE_SIZE);
> > >   	kunmap_atomic(addr);
> > >   }
> > > +EXPORT_SYMBOL_GPL(page_poisoning_enabled);
> > >   static void poison_pages(struct page *page, int n)
> > >   {
> > Looks like both the comment and the export are in the wrong place.
> 
> Thanks. Will be more careful.
> 
> > I'm a bit concerned that callers also in fact poke at the
> > PAGE_POISON - exporting that seems to be more of an accident
> > as it's only used without page_poisoning.c - it might be
> > better to have page_poisoning_enabled get u8 * and set it.
> > 
> 
> PAGE_POISON is a macro defined in the header, why would callers using it be
> a concern?


It might be a good idea to move it out of there though.

> Do you suggest to have:
> 
> bool page_poisoning_get(u8 *val)
> {
>     if (page_poisoning_enabled()) {
>         *val = PAGE_POISON;
>         return true;
>     }
> 
>     return false;
> }
> EXPORT_SYMBOL_GPL(page_poisoning_get);
> 
> 
> Best,
> Wei

Something like this, yes.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
