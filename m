Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 302706B0008
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 13:21:09 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u20-v6so17813924qka.21
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:21:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e127si770947qkc.256.2018.10.31.10.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 10:21:07 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Subject: PIE binaries are no longer mapped below 4 GiB on ppc64le
Date: Wed, 31 Oct 2018 18:20:56 +0100
Message-ID: <87k1lyf2x3.fsf@oldenburg.str.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

We tried to use Go to build PIE binaries, and while the Go toolchain is
definitely not ready (it produces text relocations and problematic
relocations in general), it exposed what could be an accidental
userspace ABI change.

With our 4.10-derived kernel, PIE binaries are mapped below 4 GiB, so
relocations like R_PPC64_ADDR16_HA work:

21f00000-220d0000 r-xp 00000000 fd:00 36593493                           /r=
oot/extld
220d0000-220e0000 r--p 001c0000 fd:00 36593493                           /r=
oot/extld
220e0000-22100000 rw-p 001d0000 fd:00 36593493                           /r=
oot/extld
22100000-22120000 rw-p 00000000 00:00 0
264b0000-264e0000 rw-p 00000000 00:00 0                                  [h=
eap]
c000000000-c000010000 rw-p 00000000 00:00 0
c41ffe0000-c420300000 rw-p 00000000 00:00 0
3fff8c000000-3fff8c030000 rw-p 00000000 00:00 0
3fff8c030000-3fff90000000 ---p 00000000 00:00 0
3fff90000000-3fff90030000 rw-p 00000000 00:00 0
3fff90030000-3fff94000000 ---p 00000000 00:00 0
3fff94000000-3fff94030000 rw-p 00000000 00:00 0
3fff94030000-3fff98000000 ---p 00000000 00:00 0
3fff98000000-3fff98030000 rw-p 00000000 00:00 0
3fff98030000-3fff9c000000 ---p 00000000 00:00 0
3fff9c000000-3fff9c030000 rw-p 00000000 00:00 0
3fff9c030000-3fffa0000000 ---p 00000000 00:00 0
3fffa2290000-3fffa22d0000 rw-p 00000000 00:00 0
3fffa22d0000-3fffa22e0000 ---p 00000000 00:00 0
3fffa22e0000-3fffa2ae0000 rw-p 00000000 00:00 0
3fffa2ae0000-3fffa2af0000 ---p 00000000 00:00 0
3fffa2af0000-3fffa32f0000 rw-p 00000000 00:00 0
3fffa32f0000-3fffa3300000 ---p 00000000 00:00 0
3fffa3300000-3fffa3b00000 rw-p 00000000 00:00 0
3fffa3b00000-3fffa3b10000 ---p 00000000 00:00 0
3fffa3b10000-3fffa4310000 rw-p 00000000 00:00 0
3fffa4310000-3fffa4320000 ---p 00000000 00:00 0
3fffa4320000-3fffa4bb0000 rw-p 00000000 00:00 0
3fffa4bb0000-3fffa4da0000 r-xp 00000000 fd:00 34316081                   /u=
sr/lib64/power9/libc-2.28.so
3fffa4da0000-3fffa4db0000 r--p 001e0000 fd:00 34316081                   /u=
sr/lib64/power9/libc-2.28.so
3fffa4db0000-3fffa4dc0000 rw-p 001f0000 fd:00 34316081                   /u=
sr/lib64/power9/libc-2.28.so
3fffa4dc0000-3fffa4df0000 r-xp 00000000 fd:00 34316085                   /u=
sr/lib64/power9/libpthread-2.28.so
3fffa4df0000-3fffa4e00000 r--p 00020000 fd:00 34316085                   /u=
sr/lib64/power9/libpthread-2.28.so
3fffa4e00000-3fffa4e10000 rw-p 00030000 fd:00 34316085                   /u=
sr/lib64/power9/libpthread-2.28.so
3fffa4e10000-3fffa4e20000 rw-p 00000000 00:00 0
3fffa4e20000-3fffa4e40000 r-xp 00000000 00:00 0                          [v=
dso]
3fffa4e40000-3fffa4e70000 r-xp 00000000 fd:00 874114                     /u=
sr/lib64/ld-2.28.so
3fffa4e70000-3fffa4e80000 r--p 00020000 fd:00 874114                     /u=
sr/lib64/ld-2.28.so
3fffa4e80000-3fffa4e90000 rw-p 00030000 fd:00 874114                     /u=
sr/lib64/ld-2.28.so
3ffff3000000-3ffff3030000 rw-p 00000000 00:00 0
[stack]

With a 4.18-derived kernel (with the hashed mm), we get this instead:

120e60000-121030000 rw-p 00000000 fd:00 102447141                        /r=
oot/extld
121030000-121060000 rw-p 001c0000 fd:00 102447141                        /r=
oot/extld
121060000-121080000 rw-p 00000000 00:00 0=20
7fffb5b00000-7fffb5cf0000 r-xp 00000000 fd:00 67169871                   /u=
sr/lib64/power9/libc-2.28.so
7fffb5cf0000-7fffb5d00000 r--p 001e0000 fd:00 67169871                   /u=
sr/lib64/power9/libc-2.28.so
7fffb5d00000-7fffb5d10000 rw-p 001f0000 fd:00 67169871                   /u=
sr/lib64/power9/libc-2.28.so
7fffb5d10000-7fffb5d40000 r-xp 00000000 fd:00 67169875                   /u=
sr/lib64/power9/libpthread-2.28.so
7fffb5d40000-7fffb5d50000 r--p 00020000 fd:00 67169875                   /u=
sr/lib64/power9/libpthread-2.28.so
7fffb5d50000-7fffb5d60000 rw-p 00030000 fd:00 67169875                   /u=
sr/lib64/power9/libpthread-2.28.so
7fffb5d60000-7fffb5d70000 r--p 00000000 fd:00 67780267                   /e=
tc/ld.so.cache
7fffb5d70000-7fffb5d90000 r-xp 00000000 00:00 0                          [v=
dso]
7fffb5d90000-7fffb5dc0000 r-xp 00000000 fd:00 1477                       /u=
sr/lib64/ld-2.28.so
7fffb5dc0000-7fffb5de0000 rw-p 00020000 fd:00 1477                       /u=
sr/lib64/ld-2.28.so
7fffff6c0000-7fffff6f0000 rw-p 00000000 00:00 0                          [s=
tack]

There are fewer mappings because the loader detects a relocation
overflow and aborts (=E2=80=9Cerror while loading shared libraries:
R_PPC64_ADDR16_HA reloc at 0x0000000120f0983c for symbol `' out of
range=E2=80=9D), so I had to recover the mappings externally.  Disabling AS=
LR
does not help.

The Go program looks like this:

package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

// #include <gnu/libc-version.h>
import "C"

func main() {
	// Force external linking against glibc.
	fmt.Printf("%#v\n", C.GoString(C.gnu_get_libc_version()))

	maps, err :=3D os.Open("/proc/self/maps")
	if err !=3D nil {
     		panic(err)
	}
	defer maps.Close()
	contents, err :=3D ioutil.ReadAll(maps)
	if err !=3D nil {
		panic(err)
	}
	_, err =3D os.Stdout.Write(contents)
	if err !=3D nil {
		panic(err)
	}
}

And it needs to be built with:

  go build -ldflags=3D-extldflags=3D-pie extld.go

I'm not entirely sure what to make of this, but I'm worried that this
could be a regression that matters to userspace.

Thanks,
Florian
