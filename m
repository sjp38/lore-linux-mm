Date: Tue, 10 Jun 2008 11:37:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.26-rc5-mm2  compile error in vmscan.c
Message-Id: <20080610113733.8d924c0e.akpm@linux-foundation.org>
In-Reply-To: <484E6A68.4060203@aitel.hist.no>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<484E6A68.4060203@aitel.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helge.hafting@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 13:50:00 +0200 Helge Hafting <helge.hafting@aitel.hist.no> wrote:

> Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm2/
> > 
> > - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
> >   vmscan.c bug which would have prevented testing of the other vmscan.c
> >   bugs^Wchanges.
> > 
> 
> Interesting to try out, but I got this:
> 
>   $ make
>    CHK     include/linux/version.h
>    CHK     include/linux/utsrelease.h
>    CALL    scripts/checksyscalls.sh
>    CHK     include/linux/compile.h
>    CC      mm/vmscan.o
> mm/vmscan.c: In function 'show_page_path':
> mm/vmscan.c:2419: error: 'struct mm_struct' has no member named 'owner'
> make[1]: *** [mm/vmscan.o] Error 1
> make: *** [mm] Error 2
> 
> 
> I then tried to configure with "Track page owner", but that did not 
> change anything.
> 

Thanks.  I guess this will get you going.

--- a/mm/vmscan.c~mm-only-vmscan-noreclaim-lru-scan-sysctl-fix
+++ a/mm/vmscan.c
@@ -2400,6 +2400,7 @@ static void show_page_path(struct page *
 		       dentry_path(dentry, buf, 256), pgoff);
 		spin_unlock(&mapping->i_mmap_lock);
 	} else {
+#ifdef CONFG_MM_OWNER
 		struct anon_vma *anon_vma;
 		struct vm_area_struct *vma;
 
@@ -2413,6 +2414,7 @@ static void show_page_path(struct page *
 			break;
 		}
 		page_unlock_anon_vma(anon_vma);
+#endif
 	}
 }
 
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
