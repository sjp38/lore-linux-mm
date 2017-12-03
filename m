Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 77B096B0033
	for <linux-mm@kvack.org>; Sat,  2 Dec 2017 23:06:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so10112840pfe.22
        for <linux-mm@kvack.org>; Sat, 02 Dec 2017 20:06:20 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id o33si7485811plb.489.2017.12.02.20.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Dec 2017 20:06:19 -0800 (PST)
Subject: Re: [PATCH] mmap.2: MAP_FIXED is no longer discouraged
References: <20171202021626.26478-1-jhubbard@nvidia.com>
 <20171202150554.GA30203@bombadil.infradead.org>
 <CAG48ez2u3fjBDCMH4x3EUhG6ZD6VUa=A1p441P9fg=wUdzwHNQ@mail.gmail.com>
 <20171202221910.GA8228@bombadil.infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d654b75e-e20b-b8ed-4564-abb1d210a921@nvidia.com>
Date: Sat, 2 Dec 2017 20:06:17 -0800
MIME-Version: 1.0
In-Reply-To: <20171202221910.GA8228@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/02/2017 02:19 PM, Matthew Wilcox wrote:
> On Sat, Dec 02, 2017 at 07:49:20PM +0100, Jann Horn wrote:
>> On Sat, Dec 2, 2017 at 4:05 PM, Matthew Wilcox <willy@infradead.org> wro=
te:
>>> On Fri, Dec 01, 2017 at 06:16:26PM -0800, john.hubbard@gmail.com wrote:
[...]
>=20
> Maybe that should be up front rather than buried at the end of the senten=
ce.
>=20
> "In a multi-threaded process, the address space can change in response to
> virtually any library call.  This is because almost any library call may =
be
> implemented by using dlopen(3) to load another shared library, which will=
 be
> mapped into the process's address space.  The PAM libraries are an excell=
ent
> example, as well as more obvious examples like brk(2), malloc(3) and even
> pthread_create(3)."
>=20
> What do you think?
>=20

Hi Matthew,

Here is a new version, based on your and Jann's comments. I also added a
reference to MAP_FIXED_SAFE. If it looks close, I'll send a v2 with proper
formatting applied.

I did wonder briefly if your ATM reference was a oblique commentary about
security, but then realized...you probably just needed some cash. :)

-----

This option is extremely hazardous (when used on its own) and moderately
non-portable.

On portability: a process's memory map may change significantly from one
run to the next, depending on library versions, kernel versions and ran=E2=
=80=90
dom numbers.

On hazards: this option forcibly removes pre-existing  mappings,  making
it easy for a multi-threaded process to corrupt its own address space.

For  example,  thread  A  looks  through /proc/<pid>/maps and locates an
available address range, while thread B simultaneously acquires part  or
all  of  that  same  address range. Thread A then calls mmap(MAP_FIXED),
effectively overwriting thread B's mapping.

Thread B need not create a mapping directly;  simply  making  a  library
call that, internally, uses dlopen(3) to load some other shared library,
will suffice. The dlopen(3) call will map the library into the process's
address  space.  Furthermore, almost any library call may be implemented
using this technique.  Examples include brk(2), malloc(3),  pthread_cre=E2=
=80=90
ate(3), and the PAM libraries (http://www.linux-pam.org).

Given the above limitations, one of the very few ways to use this option
safely is: mmap() a region, without specifying MAP_FIXED.  Then,  within
that  region,  call  mmap(MAP_FIXED) to suballocate regions. This avoids
both the portability problem (because the first mmap call lets the  ker=E2=
=80=90
nel pick the address), and the address space corruption problem (because
the region being overwritten is already owned by the calling thread).

Newer kernels (Linux 4.16 and later) have a MAP_FIXED_SAFE  option  that
avoids  the  corruption  problem; if available, MAP_FIXED_SAFE should be
preferred over MAP_FIXED.


thanks,
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
