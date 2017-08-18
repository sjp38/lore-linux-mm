Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E11F26B0292
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 12:28:36 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so48824960qki.1
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:28:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 129si5473550qkd.74.2017.08.18.09.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 09:28:34 -0700 (PDT)
Message-ID: <1503073709.6577.68.camel@redhat.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Fri, 18 Aug 2017 12:28:29 -0400
In-Reply-To: <20170817155033.172cf22ec143713d5cf98b4e@linux-foundation.org>
References: <20170811212829.29186-1-riel@redhat.com>
	 <20170811212829.29186-3-riel@redhat.com>
	 <20170815155114.ff9f4164eed28bf02db48fbb@linux-foundation.org>
	 <1502849899.6577.66.camel@redhat.com>
	 <20170817155033.172cf22ec143713d5cf98b4e@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org, torvalds@linux-foundation.org, willy@infradead.org

On Thu, 2017-08-17 at 15:50 -0700, Andrew Morton wrote:
> On Tue, 15 Aug 2017 22:18:19 -0400 Rik van Riel <riel@redhat.com>
> wrote:
> 
> > > > --- a/mm/madvise.c
> > > > +++ b/mm/madvise.c
> > > > @@ -80,6 +80,17 @@ static long madvise_behavior(struct
> > > > vm_area_struct *vma,
> > > > __		}
> > > > __		new_flags &= ~VM_DONTCOPY;
> > > > __		break;
> > > > +	case MADV_WIPEONFORK:
> > > > +		/* MADV_WIPEONFORK is only supported on
> > > > anonymous
> > > > memory. */
> > > > +		if (vma->vm_file || vma->vm_flags & VM_SHARED)
> > > > {
> > > > +			error = -EINVAL;
> > > > +			goto out;
> > > > +		}
> > > > +		new_flags |= VM_WIPEONFORK;
> > > > +		break;
> > > > +	case MADV_KEEPONFORK:
> > > > +		new_flags &= ~VM_WIPEONFORK;
> > > > +		break;
> > > > __	case MADV_DONTDUMP:
> > > > __		new_flags |= VM_DONTDUMP;
> > > > __		break;
> > > 
> > > It seems odd to permit MADV_KEEPONFORK against other-than-anon
> > > vmas?
> > 
> > Given that the only way to set VM_WIPEONFORK is through
> > MADV_WIPEONFORK, calling MADV_KEEPONFORK on an
> > other-than-anon vma would be equivalent to a noop.
> > 
> > If new_flags == vma->vm_flags, madvise_behavior() will
> > immediately exit.
> 
> Yes, but calling MADV_WIPEONFORK against an other-than-anon vma is
> presumably a userspace bug.A A A bug which will probably result in
> userspace having WIPEONFORK memory which it didn't want.A A The kernel
> can trivially tell userspace that it has this bug so why not do so?

Uh, what?

Calling MADV_WIPEONFORK on an other-than-anon vma results
in NOT getting VM_WIPEONFORK semantics on that VMA.

The code you are commenting on is the bit that CLEARS
the VM_WIPEONFORK code, not the bit where it gets set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
