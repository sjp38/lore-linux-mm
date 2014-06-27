Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id A2A336B003B
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 08:43:34 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so4535469pbc.12
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 05:43:34 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hd2si13813026pbb.196.2014.06.27.05.43.33
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 05:43:33 -0700 (PDT)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCH] msync: fix incorrect fstart calculation
Date: Fri, 27 Jun 2014 12:43:30 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE0407A787B@FMSMSX114.amr.corp.intel.com>
References: <006a01cf91fc$5d225170$1766f450$@samsung.com>
In-Reply-To: <006a01cf91fc$5d225170$1766f450$@samsung.com>
Content-Language: en-CA
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <namjae.jeon@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-ext4 <linux-ext4@vger.kernel.org>, =?Windows-1252?Q?Luk=E1=9A_Czerner?= <lczerner@redhat.com>, 'Eric Whitney' <enwlinux@gmail.com>, Ashish Sangwan <a.sangwan@samsung.com>

Acked-by: Matthew Wilcox <matthew.r.wilcox@intel.com>=0A=
________________________________________=0A=
From: Namjae Jeon [namjae.jeon@samsung.com]=0A=
Sent: June 27, 2014 4:38 AM=0A=
To: 'Andrew Morton'=0A=
Cc: linux-mm@kvack.org; linux-ext4; Luk=E1=9A Czerner; Wilcox, Matthew R; '=
Eric Whitney'; Ashish Sangwan=0A=
Subject: [PATCH] msync: fix incorrect fstart calculation=0A=
=0A=
Fix a regression caused by Commit 7fc34a62ca mm/msync.c: sync only=0A=
the requested range in msync().=0A=
xfstests generic/075 fail occured on ext4 data=3Djournal mode because=0A=
the intended range was not syncing due to wrong fstart calculation.=0A=
=0A=
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>=0A=
Cc: Luk=E1=9A Czerner <lczerner@redhat.com>=0A=
Reported-by: Eric Whitney <enwlinux@gmail.com>=0A=
Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>=0A=
Signed-off-by: Ashish Sangwan <a.sangwan@samsung.com>=0A=
---=0A=
 mm/msync.c | 3 ++-=0A=
 1 file changed, 2 insertions(+), 1 deletion(-)=0A=
=0A=
diff --git a/mm/msync.c b/mm/msync.c=0A=
index a5c6736..ad97dce 100644=0A=
--- a/mm/msync.c=0A=
+++ b/mm/msync.c=0A=
@@ -78,7 +78,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len,=
 int, flags)=0A=
                        goto out_unlock;=0A=
                }=0A=
                file =3D vma->vm_file;=0A=
-               fstart =3D start + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);=
=0A=
+               fstart =3D (start - vma->vm_start) +=0A=
+                        ((loff_t)vma->vm_pgoff << PAGE_SHIFT);=0A=
                fend =3D fstart + (min(end, vma->vm_end) - start) - 1;=0A=
                start =3D vma->vm_end;=0A=
                if ((flags & MS_SYNC) && file &&=0A=
--=0A=
1.7.11-rc0=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
