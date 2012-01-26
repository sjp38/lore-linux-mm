Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 206646B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 11:59:47 -0500 (EST)
References: <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost> <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca> <1327502034.2720.23.camel@menhir> <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com> <1327509623.2720.52.camel@menhir> <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com> <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com> <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com> <20120125200613.GH15866@shiny> <20120125224614.GM30782@redhat.com> <D3F292ADF945FB49B35E96C94C2061B915A64111@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B915A64111@nsmail.netscout.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <10715842-8E51-40A5-8C28-AD8B1090645D@dilger.ca>
Content-Transfer-Encoding: quoted-printable
From: Andreas Dilger <adilger@dilger.ca>
Subject: Re: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Date: Thu, 26 Jan 2012 10:00:04 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Chris Mason <chris.mason@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, "<linux-scsi@vger.kernel.org>" <linux-scsi@vger.kernel.org>, "<neilb@suse.de>" <neilb@suse.de>, "<dm-devel@redhat.com>" <dm-devel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "<linux-mm@kvack.org>" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>, "<lsf-pc@lists.linux-foundation.org>" <lsf-pc@lists.linux-foundation.org>, "Darrick J.Wong" <djwong@us.ibm.com>

On 2012-01-26, at 9:40, "Loke, Chetan" <Chetan.Loke@netscout.com> wrote:
> And 'maybe' for adaptive RA just increase the RA-blocks by '1'(or some
> N) over period of time. No more smartness. A simple 10 line function is
> easy to debug/maintain. That is, a scaled-down version of
> ramp-up/ramp-down. Don't go crazy by ramping-up/down after every RA(like
> SCSI LLDD madness). Wait for some event to happen.

Doing 1-block readahead increments is a performance disaster on RAID-5/6. Th=
at means you seek all the disks, but use only a fraction of the data that th=
e controller read internally and had to parity check.

It makes more sense to keep the read units the same size as write units (1 M=
B or as dictated by RAID geometry) that the filesystem is also hopefully usi=
ng for allocation.  When doing a readahead it should fetch the whole chunk a=
t one time, then not do another until it needs another full chunk.

Cheers, Andreas=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
