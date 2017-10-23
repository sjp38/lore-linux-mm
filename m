Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7076B0069
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 06:45:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z80so16036166pff.11
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:45:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a1si3905585plt.229.2017.10.23.03.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 03:45:42 -0700 (PDT)
From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH 01/15] sched: convert sighand_struct.count to refcount_t
Date: Mon, 23 Oct 2017 10:45:35 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B802B439C@IRSMSX102.ger.corp.intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
 <1508501757-15784-2-git-send-email-elena.reshetova@intel.com>
 <alpine.DEB.2.20.1710201430420.4531@nanos>
 <2236FBA76BA1254E88B949DDB74E612B802B4359@IRSMSX102.ger.corp.intel.com>
 <alpine.DEB.2.20.1710231223450.4241@nanos>
In-Reply-To: <alpine.DEB.2.20.1710231223450.4241@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "mingo@redhat.com" <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "tj@kernel.org" <tj@kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "lizefan@huawei.com" <lizefan@huawei.com>, "acme@kernel.org" <acme@kernel.org>, "alexander.shishkin@linux.intel.com" <alexander.shishkin@linux.intel.com>, "eparis@redhat.com" <eparis@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "luto@kernel.org" <luto@kernel.org>, "keescook@chromium.org" <keescook@chromium.org>, "dvhart@infradead.org" <dvhart@infradead.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "axboe@kernel.dk" <axboe@kernel.dk>

> On Mon, 23 Oct 2017, Reshetova, Elena wrote:
> > > On Fri, 20 Oct 2017, Elena Reshetova wrote:
> > > How did you make sure that these atomic operations have no other
> > > serialization effect and can be replaced with refcount?
> >
> > What serialization effects? Are you taking about smth else than memory
> > ordering?
>=20
> Well, the memory ordering constraints can be part of serialization
> mechanisms. Unfortunately they are not well documented ....

Would you be able to point to any documentation or examples of this?
I would be happy to understand more, it is really not smth very straightfor=
ward.

The reason I also don't want to confuse people even more with this ordering=
 issue
is that it can be different if you use arch. specific implementation vs. ar=
ch. independent.
So, it is not as simple as to say "refcount_t would always result in weak m=
emory ordering",
it really depends what REFCOUNT config option is "on", what arch. you are r=
unning on etc.
Nothing to add is that by default refount_t =3D atomic_t unless you start e=
nabling
the related configs...
=20
>=20
> > For memory ordering my current hope is that we can just make refcount_t
> > to use same strict atomic primitives and then it would not make any
> > difference.  I think this would be the simplest way for everyone since =
I
> > think even some maintainers are having issues understanding all the
> > implications of "relaxed" ordering.
>=20
> Well, that would make indeed the conversion simpler because then it is ju=
st
> a drop in replacement. Albeit there might be some places which benefit of
> the relaxed ordering as on some architectures strict ordering is expensiv=
e.

Well refcount_t was not meant to provide any other benefits from atomic_t a=
part from
better security guarantees and potentially better written code (less possib=
ilities to do smth
stupid with a smaller API). If someone really have an issue with speed, the=
y should be enabling
arch. specific refcount_t implementation for their arch. anyway and then it=
 is hopefully does
it the best possible/faster way.=20

Best Regards,
Elena.

>=20
> Thanks,
>=20
> 	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
