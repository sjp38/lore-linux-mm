Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A1A306B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:46:22 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 62so8166632ply.4
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:46:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 59-v6sor3101553pla.75.2018.02.26.13.46.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 13:46:21 -0800 (PST)
Date: Mon, 26 Feb 2018 13:46:13 -0800
From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/2] mark some slabs as visible not mergeable
Message-ID: <20180226134613.04edcc98@xeon-e3>
In-Reply-To: <20180226.151502.1181392845403505211.davem@redhat.com>
References: <20180224190454.23716-1-sthemmin@microsoft.com>
	<20180226.151502.1181392845403505211.davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@redhat.com>
Cc: willy@infradead.org, netdev@vger.kernel.org, linux-mm@kvack.org, ikomyagin@gmail.com, sthemmin@microsoft.com

On Mon, 26 Feb 2018 15:15:02 -0500 (EST)
David Miller <davem@redhat.com> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sat, 24 Feb 2018 11:04:52 -0800
>=20
> > This fixes an old bug in iproute2's ss command because it was
> > reading slabinfo to get statistics. There isn't a better API
> > to do this, and one can argue that /proc is a UAPI that must
> > not change. =20
>=20
> Please elaborate what kind of statistics are needed.

This is ancient original iproute2 code that dumpster dives into
slabinfo to get summary statistics on active objects.

	1) open sockets (sock_inode_cache)
	2) TCP ports bound (tcp_bind_buckets) [*]
	3) TCP time wait sockets (tw_sock_TCP) [*]
	4) TCP syn sockets (request_sock_TCP) [*]

=46rom man page:

       -s, --summary
              Print summary statistics. This option does not parse socket l=
ists  obtaining  summary  from
              various  sources. It is useful when amount of sockets is so h=
uge that parsing /proc/net/tcp
              is painful.


The items with * are currently broken. See 0 for timewait, synrecv, and por=
ts.

$ sudo ss -s

Total: 1089 (kernel 1093)
TCP:   33 (estab 4, closed 1, orphaned 0, synrecv 0, timewait 0/0), ports 0

Transport Total     IP        IPv6
*	  1093      -         -       =20
RAW	  0         0         0       =20
UDP	  21        13        8       =20
TCP	  32        24        8       =20
INET	  53        37        16      =20
FRAG	  0         0         0       =20

>=20
> > Therefore this patch set adds a flag to slab to give another
> > reason to prevent merging, and then uses it in network code.
> >=20
> > The patches are against davem's linux-net tree and should also
> > goto stable as well. =20
>=20
> Well, as has been pointed out this never worked with SLUB so
> in some sense this was always broken.
>=20
> And the "UAPI" of slabinfo is to show the state of the various
> slab caches.  And that's it.
>=20
> If the implementation does merging or whatever, the UAPI is expressing
> that and it's perfectly legitimate and not breaking UAPI in my
> opinion.
>=20
> I think the better solution is to grab the information from somewhere
> else, so let's move this conversation along with the answer to my
> question about asking for more details about what is needed by
> iproute2.
>=20
> Thank you.

There is no where else that gives summary information.

Both /proc/net/tcp and sock diag info require user space to
read all the data, which is what I think Alexey was trying to avoid.
Ideally there would be network namespace aware API to do this, but
the code (iproute2 and kernel) are currently broken. Some values
are missing (because they are merged) and some values have wrong
cache name (because of acme's changes to make this generic).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
