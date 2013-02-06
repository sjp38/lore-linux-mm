Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 40D256B000A
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 16:43:20 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so845635dak.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 13:43:19 -0800 (PST)
Date: Wed, 6 Feb 2013 13:43:16 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie
 to a config option
Message-ID: <20130206214316.GA21148@kroah.com>
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
 <20130206190924.GB32275@kroah.com>
 <761b5c6e-df13-49ff-b322-97a737def114@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <761b5c6e-df13-49ff-b322-97a737def114@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org

On Wed, Feb 06, 2013 at 12:51:25PM -0800, Dan Magenheimer wrote:
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie to a config option
> > 
> > On Wed, Feb 06, 2013 at 10:27:41AM -0800, Dan Magenheimer wrote:
> > > It was observed by Andrea Arcangeli in 2011 that zcache can get "full"
> > > and there must be some way for compressed swap pages to be (uncompressed
> > > and then) sent through to the backing swap disk.  A prototype of this
> > > functionality, called "unuse", was added in 2012 as part of a major update
> > > to zcache (aka "zcache2"), but was left unfinished due to the unfortunate
> > > temporary fork of zcache.
> > >
> > > This earlier version of the code had an unresolved memory leak
> > > and was anyway dependent on not-yet-upstream frontswap and mm changes.
> > > The code was meanwhile adapted by Seth Jennings for similar
> > > functionality in zswap (which he calls "flush").  Seth also made some
> > > clever simplifications which are herein ported back to zcache.  As a
> > > result of those simplifications, the frontswap changes are no longer
> > > necessary, but a slightly different (and simpler) set of mm changes are
> > > still required [1].  The memory leak is also fixed.
> > >
> > > Due to feedback from akpm in a zswap thread, this functionality in zcache
> > > has now been renamed from "unuse" to "writeback".
> > >
> > > Although this zcache writeback code now works, there are open questions
> > > as how best to handle the policy that drives it.  As a result, this
> > > patch also ties writeback to a new config option.  And, since the
> > > code still depends on not-yet-upstreamed mm patches, to avoid build
> > > problems, the config option added by this patch temporarily depends
> > > on "BROKEN"; this config dependency can be removed in trees that
> > > contain the necessary mm patches.
> > 
> > I'll wait for those options to be in Linus's tree before accepting a
> > patch like this, sorry.
> > 
> > greg k-h
> 
> Hi Greg --
> 
> Hmmmm... that creates the classic chicken-and-egg problem...  It's hard
> to get a patch into the kernel (especially mm) without a demonstrated
> "user" for the patch, but the "user" can't be added without the patch it
> is dependent on because the "user" code won't work and/or would break
> the build without it.
> 
> In the past (e.g. with cleancache and frontswap), you've resolved that
> by taking the "user" (e.g. zcache) code into staging, properly ifdef'd
> to avoid build issues, which clearly demonstrated the use for the
> matching mm changes, which were eventually merged into Linus's tree,
> at which point the ifdefs were removed.

Yes, but these mm changes are in no one's trees, and I have no idea if
they ever will be merged.

So, how about I try being mean again.  I will accept no more patches for
the zcache/zram/zsmalloc code, unless is it an obvious bugfix, or it is
to move it out of the drivers/staging/ tree.  You all have had many
years to get your act together, and it's getting really frustrating from
my end.

This patch looks to me that it is adding new functionality, and not
working to get it moved out of staging.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
