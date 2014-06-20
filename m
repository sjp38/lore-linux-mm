Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE3C6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:41:38 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so1026641wib.13
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:41:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a5si2821012wiy.31.2014.06.20.08.41.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jun 2014 08:41:18 -0700 (PDT)
Date: Fri, 20 Jun 2014 11:40:56 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kernel BUG at /src/linux-dev/mm/mempolicy.c:1738! on v3.16-rc1
Message-ID: <20140620154056.GB15620@nhori.bos.redhat.com>
References: <20140619215641.GA9792@nhori.bos.redhat.com>
 <alpine.LSU.2.11.1406192121470.988@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406192121470.988@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jun 19, 2014 at 09:35:48PM -0700, Hugh Dickins wrote:
> On Thu, 19 Jun 2014, Naoya Horiguchi wrote:
> > Hi,
> > 
> > I triggered the following bug on v3.16-rc1 when I did mbind() testing
> > where multiple processes repeat calling mbind() for a shared mapped file
> > (causing pingpong of page migration.)
> 
> The shared mapped file on shmem/tmpfs?  So involving shared policy stuff?

Sorry if it was confusing, I used an ext4 file and mapped it to multiple
processes, and then let the processes call mbind() with arguments of
random address, random length, and random node.
And yes, I think it's memory policy thing too.

> > 
> > In my investigation, it seems that some vma accidentally has vma->vm_start
> > = 0, which makes new_vma_page() choose a wrong vma and results in breaking
> > the assumption that the address passed to alloc_pages_vma() should be
> > inside a given vma.
> 
> I've not heard of that before.  What evidence led you there?

First of all, I checked the return value of get_vma_policy() when BUG() happens
(the BUG() was triggered when policy->mode is not MPOL_PREFERRED or MPOL_BIND,
so I thought that something happened on struct mempolicy.)
The result was weird, I got something like this:
  policy->flags 0xffff, policy->mode 0x8801, policy->refcnt 0x1d2cd5a9

So I tried to see why this happened, and checked the argument vma of
page_address_in_vma(), then got vma->vm_start == 0 when the BUG() was triggered.
page_address_in_vma() returns the address of a given page if the address is
within the vma, so if vma's range is corrupted, the result is corrupted too.

Unfortunately, I'm not sure why this wrong vma happened, but when I check
the vma->vm_prev and vma->vm_next, I got something like this:

  corrupted vma, vm_start:0,            vm_end:700000083000            
  vma->vm_prev,  vm_start:70000000d000, vm_end:7000003e5000
    # mempolicy associated with this vma was like this:
    #   policy->flags 0, policy->mode 2, policy->refcnt 1 
    # so this vma seems fine.
  vma->vm_next was NULL

so these vmas seems to be partially overlapped, that's why I suspected
vma might be split or merged in the wrong way.

> > I'm suspecting that mbind_range() do something wrong around vma handling,
> > but I don't have enough luck yet. Anyone has an idea?
> 
> No idea at present.
> 
> Please send disassembly (objdump -d, or objdump -ld if you had DEBUG_INFO)
> of policy_zonelist() - the Code line isn't enough to go on, since it just
> shows where the BUG jumped to out-of-line, with no clue as to what might
> be in the registers - thanks.

OK, it's like below:

