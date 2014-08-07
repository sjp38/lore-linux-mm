Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80B056B0038
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 18:44:40 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id uy5so3405042obc.39
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 15:44:40 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id jt1si9383301obc.25.2014.08.07.15.44.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 15:44:39 -0700 (PDT)
Message-ID: <1407451471.2513.7.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 2/6] m68k: call find_vma with the mmap_sem held in
 sys_cacheflush()
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 07 Aug 2014 15:44:31 -0700
In-Reply-To: <CAMuHMdV5HKvzE6H_JCH=01med8mVuXbVBz92tpNk7poH4ymXOQ@mail.gmail.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
	 <1397960791-16320-3-git-send-email-davidlohr@hp.com>
	 <CAMuHMdVBZSC3Kvwsw5pa-m8ZAUCjpkF8gjJH1XbOK2iFbU1KEg@mail.gmail.com>
	 <1398032896.19331.25.camel@buesod1.americas.hpqcorp.net>
	 <CAMuHMdV5HKvzE6H_JCH=01med8mVuXbVBz92tpNk7poH4ymXOQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Aswin Chandramouleeswaran <aswin@hp.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

Hi Geert,

On Mon, 2014-04-21 at 09:52 +0200, Geert Uytterhoeven wrote:
> Hi David,
> 
> On Mon, Apr 21, 2014 at 12:28 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > On Sun, 2014-04-20 at 10:04 +0200, Geert Uytterhoeven wrote:
> >> On Sun, Apr 20, 2014 at 4:26 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> >> > Performing vma lookups without taking the mm->mmap_sem is asking
> >> > for trouble. While doing the search, the vma in question can be
> >> > modified or even removed before returning to the caller. Take the
> >> > lock (shared) in order to avoid races while iterating through
> >> > the vmacache and/or rbtree.
> >>
> >> Thanks for your patch!
> >>
> >> > This patch is completely *untested*.
> >> >
> >> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> >> > Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> >> > Cc: linux-m68k@lists.linux-m68k.org
> >> > ---
> >> >  arch/m68k/kernel/sys_m68k.c | 18 ++++++++++++------
> >> >  1 file changed, 12 insertions(+), 6 deletions(-)
> >> >
> >> > diff --git a/arch/m68k/kernel/sys_m68k.c b/arch/m68k/kernel/sys_m68k.c
> >> > index 3a480b3..d2263a0 100644
> >> > --- a/arch/m68k/kernel/sys_m68k.c
> >> > +++ b/arch/m68k/kernel/sys_m68k.c
> >> > @@ -376,7 +376,6 @@ cache_flush_060 (unsigned long addr, int scope, int cache, unsigned long len)
> >> >  asmlinkage int
> >> >  sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
> >> >  {
> >> > -       struct vm_area_struct *vma;
> >> >         int ret = -EINVAL;
> >> >
> >> >         if (scope < FLUSH_SCOPE_LINE || scope > FLUSH_SCOPE_ALL ||
> >> > @@ -389,16 +388,23 @@ sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
> >> >                 if (!capable(CAP_SYS_ADMIN))
> >> >                         goto out;
> >> >         } else {
> >> > +               struct vm_area_struct *vma;
> >> > +               bool invalid;
> >> > +
> >> > +               /* Check for overflow.  */
> >> > +               if (addr + len < addr)
> >> > +                       goto out;
> >> > +
> >> >                 /*
> >> >                  * Verify that the specified address region actually belongs
> >> >                  * to this process.
> >> >                  */
> >> > -               vma = find_vma (current->mm, addr);
> >> >                 ret = -EINVAL;
> >> > -               /* Check for overflow.  */
> >> > -               if (addr + len < addr)
> >> > -                       goto out;
> >> > -               if (vma == NULL || addr < vma->vm_start || addr + len > vma->vm_end)
> >> > +               down_read(&current->mm->mmap_sem);
> >> > +               vma = find_vma(current->mm, addr);
> >> > +               invalid = !vma || addr < vma->vm_start || addr + len > vma->vm_end;
> >> > +               up_read(&current->mm->mmap_sem);
> >> > +               if (invalid)
> >> >                         goto out;
> >> >         }
> >>
> >> Shouldn't the up_read() be moved to the end of the function?
> >> The vma may still be modified or destroyed between the call to find_vma(),
> >> and the actual cache flush?
> >
> > I don't think so. afaict the vma is only searched to check upon validity
> > for the address being passed. Once the sem is dropped, the call doesn't
> > do absolutely anything else with the returned vma.
> 
> The function indeed doesn't do anything anymore with the vma itself, but
> it does do something with the addr/len pair, which may no longer match
> with the vma if it changes after the up_read(). I.e. the address may no longer
> be valid when the cache is actually flushed.

Apologies for the delay, I completely forgot about this. 

So I wasn't sure if we *really* required to serialize the entire address
space for this operation. However, looking at other archs, sh seems to
do exactly that, so I guess, at least for safety, we should hold the
lock until we exit the function. I guess taking it as a reader enables
us to guarantee it won't be removed underneath us. So here's v2.

Thanks,
Davidlohr


8<-------------------------------------------------------------------------
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH v2] m68k: call find_vma with the mmap_sem held in sys_cacheflush()

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can be
modified or even removed before returning to the caller. Take the
lock (shared) in order to avoid races while iterating through
the vmacache and/or rbtree. In addition, this guarantees that the
address space will remain intact during the CPU flushing.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
Completely untested patch.

 arch/m68k/kernel/sys_m68k.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/arch/m68k/kernel/sys_m68k.c b/arch/m68k/kernel/sys_m68k.c
index 3a480b3..9aa01ad 100644
--- a/arch/m68k/kernel/sys_m68k.c
+++ b/arch/m68k/kernel/sys_m68k.c
@@ -376,7 +376,6 @@ cache_flush_060 (unsigned long addr, int scope, int cache, unsigned long len)
 asmlinkage int
 sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
 {
-	struct vm_area_struct *vma;
 	int ret = -EINVAL;
 
 	if (scope < FLUSH_SCOPE_LINE || scope > FLUSH_SCOPE_ALL ||
@@ -389,17 +388,21 @@ sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
 		if (!capable(CAP_SYS_ADMIN))
 			goto out;
 	} else {
+		struct vm_area_struct *vma;
+
+		/* Check for overflow.  */
+		if (addr + len < addr)
+			goto out;
+
 		/*
 		 * Verify that the specified address region actually belongs
 		 * to this process.
 		 */
-		vma = find_vma (current->mm, addr);
 		ret = -EINVAL;
-		/* Check for overflow.  */
-		if (addr + len < addr)
-			goto out;
-		if (vma == NULL || addr < vma->vm_start || addr + len > vma->vm_end)
-			goto out;
+		down_read(&current->mm->mmap_sem);
+		vma = find_vma(current->mm, addr);
+		if (!vma || addr < vma->vm_start || addr + len > vma->vm_end)
+			goto out_unlock;
 	}
 
 	if (CPU_IS_020_OR_030) {
@@ -429,7 +432,7 @@ sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
 			__asm__ __volatile__ ("movec %0, %%cacr" : : "r" (cacr));
 		}
 		ret = 0;
-		goto out;
+		goto out_unlock;
 	} else {
 	    /*
 	     * 040 or 060: don't blindly trust 'scope', someone could
@@ -446,6 +449,8 @@ sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
 		ret = cache_flush_060 (addr, scope, cache, len);
 	    }
 	}
+out_unlock:
+	up_read(&current->mm->mmap_sem);
 out:
 	return ret;
 }
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
