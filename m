Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7E2FA6006AB
	for <linux-mm@kvack.org>; Sun,  2 May 2010 14:21:06 -0400 (EDT)
Date: Sun, 2 May 2010 20:20:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100502182040.GB19891@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
 <20100429162120.GC22108@random.random>
 <m2j28c262361005021040q118934b8j1f2f0146c9217a0f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2j28c262361005021040q118934b8j1f2f0146c9217a0f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 03, 2010 at 02:40:44AM +0900, Minchan Kim wrote:
> On Fri, Apr 30, 2010 at 1:21 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > Hi Mel,
> >
> > did you see my proposed fix? I'm running with it applied, I'd be
> > interested if you can test it. Surely it will also work for new
> > anon-vma code in upstream, because at that point there's just 1
> > anon-vma and nothing else attached to the vma.
> >
> > http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=6efa1dfa5152ef8d7f26beb188d6877525a9dd03
> >
> > I think it's wrong to try to handle the race in rmap walk by making
> > magic checks on vm_flags VM_GROWSDOWN|GROWSUP and
> > vma->vm_mm->map_count == 1, when we can fix it fully and simply in
> > exec.c by indexing two vmas in the same anon-vma with a different
> > vm_start so the pages will be found at all times by the rmap_walk.
> >
> 
> I like this approach than exclude temporal stack while migration.
> 
> If we look it through viewpoint of performance, Mel and Kame's one
> look good and simple. But If I look it through viewpoint of
> correctness, Andrea's one looks good.
> I mean Mel's approach is that problem is here but let us solve it with
> there. it makes dependency between here and there. And In future, if
> temporal stack and rmap code might be problem, we also should solve it
> in there. :)

That explains exactly why I wanted to solve it locally to exec.c and
by using the same method of mremap. And it fixes all users not just
migrate (split_huge_page may also need it in the future if we ever
allow the user stack to be born huge instead of growing huge with
khugepaged if needed).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
