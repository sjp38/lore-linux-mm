Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8B65B6B0036
	for <linux-mm@kvack.org>; Sat, 24 May 2014 09:50:41 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so3321204lbv.21
        for <linux-mm@kvack.org>; Sat, 24 May 2014 06:50:40 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id d5si12372118lbr.46.2014.05.24.06.50.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 May 2014 06:50:40 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id hr17so4932713lab.3
        for <linux-mm@kvack.org>; Sat, 24 May 2014 06:50:39 -0700 (PDT)
Subject: [PATCH RFC] proc/pid/mem: implement SEEK_DATA and SEEK_HOLE
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 24 May 2014 17:50:35 +0400
Message-ID: <20140524135035.32281.93663.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

lseek(fd, addr, SEEK_DATA) adjust file offset to the start address of next VMA,
or to addr if this address is allocated.

lseek(fd, addr, SEEK_HOLE) adjust file offset to the end address of VMA which
addr belongs to, or to addr itself if there is hole.

This way SEEK_HOLE reports a virtual zero-length hole between each contiguous
VMAs. This hack seems completely legit and allows to simplify implementation
(there is no function for finding next hole in VMAs' tree, walking along
 ->vm_next might be expensive) This also gives more information about layout.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

---

I have no practical use for this, just found this interesting.
---
 fs/proc/base.c |   31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 2d696b0..aba4b47 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -769,13 +769,40 @@ static ssize_t mem_write(struct file *file, const char __user *buf,
 
 loff_t mem_lseek(struct file *file, loff_t offset, int orig)
 {
+	struct mm_struct *mm = file->private_data;
+	struct vm_area_struct *vma;
+
 	switch (orig) {
-	case 0:
+	case SEEK_SET:
 		file->f_pos = offset;
 		break;
-	case 1:
+	case SEEK_CUR:
 		file->f_pos += offset;
 		break;
+	case SEEK_DATA:
+	case SEEK_HOLE:
+		if (!mm || !atomic_inc_not_zero(&mm->mm_users))
+			return -ENXIO;
+		down_read(&mm->mmap_sem);
+		vma = find_vma(mm, offset);
+		if (vma) {
+			if (orig == SEEK_DATA) {
+				if (offset >= vma->vm_start)
+					file->f_pos = offset;
+				else
+					file->f_pos = vma->vm_start;
+			} else {
+				if (offset < vma->vm_start)
+					file->f_pos = offset;
+				else
+					file->f_pos = vma->vm_end;
+			}
+		}
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+		if (!vma)
+			return -ENXIO;
+		break;
 	default:
 		return -EINVAL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
