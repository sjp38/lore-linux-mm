Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 04CE6831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 15:00:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x64so40331965pgd.6
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:00:57 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id 74si6176613pgd.238.2017.05.18.12.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 12:00:56 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id u187so26936575pgb.0
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:00:56 -0700 (PDT)
From: Junaid Shahid <junaids@google.com>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
Date: Thu, 18 May 2017 12:00:51 -0700
Message-ID: <3231054.TTUGOL1l3r@js-desktop.svl.corp.google.com>
In-Reply-To: <20170518185040.108293-1-junaids@google.com>
References: <20170518185040.108293-1-junaids@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, mpatocka@redhat.com, rientjes@google.com, mhocko@suse.com, vbabka@suse.cz

(Correcting linux-mm email addr)

d224e9381897 (drivers/md/dm-ioctl.c: use kvmalloc rather than opencoded
variant) left out the __GFP_HIGH flag when converting from __vmalloc to
kvmalloc. This can cause the IOCTL to fail in some low memory situations
where it wouldn't have failed earlier. This patch adds it back to avoid
any potential regression.

Signed-off-by: Junaid Shahid <junaids@google.com>
---
 drivers/md/dm-ioctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index 0555b4410e05..bacad7637a56 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1715,7 +1715,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
 	 */
 	dmi = NULL;
 	noio_flag = memalloc_noio_save();
-	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL);
+	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL | __GFP_HIGH);
 	memalloc_noio_restore(noio_flag);
 
 	if (!dmi) {
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
