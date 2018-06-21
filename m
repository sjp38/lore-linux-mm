Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 835CC6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 14:06:52 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d70-v6so3299116itd.1
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 11:06:52 -0700 (PDT)
Received: from 9pmail.ess.barracuda.com (9pmail.ess.barracuda.com. [64.235.150.224])
        by mx.google.com with ESMTPS id y8-v6si1878196iof.72.2018.06.21.11.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 11:06:50 -0700 (PDT)
Date: Thu, 21 Jun 2018 11:06:38 -0700
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Message-ID: <20180621180638.ahxpgzwrztopve55@pburton-laptop>
References: <20180606194144.16990-1-malat@debian.org>
 <CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
 <20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Tony Luck <tony.luck@gmail.com>, Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Andrew & Stephen,

On Fri, Jun 15, 2018 at 12:17:16PM -0700, Andrew Morton wrote:
> > Sadly that breaks ia64 build:
> >=20
> >   CC      mm/memblock.o
> > mm/memblock.c:1340: error: redefinition of =E2=80=98memblock_virt_alloc=
_try_nid_raw=E2=80=99
> > ./include/linux/bootmem.h:335: error: previous definition of
> > =E2=80=98memblock_virt_alloc_try_nid_raw=E2=80=99 was here
> > mm/memblock.c:1377: error: redefinition of =E2=80=98memblock_virt_alloc=
_try_nid_nopanic=E2=80=99
> > ./include/linux/bootmem.h:343: error: previous definition of
> > =E2=80=98memblock_virt_alloc_try_nid_nopanic=E2=80=99 was here
> > mm/memblock.c:1413: error: redefinition of =E2=80=98memblock_virt_alloc=
_try_nid=E2=80=99
> > ./include/linux/bootmem.h:327: error: previous definition of
> > =E2=80=98memblock_virt_alloc_try_nid=E2=80=99 was here
> > make[1]: *** [mm/memblock.o] Error 1
> > make: *** [mm/memblock.o] Error 2
>=20
> Huh.  How did that ever work.  I guess it's either this:
<snip>
> and I'm not sure which.  I think I'll just revert $subject for now.

This is fine now in master after Andrew's revert, but the problematic
patch is still being picked up in linux-next somehow. This breaks MIPS
builds from linux-next, and presumably the ia64 build too.

I'm not sure I understand how it's picked up - next-20180621 appears to
based atop 1abd8a8f39cd:

  $ git show next-20180621:Next/SHA1s | grep -E '^origin\s'
  origin          1abd8a8f39cd9a2925149000056494523c85643a

There we have the Andrew's revert:

  $ git log --pretty=3Doneline -n5 1abd8a8f39cd mm/memblock.c
  6cc22dc08a247b7b4a173e4561e39705a557d300 revert "mm/memblock: add missing=
 include <linux/bootmem.h>"
  0825a6f98689d847ab8058c51b3a55f0abcc6563 mm: use octal not symbolic permi=
ssions
  69b5086b12cda645d95f00575c25f1dfd1e929ad mm/memblock: add missing include=
 <linux/bootmem.h>
  25cf23d7a95716fc6eb165208b5eb2e3b2e86f82 mm/memblock: print memblock_remo=
ve
  1c4bc43ddfd52cbe5a08bb86ae636f55d2799424 mm/memblock: introduce PHYS_ADDR=
_MAX

Yet the revert doesn't show up at all in next-20180621..?

  $ git log --pretty=3Doneline -n5 next-20180621 mm/memblock.c
  a95f41a659344e221e8ad39e8fbba2e0f419c096 mm: use octal not symbolic permi=
ssions
  0b558dea04a405800505c7f56eb1638ae761b5d4 mm/memblock: add missing include=
 <linux/bootmem.h>
  25cf23d7a95716fc6eb165208b5eb2e3b2e86f82 mm/memblock: print memblock_remo=
ve
  1c4bc43ddfd52cbe5a08bb86ae636f55d2799424 mm/memblock: introduce PHYS_ADDR=
_MAX
  49a695ba723224875df50e327bd7b0b65dd9a56b Merge tag 'powerpc-4.17-1' of gi=
t://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux

I was expecting to see the original commit, then the revert, then
perhaps a re-application of it but instead it looks like the commits
from master are missing entirely after 25cf23d7a957 ("mm/memblock: print
memblock_remove"). Maybe I'm missing something about the way the merges
for linux-next are done..?

In any case, could we get the problematic patch removed from linux-next?

Thanks,
    Paul
