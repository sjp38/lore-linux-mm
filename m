Date: Thu, 5 Apr 2007 05:45:04 -0400
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: missing madvise functionality
Message-ID: <20070405094504.GM355@devserv.devel.redhat.com>
Reply-To: Jakub Jelinek <jakub@redhat.com>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <4614A5CC.5080508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4614A5CC.5080508@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 05, 2007 at 03:31:24AM -0400, Rik van Riel wrote:
> >My guess is that all the page zeroing is pretty expensive as well and
> >takes significant time, but I haven't profiled it.
> 
> With the attached patch (Andrew, I'll change the details around
> if you want - I just wanted something to test now), your test
> case run time went down considerably.

Thanks.

--- linux-2.6.20.noarch/mm/madvise.c.madvise	2007-04-03 21:53:47.000000000 -0400
+++ linux-2.6.20.noarch/mm/madvise.c	2007-04-04 23:48:34.000000000 -0400
@@ -142,8 +142,12 @@ static long madvise_dontneed(struct vm_a
 			.last_index = ULONG_MAX,
 		};
 		zap_page_range(vma, start, end - start, &details);
-	} else
-		zap_page_range(vma, start, end - start, NULL);
+	} else {
+		struct zap_details details = {
+			.madv_free = 1,
+		};
+		zap_page_range(vma, start, end - start, &details);
+	}
 	return 0;
 }
 
@@ -209,7 +213,9 @@ madvise_vma(struct vm_area_struct *vma, 
 		error = madvise_willneed(vma, prev, start, end);
 		break;
 
+	/* FIXME: POSIX says that MADV_DONTNEED cannot throw away data. */
 	case MADV_DONTNEED:
+	case MADV_FREE:
 		error = madvise_dontneed(vma, prev, start, end);
 		break;
 
I think you should only use the new behavior for madvise MADV_FREE, not for
MADV_DONTNEED.  The current MADV_DONTNEED behavior (which conflicts with
POSIX POSIX_MADV_DONTNEED, but that doesn't matter since what glibc
maps posix_madvise POSIX_MADV_DONTNEED in madvise call if anything doesn't
have to be MADV_DONTNEED, but can be anything else) is apparently documented
in Linux man pages:
       MADV_DONTNEED
              Do not expect access in the near future.  (For the time being, the application is finished with  the
              given  range, so the kernel can free resources associated with it.)  Subsequent accesses of pages in
              this range will succeed, but will result either in re-loading of the memory contents from the under-
              lying mapped file (see mmap()) or zero-fill-on-demand pages for mappings without an underlying file.
so it wouldn't surprise me if something relied on zero filling.
So IMHO madv_free in details should be only set if MADV_FREE.

Also, I think MADV_FREE shouldn't do anything at all (i.e. don't call
zap_page_range, but don't fail either) for shared or file backed vmas,
only for private anon memory it should do something.  After all, it
is just an optimization and it makes sense only for private anon mappings.

	Jakub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
