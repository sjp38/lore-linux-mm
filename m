Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7508F6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 18:41:58 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9647801pbb.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 15:41:57 -0700 (PDT)
Date: Mon, 14 May 2012 15:41:53 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interface
Message-ID: <20120514224153.GB28559@kroah.com>
References: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
 <20120514200659.GA15604@kroah.com>
 <0966a902-a35e-4c06-ab04-7d088bf25696@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0966a902-a35e-4c06-ab04-7d088bf25696@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com

On Mon, May 14, 2012 at 01:45:36PM -0700, Dan Magenheimer wrote:
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > Subject: Re: [PATCH] ramster: switch over to zsmalloc and crypto interface
> > 
> > On Thu, May 10, 2012 at 12:06:21PM -0700, Dan Magenheimer wrote:
> > > RAMster does many zcache-like things.  In order to avoid major
> > > merge conflicts at 3.4, ramster used lzo1x directly for compression
> > > and retained a local copy of xvmalloc, while zcache moved to the
> > > new zsmalloc allocator and the crypto API.
> > >
> > > This patch moves ramster forward to use zsmalloc and crypto.
> > >
> > > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> > 
> 
> Hi Greg --
> 
> > I finally enabled building this one (didn't realize it required ZCACHE
> > to be disabled, I can only build one or the other)
> 
> Yes, correct.  This overlap is explained in drivers/staging/ramster/TODO
> (which IIRC you were the one that asked me to create that file).
> In short the TODO says: ramster is a superset of zcache that also
> "remotifies" zcache-compressed pages to another machine, and the overlap
> with zcache will need to be rectified before either is promoted
> from staging.
> 
> > and I noticed after
> > this patch the following warnings in my build:
> > 
> > drivers/staging/ramster/zcache-main.c:950:13: warning: a??zcache_do_remotify_opsa?? defined but not used
> > [-Wunused-function]
> > drivers/staging/ramster/zcache-main.c:1039:13: warning: a??ramster_remotify_inita?? defined but not used
> > [-Wunused-function]
> 
> These are because CONFIG_FRONTSWAP isn't yet in your tree.  It is
> in linux-next and will hopefully finally be in Linus' tree at
> the next window.  Ramster (and zcache) has low value without
> frontswap, so the correct fix, after frontswap is merged, is
> to remove all the "ifdef CONFIG_FRONTSWAP" and force the
> dependency in Kconfig... but I can't do that until frontswap
> is merged. :-(

Ok, no problem then.

> > drivers/staging/ramster/zcache-main.c: In function a??zcache_puta??:
> > drivers/staging/ramster/zcache-main.c:1594:4: warning: a??pagea?? may be used uninitialized in this
> > function [-Wuninitialized]
> > drivers/staging/ramster/zcache-main.c:1536:8: note: a??pagea?? was declared here
> 
> Hmmm... this looks like an overzealous compiler.  The code
> is correct and was unchanged by this patch.  My compiler
> (gcc 4.4.4) doesn't even report it.  I think I could fix it
> by assigning a superfluous NULL at the declaration and will
> do that if you want but I can't test the fix with my compiler
> since it doesn't report it.
> 
> > Care to please fix them up?
> 
> It looks like you've taken the patch... if my whining
> above falls on deaf ears and you still want me to "fix"
> one or both, let me know and I will submit a fixup patch.
> (And then... what gcc are you using?)

I'm using gcc 4.6.2 from openSUSE 12.1, if that matters.  No big deal if
these are compiler warnings you are used to, it's just the first time
I've built the code in a long time and wanted to ensure that you were
aware of them.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
