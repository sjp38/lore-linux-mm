Content-Disposition: inline
From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Fwd: [2.6.15-rc1+ regression] do_file_page bug introduced in recent rework
Date: Sat, 3 Dec 2005 04:44:12 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200512030444.12359.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Fwd'ing because sent to the wrong linux-mm address.

----------  Forwarded Message  ----------

Subject: [2.6.15-rc1+ regression] do_file_page bug introduced in recent rework
Date: Friday 02 December 2005 01:11
From: Blaisorblade <blaisorblade@yahoo.it>
To: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@vger.kernel.org

I recently found a bug introduced in your commit
65500d234e74fc4e8f18e1a429bc24e51e75de4a, i.e. between 2.6.14 and 2.6.15-rc1,
about do_file_page changes wrt remap_file_pages and MAP_POPULATE.

Quoting from the changelog (which is wrong):

    do_file_page's fallback to do_no_page dates from a time when we were
testing
    pte_file by using it wherever possible: currently it's peculiar to
nonlinear
    vmas, so just check that.  BUG_ON if not?  Better not, it's probably page
    table corruption, so just show the pte: hmm, there's a pte_ERROR macro,
let's
    use that for do_wp_page's invalid pfn too.

This is false:

do_mmap_pgoff:
        if (flags & MAP_POPULATE) {
                up_write(&mm->mmap_sem);
                sys_remap_file_pages(addr, len, 0,
                                        pgoff, flags & MAP_NONBLOCK);
                down_write(&mm->mmap_sem);
        }

So, with MAP_POPULATE|MAP_NONBLOCK passed, you can get a linear PAGE_FILE pte
in a !VM_NONLINEAR vma.

That PTE is very useless since it doesn't add any information, I know that,
 so avoiding that possible installation is a possible fix, but for now it's
 simpler to change the test in do_file_page(). Btw, in fact I discovered this
 bug while I was implementing this optimization (working again on
remap_file_pages() patches of this summer).

Indeed, the condition to test (and to possibly BUG_ON/pte_ERROR) is that
->populate must exist for the sys_remap_file_pages call to work.
--
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

-------------------------------------------------------

-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
