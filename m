Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B96D8E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:34 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id t133so5333623iof.20
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:34 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id t185si2707553itt.131.2019.01.16.10.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 10:25:32 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 16 Jan 2019 11:25:17 -0700
Message-Id: <20190116182523.19446-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v25 0/6] Add io{read|write}64 to io-64-atomic headers
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, =?UTF-8?q?Horia=20Geant=C4=83?= <horia.geanta@nxp.com>, Logan Gunthorpe <logang@deltatee.com>

This is resend number 6 since the last change to this series.

This cleanup was requested by Greg KH back in June of 2017. I've resent the series
a couple times a cycle since then, updating and fixing as feedback was slowly
recieved some patches were alread accepted by specific arches. In June 2018,
Andrew picked the remainder of this up and it was in linux-next for a
couple weeks. There were a couple problems that were identified and addressed
back then and I'd really like to get the ball rolling again. A year
and a half of sending this without much feedback is far too long.

@Andrew, can you please pick this set up again so it can get into
linux-next? Or let me know if there's something else I should be doing.

Thanks,

Logan

--

Changes since v24:
- Rebased onto v5.0-rc2 (No Changes)

Changes since v23:
- Rebased onto v4.20-rc4 (No Changes)

Changes since v22:
- Rebased onto v4.20-rc1 (No Changes)

Changes since v21:
- Rebased onto v4.19-rc6 (No Changes)

Changes since v20:
- Rebased onto v4.19-rc3 (No Changes)

Changes since v19:
- Rebased onto v4.19-rc1 (No Changes)

Changes since v18:
- Dropped the CAAM patch as it was subtly wrong and broke when people
  tested it in linux-next. Seeing the code is much trickier than it
  appears, we'll leave it to its maintainers to clean it up,
  should they chose.
- Restored the ioread64/iowrite64 extern prototypes as despite
  appearing to be unusued, they are in fact used in a rare corner case
  by the caam driver on 64bit powerpc. This was reported by Guenter testing
  on linux-next.
- Rebased onto v4.18-rc4 (No Changes)

Changes since v17:
- Rebased onto v4.18-rc1 (No Changes)

Changes since v16:
- Rebased onto v4.17-rc4 (No Changes)

Changes since v15:
- Rebased onto v4.17-rc1, dropping the powerpc patches which were
  picked up by Michael

Changes since v14:
- Rebased onto v4.16-rc7
- Replace the first two patches so that instead of correcting the
  endianness annotations we change to using writeX() and readX() with
  swabX() calls. This makes the big-endian functions more symmetric
  with the little-endian versions (with respect to barriers that are
  not included in the raw functions). As a side effect, it also fixes
  the kbuild warnings that the first two patches tried to address.

Changes since v13:
- Changed the subject of patch 0001 to correct a nit pointed out by Luc

Changes since v12:
- Rebased onto v4.16-rc6
- Split patch 0001 into two and reworked the commit log as requested
  by Luc Van Oostenryck

Changes since v11:
- Rebased onto v4.16-rc5
- Added a patch (0001) to fix some old and new sparse warnings
  that the kbuild robot warned about this cycle. The latest version
  of sparse was required to reproduce these.
- Added a patch (0002) to add io{read|write}64 to parisc which the kbuild
  robot also found errors for this cycle

Changes since v10:
- Rebased onto v4.16-rc4, this droped the drm/tilcdc patch which was
  picked up by that tree and is already in 4.16.

Changes since v9:
- Rebased onto v4.15-rc6
- Fixed a couple of issues in the new version of the CAAM patch as
  pointed out by Horia

Changes since v8:
- Rebased onto v4.15-rc2, as a result rewrote patch 7 seeing someone did
  some similar cleanup in that area.
- Added a patch to clean up the Switchtec NTB driver which landed in
  v4.15-rc1

Changes since v7:
- Fix minor nits from Andy Shevchenko
- Rebased onto v4.14-rc1

Changes since v6:
 ** none **

Changes since v5:
- Added a fix to the tilcdc driver to ensure it doesn't use the
  non-atomic operation. (This includes adding io{read|write}64[be]_is_nonatomic
  defines).

Changes since v4:
- Add functions so the powerpc implementation of iomap.c compiles. (As
  noticed by Horia)

Changes since v3:

- I noticed powerpc didn't use the appropriate functions seeing
  readq/writeq were not defined when iomap.h was included. Thus I've
  included a patch to adjust this
- Fixed some mistakes with a couple of the defines in io-64-nonatomic*
  headers
- Fixed a typo noticed by Horia.

(earlier versions were drastically different)


--

Logan Gunthorpe (6):
  iomap: Use non-raw io functions for io{read|write}XXbe
  parisc: iomap: introduce io{read|write}64
  iomap: introduce io{read|write}64_{lo_hi|hi_lo}
  io-64-nonatomic: add io{read|write}64[be]{_lo_hi|_hi_lo} macros
  ntb: ntb_hw_intel: use io-64-nonatomic instead of in-driver hacks
  ntb: ntb_hw_switchtec: Cleanup 64bit IO defines to use the common
    header

 arch/parisc/include/asm/io.h           |   9 ++
 arch/parisc/lib/iomap.c                |  64 +++++++++++
 arch/powerpc/include/asm/io.h          |   2 +
 drivers/ntb/hw/intel/ntb_hw_intel.h    |  30 +-----
 drivers/ntb/hw/mscc/ntb_hw_switchtec.c |  36 +------
 include/asm-generic/iomap.h            |  22 ++++
 include/linux/io-64-nonatomic-hi-lo.h  |  64 +++++++++++
 include/linux/io-64-nonatomic-lo-hi.h  |  64 +++++++++++
 lib/iomap.c                            | 140 ++++++++++++++++++++++++-
 9 files changed, 366 insertions(+), 65 deletions(-)

--
2.19.0
