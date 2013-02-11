Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 758BA6B0005
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 17:05:09 -0500 (EST)
MIME-Version: 1.0
Message-ID: <334c7852-9d68-4cda-b25c-01dc5b74aaed@default>
Date: Mon, 11 Feb 2013 14:05:01 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie to
 a config option
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
 <20130206190924.GB32275@kroah.com>
 <761b5c6e-df13-49ff-b322-97a737def114@default>
 <20130206214316.GA21148@kroah.com>
 <abbc2f75-2982-470c-a3ca-675933d112c3@default>
 <20130207000338.GB18984@kroah.com>
 <7393d8c5-fb02-4087-93d1-0f999fb3cafd@default>
 <20130211214944.GA22090@kroah.com>
In-Reply-To: <20130211214944.GA22090@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: sjenning@linux.vnet.ibm.com, minchan@kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org

> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, t=
ie to a config option
>=20
> On Mon, Feb 11, 2013 at 01:43:58PM -0800, Dan Magenheimer wrote:
> > > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> >
> > > So, how about this, please draw up a specific plan for how you are go=
ing
> > > to get this code out of drivers/staging/  I want to see the steps
> > > involved, who is going to be doing the work, and who you are going to
> > > have to get to agree with your changes to make it happen.
> > >  :
> > > Yeah, a plan, I know it goes against normal kernel development
> > > procedures, but hey, we're in our early 20's now, it's about time we
> > > started getting responsible.
> >
> > Hi Greg --
> >
> > I'm a big fan of planning, though a wise boss once told me:
> > "Plans fail... planning succeeds".
> >
> > So here's the plan I've been basically trying to pursue since about
> > ten months ago, ignoring the diversion due to "zcache1 vs zcache2"
> > from last summer.  There is no new functionality on this plan
> > other than as necessary from feedback obtained at or prior to
> > LSF/MM in April 2012.
> >
> > Hope this meets your needs, and feedback welcome!
> > Dan
> >
> > =3D=3D=3D=3D=3D=3D=3D
> >
> > ** ZCACHE PLAN FOR PROMOTION FROM STAGING **
> >
> > PLAN STEPS
> >
> > 1. merge zcache and ramster to eliminate horrible code duplication
> > 2. converge on a predictable, writeback-capable allocator
> > 3. use debugfs instead of sysfs (per akpm feedback in 2011)
> > 4. zcache side of cleancache/mm WasActive patch
> > 5. zcache side of frontswap exclusive gets
> > 6. zcache must be able to writeback to physical swap disk
> >     (per Andrea Arcangeli feedback in 2011)
> > 7. implement adequate policy for writeback
> > 8. frontswap/cleancache work to allow zcache to be loaded
> >     as a module
> > 9. get core mm developer to review
> > 10. incorporate feedback from review
> > 11. get review/acks from 1-2 additional mm developers
> > 12. incorporate any feedback from additional mm reviews
> > 13. propose location/file-naming in mm tree
> > 14. repeat 9-13 as necessary until akpm is happy and merges
> >
> > STATUS/OWNERSHIP
> >
> > 1. DONE as part of "new" zcache; now in staging/zcache
> > 2. DONE as part of "new" zcache (cf zbud.[ch]); now in staging/zcache
> >     (this was the core of the zcache1 vs zcache2 flail)
> > 3. DONE as part of "new" zcache; now in staging/zcache
> > 4. DONE as part of "new" zcache; per cleancache performance
> >     feedback see https://lkml.org/lkml/2011/8/17/351, now
> >     in staging/zcache; dependent on proposed mm patch, see
> >     https://lkml.org/lkml/2012/1/25/300
> > 5. DONE as part of "new" zcache; performance tuning only,
> >     now in staging/zcache; dependent on frontswap patch
> >     merged in 3.7 (33c2a174)
> > 6. PROTOTYPED as part of "new" zcache; protoype is now
> >     in staging/zcache but has bad memory leak; reimplemented
> >     to use sjennings clever tricks and proposed mm patches
> >     with new version posted https://lkml.org/lkml/2013/2/6/437;
> >     rejected by GregKH as it smells like new functionality
> >
> >     (******** YOU ARE HERE *********)
> >
> > 7. PROTOTYPED as part of "new" zcache; now in staging/zcache;
> >     needs more review (plan to discuss at LSF/MM 2013)
> > 8. IN PROGRESS; owned by Konrad Wilk; v2 recently posted
> >    http://lkml.org/lkml/2013/2/1/542
> > 9. IN PROGRESS; owned by Konrad Wilk; Mel Gorman provided
> >    great feedback in August 2012 (unfortunately of "old"
> >    zcache)
> > 10. Konrad posted series of fixes (that now need rebasing)
> >     https://lkml.org/lkml/2013/2/1/566
> > 11. NOT DONE; owned by Konrad Wilk
> > 12. TBD (depends on quantity of feedback)
> > 13. PROPOSED; one suggestion proposed by Dan; needs
> >     more ideas/feedback
> > 14. TBD (depends on feedback)
> >
> > WHO NEEDS TO AGREE
> >
> > Not sure I can answer that.  Seth seems to now be pursuing
> > a separate but semi-parallel track.  Akpm clearly has to
> > approve for any mm merge to happen.  Minchan has interest
> > but may be happy if/when zram is merged into mm.  Konrad
> > may be maintainer if akpm decides compression is maintainable
> > separately from the rest of mm.  (More LSF/MM 2013 discussion.)
>=20
> Thanks so much for this, this looks great.
>=20
> So, according to your plan, I shouldn't have rejected those patches,
> right?  :)
>=20
> If so, please resend them in the next day or so, so that they can get
> into 3.9, and then you can move on to the next steps of what you need to
> do here.
>=20
> Sound good?

Excellent.  Thanks very much.  Resend coming right up!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
