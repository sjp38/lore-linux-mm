Date: Mon, 14 Apr 2003 21:39:47 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm3
Message-ID: <20030415043947.GD706@holomorphy.com>
References: <20030414015313.4f6333ad.akpm@digeo.com> <20030415020057.GC706@holomorphy.com> <20030415041759.GA12487@holomorphy.com> <20030414213114.37dc7879.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030414213114.37dc7879.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>> +	for (; addr < (unsigned long)uaddr + size && !ret; addr += PAGE_SIZE)
>> +		ret = __put_user(0, (char *)max(addr, (unsigned long)uaddr));

On Mon, Apr 14, 2003 at 09:31:14PM -0700, Andrew Morton wrote:
> This hurts my brain.  If anything, it should be formulated as a do-while loop.
> But I'm not sure we should really bother, because relatively large amounts of
> stuff is broken for PAGE_SIZE != PAGE_CACHE_SIZE anyway.  tmpfs comes to
> mind...
> If page clustering needs to redo this code (and I assume it does) then that
> would be an argument in favour.

Page clustering wants something similar but slightly different. The
unit it wants as its stride (MMUPAGE_SIZE) isn't present so this doesn't
really help or hurt it. I believe I actually dodged this bullet by
ensuring (or incorrectly assuming) the callers used sizes <= MMUPAGE_SIZE
and left it either unaltered and suboptimal or (worst-case) buggy.

I'm just going down the list of FIXME's in the VM I turned up by grepping.
Should we do the following instead?


-- wli


diff -urpN mm3-2.5.67-2/include/linux/pagemap.h mm3-2.5.67-2A/include/linux/pagemap.h
--- mm3-2.5.67-2/include/linux/pagemap.h	2003-04-07 10:30:34.000000000 -0700
+++ mm3-2.5.67-2A/include/linux/pagemap.h	2003-04-14 21:24:52.000000000 -0700
@@ -169,7 +169,7 @@ extern void end_page_writeback(struct pa
 /*
  * Fault a userspace page into pagetables.  Return non-zero on a fault.
  *
- * FIXME: this assumes that two userspace pages are always sufficient.  That's
+ * This assumes that two userspace pages are always sufficient.  That's
  * not true if PAGE_CACHE_SIZE > PAGE_SIZE.
  */
 static inline int fault_in_pages_writeable(char *uaddr, int size)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
