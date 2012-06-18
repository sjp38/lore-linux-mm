Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2F4E06B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 16:37:24 -0400 (EDT)
Date: Mon, 18 Jun 2012 22:37:20 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH -mm 3/6] Fix the x86-64 page colouring code to take pgoff
 into account and use that code as the basis for a generic page colouring
 code.
Message-ID: <20120618203720.GA4148@liondog.tnic>
References: <1340029878-7966-1-git-send-email-riel@redhat.com>
 <1340029878-7966-4-git-send-email-riel@redhat.com>
 <m2k3z48twb.fsf@firstfloor.org>
 <4FDF5B3C.1000007@redhat.com>
 <20120618181658.GA7190@x1.osrc.amd.com>
 <4FDF7B5E.301@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FDF7B5E.301@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, hnaz@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, Jun 18, 2012 at 03:02:54PM -0400, Rik van Riel wrote:
> On 06/18/2012 02:16 PM, Borislav Petkov wrote:
> >On Mon, Jun 18, 2012 at 12:45:48PM -0400, Rik van Riel wrote:
> >>>What tree is that against? I cannot find x86 page colouring code in next
> >>>or mainline.
> >>
> >>This is against mainline.
> >
> >Which mainline do you mean exactly?
> >
> >1/6 doesn't apply ontop of current mainline and by "current" I mean
> >v3.5-rc3-57-g39a50b42f702.
> 
> After pulling in the latest patches, including that
> 39a50b... commit, all patches still apply here when
> I type guilt push -a.

That's strange.

I'm also pulling from

git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6

Btw, if I had local changes, the top commit id would've changed, right?
So I wouldn't have had 39a50b anymore.

Just in case, I tried applying 1/6 on another repository and it still
doesn't apply:

$ patch -p1 --dry-run -i /tmp/riel.01
patching file include/linux/mm_types.h
Hunk #1 succeeded at 300 (offset -7 lines).
patching file mm/mmap.c
Hunk #2 succeeded at 206 with fuzz 1 (offset -45 lines).
Hunk #3 FAILED at 398.
Hunk #4 FAILED at 461.
Hunk #5 succeeded at 603 (offset -57 lines).
Hunk #6 succeeded at 1404 (offset -66 lines).
Hunk #7 succeeded at 1441 (offset -66 lines).
Hunk #8 succeeded at 1528 (offset -66 lines).
Hunk #9 succeeded at 1570 (offset -66 lines).
Hunk #10 FAILED at 1908.
Hunk #11 FAILED at 2093.
4 out of 11 hunks FAILED -- saving rejects to file mm/mmap.c.rej

riel.01 is the mail saved from mutt so it should be fine.

Now let's look at the first failing hunk:

Mainline has:

void validate_mm(struct mm_struct *mm)
{
	int bug = 0;
	int i = 0;
	struct vm_area_struct *tmp = mm->mmap;
	while (tmp) {
		tmp = tmp->vm_next;
		i++;
	}
	if (i != mm->map_count)
		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
	i = browse_rb(&mm->mm_rb);
	if (i != mm->map_count)
		printk("map_count %d rb %d\n", mm->map_count, i), bug = 1;
	BUG_ON(bug);
}

--
and your patch has some new ifs in it:

@@ -386,12 +398,16 @@ void validate_mm(struct mm_struct *mm)
 	int bug = 0;
 	int i = 0;
 	struct vm_area_struct *tmp = mm->mmap;
+	unsigned long highest_address = 0;
 	while (tmp) {
 		if (tmp->free_gap != max_free_space(&tmp->vm_rb))
 			printk("free space %lx, correct %lx\n", tmp->free_gap, max_free_space(&tmp->vm_rb)), bug = 1;

			^^^^^^^^^^^^^^

I think this if-statement is the problem. It is not present in mainline
but this patch doesn't add it so some patch earlier than that adds it
which is probably in your queue?

+		highest_address = tmp->vm_end;
 		tmp = tmp->vm_next;
 		i++;
 	}
+	if (highest_address != mm->highest_vma)
+		printk("mm->highest_vma %lx, found %lx\n", mm->highest_vma, highest_address), bug = 1;

 	if (i != mm->map_count)
 		printk("map_count %d vm_next %d\n", mm->map_count, i), bug = 1;
 	i = browse_rb(&mm->mm_rb);
--

I haven't looked at the other failing hunks...

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