ffffffff811ebf90 <policy_zonelist>:
policy_zonelist():
/src/linux-dev/mm/mempolicy.c:1720
ffffffff811ebf90:       e8 9b d5 55 00          callq  ffffffff81749530 <__fentry__>
ffffffff811ebf95:       55                      push   %rbp
ffffffff811ebf96:       48 89 e5                mov    %rsp,%rbp
ffffffff811ebf99:       53                      push   %rbx
/src/linux-dev/mm/mempolicy.c:1721
ffffffff811ebf9a:       0f b7 46 04             movzwl 0x4(%rsi),%eax
ffffffff811ebf9e:       66 83 f8 01             cmp    $0x1,%ax
ffffffff811ebfa2:       74 44                   je     ffffffff811ebfe8 <policy_zonelist+0x58>
ffffffff811ebfa4:       66 83 f8 02             cmp    $0x2,%ax
ffffffff811ebfa8:       75 36                   jne    ffffffff811ebfe0 <policy_zonelist+0x50>
/src/linux-dev/mm/mempolicy.c:1733
ffffffff811ebfaa:       89 fb                   mov    %edi,%ebx
ffffffff811ebfac:       81 e3 00 00 04 00       and    $0x40000,%ebx
ffffffff811ebfb2:       75 56                   jne    ffffffff811ec00a <policy_zonelist+0x7a>
ffffffff811ebfb4:       48 63 d2                movslq %edx,%rdx
gfp_zonelist():
/src/linux-dev/include/linux/gfp.h:274
ffffffff811ebfb7:       31 c0                   xor    %eax,%eax
ffffffff811ebfb9:       85 db                   test   %ebx,%ebx
policy_zonelist():
/src/linux-dev/mm/mempolicy.c:1740
ffffffff811ebfbb:       48 8b 14 d5 00 2d d6    mov    -0x7e29d300(,%rdx,8),%rdx
ffffffff811ebfc2:       81 
node_zonelist():
/src/linux-dev/include/linux/gfp.h:274
ffffffff811ebfc3:       0f 95 c0                setne  %al
policy_zonelist():
/src/linux-dev/mm/mempolicy.c:1740
ffffffff811ebfc6:       48 69 c0 20 22 01 00    imul   $0x12220,%rax,%rax
/src/linux-dev/mm/mempolicy.c:1741
ffffffff811ebfcd:       5b                      pop    %rbx
ffffffff811ebfce:       5d                      pop    %rbp
/src/linux-dev/mm/mempolicy.c:1740
ffffffff811ebfcf:       48 8d 84 02 00 1d 00    lea    0x1d00(%rdx,%rax,1),%rax
ffffffff811ebfd6:       00 
/src/linux-dev/mm/mempolicy.c:1741
ffffffff811ebfd7:       c3                      retq   
ffffffff811ebfd8:       0f 1f 84 00 00 00 00    nopl   0x0(%rax,%rax,1)
ffffffff811ebfdf:       00 
/src/linux-dev/mm/mempolicy.c:1738
ffffffff811ebfe0:       0f 0b                   ud2    
ffffffff811ebfe2:       66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
/src/linux-dev/mm/mempolicy.c:1723
ffffffff811ebfe8:       f6 46 06 02             testb  $0x2,0x6(%rsi)
ffffffff811ebfec:       75 12                   jne    ffffffff811ec000 <policy_zonelist+0x70>
ffffffff811ebfee:       89 fb                   mov    %edi,%ebx
ffffffff811ebff0:       48 0f bf 56 08          movswq 0x8(%rsi),%rdx
ffffffff811ebff5:       81 e3 00 00 04 00       and    $0x40000,%ebx
ffffffff811ebffb:       eb ba                   jmp    ffffffff811ebfb7 <policy_zonelist+0x27>
ffffffff811ebffd:       0f 1f 00                nopl   (%rax)
ffffffff811ec000:       81 e7 00 00 04 00       and    $0x40000,%edi
ffffffff811ec006:       89 fb                   mov    %edi,%ebx
ffffffff811ec008:       eb aa                   jmp    ffffffff811ebfb4 <policy_zonelist+0x24>
/src/linux-dev/mm/mempolicy.c:1734
ffffffff811ec00a:       48 8d 7e 08             lea    0x8(%rsi),%rdi
ffffffff811ec00e:       48 63 d2                movslq %edx,%rdx
variable_test_bit():
/src/linux-dev/arch/x86/include/asm/bitops.h:318
ffffffff811ec011:       48 0f a3 56 08          bt     %rdx,0x8(%rsi)
ffffffff811ec016:       19 c0                   sbb    %eax,%eax
policy_zonelist():
/src/linux-dev/mm/mempolicy.c:1733
ffffffff811ec018:       85 c0                   test   %eax,%eax
ffffffff811ec01a:       75 9b                   jne    ffffffff811ebfb7 <policy_zonelist+0x27>
__first_node():
/src/linux-dev/include/linux/nodemask.h:248
ffffffff811ec01c:       be 00 04 00 00          mov    $0x400,%esi
ffffffff811ec021:       e8 9a ae 1b 00          callq  ffffffff813a6ec0 <find_first_bit>
ffffffff811ec026:       ba 00 04 00 00          mov    $0x400,%edx
ffffffff811ec02b:       3d 00 04 00 00          cmp    $0x400,%eax
ffffffff811ec030:       0f 4e d0                cmovle %eax,%edx
ffffffff811ec033:       48 63 d2                movslq %edx,%rdx
ffffffff811ec036:       e9 7c ff ff ff          jmpq   ffffffff811ebfb7 <policy_zonelist+0x27>
policy_zonelist():
ffffffff811ec03b:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)


Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
