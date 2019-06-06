Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF850C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75271208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:16:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75271208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 256AB6B02B5; Thu,  6 Jun 2019 16:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E05F6B02B7; Thu,  6 Jun 2019 16:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26D76B02B8; Thu,  6 Jun 2019 16:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B15956B02B5
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so2594381pfm.16
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=T05HjB1dOtC+7biOT8TU+T3c2hChEvbbYH9fK1G4wmY=;
        b=uhUWkTXGpncXz+z9i7XWp4xKmd9+1+xGWazM4VdbyKG1fUU5W6nwXc2pE9gNKA4t9W
         m4WZazk05XGgyXMVz8Sou9rz59Zvh6A80LcQuNYZ4lciwFTUSSuCQIFBaFuSk+GcEU9j
         OvSVr6mGS5WJaALROzKRN1dglpceMiUiFEQC78N0FGnABNxbQIOAisRYYCjauB87uBH2
         p3A4yPUANH4srp0nHLJUxRJEpDoqBrL33li0NifZjkjw/r6U2x/XEbOoSkulQQIV/KRn
         bzSAkwY1ziN8cyDP5bLx60shBdc14tr4fW8Nj8Z9HqtslH1QFEGUASZQtyv70/CowR4g
         iyIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWVwBcNnLs1/eauhjTCX3DZV9J6W2LgZ649RQ5C2iP0cvx8cBzo
	MzsBuu5kUhS+/FKmLXJ+jAmFE+SQYDu/6CalOzfVLlSF21u0cbeyapVJIpSYgA7e66EUoTDkbH/
	GzZCHR03PYw+r3L7ZzI7+lpUHhXXiM15vNlyUzH5OVYCvtBGfzZCAjdLHmVkUlf7b3g==
X-Received: by 2002:a63:3d89:: with SMTP id k131mr299710pga.121.1559852139247;
        Thu, 06 Jun 2019 13:15:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnyS2ITahLPu0ZqvFbqFSftDnHjRkzkQGczhakqfzswXIdcDkKfoh7VMyLfC4WHYklMzpU
X-Received: by 2002:a63:3d89:: with SMTP id k131mr299635pga.121.1559852137964;
        Thu, 06 Jun 2019 13:15:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852137; cv=none;
        d=google.com; s=arc-20160816;
        b=zUWx5sKKlX6ULotYRCZE2tqG2CyoFrihk/6nsDjZSoc8OJdfcwA1BYqrZI3ALaqp4Q
         zjNGOh8HByMYuYyO6XYmekOjkotjzt24hAbCEwBKk56WncnQr1eJm+UjjVtfWsOwNS+T
         RQoKtGLgLxBoRXpBv6IDc7sMJ9Dc1ELk1HXd17793mI/B25/RzFbm/YDL7GP7RxWDhji
         YSMewIHD67B6cUNsMHSXULy/Mnnn9kziHN00bI/lMWrmo/4Mm4FIcG6xOiF9ZAUU3HCP
         gGXCry+mwdBctv1er377wJx1SQ+ISR1I8qSnpNWFud5U5fIqAWqfA+jtfDZPnUWVDBQX
         bnAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=T05HjB1dOtC+7biOT8TU+T3c2hChEvbbYH9fK1G4wmY=;
        b=Xkj2UV3GyDCzhoVcBIUlN3llh10kdAqQPYHwqEZhAVMGATgopTCLLYmIJ/5M0YE+c6
         RYZ9l8IL7oNtD7xJ1LEoaKdpyfX4Sw2Ff7iOowovYOHulAmLS3z60qvIlKBAKSeg40PO
         lAkx34REd0e97MOdspDgKzkvfSCiY7voCsNQpdkqgsQftrmz+U+stCchdQneuHEPV3AY
         EYEL7gzHKToU0cotujdyTQSlloUD0sLcJ2oH21dW8FVkpuQwx05SvkZW5aITks46ezly
         exh/Ygj4q7N9x9plPAc2wJzpcY4gKqzNjEFEW/0H/RbAkqmjSuJSXbpOA41wPUxPf8X+
         gxOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:37 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:36 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an ELF file
