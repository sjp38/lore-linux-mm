Date: Wed, 2 Apr 2003 15:38:45 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-Id: <20030402153845.0770ef54.akpm@digeo.com>
In-Reply-To: <102170000.1049325787@baldur.austin.ibm.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
	<20030402132939.647c74a6.akpm@digeo.com>
	<80300000.1049320593@baldur.austin.ibm.com>
	<20030402150903.21765844.akpm@digeo.com>
	<102170000.1049325787@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> > i_shared_sem won't stop that.  The pte points into thin air, and may now
> > point at a value which looks like our page.
> 
> Once we find a match in the pte entry, we have the additional protection of
> the pte_chain lock.  The pte entry is never cleared without a call to
> page_remove_rmap, which will block on the pte_chain lock.

But:

+	/* Double check to make sure the pte page hasn't been freed */
+	if (!pmd_present(*pmd))
+		goto out_unmap;
+
	==> munmap, pte page is freed, reallocated for pagecache, someone
	    happens to write the correct value into it.
	
+	if (page_to_pfn(page) != pte_pfn(*pte))
+		goto out_unmap;
+
+	if (addr)
+		*addr = address;
+

> >> Because the page is in transition from !PageAnon to PageAnon.
> > 
> > These are file-backed pages.  So what does PageAnon really mean?
> 
> I suppose PageAnon should be renamed to PageChain, to mean it's using
> pte_chains.  It did mean anon pages until I used it for nonlinear pages.

OK, I'll edit the diffs at a convenient time.

> >> We have to
> >> hold the pte_chain lock during the entire transition in case someone else
> >> tries to do something like page_remove_rmap, which would break.
> > 
> > How about setting PageAnon at the _start_ of the operation? 
> > page_remove_rmap() will cope with that OK.
> 
> Hmm... I was gonna say that page_remove_rmap will BUG() if it doesn't find
> the entry, but it's only under DEBUG and could easily be changed.

That debug already triggers if it is enabled.  I forget why, but it's OK.

> Lemme
> think on this one a bit.  I need to assure myself it's safe to go unlocked
> in the middle.

Thanks.  It's tricky.  I wish we had more tests for this stuff, and real
applications which use it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
