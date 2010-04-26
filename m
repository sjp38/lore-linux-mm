Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3576B6B01F2
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 19:29:16 -0400 (EDT)
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <4BD61147.40709@tauceti.net>
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net>
	 <20100419131718.GB16918@redhat.com>
	 <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net>
	 <20100421094249.GC30855@redhat.com>
	 <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net>
	 <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net>
	 <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net>
	 <20100425204916.GA12686@redhat.com>
	 <1272284154.4252.34.camel@localhost.localdomain>
	 <4BD5F6C5.8080605@tauceti.net>
	 <1272315854.8984.125.camel@localhost.localdomain>
	 <4BD61147.40709@tauceti.net>
Content-Type: multipart/mixed; boundary="=-VJUQJgQ37UgEeLWr5kvS"
Date: Mon, 26 Apr 2010 19:28:56 -0400
Message-ID: <1272324536.16814.45.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Robert Wimmer <kernel@tauceti.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--=-VJUQJgQ37UgEeLWr5kvS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-04-27 at 00:18 +0200, Robert Wimmer wrote:=20
> > Sure. In addition to what you did above, please do
> >
> > mount -t debugfs none /sys/kernel/debug
> >
> > and then cat the contents of the pseudofile at
> >
> > /sys/kernel/debug/tracing/stack_trace
> >
> > Please do this more or less immediately after you've finished mounting
> > the NFSv4 client.
> >  =20
>=20
> I've uploaded the stack trace. It was generated
> directly after mounting. Here are the stacks:
>=20
> After mounting:
> https://bugzilla.kernel.org/attachment.cgi?id=3D26153
> After the soft lockup:
> https://bugzilla.kernel.org/attachment.cgi?id=3D26154
> The dmesg output of the soft lockup:
> https://bugzilla.kernel.org/attachment.cgi?id=3D26155
>=20
> > Does your server have the 'crossmnt' or 'nohide' flags set, or does it
> > use the 'refer' export option anywhere? If so, then we might have to
> > test further, since those may trigger the NFSv4 submount feature.
> >  =20
> The server has the following settings:
> rw,nohide,insecure,async,no_subtree_check,no_root_squash
>=20
> Thanks!
> Robert
>=20
>=20

That second trace is more than 5.5K deep, more than half of which is
socket overhead :-(((.

The process stack does not appear to have overflowed, however that trace
doesn't include any IRQ stack overhead.

OK... So what happens if we get rid of half of that trace by forcing
asynchronous tasks such as this to run entirely in rpciod instead of
first trying to run in the process context?

See the attachment...

--=-VJUQJgQ37UgEeLWr5kvS
Content-Disposition: attachment; filename="linux-2.6.34-000-reduce_async_rpc_stack_usage.dif"
Content-Type: text/plain; name="linux-2.6.34-000-reduce_async_rpc_stack_usage.dif"; charset="UTF-8"
Content-Transfer-Encoding: base64

U1VOUlBDOiBSZWR1Y2UgYXN5bmNocm9ub3VzIFJQQyB0YXNrIHN0YWNrIHVzYWdlDQoNCkZyb206
IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20+DQoNCldlIHNob3Vs
ZCBqdXN0IGZhcm0gb3V0IGFzeW5jaHJvbm91cyBSUEMgdGFza3MgaW1tZWRpYXRlbHkgdG8gcnBj
aW9kLi4uDQoNClNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8VHJvbmQuTXlrbGVidXN0
QG5ldGFwcC5jb20+DQotLS0NCg0KIG5ldC9zdW5ycGMvc2NoZWQuYyB8ICAgIDcgKysrKysrLQ0K
IDEgZmlsZXMgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQ0KDQoNCmRp
ZmYgLS1naXQgYS9uZXQvc3VucnBjL3NjaGVkLmMgYi9uZXQvc3VucnBjL3NjaGVkLmMNCmluZGV4
IGM4OTc5Y2UuLjIyYTA5N2YgMTAwNjQ0DQotLS0gYS9uZXQvc3VucnBjL3NjaGVkLmMNCisrKyBi
L25ldC9zdW5ycGMvc2NoZWQuYw0KQEAgLTcyMCw3ICs3MjAsMTIgQEAgdm9pZCBycGNfZXhlY3V0
ZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQogew0KIAlycGNfc2V0X2FjdGl2ZSh0YXNrKTsNCiAJ
cnBjX3NldF9ydW5uaW5nKHRhc2spOw0KLQlfX3JwY19leGVjdXRlKHRhc2spOw0KKwlpZiAoUlBD
X0lTX0FTWU5DKHRhc2spKSB7DQorCQlJTklUX1dPUksoJnRhc2stPnUudGtfd29yaywgcnBjX2Fz
eW5jX3NjaGVkdWxlKTsNCisJCXF1ZXVlX3dvcmsocnBjaW9kX3dvcmtxdWV1ZSwgJnRhc2stPnUu
dGtfd29yayk7DQorDQorCX0gZWxzZQ0KKwkJX19ycGNfZXhlY3V0ZSh0YXNrKTsNCiB9DQogDQog
c3RhdGljIHZvaWQgcnBjX2FzeW5jX3NjaGVkdWxlKHN0cnVjdCB3b3JrX3N0cnVjdCAqd29yaykN
Cg==


--=-VJUQJgQ37UgEeLWr5kvS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
