Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA22564
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 18:02:51 -0800 (PST)
Date: Fri, 7 Feb 2003 18:02:53 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030207180253.6ea5b3de.akpm@digeo.com>
In-Reply-To: <6315617889C99D4BA7C14687DEC8DB4E023D2E6E@fmsmsx402.fm.intel.com>
References: <6315617889C99D4BA7C14687DEC8DB4E023D2E6E@fmsmsx402.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Seth, Rohit" <rohit.seth@intel.com> wrote:
>
> Andrew,
> 
> Will it be possible to have a macro, something like
> is_valid_hugepage_addr, that has the arch. specific definition of
> checking the validity (like len > TASK_SIZE etc) of any hugepage addr.
> It will make the following code more usable across archs. I know we
> could have HAVE_ARCH_HUGETLB_UNMAPPED_AREA to have arch specific thing,
> but just thought if a small cahnge in existing function could make this
> code widely useable.
> 
> In addition, HUGE_PAGE_ALIGNMENT sanity check is also needed in
> generic_unmapped_area code for MAP_FIXED cases.

Oh cripes.  Yes, we need to fix that.

> I'm attaching a patch.  For i386, the addr parameter to this function is
> not modified.  But other archs like ia64 will do that.

OK, but it needs some changes.

- is_valid_hugepage_range() will not compile.  `addrp' vs `addr'

- We should not pass in a flag variable which alters a function's behaviour
  in this manner.  Especially when it has the wonderful name "flag", and no
  supporting commentary!

  Please split this into two separate (and documented) functions.

- A name like "is_valid_hugepage_range" implies that this function is
  purely a predicate.  Yet it is capable of altering part of the caller's
  environment.  Can we have a more appropriate name?

- I've been trying to keep ia64/sparc64/x86_64 as uptodate as I can
  throughout this.  I think we can safely copy the ia32 implementation over
  into there as well, can't we?

  If there's any doubt then probably it's best to just leave the symbol
  undefined, let the arch maintainers curse us ;)

Are you working against Linus's current tree?  A lot has changed in there. 
I'd like to hear if hugetlbfs is working correctly in a non-ia32 kernel.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
