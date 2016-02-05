Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 13DBE4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 08:51:20 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id 128so71497086wmz.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 05:51:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b201si26971931wmf.117.2016.02.05.05.51.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 05 Feb 2016 05:51:18 -0800 (PST)
Date: Fri, 5 Feb 2016 14:51:16 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH v2] floppy: refactor open() flags handling (was Re: mm:
 uninterruptable tasks hanged on mmap_sem)
In-Reply-To: <CACT4Y+aBCt_pVK+SY9fRpRFU9KTVOChn_vs5pv_KFiUbkGCm4Q@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1602051445520.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com> <alpine.LNX.2.00.1602042219460.22727@cbobk.fhfr.pm> <CACT4Y+aBCt_pVK+SY9fRpRFU9KTVOChn_vs5pv_KFiUbkGCm4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, 5 Feb 2016, Dmitry Vyukov wrote:

> > could you please feed the patch below (on top of the previous floppy fix)
> > to your syzkaller machinery and test whether you are still able to
> > reproduce the problem? It passess my local testing here.
> 
> Now that open exits early with EWOULDBLOCK, I guess the reproduced is
> not doing anything particularly interesting. 

Yeah. But as I explained in the changelog, I think it's a valid thing to 
do (opinions welcome).

I don't think having a huge discussion about what nonblocking really means 
for floppy and then try to refactor the whole driver to support that would 
make sense.

Alternatively we can take more conservative aproach, accept the 
nonblocking flag, but do the regular business of the driver.

Actually, let's try that, to make sure that we don't introduce userspace 
breakage.

Could you please retest with the patch below?

Thanks a lot.



From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH v2] floppy: refactor open() flags handling

In case /dev/fdX is open with O_NDELAY / O_NONBLOCK, floppy_open() immediately
succeeds, without performing any further media / controller preparations.
That's "correct" wrt. the NODELAY flag, but is hardly correct wrt. the rest
of the floppy driver, that is not really O_NONBLOCK ready, at all. Therefore
it's not too surprising, that subsequent attempts to work with the
filedescriptor produce bad results. Namely, syzkaller tool has been able
to livelock mmap() on the returned fd to keep waiting on the page unlock
bit forever.

Quite frankly, I have trouble defining what non-blocking behavior would be for
floppies. Is waiting ages for the driver to actually succeed reading a sector
blocking operation? Is waiting for drive motor to start blocking operation? How
about in case of virtualized floppies?

One option would be returning EWOULDBLOCK in case O_NDLEAY / O_NONBLOCK is
being passed to open(). That has a theoretical potential of breaking some
arcane and archaic userspace though.

Let's take a more conservative aproach, and accept the O_NDLEAY flag, and let
the driver behave as usual.

While at it, clean up a bit handling of !(mode & (FMODE_READ|FMODE_WRITE))
case and return EINVAL instead of succeeding as well.

Spotted by syzkaller tool.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
NOT-YET-Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 drivers/block/floppy.c | 34 +++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index d15d415..f7d4d7b 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -3662,6 +3662,11 @@ static int floppy_open(struct block_device *bdev, fmode_t mode)
 
 	opened_bdev[drive] = bdev;
 
+	if (!(mode & (FMODE_READ|FMODE_WRITE))) {
+		res = -EINVAL;
+		goto out;
+	}
+
 	res = -ENXIO;
 
 	if (!floppy_track_buffer) {
@@ -3705,21 +3710,20 @@ static int floppy_open(struct block_device *bdev, fmode_t mode)
 	if (UFDCS->rawcmd == 1)
 		UFDCS->rawcmd = 2;
 
-	if (!(mode & FMODE_NDELAY)) {
-		if (mode & (FMODE_READ|FMODE_WRITE)) {
-			UDRS->last_checked = 0;
-			clear_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags);
-			check_disk_change(bdev);
-			if (test_bit(FD_DISK_CHANGED_BIT, &UDRS->flags))
-				goto out;
-			if (test_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags))
-				goto out;
-		}
-		res = -EROFS;
-		if ((mode & FMODE_WRITE) &&
-		    !test_bit(FD_DISK_WRITABLE_BIT, &UDRS->flags))
-			goto out;
-	}
+	UDRS->last_checked = 0;
+	clear_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags);
+	check_disk_change(bdev);
+	if (test_bit(FD_DISK_CHANGED_BIT, &UDRS->flags))
+		goto out;
+	if (test_bit(FD_OPEN_SHOULD_FAIL_BIT, &UDRS->flags))
+		goto out;
+
+	res = -EROFS;
+
+	if ((mode & FMODE_WRITE) &&
+			!test_bit(FD_DISK_WRITABLE_BIT, &UDRS->flags))
+		goto out;
+
 	mutex_unlock(&open_lock);
 	mutex_unlock(&floppy_mutex);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
