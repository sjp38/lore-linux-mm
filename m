Date: Wed, 30 Apr 2003 17:04:46 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.68-mm3
Message-Id: <20030430170446.6fe9b804.akpm@digeo.com>
In-Reply-To: <200304301957.58729.tomlins@cam.org>
References: <20030429235959.3064d579.akpm@digeo.com>
	<200304301957.58729.tomlins@cam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> wrote:
>
> On April 30, 2003 02:59 am, Andrew Morton wrote:
> > Bits and pieces.  Nothing major, apart from the dynamic request allocation
> > patch.  This arbitrarily increases the maximum requests/queue to 1024, and
> > could well make large (and usually bad) changes to various benchmarks.
> > However some will be helped.
> 
> Here is something a little broken.  Suspect it might be in 68-bk too:
> 
> if [ -r System.map ]; then /sbin/depmod -ae -F System.map  2.5.68-mm3; fi
> WARNING: /lib/modules/2.5.68-mm3/kernel/sound/oss/cs46xx.ko needs unknown symbol cs4x_ClearPageReserved
> 

Yes, thanks.  It's a case of search-n-replace-n-dont-test.


diff -puN sound/oss/cs46xx.c~cs46xx-PageReserved-fix sound/oss/cs46xx.c
--- 25/sound/oss/cs46xx.c~cs46xx-PageReserved-fix	Wed Apr 30 17:03:41 2003
+++ 25-akpm/sound/oss/cs46xx.c	Wed Apr 30 17:03:48 2003
@@ -1247,7 +1247,7 @@ static void dealloc_dmabuf(struct cs_sta
 		mapend = virt_to_page(dmabuf->rawbuf + 
 				(PAGE_SIZE << dmabuf->buforder) - 1);
 		for (map = virt_to_page(dmabuf->rawbuf); map <= mapend; map++)
-			cs4x_ClearPageReserved(map);
+			ClearPageReserved(map);
 		free_dmabuf(state->card, dmabuf);
 	}
 
@@ -1256,7 +1256,7 @@ static void dealloc_dmabuf(struct cs_sta
 		mapend = virt_to_page(dmabuf->tmpbuff +
 				(PAGE_SIZE << dmabuf->buforder_tmpbuff) - 1);
 		for (map = virt_to_page(dmabuf->tmpbuff); map <= mapend; map++)
-			cs4x_ClearPageReserved(map);
+			ClearPageReserved(map);
 		free_dmabuf2(state->card, dmabuf);
 	}
 

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
