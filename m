Message-ID: <4296082A.3000900@rentec.com>
Date: Thu, 26 May 2005 13:32:26 -0400
From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
References: <200505202351.j4KNpHg21468@unix-os.sc.intel.com>
In-Reply-To: <200505202351.j4KNpHg21468@unix-os.sc.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org, colin.harrison@virgin.net
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote:
> Andrew Morton wrote on Thursday, May 19, 2005 3:55 PM
> 
>>Wolfgang Wander <wwc@rentec.com> wrote:
>>
>>>Clearly one has to weight the performance issues against the memory
>>> efficiency but since we demonstratibly throw away 25% (or 1GB) of the
>>> available address space in the various accumulated holes a long
>>> running application can generate
>>
>>That sounds pretty bad.
>>
>>
>>>I hope that for the time being we can
>>> stick with my first solution,
>>
>>I'm inclined to do this.
>>
>>
>>>preferably extended by your munmap fix?
>>
>>And this, if someone has a patch? 
> 
> 
> 
> 2nd patch on top of wolfgang's patch.  It's a compliment on top of initial
> attempt by wolfgang to solve the fragmentation problem.  The code path
> in munmap is suboptimal and potentially worsen the fragmentation because
> with a series of munmap, the free_area_cache would point to last vma that
> was freed, ignoring its surrounding and not performing any coalescing at all,
> thus artificially create more holes in the virtual address space than necessary.
> Since all the information needed to perform coalescing are actually already there.
> This patch put that data in use so we will prevent artificial fragmentation.
> 


This one seems to have triggered already the second bug report on lkm.

Is it possible that  in

static void
detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
     struct vm_area_struct *prev, unsigned long end)
{
     struct vm_area_struct **insertion_point;
     struct vm_area_struct *tail_vma = NULL;

     insertion_point = (prev ? &prev->vm_next : &mm->mmap);
     do {
         rb_erase(&vma->vm_rb, &mm->mm_rb);
         mm->map_count--;
         tail_vma = vma;
         vma = vma->vm_next;
     } while (vma && vma->vm_start < end);
     *insertion_point = vma;
     tail_vma->vm_next = NULL;
     if (mm->unmap_area == arch_unmap_area)
         tail_vma->vm_private_data = (void*) prev->vm_end;
     else
         tail_vma->vm_private_data = vma ?
             (void*) vma->vm_start : (void*) mm->mmap_base;
     mm->mmap_cache = NULL;        /* Kill the cache. */
}

'prev' seems to possibly be NULL and the assignemnt of
   tail_vma->vm_private_data = (void*) prev->vm_end;
which fix-2 adds does not check for that.
That potential problem does not seem to match the stacktrace
below however...

           Wolfgang


Colin Harrison wrote:

 > Hi
 >
 > I'm using kernel 2.6.12-rc5-git1
 > with patches from -mm
 > avoiding-mmap-fragmentation.patch
 > avoiding-mmap-fragmentation-tidy.patch
 > avoiding-mmap-fragmentation-fix.patch
 > avoiding-mmap-fragmentation-revert-unneeded-64-bit-changes.patch
 > avoiding-mmap-fragmentation-fix-2.patch
 >
 > I get a oops when exiting from mplayer playing (dfbmga framebuffer):-
 >
 > xxxxxxxx.xxxxxxxxxxxxxx.com login: Unable to handle kernel paging 
request at
 > v0
 >  printing eip:
 > *pde = 00000000
 > Oops: 0002 [#1]
 > PREEMPT
 > Modules linked in: parport_pc lp parport floppy natsemi 
nls_iso8859_15 ntfs
 > mgai
 > CPU:    0
 > EIP:    0060:[<e29245cc>]    Not tainted VLI
 > EFLAGS: 00210286   (2.6.12-rc5-git1)
 > EIP is at snd_pcm_mmap_data_close+0x6/0xd [snd_pcm]
 > eax: 0000863c   ebx: d6073000   ecx: d4dc356c   edx: e29245c6
 > esi: d50756fc   edi: d58a7180   ebp: d66b9800   esp: d6073f6c
 > ds: 007b   es: 007b   ss: 0068
 > Process mplayer (pid: 1634, threadinfo=d6073000 task=d72e6020)
 > Stack: c013ddbc 00000000 d66b9800 d50756fc c013f532 b747e000 b746e000
 > c013f8ad
 >        b746e000 b747e000 d4dc3a14 d66b9800 d66b9830 ffff0001 d6073000
 > c013f928
 >        b746e000 00000002 00000002 c01026ff b746e000 00010000 b7ec143c
 > 00000002
 > Call Trace:
 >  [<c013ddbc>] remove_vm_struct+0x78/0x81
 >  [<c013f532>] unmap_vma_list+0xe/0x17
 >  [<c013f8ad>] do_munmap+0xf1/0x12c
 >  [<c013f928>] sys_munmap+0x40/0x63
 >  [<c01026ff>] sysenter_past_esp+0x54/0x75
 > Code: 81 dd 89 f8 8b 5c 24 04 8b 74 24 08 8b 7c 24 0c 8b 6c 24 10 83 
c4 14
 > c3 8
 >
 > (sorry didn't have linewrap on my minicom!)
 >
 > Without the last patch, avoiding-mmap-fragmentation-fix-2, works fine 
doing
 > same stuff with mplayer.
 >
 > More information/testing can be supplied/performed as required.
 >
 > Thanks
 > Colin Harrison
 >
 > -
 > To unsubscribe from this list: send the line "unsubscribe 
linux-kernel" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
 > Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