Date: Thu,  6 Jun 2019 13:06:41 -0700
Message-Id: <20190606200646.3951-23-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

An ELF file's .note.gnu.property indicates features the executable file
can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
GNU_PROPERTY_X86_FEATURE_1_SHSTK.

With this patch, if an arch needs to setup features from ELF properties,
it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
arch_setup_property().

For example, for X86_64:

int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
{
	int r;
	uint32_t property;

	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
			     &property);
	...
}

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 fs/Kconfig.binfmt        |   3 +
 fs/Makefile              |   1 +
 fs/binfmt_elf.c          |  13 ++
 fs/gnu_property.c        | 351 +++++++++++++++++++++++++++++++++++++++
 include/linux/elf.h      |  12 ++
 include/uapi/linux/elf.h |  14 ++
 6 files changed, 394 insertions(+)
 create mode 100644 fs/gnu_property.c

diff --git a/fs/Kconfig.binfmt b/fs/Kconfig.binfmt
index f87ddd1b6d72..397138ab305b 100644
--- a/fs/Kconfig.binfmt
+++ b/fs/Kconfig.binfmt
@@ -36,6 +36,9 @@ config COMPAT_BINFMT_ELF
 config ARCH_BINFMT_ELF_STATE
 	bool
 
+config ARCH_USE_GNU_PROPERTY
+	bool
+
 config BINFMT_ELF_FDPIC
 	bool "Kernel support for FDPIC ELF binaries"
 	default y if !BINFMT_ELF
diff --git a/fs/Makefile b/fs/Makefile
index c9aea23aba56..b69f18c14e09 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -44,6 +44,7 @@ obj-$(CONFIG_BINFMT_ELF)	+= binfmt_elf.o
 obj-$(CONFIG_COMPAT_BINFMT_ELF)	+= compat_binfmt_elf.o
 obj-$(CONFIG_BINFMT_ELF_FDPIC)	+= binfmt_elf_fdpic.o
 obj-$(CONFIG_BINFMT_FLAT)	+= binfmt_flat.o
+obj-$(CONFIG_ARCH_USE_GNU_PROPERTY) += gnu_property.o
 
 obj-$(CONFIG_FS_MBCACHE)	+= mbcache.o
 obj-$(CONFIG_FS_POSIX_ACL)	+= posix_acl.o
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 8264b468f283..c3ea73787e93 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1080,6 +1080,19 @@ static int load_elf_binary(struct linux_binprm *bprm)
 		goto out_free_dentry;
 	}
 
