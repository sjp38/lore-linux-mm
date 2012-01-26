Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id AD6F36B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 12:16:48 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-class: urn:content-classes:message
Subject: RE: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Date: Thu, 26 Jan 2012 12:16:14 -0500
Message-ID: <D3F292ADF945FB49B35E96C94C2061B915A64180@nsmail.netscout.com>
In-Reply-To: <10715842-8E51-40A5-8C28-AD8B1090645D@dilger.ca>
References: <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost> <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca> <1327502034.2720.23.camel@menhir> <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com> <1327509623.2720.52.camel@menhir> <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com> <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com> <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com> <20120125200613.GH15866@shiny> <20120125224614.GM30782@redhat.com> <D3F292ADF945FB49B35E96C94C2061B915A64111@nsmail.netscout.com> <10715842-8E51-40A5-8C28-AD8B1090645D@dilger.ca>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Chris Mason <chris.mason@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Steven Whitehouse <swhiteho@redhat.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, "Darrick J.Wong" <djwong@us.ibm.com>

> > And 'maybe' for adaptive RA just increase the RA-blocks by '1'(or
some N) over period of time. No more smartness. A simple 10 line
function is
> > easy to debug/maintain. That is, a scaled-down version of
ramp-up/ramp-down. Don't go crazy by ramping-up/down after every RA(like
> > SCSI LLDD madness). Wait for some event to happen.
>=20
> Doing 1-block readahead increments is a performance disaster on RAID-
> 5/6. That means you seek all the disks, but use only a fraction of the
> data that the controller read internally and had to parity check.
>=20
> It makes more sense to keep the read units the same size as write
units
> (1 MB or as dictated by RAID geometry) that the filesystem is also
> hopefully using for allocation.  When doing a readahead it should
fetch
> the whole chunk at one time, then not do another until it needs
another
> full chunk.
>=20

I was using it loosely(don't confuse it with 1 block as in 4K :). RA
could be tied to whatever appropriate parameters depending on the
setup(underlying backing store) etc.
But the point I'm trying to make is to (may be)keep the adaptive logic
simple. So if you start with RA-chunk =3D=3D 512KB/xMB, then when we
increment it, do something like (RA-chunk << N).
BTW, it's not just RAID but also different abstractions you might have.
Stripe-width worth of RA is still useless if your LVM chunk is N *
stripe-width.

> Cheers, Andreas
Chetan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
