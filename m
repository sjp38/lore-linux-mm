Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 375E66B00C9
	for <linux-mm@kvack.org>; Tue, 19 May 2015 11:13:07 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so120795125wic.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 08:13:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13si24025251wjq.175.2015.05.19.08.13.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 08:13:05 -0700 (PDT)
Date: Tue, 19 May 2015 16:13:02 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519151302.GG2462@suse.de>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
 <20150519145340.GI6203@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150519145340.GI6203@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue, May 19, 2015 at 04:53:40PM +0200, Michal Hocko wrote:
> On Tue 19-05-15 10:18:07, Johannes Weiner wrote:
> > CC'ing Tejun and cgroups for the generic cgroup interface part
> > 
> > On Tue, May 19, 2015 at 11:40:57AM +0100, Mel Gorman wrote:
> [...]
> > > /usr/src/linux-4.0-vanilla/mm/memcontrol.c                           6.6441   395842
> > >   mem_cgroup_try_charge                                                        2.950%   175781
> > 
> > Ouch.  Do you have a way to get the per-instruction breakdown of this?
> > This function really isn't doing much.  I'll try to reproduce it here
> > too, I haven't seen such high costs with pft in the past.
> > 
> > >   try_charge                                                                   0.150%     8928
> > >   get_mem_cgroup_from_mm                                                       0.121%     7184
> 
> Indeed! try_charge + get_mem_cgroup_from_mm which I would expect to be
> the biggest consumers here are below 10% of the mem_cgroup_try_charge.
> Other than that the function doesn't do much else than some flags
> queries and css_put...
> 
> Do you have the full trace? Sorry for a stupid question but do inlines
> from other header files get accounted to memcontrol.c?
> 

The annotations for those functions look like with some very basic notes are
as follows. Note that I've done almost no research on this. I just noticed
that the memcg overhead was still there when looking for something else.

ffffffff811c15f0 <mem_cgroup_try_charge>: /* mem_cgroup_try_charge total: 176903  2.9692 */
   765  0.0128 :ffffffff811c15f0:       callq  ffffffff816435e0 <__fentry__>
    78  0.0013 :ffffffff811c15f5:       push   %rbp
  1185  0.0199 :ffffffff811c15f6:       mov    %rsp,%rbp
   356  0.0060 :ffffffff811c15f9:       push   %r14
   209  0.0035 :ffffffff811c15fb:       push   %r13
  1599  0.0268 :ffffffff811c15fd:       push   %r12
   320  0.0054 :ffffffff811c15ff:       mov    %rcx,%r12
   305  0.0051 :ffffffff811c1602:       push   %rbx
   325  0.0055 :ffffffff811c1603:       sub    $0x10,%rsp
   878  0.0147 :ffffffff811c1607:       mov    0xb7501b(%rip),%ecx        # ffffffff81d36628 <memory_cgrp_subsys+0x68>
   571  0.0096 :ffffffff811c160d:       test   %ecx,%ecx

### MEL: Function entry, check for mem_cgroup_disabled()


               :ffffffff811c160f:       je     ffffffff811c1630 <mem_cgroup_try_charge+0x40>
               :ffffffff811c1611:       xor    %eax,%eax
               :ffffffff811c1613:       xor    %ebx,%ebx
     1 1.7e-05 :ffffffff811c1615:       mov    %rbx,(%r12)
     7 1.2e-04 :ffffffff811c1619:       add    $0x10,%rsp
  1211  0.0203 :ffffffff811c161d:       pop    %rbx
     5 8.4e-05 :ffffffff811c161e:       pop    %r12
     5 8.4e-05 :ffffffff811c1620:       pop    %r13
  1249  0.0210 :ffffffff811c1622:       pop    %r14
     7 1.2e-04 :ffffffff811c1624:       pop    %rbp
     5 8.4e-05 :ffffffff811c1625:       retq   
               :ffffffff811c1626:       nopw   %cs:0x0(%rax,%rax,1)
   295  0.0050 :ffffffff811c1630:       mov    (%rdi),%rax
160703  2.6973 :ffffffff811c1633:       mov    %edx,%r13d

