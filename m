Date: Sun, 24 Nov 2002 23:34:49 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: [PATCH] Really start using the page walking API
Message-ID: <20021124233449.F5263@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HWvPVVuAAfuRc6SZ"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Kai Makisara <Kai.Makisara@kolumbus.fi>, Douglas Gilbert <dougg@torque.net>, Gerd Knorr <kraxel@bytesex.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--HWvPVVuAAfuRc6SZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

here come some improvements of the page walking API code.

First: make_pages_present() would do an infinite recursion, if
   used in find_extend_vma(). I fixed this. Might as well have
   caused the ntp crash, that has been observed. 
   So these make_pages_present parts are really important.

I also did the promised rewrite of make_pages_present() and its
users.

MM-Gurus: Please double check, that I always provide the right vma.

I also did two sample implementations (Kai and Doug, this is why
you are CC'ed) of the scatter list walking and removed ~100
lines of code while doing it.

Gerd: Your video-buf.[ch] is next on my list and I must coalesce 
   videobuf_pages_to_sg() and videobuf_init_user() to do it
   efficiently. May be you can come up with a better solution for
   this or are already working on sth. here. If not, I'll do it
   my way first and wait for your approval ;-)

That's all for now. I omitted the patches, to make 2.5.49-mm1
compile, as usual.

Patch against 2.5.49-mm1 attached.

diffstat of this patch:

 drivers/scsi/sg.c         |  102 +++++++++----------------------------------
 drivers/scsi/st.c         |  109 ++++++++--------------------------------------
 include/linux/mm.h        |    2 
 include/linux/page_walk.h |   13 +++--
 mm/mlock.c                |    2 
 mm/mmap.c                 |   11 ++--
 mm/mremap.c               |    4 -
 mm/page_walk.c            |   83 ++++++++++++++++++++++++-----------
 8 files changed, 119 insertions, 207 deletions

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth

--HWvPVVuAAfuRc6SZ
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="page-walk-api-2.5.49-mm1-improvements.patch.bz2"
Content-Transfer-Encoding: base64

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

--HWvPVVuAAfuRc6SZ--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
