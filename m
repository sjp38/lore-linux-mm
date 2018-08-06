Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id F24A26B0271
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 12:41:06 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 40-v6so11111356wrb.23
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 09:41:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 125-v6sor1642202wmk.50.2018.08.06.09.41.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 09:41:05 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v5 08/10] usb, arm64: untag user addresses in devio
Date: Mon,  6 Aug 2018 18:40:43 +0200
Message-Id: <39bbae2c9d880bd3c27ac3ee03d4be72e161491c.1533573460.git.andreyknvl@google.com>
In-Reply-To: <cover.1533573460.git.andreyknvl@google.com>
References: <cover.1533573460.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

devio allows to mmap memory regions and keeps them in a list. It also
accepts a user address through an ioctl call and searches the memory
region list for the region that contains this address. Since the addresses
provided to mmap must not be tagged, and the addresses provided to ioctl
might be tagged, we might compare tagged and untagged addresses during the
search.

Untag the provided addresses before searching.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/usb/core/devio.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
index 476dcc5f2da3..357c2e7b87b8 100644
--- a/drivers/usb/core/devio.c
+++ b/drivers/usb/core/devio.c
@@ -1404,7 +1404,7 @@ find_memory_area(struct usb_dev_state *ps, const struct usbdevfs_urb *uurb)
 {
 	struct usb_memory *usbm = NULL, *iter;
 	unsigned long flags;
-	unsigned long uurb_start = (unsigned long)uurb->buffer;
+	unsigned long uurb_start = (unsigned long)untagged_addr(uurb->buffer);
 
 	spin_lock_irqsave(&ps->lock, flags);
 	list_for_each_entry(iter, &ps->memory_list, memlist) {
@@ -1633,7 +1633,8 @@ static int proc_do_submiturb(struct usb_dev_state *ps, struct usbdevfs_urb *uurb
 		}
 	} else if (uurb->buffer_length > 0) {
 		if (as->usbm) {
-			unsigned long uurb_start = (unsigned long)uurb->buffer;
+			unsigned long uurb_start =
+				(unsigned long)untagged_addr(uurb->buffer);
 
 			as->urb->transfer_buffer = as->usbm->mem +
 					(uurb_start - as->usbm->vm_start);
@@ -1712,7 +1713,8 @@ static int proc_do_submiturb(struct usb_dev_state *ps, struct usbdevfs_urb *uurb
 	as->ps = ps;
 	as->userurb = arg;
 	if (as->usbm) {
-		unsigned long uurb_start = (unsigned long)uurb->buffer;
+		unsigned long uurb_start =
+			(unsigned long)untagged_addr(uurb->buffer);
 
 		as->urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
 		as->urb->transfer_dma = as->usbm->dma_handle +
-- 
2.18.0.597.ga71716f1ad-goog