#### MEL: I was surprised to see this atrocity. It's a PageSwapCache check
#### /usr/src/linux-4.0-vanilla/./arch/x86/include/asm/bitops.h:311
#### /usr/src/linux-4.0-vanilla/include/linux/page-flags.h:261
#### /usr/src/linux-4.0-vanilla/mm/memcontrol.c:5473
####
#### Everything after here is consistent small amounts of overhead just from
#### being called a lot

   179  0.0030 :ffffffff811c1636:       test   $0x10000,%eax
               :ffffffff811c163b:       je     ffffffff811c1648 <mem_cgroup_try_charge+0x58>
               :ffffffff811c163d:       xor    %eax,%eax
               :ffffffff811c163f:       xor    %ebx,%ebx
               :ffffffff811c1641:       cmpq   $0x0,0x38(%rdi)
               :ffffffff811c1646:       jne    ffffffff811c1615 <mem_cgroup_try_charge+0x25>
  1343  0.0225 :ffffffff811c1648:       mov    (%rdi),%rax
    26 4.4e-04 :ffffffff811c164b:       mov    $0x1,%r14d
    24 4.0e-04 :ffffffff811c1651:       test   $0x40,%ah
               :ffffffff811c1654:       je     ffffffff811c1665 <mem_cgroup_try_charge+0x75>
               :ffffffff811c1656:       mov    (%rdi),%rax
               :ffffffff811c1659:       test   $0x40,%ah
               :ffffffff811c165c:       je     ffffffff811c1665 <mem_cgroup_try_charge+0x75>
               :ffffffff811c165e:       mov    0x68(%rdi),%rcx
               :ffffffff811c1662:       shl    %cl,%r14d
  1225  0.0206 :ffffffff811c1665:       mov    0xb74f35(%rip),%eax        # ffffffff81d365a0 <do_swap_account>
    66  0.0011 :ffffffff811c166b:       test   %eax,%eax
               :ffffffff811c166d:       jne    ffffffff811c16a8 <mem_cgroup_try_charge+0xb8>
     3 5.0e-05 :ffffffff811c166f:       mov    %rsi,%rdi
    22 3.7e-04 :ffffffff811c1672:       callq  ffffffff811bc920 <get_mem_cgroup_from_mm>
  1291  0.0217 :ffffffff811c1677:       mov    %rax,%rbx
     3 5.0e-05 :ffffffff811c167a:       mov    %r14d,%edx
               :ffffffff811c167d:       mov    %r13d,%esi
    10 1.7e-04 :ffffffff811c1680:       mov    %rbx,%rdi
  1380  0.0232 :ffffffff811c1683:       callq  ffffffff811c0950 <try_charge>
    10 1.7e-04 :ffffffff811c1688:       testb  $0x1,0x74(%rbx)
  1235  0.0207 :ffffffff811c168c:       je     ffffffff811c16d0 <mem_cgroup_try_charge+0xe0>
     7 1.2e-04 :ffffffff811c168e:       cmp    $0xfffffffc,%eax
               :ffffffff811c1691:       jne    ffffffff811c1615 <mem_cgroup_try_charge+0x25>
               :ffffffff811c1693:       mov    0xb74f0e(%rip),%rbx        # ffffffff81d365a8 <root_mem_cgroup>
               :ffffffff811c169a:       xor    %eax,%eax
               :ffffffff811c169c:       jmpq   ffffffff811c1615 <mem_cgroup_try_charge+0x25>
               :ffffffff811c16a1:       nopl   0x0(%rax)
               :ffffffff811c16a8:       mov    (%rdi),%rax
               :ffffffff811c16ab:       test   $0x10000,%eax
               :ffffffff811c16b0:       je     ffffffff811c166f <mem_cgroup_try_charge+0x7f>
               :ffffffff811c16b2:       mov    %rsi,-0x28(%rbp)
               :ffffffff811c16b6:       callq  ffffffff811c0450 <try_get_mem_cgroup_from_page>
               :ffffffff811c16bb:       test   %rax,%rax
               :ffffffff811c16be:       mov    %rax,%rbx
               :ffffffff811c16c1:       mov    -0x28(%rbp),%rsi
               :ffffffff811c16c5:       jne    ffffffff811c167a <mem_cgroup_try_charge+0x8a>
               :ffffffff811c16c7:       jmp    ffffffff811c166f <mem_cgroup_try_charge+0x7f>
               :ffffffff811c16c9:       nopl   0x0(%rax)
               :ffffffff811c16d0:       mov    0x18(%rbx),%rdx
               :ffffffff811c16d4:       test   $0x3,%dl
               :ffffffff811c16d7:       jne    ffffffff811c16df <mem_cgroup_try_charge+0xef>
               :ffffffff811c16d9:       decq   %gs:(%rdx)
               :ffffffff811c16dd:       jmp    ffffffff811c168e <mem_cgroup_try_charge+0x9e>
               :ffffffff811c16df:       lea    0x10(%rbx),%rdi
               :ffffffff811c16e3:       lock subq $0x1,0x10(%rbx)
               :ffffffff811c16e9:       je     ffffffff811c16ed <mem_cgroup_try_charge+0xfd>
               :ffffffff811c16eb:       jmp    ffffffff811c168e <mem_cgroup_try_charge+0x9e>
               :ffffffff811c16ed:       mov    %eax,-0x28(%rbp)
               :ffffffff811c16f0:       callq  *0x20(%rbx)
               :ffffffff811c16f3:       mov    -0x28(%rbp),%eax
               :ffffffff811c16f6:       jmp    ffffffff811c168e <mem_cgroup_try_charge+0x9e>
               :ffffffff811c16f8:       nopl   0x0(%rax,%rax,1)

