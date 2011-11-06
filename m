Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B74D6B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 16:48:35 -0500 (EST)
Message-ID: <4EB700B1.3050205@cfl.rr.com>
Date: Sun, 06 Nov 2011 16:48:33 -0500
From: Phillip Susi <psusi@cfl.rr.com>
MIME-Version: 1.0
Subject: write_cache_pages inefficiency
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I've read over write_cache_pages() in page-writeback.c, and related
writepages() functions, and it seems to me that it suffers from a
performance problem whenever an fsync is done on a file and some of
its pages have already begun writeback.  The comment in the code says:

 * If a page is already under I/O, write_cache_pages() skips it, even
 * if it's dirty.  This is desirable behaviour for memory-cleaning
writeback,
 * but it is INCORRECT for data-integrity system calls such as
fsync().  fsync()
 * and msync() need to guarantee that all the data which was dirty at
the time
 * the call was made get new I/O started against them.  If
wbc->sync_mode is
 * WB_SYNC_ALL then we were called for data integrity and we must wait for
 * existing IO to complete.

Based on this, I would expect the function to wait for an existing
write to complete only if the page is also dirty.  Instead, it waits
for existing page writes to complete regardless of the dirty bit.
Additionally, it does each wait serially, so if you are trying to
fsync 1000 dirty pages, and the first 10 are already being written
out, the thread will block on each of those 10 pages write completion
before it begins queuing any new writes.

Instead, shouldn't it go ahead and initiate pagewrite on all pages not
already being written, and then come back and wait on those that were
already in flight to complete, then initiate a second write on them if
they are dirty?
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk63ALEACgkQJ4UciIs+XuL/NgCfXBftM2PRN10u0i3DBG94hny6
dVoAoKbQp3yiY6ZotjbqHyd+kOEXiLgf
=dK4Q
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
