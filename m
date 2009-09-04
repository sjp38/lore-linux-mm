Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DD1486B008A
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 15:27:57 -0400 (EDT)
Subject: [PATCH 4/4] pci: Remove bogus check of proc dir entry usage.
References: <m1fxb2wm0z.fsf@fess.ebiederm.org>
	<m1bplqwlzr.fsf@fess.ebiederm.org>
	<m17hwewlxr.fsf_-_@fess.ebiederm.org>
	<m13a72wlwm.fsf_-_@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 04 Sep 2009 12:28:03 -0700
In-Reply-To: <m13a72wlwm.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 04 Sep 2009 12\:27\:21 -0700")
Message-ID: <m1ws4ev7b0.fsf_-_@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


This check prevents /proc/bus/pci/*/* from being removed when
pci devices are hot unpluged and someone happens to have it open.
This is not a problem because proc handles this case properly.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/pci/proc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/pci/proc.c b/drivers/pci/proc.c
index 593bb84..afd2a6a 100644
--- a/drivers/pci/proc.c
+++ b/drivers/pci/proc.c
@@ -430,8 +430,6 @@ int pci_proc_detach_device(struct pci_dev *dev)
 	struct proc_dir_entry *e;
 
 	if ((e = dev->procent)) {
-		if (atomic_read(&e->count) > 1)
-			return -EBUSY;
 		remove_proc_entry(e->name, dev->bus->procdir);
 		dev->procent = NULL;
 	}
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
