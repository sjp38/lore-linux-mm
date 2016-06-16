Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 768BC6B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:58:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so92948293pfx.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:58:46 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id y1si14914248pax.35.2016.06.16.01.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 01:58:45 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id c74so3646844pfb.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 01:58:45 -0700 (PDT)
Date: Thu, 16 Jun 2016 10:58:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160616085836.GC6836@dhcp22.suse.cz>
References: <20160616084656.GB432@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616084656.GB432@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu 16-06-16 17:46:57, Sergey Senozhatsky wrote:
> Hello,
> 
> [..]
> [  272.687656] vma ffff8800b855a5a0 start 00007f3576d58000 end 00007f3576f66000
>                next ffff8800b977d2c0 prev ffff8800bdfb1860 mm ffff8801315ff200
>                prot 8000000000000025 anon_vma ffff8800b7e583b0 vm_ops           (null)
>                pgoff 7f3576d58 file           (null) private_data           (null)
>                flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> [  272.691793] ------------[ cut here ]------------
> [  272.692820] kernel BUG at mm/rmap.c:1251!

Is this?
page_add_new_anon_rmap:
	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma)
[...]
> [  272.727842] BUG: sleeping function called from invalid context at include/linux/sched.h:2960

If yes then I am not sure we can do much about the this part. BUG_ON in
an atomic context is unfortunate but the BUG_ON points out a real bug so
we shouldn't drop it because of the potential atomic context. The above
VM_BUG_ON should definitely be addressed. I thought that Vlastimil has
pointed out some issues with the khugepaged lock inconsistencies which
might lead to issues like this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
