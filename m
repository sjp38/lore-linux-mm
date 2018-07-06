Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 745EF6B0005
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 01:35:51 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id y7-v6so3759668plt.17
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 22:35:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9-v6si3152418pgm.659.2018.07.05.22.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 22:35:49 -0700 (PDT)
Date: Fri, 6 Jul 2018 07:35:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180706053545.GD32658@dhcp22.suse.cz>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
 <20180704121107.GL22503@dhcp22.suse.cz>
 <20180704151529.GA23317@techadventures.net>
 <20180705064335.GA32658@dhcp22.suse.cz>
 <20180705071839.GB30187@techadventures.net>
 <20180705123017.GA31959@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705123017.GA31959@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On Thu 05-07-18 14:30:17, Oscar Salvador wrote:
> On Thu, Jul 05, 2018 at 09:18:39AM +0200, Oscar Salvador wrote:
> >  
> > > This is more than unexpected. The patch merely move the alignment check
> > > up. I will try to investigate some more but I am off for next four days
> > > and won't be online most of the time.
> > > 
> > > Btw. does the same happen if you keep do_brk helper and add the length
> > > sanitization there as well?
> 
> I took another look.
> The problem was that while deleting the check in do_brk_flags(), this left then "len"
> local variable with an unset value, but we need it to contain the request value
> because we do use it in further calls in do_brk_flags(), like:

Very well spotted. Thanks for noticing! I am really half online so I
cannot give it much testing right now. But here is the updated patch
with the changelog. I cannot really tell whether the other change to
align up in load_elf_library is correct as well. It seems OK but
everything around elf loading is tricky from my past experience.

My patch simply makes vm_brk_flags behavior consistent so I believe we
should do that regardless (unless I've screwed something else here of
course).
