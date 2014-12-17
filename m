Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3CAA16B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 17:30:13 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id h15so9614543igd.2
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 14:30:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bg1si4494707icb.41.2014.12.17.14.30.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 14:30:12 -0800 (PST)
Date: Wed, 17 Dec 2014 14:30:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
Message-Id: <20141217143010.ccf73cbd544ade86bb4dec3f@linux-foundation.org>
In-Reply-To: <1418663733-15949-1-git-send-email-petrcermak@chromium.org>
References: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
	<1418663733-15949-1-git-send-email-petrcermak@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Cermak <petrcermak@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bjorn Helgaas <bhelgaas@google.com>, Primiano Tucci <primiano@chromium.org>

On Mon, 15 Dec 2014 17:15:33 +0000 Petr Cermak <petrcermak@chromium.org> wrote:

> Peak resident size of a process can be reset by writing "5" to
> /proc/pid/clear_refs. The driving use-case for this would be getting the
> peak RSS value, which can be retrieved from the VmHWM field in
> /proc/pid/status, per benchmark iteration or test scenario.

The term "reset" is ambiguous - it often means "reset it to zero".

This?

--- a/Documentation/filesystems/proc.txt~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss-fix
+++ a/Documentation/filesystems/proc.txt
@@ -488,7 +488,8 @@ To clear the bits for the file mapped pa
 To clear the soft-dirty bit
     > echo 4 > /proc/PID/clear_refs
 
-To reset the peak resident set size ("high water mark")
+To reset the peak resident set size ("high water mark") to the process's
+current value:
     > echo 5 > /proc/PID/clear_refs
 
 Any other value written to /proc/PID/clear_refs will have no effect.
--- a/fs/proc/task_mmu.c~task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss-fix
+++ a/fs/proc/task_mmu.c
@@ -859,7 +859,7 @@ static ssize_t clear_refs_write(struct f
 	if (type == CLEAR_REFS_MM_HIWATER_RSS) {
 		/*
 		 * Writing 5 to /proc/pid/clear_refs resets the peak resident
-		 * set size.
+		 * set size to this mm's current rss value.
 		 */
 		down_write(&mm->mmap_sem);
 		reset_mm_hiwater_rss(mm);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