+	if (interpreter) {
+		retval = arch_setup_property(&loc->interp_elf_ex,
+					     interp_elf_phdata,
+					     interpreter, true);
+	} else {
+		retval = arch_setup_property(&loc->elf_ex,
+					     elf_phdata,
+					     bprm->file, false);
+	}
+
+	if (retval < 0)
+		goto out_free_dentry;
+
 	if (interpreter) {
 		unsigned long interp_map_addr = 0;
 
diff --git a/fs/gnu_property.c b/fs/gnu_property.c
new file mode 100644
index 000000000000..9c4d1d5ebf00
--- /dev/null
+++ b/fs/gnu_property.c
@@ -0,0 +1,351 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+/*
+ * Extract an ELF file's .note.gnu.property.
+ *
+ * The path from the ELF header to the note section is the following:
+ * elfhdr->elf_phdr->elf_note->property[].
+ */
+
+#include <uapi/linux/elf-em.h>
+#include <linux/processor.h>
+#include <linux/binfmts.h>
+#include <linux/elf.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/string.h>
+#include <linux/compat.h>
+
+/*
+ * The .note.gnu.property layout:
+ *
+ *	struct elf_note {
+ *		u32 n_namesz; --> sizeof(n_name[]); always (4)
+ *		u32 n_ndescsz;--> sizeof(property[])
+ *		u32 n_type;   --> always NT_GNU_PROPERTY_TYPE_0
+ *	};
+ *	char n_name[4]; --> always 'GNU\0'
+ *
+ *	struct {
+ *		struct gnu_property {
+ *			u32 pr_type;
+ *			u32 pr_datasz;
+ *		};
+ *		u8 pr_data[pr_datasz];
+ *	}[];
+ */
+
+#define BUF_SIZE (PAGE_SIZE / 4)
+
+typedef bool (test_item_fn)(void *buf, u32 *arg, u32 type);
+typedef void *(next_item_fn)(void *buf, u32 *arg, u32 type);
+
+static inline bool test_note_type(void *buf, u32 *align, u32 note_type)
+{
+	struct elf_note *n = buf;
+
+	return ((n->n_type == note_type) && (n->n_namesz == 4) &&
+		(memcmp(n + 1, "GNU", 4) == 0));
+}
+
+static inline void *next_note(void *buf, u32 *align, u32 note_type)
+{
+	struct elf_note *n = buf;
+	u64 size;
+
+	if (check_add_overflow((u64)sizeof(*n), (u64)n->n_namesz, &size))
+		return NULL;
+
+	size = round_up(size, *align);
+
+	if (check_add_overflow(size, (u64)n->n_descsz, &size))
+		return NULL;
+
+	size = round_up(size, *align);
+
+	if (buf + size < buf)
+		return NULL;
+	else
+		return (buf + size);
+}
+
+static inline bool test_property(void *buf, u32 *max_type, u32 pr_type)
+{
+	struct gnu_property *pr = buf;
+
+	/*
+	 * Property types must be in ascending order.
+	 * Keep track of the max when testing each.
+	 */
+	if (pr->pr_type > *max_type)
+		*max_type = pr->pr_type;
+
+	return (pr->pr_type == pr_type);
+}
+
+static inline void *next_property(void *buf, u32 *max_type, u32 pr_type)
+{
+	struct gnu_property *pr = buf;
+
+	if ((buf + sizeof(*pr) +  pr->pr_datasz < buf) ||
+	    (pr->pr_type > pr_type) ||
+	    (pr->pr_type > *max_type))
+		return NULL;
+	else
+		return (buf + sizeof(*pr) + pr->pr_datasz);
+}
+
+/*
+ * Scan 'buf' for a pattern; return true if found.
+ * *pos is the distance from the beginning of buf to where
+ * the searched item or the next item is located.
+ */
+static int scan(u8 *buf, u32 buf_size, int item_size, test_item_fn test_item,
+		next_item_fn next_item, u32 *arg, u32 type, u32 *pos)
+{
+	int found = 0;
+	u8 *p, *max;
+
+	max = buf + buf_size;
+	if (max < buf)
+		return 0;
+
+	p = buf;
+
+	while ((p + item_size < max) && (p + item_size > buf)) {
+		if (test_item(p, arg, type)) {
+			found = 1;
+			break;
+		}
+
+		p = next_item(p, arg, type);
+	}
+
+	*pos = (p + item_size <= buf) ? 0 : (u32)(p - buf);
+	return found;
+}
+
+/*
+ * Search an NT_GNU_PROPERTY_TYPE_0 for the property of 'pr_type'.
+ */
+static int find_property(struct file *file, unsigned long desc_size,
+			 loff_t file_offset, u8 *buf,
+			 u32 pr_type, u32 *property)
+{
+	u32 buf_pos;
+	unsigned long read_size;
+	unsigned long done;
+	int found = 0;
+	int ret = 0;
+	u32 last_pr = 0;
+
+	*property = 0;
+	buf_pos = 0;
+
+	for (done = 0; done < desc_size; done += buf_pos) {
+		read_size = desc_size - done;
+		if (read_size > BUF_SIZE)
+			read_size = BUF_SIZE;
+
+		ret = kernel_read(file, buf, read_size, &file_offset);
+
+		if (ret != read_size)
+			return (ret < 0) ? ret : -EIO;
+
+		ret = 0;
+		found = scan(buf, read_size, sizeof(struct gnu_property),
+			     test_property, next_property,
+			     &last_pr, pr_type, &buf_pos);
+
+		if ((!buf_pos) || found)
+			break;
+
+		file_offset += buf_pos - read_size;
+	}
+
+	if (found) {
+		struct gnu_property *pr =
+			(struct gnu_property *)(buf + buf_pos);
+
+		if (pr->pr_datasz == 4) {
+			u32 *max =  (u32 *)(buf + read_size);
+			u32 *data = (u32 *)((u8 *)pr + sizeof(*pr));
+
+			if (data + 1 <= max) {
+				*property = *data;
+			} else {
+				file_offset += buf_pos - read_size;
+				file_offset += sizeof(*pr);
+				ret = kernel_read(file, property, 4,
+						  &file_offset);
+			}
+		}
+	}
+
+	return ret;
+}
+
+/*
+ * Search a PT_NOTE segment for NT_GNU_PROPERTY_TYPE_0.
+ */
+static int find_note_type_0(struct file *file, loff_t file_offset,
+			    unsigned long note_size, u32 align,
+			    u32 pr_type, u32 *property)
+{
+	u8 *buf;
+	u32 buf_pos;
+	unsigned long read_size;
+	unsigned long done;
+	int found = 0;
+	int ret = 0;
+
+	buf = kmalloc(BUF_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	*property = 0;
+	buf_pos = 0;
+
+	for (done = 0; done < note_size; done += buf_pos) {
+		read_size = note_size - done;
+		if (read_size > BUF_SIZE)
+			read_size = BUF_SIZE;
+
+		ret = kernel_read(file, buf, read_size, &file_offset);
+
+		if (ret != read_size) {
+			ret = (ret < 0) ? ret : -EIO;
+			kfree(buf);
+			return ret;
+		}
+
+		/*
+		 * item_size = sizeof(struct elf_note) + elf_note.n_namesz.
+		 * n_namesz is 4 for the note type we look for.
+		 */
+		ret = scan(buf, read_size, sizeof(struct elf_note) + 4,
+			      test_note_type, next_note,
+			      &align, NT_GNU_PROPERTY_TYPE_0, &buf_pos);
+
+		file_offset += buf_pos - read_size;
+
+		if (ret && !found) {
+			struct elf_note *n =
+				(struct elf_note *)(buf + buf_pos);
+			u64 start = round_up(sizeof(*n) + n->n_namesz, align);
+			u64 total = 0;
+
+			if (check_add_overflow(start, (u64)n->n_descsz, &total)) {
+				ret = -EINVAL;
+				break;
+			}
+			total = round_up(total, align);
+
+			ret = find_property(file, n->n_descsz,
+					    file_offset + start,
+					    buf, pr_type, property);
+			found++;
+			file_offset += total;
+			buf_pos += total;
+		} else if (!buf_pos || ret) {
+			ret = 0;
+			*property = 0;
+			break;
+		}
+	}
+
+	kfree(buf);
+	return ret;
+}
+
+/*
+ * Look at an ELF file's PT_NOTE segments, then NT_GNU_PROPERTY_TYPE_0, then
+ * the property of pr_type.
+ *
+ * Input:
+ *	file: the file to search;
+ *	phdr: the file's elf header;
+ *	phnum: number of entries in phdr;
+ *	pr_type: the property type.
+ *
+ * Output:
+ *	The property found.
+ *
+ * Return:
+ *	Zero or error.
+ */
+static int scan_segments_64(struct file *file, struct elf64_phdr *phdr,
+			    int phnum, u32 pr_type, u32 *property)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0; i < phnum; i++, phdr++) {
+		if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 8))
+			continue;
+
+		/*
+		 * Search the PT_NOTE segment for NT_GNU_PROPERTY_TYPE_0.
+		 */
+		err = find_note_type_0(file, phdr->p_offset, phdr->p_filesz,
+				       phdr->p_align, pr_type, property);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int scan_segments_32(struct file *file, struct elf32_phdr *phdr,
+			    int phnum, u32 pr_type, u32 *property)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0; i < phnum; i++, phdr++) {
+		if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 4))
+			continue;
+
+		/*
+		 * Search the PT_NOTE segment for NT_GNU_PROPERTY_TYPE_0.
+		 */
+		err = find_note_type_0(file, phdr->p_offset, phdr->p_filesz,
+				       phdr->p_align, pr_type, property);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
+		     u32 pr_type, u32 *property)
+{
+	struct elf64_hdr *ehdr64 = ehdr_p;
+	int err = 0;
+
+	*property = 0;
+
+	if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
+		struct elf64_phdr *phdr64 = phdr_p;
+
+		err = scan_segments_64(f, phdr64, ehdr64->e_phnum,
+				       pr_type, property);
+		if (err < 0)
+			goto out;
+	} else {
+		struct elf32_hdr *ehdr32 = ehdr_p;
+
+		if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
+			struct elf32_phdr *phdr32 = phdr_p;
+
+			err = scan_segments_32(f, phdr32, ehdr32->e_phnum,
+					       pr_type, property);
+			if (err < 0)
+				goto out;
+		}
+	}
+
+out:
+	return err;
+}
diff --git a/include/linux/elf.h b/include/linux/elf.h
index e3649b3e970e..c15febebe7f2 100644
--- a/include/linux/elf.h
+++ b/include/linux/elf.h
@@ -56,4 +56,16 @@ static inline int elf_coredump_extra_notes_write(struct coredump_params *cprm) {
 extern int elf_coredump_extra_notes_size(void);
 extern int elf_coredump_extra_notes_write(struct coredump_params *cprm);
 #endif
+
+#ifdef CONFIG_ARCH_USE_GNU_PROPERTY
+extern int arch_setup_property(void *ehdr, void *phdr, struct file *f,
+			       bool interp);
+extern int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
+			    u32 pr_type, u32 *feature);
+#else
+static inline int arch_setup_property(void *ehdr, void *phdr, struct file *f,
+				      bool interp) { return 0; }
+static inline int get_gnu_property(void *ehdr_p, void *phdr_p, struct file *f,
+				   u32 pr_type, u32 *feature) { return 0; }
+#endif
 #endif /* _LINUX_ELF_H */
diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
index 34c02e4290fe..316177ce9e76 100644
--- a/include/uapi/linux/elf.h
+++ b/include/uapi/linux/elf.h
@@ -372,6 +372,7 @@ typedef struct elf64_shdr {
 #define NT_PRFPREG	2
 #define NT_PRPSINFO	3
 #define NT_TASKSTRUCT	4
+#define NT_GNU_PROPERTY_TYPE_0 5
 #define NT_AUXV		6
 /*
  * Note to userspace developers: size of NT_SIGINFO note may increase
@@ -443,4 +444,17 @@ typedef struct elf64_note {
   Elf64_Word n_type;	/* Content type */
 } Elf64_Nhdr;
 
+/* NT_GNU_PROPERTY_TYPE_0 header */
+struct gnu_property {
+  __u32 pr_type;
+  __u32 pr_datasz;
+};
+
+/* .note.gnu.property types */
+#define GNU_PROPERTY_X86_FEATURE_1_AND		(0xc0000002)
+
+/* Bits of GNU_PROPERTY_X86_FEATURE_1_AND */
+#define GNU_PROPERTY_X86_FEATURE_1_IBT		(0x00000001)
+#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
+
 #endif /* _UAPI_LINUX_ELF_H */
-- 
2.17.1

