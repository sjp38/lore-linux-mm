Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B30A6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 03:18:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e193-v6so809024wmg.1
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 00:18:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x3-v6sor2527486wrr.37.2018.07.05.00.18.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 00:18:10 -0700 (PDT)
Date: Thu, 5 Jul 2018 09:18:08 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180705071808.GA30187@techadventures.net>
References: <20180704121107.GL22503@dhcp22.suse.cz>
 <20180704151529.GA23317@techadventures.net>
 <201807050035.w650Z4RT018631@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201807050035.w650Z4RT018631@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: viro@zeniv.linux.org.uk, Michal Hocko <mhocko@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

> So, indeed "bss" needs to be aligned.
> But ELF_PAGESTART() or ELF_PAGEALIGN(), which one to use?
> 
> #define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
> #define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))
> 
> Is
> 
> -	len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
> -			    ELF_MIN_ALIGN - 1);
> +	len = ELF_PAGEALIGN(eppnt->p_filesz + eppnt->p_vaddr);
> 
> suggesting that
> 
> -	bss = eppnt->p_memsz + eppnt->p_vaddr;
> +	bss = ELF_PAGEALIGN(eppnt->p_memsz + eppnt->p_vaddr);
> 
> is the right choice? I don't know...

Yes, I think that ELF_PAGEALIGN is the right choice here.
Given that bss is 0x7bf88676, using ELF_PAGESTART aligns it but backwards, while ELF_PAGEALIGN does
the right thing:

bss = 0x7bf88676
ELF_PAGESTART (bss) = 0x7bf88000
ELF_PAGEALIGN (bss) = 0x7bf89000

-- 
Oscar Salvador
SUSE L3
