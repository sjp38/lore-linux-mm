Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83BFA6B0005
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 19:06:37 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j6so89528733qkc.3
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 16:06:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g14si11873981qte.45.2016.08.14.16.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 16:06:36 -0700 (PDT)
Date: Mon, 15 Aug 2016 02:06:31 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160815020525-mutt-send-email-mst@kernel.org>
References: <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160813001500.yvmv67cram3bp7ug@redhat.com>
 <20160814084151.GA9248@dhcp22.suse.cz>
 <20160814165720.wcvejj7h6k7zz72a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160814165720.wcvejj7h6k7zz72a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Sun, Aug 14, 2016 at 07:57:20PM +0300, Michael S. Tsirkin wrote:
> On Sun, Aug 14, 2016 at 10:41:52AM +0200, Michal Hocko wrote:
> > On Sat 13-08-16 03:15:00, Michael S. Tsirkin wrote:
> > > On Fri, Aug 12, 2016 at 03:21:41PM +0200, Oleg Nesterov wrote:
> > > > Whats really interesting is that I still fail to understand do we really
> > > > need this hack, iiuc you are not sure too, and Michael didn't bother to
> > > > explain why a bogus zero from anon memory is worse than other problems
> > > > caused by SIGKKILL from oom-kill.c.
> > > 
> > > vhost thread will die, but vcpu thread is going on.  If it's memory is
> > > corrupted because vhost read 0 and uses that as an array index, it can
> > > do things like corrupt the disk, so it can't be restarted.
> > > 
> > > But I really wish we didn't need this special-casing.  Can't PTEs be
> > > made invalid on oom instead of pointing them at the zero page?
> > 
> > Well ptes are just made !present and the subsequent #PF will allocate
> > a fresh new page which will be a zero page as the original content is
> > gone already.
> 
> Can't we set a flag to make fixups desist from faulting
> in memory?
> 
> 
> > But I am not really sure what you mean by an invalid
> > pte. You are in a kernel thread context, aka unkillable context. How
> > would you handle SIGBUS or whatever other signal as a result of the
> > invalid access?
> 
> No need for signal - each copy from user access is already
> checked for errors.
> 
> > > And then
> > > won't memory accesses trigger pagefaults instead of returning 0?
> > 
> > See above. Zero page is just result of the lost memory content. We
> > cannot both reclaim and keep the original content.
> 
> Isn't this what decides it's a valid address so
> we need to bring in a page (in __do_page_fault)?
> 
> 
>         vma = find_vma(mm, address);
>         if (unlikely(!vma)) {
>                 bad_area(regs, error_code, address);
>                 return;
>         }       
>         if (likely(vma->vm_start <= address))
>                 goto good_area;
>         if (unlikely(!(vma->vm_flags & VM_GROWSDOWN))) {
>                 bad_area(regs, error_code, address);
>                 return;
>         }       
> 
> 
> So why can't we check a flag here, and call bad_area?
> then vhost will get an error from access to userspace
> memory and can handle it correctly.
> 
> 
> > > That
> > > would make regular copy_from_user machinery do the right thing,
> > > making vhost stop running as appropriate.
> > 
> > I must be missing something here but how would you make the kernel
> > thread context find out the invalid access. You would have to perform
> > signal handling routine after every single memory access and I fail how
> > this is any different from a special copy_from_user_mm.
> 
> No because IIUC no checks are needed as long as there
> is no fault. On fault, fixups are run, at the moment
> they bring in a page, I am saying they should
> behave as if an invalid address was accessed instead.
> 
> 
> > -- 
> > Michal Hocko
> > SUSE Labs


So fundamentally, won't the following make copy to/from user
return EFAULT?  If yes, vhost is already prepared to handle that.


diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index dc80230..e5dbee5 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1309,6 +1309,11 @@ retry:
 		might_sleep();
 	}
 
+	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags))) {
+		bad_area(regs, error_code, address);
+		return;
+	}
+
 	vma = find_vma(mm, address);
 	if (unlikely(!vma)) {
 		bad_area(regs, error_code, address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
