Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2BDF6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:17:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so343145705pfg.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:17:22 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id t21si3902478pfj.215.2016.08.02.10.17.21
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 10:17:21 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [PATCH] [RFC] Introduce mmap randomization
Date: Tue, 2 Aug 2016 17:17:19 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC560127815C@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC5601260068@ORSMSX103.amr.corp.intel.com>
 <20160726214453.GN4541@io.lakedaemon.net>
In-Reply-To: <20160726214453.GN4541@io.lakedaemon.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nnk@google.com" <nnk@google.com>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>



> -----Original Message-----
> From: Jason Cooper [mailto:jason@lakedaemon.net]
> Sent: Tuesday, July 26, 2016 2:45 PM
> To: Roberts, William C <william.c.roberts@intel.com>
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; kernel-
> hardening@lists.openwall.com; akpm@linux-foundation.org;
> keescook@chromium.org; gregkh@linuxfoundation.org; nnk@google.com;
> jeffv@google.com; salyzyn@android.com; dcashman@android.com
> Subject: Re: [PATCH] [RFC] Introduce mmap randomization
>=20
> On Tue, Jul 26, 2016 at 09:06:30PM +0000, Roberts, William C wrote:
> > > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > > Behalf Of Jason Cooper On Tue, Jul 26, 2016 at 08:13:23PM +0000,
> > > Roberts, William C wrote:
> > > > > > From: Jason Cooper [mailto:jason@lakedaemon.net] On Tue, Jul
> > > > > > 26,
> > > > > > 2016 at 11:22:26AM -0700, william.c.roberts@intel.com wrote:
> > > > > > > Performance Measurements:
> > > > > > > Using strace with -T option and filtering for mmap on the
> > > > > > > program ls shows a slowdown of approximate 3.7%
> > > > > >
> > > > > > I think it would be helpful to show the effect on the resulting=
 object
> code.
> > > > >
> > > > > Do you mean the maps of the process? I have some captures for
> > > > > whoopsie on my Ubuntu system I can share.
> > >
> > > No, I mean changes to mm/mmap.o.
> >
> > Sure I can post the objdump of that, do you just want a diff of old vs =
new?
>=20
> Well, I'm partial to scripts/objdiff, but bloat-o-meter might be more fam=
iliar to
> most of the folks who you'll be trying to convince to merge this.

Ahh I didn't know there were tools for this, thanks.

>=20
> But that's the least of your worries atm. :-/  I was going to dig into mm=
ap.c to
> confirm my suspicions, but Nick answered it for me.
> Fragmentation caused by this sort of feature is known to have caused prob=
lems
> in the past.

I don't know of any mmap randomization done in the past like this. Only the=
 ASLR stuff, which
has had known issues on 32 bit address spaces.

>=20
> I would highly recommend studying those prior use cases and answering tho=
se
> concerns before progressing too much further.  As I've mentioned elsewher=
e,
> you'll need to quantify the increased difficulty to the attacker that you=
r patch
> imposes.  Personally, I would assess that first to see if it's worth the =
effort at all.

Yes agreed.

>=20
> > > > > One thing I didn't make clear in my commit message is why this
> > > > > is good. Right now, if you know An address within in a process,
> > > > > you know all offsets done with mmap(). For instance, an offset
> > > > > To libX can yield libY by adding/subtracting an offset. This is
> > > > > meant to make rops a bit harder, or In general any mapping
> > > > > offset mmore difficult to
> > > find/guess.
> > >
> > > Are you able to quantify how many bits of entropy you're imposing on
> > > the attacker?  Is this a chair in the hallway or a significant
> > > increase in the chances of crashing the program before finding the
> > > desired address?
> >
> > I'd likely need to take a small sample of programs and examine them,
> > especially considering That as gaps are harder to find, it forces the
> > randomization down and randomization can Be directly altered with
> > length on mmap(), versus randomize_addr() which didn't have this
> > restriction but OOM'd do to fragmented easier.
>=20
> Right, after the Android feedback from Nick, I think you have a lot of wo=
rk on
> your hands.  Not just in design, but also in developing convincing argume=
nts
> derived from real use cases.
>=20
> thx,
>=20
> Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