ffffffff811bc920 <get_mem_cgroup_from_mm>: /* get_mem_cgroup_from_mm total:   7251  0.1217 */
#### MEL: Nothing really big jumped out there at me.
  1318  0.0221 :ffffffff811bc920:       callq  ffffffff816435e0 <__fentry__>
    19 3.2e-04 :ffffffff811bc925:       push   %rbp
    42 7.0e-04 :ffffffff811bc926:       mov    %rsp,%rbp
  1278  0.0215 :ffffffff811bc929:       jmp    ffffffff811bc94b <get_mem_cgroup_from_mm+0x2b>
               :ffffffff811bc92b:       nopl   0x0(%rax,%rax,1)
  1259  0.0211 :ffffffff811bc930:       testb  $0x1,0x74(%rdx)
   161  0.0027 :ffffffff811bc934:       jne    ffffffff811bc980 <get_mem_cgroup_from_mm+0x60>
               :ffffffff811bc936:       mov    0x18(%rdx),%rax
               :ffffffff811bc93a:       test   $0x3,%al
               :ffffffff811bc93c:       jne    ffffffff811bc985 <get_mem_cgroup_from_mm+0x65>
               :ffffffff811bc93e:       incq   %gs:(%rax)
               :ffffffff811bc942:       mov    $0x1,%eax
               :ffffffff811bc947:       test   %al,%al
               :ffffffff811bc949:       jne    ffffffff811bc980 <get_mem_cgroup_from_mm+0x60>
    13 2.2e-04 :ffffffff811bc94b:       test   %rdi,%rdi
               :ffffffff811bc94e:       je     ffffffff811bc96c <get_mem_cgroup_from_mm+0x4c>
    47 7.9e-04 :ffffffff811bc950:       mov    0x340(%rdi),%rax
  1410  0.0237 :ffffffff811bc957:       test   %rax,%rax
               :ffffffff811bc95a:       je     ffffffff811bc96c <get_mem_cgroup_from_mm+0x4c>
    26 4.4e-04 :ffffffff811bc95c:       mov    0xca0(%rax),%rax
   179  0.0030 :ffffffff811bc963:       mov    0x70(%rax),%rdx
   174  0.0029 :ffffffff811bc967:       test   %rdx,%rdx
               :ffffffff811bc96a:       jne    ffffffff811bc930 <get_mem_cgroup_from_mm+0x10>
               :ffffffff811bc96c:       mov    0xb79c35(%rip),%rdx        # ffffffff81d365a8 <root_mem_cgroup>
     1 1.7e-05 :ffffffff811bc973:       testb  $0x1,0x74(%rdx)
               :ffffffff811bc977:       je     ffffffff811bc936 <get_mem_cgroup_from_mm+0x16>
               :ffffffff811bc979:       nopl   0x0(%rax)
  1299  0.0218 :ffffffff811bc980:       mov    %rdx,%rax
     4 6.7e-05 :ffffffff811bc983:       pop    %rbp
    21 3.5e-04 :ffffffff811bc984:       retq   
               :ffffffff811bc985:       testb  $0x2,0x18(%rdx)
               :ffffffff811bc989:       jne    ffffffff811bc9d2 <get_mem_cgroup_from_mm+0xb2>
               :ffffffff811bc98b:       mov    0x10(%rdx),%rcx
               :ffffffff811bc98f:       test   %rcx,%rcx
               :ffffffff811bc992:       je     ffffffff811bc9d2 <get_mem_cgroup_from_mm+0xb2>
               :ffffffff811bc994:       lea    0x1(%rcx),%rsi
               :ffffffff811bc998:       lea    0x10(%rdx),%r8
               :ffffffff811bc99c:       mov    %rcx,%rax
               :ffffffff811bc99f:       lock cmpxchg %rsi,0x10(%rdx)
               :ffffffff811bc9a5:       cmp    %rcx,%rax
               :ffffffff811bc9a8:       mov    %rax,%rsi
               :ffffffff811bc9ab:       jne    ffffffff811bc9b4 <get_mem_cgroup_from_mm+0x94>
               :ffffffff811bc9ad:       mov    $0x1,%eax
               :ffffffff811bc9b2:       jmp    ffffffff811bc947 <get_mem_cgroup_from_mm+0x27>
               :ffffffff811bc9b4:       test   %rsi,%rsi
               :ffffffff811bc9b7:       je     ffffffff811bc9d2 <get_mem_cgroup_from_mm+0xb2>
               :ffffffff811bc9b9:       lea    0x1(%rsi),%rcx
               :ffffffff811bc9bd:       mov    %rsi,%rax
               :ffffffff811bc9c0:       lock cmpxchg %rcx,(%r8)
               :ffffffff811bc9c5:       cmp    %rax,%rsi
               :ffffffff811bc9c8:       je     ffffffff811bc9ad <get_mem_cgroup_from_mm+0x8d>
               :ffffffff811bc9ca:       mov    %rax,%rsi
               :ffffffff811bc9cd:       test   %rsi,%rsi
               :ffffffff811bc9d0:       jne    ffffffff811bc9b9 <get_mem_cgroup_from_mm+0x99>
               :ffffffff811bc9d2:       xor    %eax,%eax
               :ffffffff811bc9d4:       jmpq   ffffffff811bc947 <get_mem_cgroup_from_mm+0x27>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
