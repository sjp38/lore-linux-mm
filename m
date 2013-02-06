Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id B5AD76B000A
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 17:42:16 -0500 (EST)
MIME-Version: 1.0
Message-ID: <abbc2f75-2982-470c-a3ca-675933d112c3@default>
Date: Wed, 6 Feb 2013 14:42:11 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie to
 a config option
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
 <20130206190924.GB32275@kroah.com>
 <761b5c6e-df13-49ff-b322-97a737def114@default>
 <20130206214316.GA21148@kroah.com>
In-Reply-To: <20130206214316.GA21148@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org

> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, t=
ie to a config option
>=20
> On Wed, Feb 06, 2013 at 12:51:25PM -0800, Dan Magenheimer wrote:
> > > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > > Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback cod=
e, tie to a config option
> > >
> > > On Wed, Feb 06, 2013 at 10:27:41AM -0800, Dan Magenheimer wrote:
> > > > It was observed by Andrea Arcangeli in 2011 that zcache can get "fu=
ll"
> > > > and there must be some way for compressed swap pages to be (uncompr=
essed
> > > > and then) sent through to the backing swap disk.  A prototype of th=
is
> > > > functionality, called "unuse", was added in 2012 as part of a major=
 update
> > > > to zcache (aka "zcache2"), but was left unfinished due to the unfor=
tunate
> > > > temporary fork of zcache.
> > > >
> > > > This earlier version of the code had an unresolved memory leak
> > > > and was anyway dependent on not-yet-upstream frontswap and mm chang=
es.
> > > > The code was meanwhile adapted by Seth Jennings for similar
> > > > functionality in zswap (which he calls "flush").  Seth also made so=
me
> > > > clever simplifications which are herein ported back to zcache.  As =
a
> > > > result of those simplifications, the frontswap changes are no longe=
r
> > > > necessary, but a slightly different (and simpler) set of mm changes=
 are
> > > > still required [1].  The memory leak is also fixed.
> > > >
> > > > Due to feedback from akpm in a zswap thread, this functionality in =
zcache
> > > > has now been renamed from "unuse" to "writeback".
> > > >
> > > > Although this zcache writeback code now works, there are open quest=
ions
> > > > as how best to handle the policy that drives it.  As a result, this
> > > > patch also ties writeback to a new config option.  And, since the
> > > > code still depends on not-yet-upstreamed mm patches, to avoid build
> > > > problems, the config option added by this patch temporarily depends
> > > > on "BROKEN"; this config dependency can be removed in trees that
> > > > contain the necessary mm patches.
> > >
> > > I'll wait for those options to be in Linus's tree before accepting a
> > > patch like this, sorry.
> > >
> > > greg k-h
> >
> > Hi Greg --
> >
> > Hmmmm... that creates the classic chicken-and-egg problem...  It's hard
> > to get a patch into the kernel (especially mm) without a demonstrated
> > "user" for the patch, but the "user" can't be added without the patch i=
t
> > is dependent on because the "user" code won't work and/or would break
> > the build without it.
> >
> > In the past (e.g. with cleancache and frontswap), you've resolved that
> > by taking the "user" (e.g. zcache) code into staging, properly ifdef'd
> > to avoid build issues, which clearly demonstrated the use for the
> > matching mm changes, which were eventually merged into Linus's tree,
> > at which point the ifdefs were removed.
>=20
> Yes, but these mm changes are in no one's trees, and I have no idea if
> they ever will be merged.

OK, I can try pushing on the "egg" side for awhile :-(

> This patch looks to me that it is adding new functionality, and not
> working to get it moved out of staging.

Not true... it is fixing broken functionality that was left latent
for too long due to last summer's unpleasant disagreements.  And this
functionality was a key reason why "zcache2" was created... because mm
developers (e.g. Andrea) insisted that it must be present before compressio=
n
functionality would be added into mm.  As evidence to support this,
note that Seth's first zswap patchset includes similar functionality
even though Seth argued vociferously last summer that the functionality
wasn't needed before "old" zcache should be promoted.

> So, how about I try being mean again.  I will accept no more patches for
> the zcache/zram/zsmalloc code, unless is it an obvious bugfix, or it is
> to move it out of the drivers/staging/ tree.  You all have had many
> years to get your act together, and it's getting really frustrating from
> my end.

I do very much understand your frustration and you have every right
to be mean.

But, since this really is technically patching up existing critical
functionality that was known to be broken, I would be very grateful
if you would reconsider applying this patch.  I agree there will be no
(more) non-bugfix staging/zcache patches from me. I've proposed a topic [1]
for LSF/MM in April to discuss all this... I totally agree it's time to
promote in-kernel compression out of staging and into mm proper.
But without this patch fixing required functionality, it will be
harder to promote.

In other words.... pretty pleeeeze? I swear this is the last time.  :-]

Thanks,
Dan "puts on cute irresistible doe-eyed child face"

[1] http://marc.info/?l=3Dlinux-mm&m=3D135923138220901&w=3D2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
