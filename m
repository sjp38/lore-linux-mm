Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 124DB6B02F4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:18:23 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u11so12647241qtu.10
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:18:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s3si9809861qtg.497.2017.08.15.19.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 19:18:22 -0700 (PDT)
Message-ID: <1502849899.6577.66.camel@redhat.com>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Tue, 15 Aug 2017 22:18:19 -0400
In-Reply-To: <20170815155114.ff9f4164eed28bf02db48fbb@linux-foundation.org>
References: <20170811212829.29186-1-riel@redhat.com>
	 <20170811212829.29186-3-riel@redhat.com>
	 <20170815155114.ff9f4164eed28bf02db48fbb@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org, torvalds@linux-foundation.org, willy@infradead.org

On Tue, 2017-08-15 at 15:51 -0700, Andrew Morton wrote:
> On Fri, 11 Aug 2017 17:28:29 -0400 riel@redhat.com wrote:
> 
> > A further complication is the proliferation of clone flags,
> > programs bypassing glibc's functions to call clone directly,
> > and programs calling unshare, causing the glibc pthread_atfork
> > hook to not get called.
> > 
> > It would be better to have the kernel take care of this
> > automatically.
> 
> I'll add "The patch also adds MADV_KEEPONFORK, to undo the effects of
> a
> prior MADV_WIPEONFORK." here.
> 
> I guess it isn't worth mentioning that these things can cause VMA
> merges and splits.A 

That's the same as every other Linux specific madvise operation.

> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -80,6 +80,17 @@ static long madvise_behavior(struct
> > vm_area_struct *vma,
> > A 		}
> > A 		new_flags &= ~VM_DONTCOPY;
> > A 		break;
> > +	case MADV_WIPEONFORK:
> > +		/* MADV_WIPEONFORK is only supported on anonymous
> > memory. */
> > +		if (vma->vm_file || vma->vm_flags & VM_SHARED) {
> > +			error = -EINVAL;
> > +			goto out;
> > +		}
> > +		new_flags |= VM_WIPEONFORK;
> > +		break;
> > +	case MADV_KEEPONFORK:
> > +		new_flags &= ~VM_WIPEONFORK;
> > +		break;
> > A 	case MADV_DONTDUMP:
> > A 		new_flags |= VM_DONTDUMP;
> > A 		break;
> 
> It seems odd to permit MADV_KEEPONFORK against other-than-anon vmas?

Given that the only way to set VM_WIPEONFORK is through
MADV_WIPEONFORK, calling MADV_KEEPONFORK on an
other-than-anon vma would be equivalent to a noop.

If new_flags == vma->vm_flags, madvise_behavior() will
immediately exit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
