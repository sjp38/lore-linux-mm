Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2BB6B03B5
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 18:09:45 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n80so1696002qke.6
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:09:45 -0700 (PDT)
Received: from esa6.hgst.iphmx.com (esa6.hgst.iphmx.com. [216.71.154.45])
        by mx.google.com with ESMTPS id v11si412449qtg.188.2017.04.18.15.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 15:09:44 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] mm: Make truncate_inode_pages_range() killable
Date: Tue, 18 Apr 2017 22:09:39 +0000
Message-ID: <1492553377.2689.13.camel@sandisk.com>
References: <20170414215507.27682-1-bart.vanassche@sandisk.com>
	 <alpine.LSU.2.11.1704141726260.9676@eggly.anvils>
	 <1492217984.2557.1.camel@sandisk.com>
	 <20170418081549.GJ22360@dhcp22.suse.cz>
In-Reply-To: <20170418081549.GJ22360@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <5383C1EA53FC4843994E4BDC2C5C8EE3@namprd04.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhocko@kernel.org" <mhocko@kernel.org>
Cc: "hughd@google.com" <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "snitzer@redhat.com" <snitzer@redhat.com>, "oleg@redhat.com" <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hare@suse.com" <hare@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "jack@suse.cz" <jack@suse.cz>

On Tue, 2017-04-18 at 10:15 +0200, Michal Hocko wrote:
> On Sat 15-04-17 00:59:46, Bart Van Assche wrote:
> > On Fri, 2017-04-14 at 17:40 -0700, Hugh Dickins wrote:
> > > Changing a fundamental function, silently not to do its essential job=
,
> > > when something in the kernel has forgotten (or is slow to) unlock_pag=
e():
> > > that seems very wrong to me in many ways.  But linux-fsdevel, Cc'ed, =
will
> > > be a better forum to advise on how to solve the problem you're seeing=
.
> >=20
> > It seems like you have misunderstood the purpose of the patch I posted.=
 It's
> > neither a missing unlock_page() nor slow I/O that I want to address but=
 a
> > genuine deadlock. In case you would not be familiar with the queue_if_n=
o_path
> > multipath configuration option, the multipath.conf man page is availabl=
e at
> > e.g. https://linux.die.net/man/5/multipath.conf.
>=20
> So, who is holding the page lock and why it cannot make forward
> progress? Is the storage gone so that the ongoing IO will never
> terminate? Btw. we have many other places which wait for the page lock
> !killable way. Why they are any different from this case?

Hello Michal,

queue_if_no_path means that if no paths are available that the dm-mpath dri=
ver
does not complete an I/O request until a path becomes available.=A0A standa=
rd
test for multipathed storage is to alternatingly remove and restore all pat=
hs.

If the reported lockup happens at the end of a test I can break the cycle b=
y
running "dmsetup message ${mpath} 0 fail_if_no_path". That command causes
pending I/O requests to fail if no paths are available.

I think it is rather unintuitive that kill -9 does not work for a process t=
hat
uses a dm-mpath device for I/O as long as no paths are available.

The call stack I reported in the first e-mail in this thread is what I ran
into while running multipath tests. I'm not sure why I have not yet hit any
other code paths that perform an unkillable wait on a page lock.

Bart.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
