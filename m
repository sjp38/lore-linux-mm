Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 292236B003A
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:52:40 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so5471671wib.7
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:52:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ej7si24275248wid.10.2014.06.02.14.52.37
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:52:38 -0700 (PDT)
Message-ID: <538cf226.a70bb50a.4d7c.5136SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] replace PAGECACHE_TAG_* definition with enumeration
Date: Mon,  2 Jun 2014 17:51:58 -0400
In-Reply-To: <20140602141657.68f831156b45251b0684b441@linux-foundation.org>
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-2-git-send-email-n-horiguchi@ah.jp.nec.com> <538CA269.6010300@intel.com> <20140602141657.68f831156b45251b0684b441@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 02:16:57PM -0700, Andrew Morton wrote:
> On Mon, 02 Jun 2014 09:12:25 -0700 Dave Hansen <dave.hansen@intel.com> wrote:
> 
> > On 06/01/2014 10:24 PM, Naoya Horiguchi wrote:
> > > -#define PAGECACHE_TAG_DIRTY	0
> > > -#define PAGECACHE_TAG_WRITEBACK	1
> > > -#define PAGECACHE_TAG_TOWRITE	2
> > > +enum {
> > > +	PAGECACHE_TAG_DIRTY,
> > > +	PAGECACHE_TAG_WRITEBACK,
> > > +	PAGECACHE_TAG_TOWRITE,
> > > +	__NR_PAGECACHE_TAGS,
> > > +};
> > 
> > Doesn't this end up exposing kernel-internal values out to a userspace
> > interface?  Wouldn't that lock these values in to the ABI?
> 
> Yes, we should be careful here.  We should not do anything which
> constrains future kernel code or which causes any form of
> compatibility/migration issues.

OK.

> I wonder if we can do something smart with the interface.  For example
> when userspace calls sys_fincore() it must explicitly ask for
> PAGECACHE_TAG_DIRTY and if some future kernel doesn't implement
> PAGECACHE_TAG_DIRTY, it can return -EINVAL.
> 
> Or maybe it can succeed, but tells userspace "you didn't get
> PAGECACHE_TAG_DIRTY".
> 
> <thinking out loud>
> 
> So userspace sends a mask of bits which select what fields it wants. 
> The kernel returns a mask of bits which tell userspace what it actually
> received.
> 
> Or something like that - you get the idea ;)

Thanks, I'll try this with another flag parameter for this purpose.

Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
