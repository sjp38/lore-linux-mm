Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id D977A440434
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 09:02:06 -0500 (EST)
Received: by mail-lf0-f52.google.com with SMTP id l143so36652406lfe.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:02:06 -0800 (PST)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id n2si7199045lfd.209.2016.02.04.06.02.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 06:02:05 -0800 (PST)
Received: by mail-lb0-x234.google.com with SMTP id cw1so31608209lbb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 06:02:05 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [PATCH] dax: dirty inode only if required
In-Reply-To: 1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com
Date: Thu, 04 Feb 2016 17:02:02 +0300
Message-ID: <87k2mkr2ud.fsf@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>


Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
---
 fs/dax.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index e0e9358..fc2e314 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -358,7 +358,8 @@ static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
 	void *entry;
 
 	WARN_ON_ONCE(pmd_entry && !dirty);
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+	if (dirty)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
 	spin_lock_irq(&mapping->tree_lock);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
