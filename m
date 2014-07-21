Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 79B7F6B0036
	for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:27:53 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so8410618pdj.1
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 20:27:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id bs8si12820355pad.157.2014.07.20.20.27.52
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 20:27:52 -0700 (PDT)
From: "Zhang, Tianfei" <tianfei.zhang@intel.com>
Subject: RE: About refault distance
Date: Mon, 21 Jul 2014 03:27:49 +0000
Message-ID: <BA6F50564D52C24884F9840E07E32DEC17D5DAE1@CDSMSX102.ccr.corp.intel.com>
References: <BA6F50564D52C24884F9840E07E32DEC17D58E35@CDSMSX102.ccr.corp.intel.com>
 <20140718151446.GI29639@cmpxchg.org>
In-Reply-To: <20140718151446.GI29639@cmpxchg.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

>=20
> On Wed, Jul 16, 2014 at 01:53:55AM +0000, Zhang, Tianfei wrote:
> > Hi Johannes,
> >
> > May I ask you a question about refault distance?
> >
> > Is it supposed the distance of the first and second time to access the
> > a faulted page cache is the same? In reality how about the ratio will b=
e the
> same?
> >
> >             Refault Distance1 =3D Refault Distance2
> >
> > On the first refault, We supposed that:
> >             Refault Distance =3D A
> >             NR_INACTIVE_FILE =3D B
> >             NR_ACTIVE_FILE =3D C
> >
> > *                  fault page add to inactive list tail
> >                     The Refault Distance  =3D A
> >                           |
> >  *                   B     |        |            C
> > *              +--------------+   |            +-------------+
> > *   reclaim <- |   inactive   | <-+-- demotion |    active   | <--+
> > *              +--------------+                +-------------+    |
> > *                     |
> |
> > *                     +-------------- promotion ------------------+
> >
> >
> > Why we use A <=3D C to add faulted page to ACTIVE LIST?
> >
> > Your patch is want to solve "A workload is thrashing when its pages
> > are frequently used but they are evicted from the inactive list every
> > time before another access would have promoted them to the active list.=
" ?
> >
> > so when a First Refault page add to INACTIVE LIST, it is a Distance B b=
efore
> eviction.
> > So I am confuse the condition on workingset_refault().
>=20
> The reuse distance of a page is B + A.  B + C is the available memory ove=
rall.
> When a page refaults, we want to compare its reuse distance to overall
> memory to see if it is eligible for activation (=3D accessed twice while =
in memory).
> That check would be A + B <=3D B + C.  But we can simply drop B on both s=
ides
> and get A <=3D C.

Thank you very much, it is more clear explanation than comments of code (wo=
rkingset.c).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
