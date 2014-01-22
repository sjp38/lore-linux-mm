Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4994E6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:02:17 -0500 (EST)
Received: by mail-ve0-f180.google.com with SMTP id db12so442828veb.39
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:02:16 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTP id vq3si4989633veb.103.2014.01.22.10.02.15
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 10:02:15 -0800 (PST)
From: Chris Mason <clm@fb.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Date: Wed, 22 Jan 2014 18:02:09 +0000
Message-ID: <1390413819.1198.20.camel@ret.masoncoding.com>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com>
	 <20140122093435.GS4963@suse.de> <52DFD168.8080001@redhat.com>
	 <20140122143452.GW4963@suse.de> <52DFDCA6.1050204@redhat.com>
	 <20140122151913.GY4963@suse.de>
	 <1390410233.1198.7.camel@ret.masoncoding.com>
	 <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <E44B69ECB3DF564D943C1ED6AA6B2644@fb.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, 2014-01-22 at 09:21 -0800, James Bottomley wrote:
+AD4- On Wed, 2014-01-22 at 17:02 +-0000, Chris Mason wrote:

+AFs- I like big sectors and I cannot lie +AF0-

+AD4- =20
+AD4- +AD4- I really think that if we want to make progress on this one, we=
 need
+AD4- +AD4- code and someone that owns it.  Nick's work was impressive, but=
 it was
+AD4- +AD4- mostly there for getting rid of buffer heads.  If we have a dev=
ice that
+AD4- +AD4- needs it and someone working to enable that device, we'll go fo=
rward
+AD4- +AD4- much faster.
+AD4-=20
+AD4- Do we even need to do that (eliminate buffer heads)?  We cope with 4k
+AD4- sector only devices just fine today because the bh mechanisms now
+AD4- operate on top of the page cache and can do the RMW necessary to upda=
te
+AD4- a bh in the page cache itself which allows us to do only 4k chunked
+AD4- writes, so we could keep the bh system and just alter the granularity=
 of
+AD4- the page cache.
+AD4-=20

We're likely to have people mixing 4K drives and +ADw-fill in some other
size here+AD4- on the same box.  We could just go with the biggest size and
use the existing bh code for the sub-pagesized blocks, but I really
hesitate to change VM fundamentals for this.

>From a pure code point of view, it may be less work to change it once in
the VM.  But from an overall system impact point of view, it's a big
change in how the system behaves just for filesystem metadata.

+AD4- The other question is if the drive does RMW between 4k and whatever i=
ts
+AD4- physical sector size, do we need to do anything to take advantage of
+AD4- it ... as in what would altering the granularity of the page cache bu=
y
+AD4- us?

The real benefit is when and how the reads get scheduled.  We're able to
do a much better job pipelining the reads, controlling our caches and
reducing write latency by having the reads done up in the OS instead of
the drive.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
