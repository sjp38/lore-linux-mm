Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4886B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 11:23:16 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id t37so18935169qtg.6
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:23:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si992315qty.275.2017.08.11.08.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Aug 2017 08:23:15 -0700 (PDT)
Message-ID: <1502464992.6577.48.camel@redhat.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Fri, 11 Aug 2017 11:23:12 -0400
In-Reply-To: <20170810152352.GZ23863@dhcp22.suse.cz>
References: <20170806140425.20937-1-riel@redhat.com>
	 <20170806140425.20937-3-riel@redhat.com>
	 <20170810152352.GZ23863@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Thu, 2017-08-10 at 17:23 +0200, Michal Hocko wrote:
> On Sun 06-08-17 10:04:25, Rik van Riel wrote:
> [...]
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 17921b0390b4..db1fb2802ecc 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -659,6 +659,13 @@ static __latent_entropy int dup_mmap(struct
> > mm_struct *mm,
> > A 		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
> > A 		tmp->vm_next = tmp->vm_prev = NULL;
> > A 		file = tmp->vm_file;
> > +
> > +		/* With VM_WIPEONFORK, the child gets an empty
> > VMA. */
> > +		if (tmp->vm_flags & VM_WIPEONFORK) {
> > +			tmp->vm_file = file = NULL;
> > +			tmp->vm_ops = NULL;
> > +		}
> 
> What about VM_SHARED/|VM)MAYSHARE flags. Is it OK to keep the around?
> At
> least do_anonymous_page SIGBUS on !vm_ops && VM_SHARED. Or do I miss
> where those flags are cleared?

Huh, good spotting.  That makes me wonder why the test case that
Mike and I ran worked just fine on a MAP_SHARED|MAP_ANONYMOUS VMA,
and returned zero-filled memory when read by the child process.

OK, I'll do a minimal implementation for now, which will return
-EINVAL if MADV_WIPEONFORK is called on a VMA with MAP_SHARED
and/or an mmapped file.

It will work the way it is supposed to with anonymous MAP_PRIVATE
memory, which is likely the only memory it will be used on, anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
