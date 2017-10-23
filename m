Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5363C6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:22:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a192so11561072pge.1
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:22:15 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v14si4720117pgc.214.2017.10.23.03.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 03:22:07 -0700 (PDT)
From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH 01/15] sched: convert sighand_struct.count to refcount_t
Date: Mon, 23 Oct 2017 10:22:01 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B802B4359@IRSMSX102.ger.corp.intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
 <1508501757-15784-2-git-send-email-elena.reshetova@intel.com>
 <alpine.DEB.2.20.1710201430420.4531@nanos>
In-Reply-To: <alpine.DEB.2.20.1710201430420.4531@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "tj@kernel.org" <tj@kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "lizefan@huawei.com" <lizefan@huawei.com>, "acme@kernel.org" <acme@kernel.org>, "alexander.shishkin@linux.intel.com" <alexander.shishkin@linux.intel.com>, "eparis@redhat.com" <eparis@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "luto@kernel.org" <luto@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "dvhart@infradead.org" <dvhart@infradead.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "axboe@kernel.dk" <axboe@kernel.dk>

> On Fri, 20 Oct 2017, Elena Reshetova wrote:
>=20
> > atomic_t variables are currently used to implement reference
> > counters with the following properties:
> >  - counter is initialized to 1 using atomic_set()
> >  - a resource is freed upon counter reaching zero
> >  - once counter reaches zero, its further
> >    increments aren't allowed
> >  - counter schema uses basic atomic operations
> >    (set, inc, inc_not_zero, dec_and_test, etc.)
> >
> > Such atomic variables should be converted to a newly provided
> > refcount_t type and API that prevents accidental counter overflows
> > and underflows. This is important since overflows and underflows
> > can lead to use-after-free situation and be exploitable.
> >
> > The variable sighand_struct.count is used as pure reference counter.
>=20
> This still does not mention that atomic_t !=3D recfcount_t ordering wise =
and
> why you think that this does not matter in that use case.
>
>
> And looking deeper:
>=20
> > @@ -1381,7 +1381,7 @@ static int copy_sighand(unsigned long clone_flags=
,
> struct task_struct *tsk)
> >  	struct sighand_struct *sig;
> >
> >  	if (clone_flags & CLONE_SIGHAND) {
> > -		atomic_inc(&current->sighand->count);
> > +		refcount_inc(&current->sighand->count);
> >  		return 0;
>=20
> >  void __cleanup_sighand(struct sighand_struct *sighand)
> >  {
> > -	if (atomic_dec_and_test(&sighand->count)) {
> > +	if (refcount_dec_and_test(&sighand->count)) {
>=20
> How did you make sure that these atomic operations have no other
> serialization effect and can be replaced with refcount?

What serialization effects? Are you taking about smth else than memory
ordering?=20

For memory ordering my current hope is that we can just make refcount_t
to use same strict atomic primitives and then it would not make any differe=
nce.
I think this would be the simplest way for everyone since I think even some=
 maintainers
are having issues understanding all the implications of "relaxed" ordering.=
=20

Best Regards,
Elena

>=20
> I complained about that before and Peter explained it to you in great
> length, but you just resend the same thing again. Where is the correctnes=
s
> analysis? Seriously, for this kind of stuff it's not sufficient to use a
> coccinelle script and copy boiler plate change logs and be done with it.
>=20
> Thanks,
>=20
> 	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
