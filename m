Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0058C6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 15:20:26 -0400 (EDT)
Received: by ladw1 with SMTP id w1so48765114lad.0
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:20:25 -0700 (PDT)
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com. [209.85.217.176])
        by mx.google.com with ESMTPS id mp6si8861855lbb.4.2015.03.16.12.20.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 12:20:24 -0700 (PDT)
Received: by lbcgn8 with SMTP id gn8so27225818lbc.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:20:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150316190154.GA18472@redhat.com>
References: <878ufc9kau.fsf@redhat.com> <20150305154827.GA9441@host1.jankratochvil.net>
 <87zj7r5fpz.fsf@redhat.com> <20150305205744.GA13165@host1.jankratochvil.net>
 <20150311200052.GA22654@redhat.com> <20150312143438.GA4338@redhat.com>
 <CALCETrW5rmAHutzm_OwK2LTd_J0XByV3pvWGyW=AmC=v7rLfhQ@mail.gmail.com>
 <20150312165423.GA10073@redhat.com> <20150312174653.GA13086@redhat.com> <20150316190154.GA18472@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 16 Mar 2015 12:20:03 -0700
Message-ID: <CALCETrU9pLE2x3+vei1xw6B8uu4B33DOEzP03ue9DeS8sJhYUg@mail.gmail.com>
Subject: Re: install_special_mapping && vm_pgoff (Was: vvar, gup && coredump)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kratochvil <jan.kratochvil@redhat.com>, Sergio Durigan Junior <sergiodj@redhat.com>, GDB Patches <gdb-patches@sourceware.org>, Pedro Alves <palves@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

[cc: linux-mm]

On Mon, Mar 16, 2015 at 12:01 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 03/12, Oleg Nesterov wrote:
>>
>> OTOH. We can probably add ->access() into special_mapping_vmops, this
>> way __access_remote_vm() could work even if gup() fails ?
>
> So I tried to think how special_mapping_vmops->access() can work, it
> needs to rely on ->vm_pgoff.
>
> But afaics this logic is just broken. Lets even forget about vvar vma
> which uses remap_file_pages(). Lets look at "[vdso]" which uses the
> "normal" pages.
>
> The comment in special_mapping_fault() says
>
>          * special mappings have no vm_file, and in that case, the mm
>          * uses vm_pgoff internally.
>
> Yes. But afaics mm/ doesn't do this correctly. So
>
>          * do not copy this code into drivers!
>
> looks like a good recommendation ;)
>
> I think that this logic is wrong even if ARRAY_SIZE(pages) == 1, but I am
> not sure. But since vdso use 2 pages, it is trivial to show that this logic
> is wrong. To verify, I changed show_map_vma() to expose pgoff even if !file,
> but this test-case can show the problem too:
>
>         #include <stdio.h>
>         #include <unistd.h>
>         #include <stdlib.h>
>         #include <string.h>
>         #include <sys/mman.h>
>         #include <assert.h>
>
>         void *find_vdso_vaddr(void)
>         {
>                 FILE *perl;
>                 char buf[32] = {};
>
>                 perl = popen("perl -e 'open STDIN,qq|/proc/@{[getppid]}/maps|;"
>                                 "/^(.*?)-.*vdso/ && print hex $1 while <>'", "r");
>                 fread(buf, sizeof(buf), 1, perl);
>                 fclose(perl);
>
>                 return (void *)atol(buf);
>         }
>
>         #define PAGE_SIZE       4096
>
>         int main(void)
>         {
>                 void *vdso = find_vdso_vaddr();
>                 assert(vdso);
>
>                 // of course they should differ, and they do so far
>                 printf("vdso pages differ: %d\n",
>                         !!memcmp(vdso, vdso + PAGE_SIZE, PAGE_SIZE));
>
>                 // split into 2 vma's
>                 assert(mprotect(vdso, PAGE_SIZE, PROT_READ) == 0);
>
>                 // force another fault on the next check
>                 assert(madvise(vdso, 2 * PAGE_SIZE, MADV_DONTNEED) == 0);

I really hope this doesn't do anything (or fails) on the vvar page,
which is a pfnmap.

>
>                 // now they no longer differ, the 2nd vm_pgoff is wrong
>                 printf("vdso pages differ: %d\n",
>                         !!memcmp(vdso, vdso + PAGE_SIZE, PAGE_SIZE));
>
>                 return 0;
>         }
>
> output:
>
>         vdso pages differ: 1
>         vdso pages differ: 0
>
> And not only "split_vma" is wrong, I think that "move_vma" is not right too.
> Note this check in copy_vma(),
>
>         /*
>          * If anonymous vma has not yet been faulted, update new pgoff
>          * to match new location, to increase its chance of merging.
>          */
>         if (unlikely(!vma->vm_file && !vma->anon_vma)) {
>                 pgoff = addr >> PAGE_SHIFT;
>                 faulted_in_anon_vma = false;
>         }
>
> I can easily misread this code. But it doesn't look right too. If vdso was cow'ed
> (breakpoint installed by gdb) and sys_nremap()'ed, then the new pgoff will be wrong
> too after, say, MADV_DONTNEED.
>
> Or I am totally confused?

Ick, you're probably right.  For what it's worth, the vdso *seems* to
be okay (on 64-bit only, and only if you don't poke at it too hard) if
you mremap it in one piece.  CRIU does that.

What does the mm code do with vm_pgoff for vmas with no vm_file?  I'm
mystified.  There's this comment:

 * The way we recognize COWed pages within VM_PFNMAP mappings is through the
 * rules set up by "remap_pfn_range()": the vma will have the VM_PFNMAP bit
 * set, and the vm_pgoff will point to the first PFN mapped: thus every special
 * mapping will always honor the rule
 *
 *    pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)

Is that referring to special mappings in the install_special_mapping
sense or to something else.  FWIW, the vdso ins't a VM_PFNMAP at all.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
