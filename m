Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E2FEC6B0082
	for <linux-mm@kvack.org>; Mon, 21 May 2012 18:00:50 -0400 (EDT)
Received: by wibhj6 with SMTP id hj6so2401235wib.8
        for <linux-mm@kvack.org>; Mon, 21 May 2012 15:00:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120521143701.74ab2d0b.akpm@linux-foundation.org>
References: <20120209092642.GE16600@linux.vnet.ibm.com> <tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
 <20120521143701.74ab2d0b.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 21 May 2012 15:00:28 -0700
Message-ID: <CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to install
 and remove uprobes breakpoints
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, a.p.zijlstra@chello.nl, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, sfr@canb.auug.org.au, roland@hack.frob.com, mingo@elte.hu, linux-tip-commits@vger.kernel.org

On Mon, May 21, 2012 at 2:37 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> hm, we seem to have conflicting commits between mainline and linux-next.
> During the merge window. =A0Again. =A0Nobody knows why this happens.

I didn't have my trivial cleanup branches in linux-next, I'm afraid.
Usually my pending cleanups are just small patches that I carry along
without even committing them, this time around I had slightly more
than that.

>
> static void unmap_single_vma(struct mmu_gather *tlb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct vm_area_struct *vma, unsigned long =
start_addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long end_addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zap_details *details)
> {
> =A0 =A0 =A0 =A0unsigned long start =3D max(vma->vm_start, start_addr);
> =A0 =A0 =A0 =A0unsigned long end;
>
> =A0 =A0 =A0 =A0if (start >=3D vma->vm_end)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0end =3D min(vma->vm_end, end_addr);
> =A0 =A0 =A0 =A0if (end <=3D vma->vm_start)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> <<<<<<< HEAD
> =3D=3D=3D=3D=3D=3D=3D
> =A0 =A0 =A0 =A0if (vma->vm_file)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uprobe_munmap(vma, start, end);
>
> =A0 =A0 =A0 =A0if (vma->vm_flags & VM_ACCOUNT)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*nr_accounted +=3D (end - start) >> PAGE_S=
HIFT;
>
>>>>>>>> linux-next/akpm-base

Just remove the VM_ACCOUNT and *nr_accounted lines - they're done in
the caller now. They always should have been, I'm not sure why it was
in the "walk the page tables" path, which has nothing to do with it.

That said, I think that's true of uprobes too. Why the f*ck would
uprobes do it's "munmap" operation when we walk the page tables? This
function was called by more than just the actual unmapping, it was
called by stuff that wants to zap the pages but leave the mapping
around.

So that uprobe_munmap() could probably also be better moved into the
caller - where we actually remove the vma. Maybe.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
