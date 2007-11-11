From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
Date: Sun, 11 Nov 2007 11:09:34 +1100
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
In-Reply-To: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711111109.34562.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>, benh@kernel.crashing.org
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 10 November 2007 06:15, Jared Hulbert wrote:
> Per conversations regarding XIP from the vm/fs mini-summit a couple
> months back I've got a patch to air out.
>
> The basic problem is that the assumptions about PFN mappings stemming
> from the rules of remap_pfn_range() aren't always valid.  For example:
> what stops one from using vm_insert_pfn() to map PFN's into a vma in
> an arbitrary order?  Nothing.  Yet those PFN's cause problems in two
> ways.
>
> First, vm_normal_page() won't return NULL. 

They will, because it isn't allowed to be a COW mapping, and hence it
fails the vm_normal_page() test.

> My answer to this is to 
> simply check if pfn_valid()  if it isn't then we've got a proper PFN
> that can only be a PFN.  If you do have a valid PFN then you are (A) a
> 'cow'ed' PFN that is now a real page or (B) you are a real page
> pretending to be a PFN only.  The thing that makes me nervous is that
> my hack doesn't let that page pretend to be a PFN.  I can't figure out
> why a page would need/want to pretend to be a PFN so I don't see
> anything wrong with this, but maybe somebody does.
>
> Second, there are a few random BUG_ON() that don't seem to serve any
> purpose other than to punish the PFN's that don't abide by
> remap_pfn_range() rules.  I just get rid of them.  The problem is I
> don't really understand why they are there in the first place so for
> all I know I'm horribly breaking spufs or something.

They are perhaps slightly undercommented, but they are definitely
required. And it is to ensure that everything works correctly.


> Okay so I haven't tried this out on 2.6.24-rc1 yet, but the same basic
> idea worked on 2.6.23 and older.  I just wanted to get feedback on
> this approach.  I don't know the vm all that well so I want to make
> sure I'm not doing something really stupid that breaks a bunch of code
> paths I don't use.

You actually can't just use pfn_valid, because there are cases where
you actually *cannot* touch the underlying struct page's mapcount,
flags, etc. I think the only real user is /dev/mem.

So my suggestion to you, if you want to support COW pfnmaps, is to
create a new VM_FLAG type (VM_INVALIDPFNMAP? ;)), which has the
pfn_valid() == COW semantics that you want.

Keep the streamlined fastpath in vm_normal_page()...

  if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_JAREDMAP))) {
    if (vma->vm_flags & VM_JAREDMAP) {
      if (!pfn_valid(pfn))
        return NULL;
    } else {
      unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
      if (pfn == vma->vm_pgoff + off)
        return NULL;
      if (!is_cow_mapping(vma->vm_flags))
        return NULL;
    }
}

The tests in vm_insert_pfn would just be complementary to your new
scheme..
BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_JAREDMAP)));
BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
BUG_ON((vma->vm_flags & VM_JAREDMAP) && pfn_valid(pfn));

May not work out so easy, but AFAIKS it will work. See how much milage
that gets you.

The other thing you might like is to allow pfn_valid(pfn) pfns to go
into these mappings, and you know it is fine to twiddle with the
struct page (eg. if you want to switch between different pfns, which
I know the spufs guys want to). That's not too hard: just take out some
of the assertions. You might have to do a little bit of setup work too,
like increment the page count and mapcount etc. but just so long as you
put that in a mm/memory.c helper rather than your own code, it should
be clean enough.

>
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 9791e47..fb962d0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -366,29 +366,19 @@ static inline int is_cow_mapping(unsigned int flags)
>   * NOTE! Some mappings do not have "struct pages". A raw PFN mapping
>   * will have each page table entry just pointing to a raw page frame
>   * number, and as far as the VM layer is concerned, those do not have
> - * pages associated with them - even if the PFN might point to memory
> - * that otherwise is perfectly fine and has a "struct page".
> + * pages associated with them.
>   *
> - * The way we recognize those mappings is through the rules set up
> - * by "remap_pfn_range()": the vma will have the VM_PFNMAP bit set,
> - * and the vm_pgoff will point to the first PFN mapped: thus every
> - * page that is a raw mapping will always honor the rule
> - *
> - *	pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
> - *
> - * and if that isn't true, the page has been COW'ed (in which case it
> - * _does_ have a "struct page" associated with it even if it is in a
> - * VM_PFNMAP range).
> + * The old "remap_pfn_range()" rules don't work for all applications.
> + * Each "page" in a PFN mapping either has a page struct backing it
> + * or it doesn't.  If it does then treat it like the page it is, if
> + * if it doesn't then it is not a normal page so just return NULL.
>   */
>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long
> addr, pte_t pte)
>  {
>  	unsigned long pfn = pte_pfn(pte);
>
>  	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
> -		unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
> -		if (pfn == vma->vm_pgoff + off)
> -			return NULL;
> -		if (!is_cow_mapping(vma->vm_flags))
> +		if (!pfn_valid(pfn))
>  			return NULL;
>  	}
>
> @@ -1212,7 +1202,6 @@ int vm_insert_pfn(struct vm_area_struct *vma,
> unsigned long addr,
>  	spinlock_t *ptl;
>
>  	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
> -	BUG_ON(is_cow_mapping(vma->vm_flags));
>
>  	retval = -ENOMEM;
>  	pte = get_locked_pte(mm, addr, &ptl);
> @@ -2216,8 +2205,6 @@ static int __do_fault(struct mm_struct *mm,
> struct vm_area_struct *vma,
>  	vmf.flags = flags;
>  	vmf.page = NULL;
>
> -	BUG_ON(vma->vm_flags & VM_PFNMAP);
> -
>  	if (likely(vma->vm_ops->fault)) {
>  		ret = vma->vm_ops->fault(vma, &vmf);
>  		if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
