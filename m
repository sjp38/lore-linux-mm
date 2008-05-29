Date: Thu, 29 May 2008 10:58:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] hugetlb: fix lockdep error
Message-ID: <20080529085801.GA6881@wotan.suse.de>
References: <20080529015956.GC3258@wotan.suse.de> <20080528191657.ba5f283c.akpm@linux-foundation.org> <20080529022919.GD3258@wotan.suse.de> <20080528193808.6e053dac.akpm@linux-foundation.org> <20080529030745.GG3258@wotan.suse.de> <20080528201929.cf766924.akpm@linux-foundation.org> <29495f1d0805282048s5c699e70rf4ab1377b18f337e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29495f1d0805282048s5c699e70rf4ab1377b18f337e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, agl@us.ibm.com, nacc@us.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 08:48:36PM -0700, Nish Aravamudan wrote:
> On 5/28/08, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 29 May 2008 05:07:45 +0200 Nick Piggin <npiggin@suse.de> wrote:
> >
> >  > > >  mm/hugetlb.c |    2 +-
> >  > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> >  > > >
> >  > > > Index: linux-2.6/mm/hugetlb.c
> >  > > > ===================================================================
> >  > > > --- linux-2.6.orig/mm/hugetlb.c
> >  > > > +++ linux-2.6/mm/hugetlb.c
> >  > > > @@ -785,7 +785,7 @@ int copy_hugetlb_page_range(struct mm_st
> >  > > >                   continue;
> >  > > >
> >  > > >           spin_lock(&dst->page_table_lock);
> >  > > > -         spin_lock(&src->page_table_lock);
> >  > > > +         spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
> >  > > >           if (!huge_pte_none(huge_ptep_get(src_pte))) {
> >  > > >                   if (cow)
> >  > > >                           huge_ptep_set_wrprotect(src, addr, src_pte);
> >  > >
> >  > > Confused.  This code has been there since October 2005.  Why are we
> >  > > only seeing lockdep warnings now?
> >  >
> >  > Can't say. Haven't looked at hugetlb code or tested it much until now.
> >  > I am using a recent libhugetlbfs test suite, FWIW.
> >
> >
> > I don't believe that it's possible that nobody has run that test suite
> >  with lockdep enabled at any time in the past three years.
> 
> I can't tell from Nick's mail if the lockdep error is specific to this
> particular testcase or not, but if so, that would make it the past two
> (almost three) months, as that was when this particular testcase was
> added. And I'm not sure when we released the first development
> snapshot that would have included it (for non-git users, that is). In
> any case, I also don't know how we wouldn't have seen this issue on
> our systems and that's a problem. I will make a concerted effort to

I didn't check if other tests trigger it (lockdep I think turns off after
the first message...). But I guess anything which calls fork and has a
non shared, populated hugepage pagetable entry should trigger it...
Anyway the good news is that no other lockdep problems ever came up
after this false positive was fixed, so not much harm done ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
