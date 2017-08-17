Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB79C6B0491
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:50:37 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p14so5814389wrg.8
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:50:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o17si1830454wrg.433.2017.08.17.15.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:50:36 -0700 (PDT)
Date: Thu, 17 Aug 2017 15:50:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm,fork: introduce MADV_WIPEONFORK
Message-Id: <20170817155033.172cf22ec143713d5cf98b4e@linux-foundation.org>
In-Reply-To: <1502849899.6577.66.camel@redhat.com>
References: <20170811212829.29186-1-riel@redhat.com>
	<20170811212829.29186-3-riel@redhat.com>
	<20170815155114.ff9f4164eed28bf02db48fbb@linux-foundation.org>
	<1502849899.6577.66.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org, fweimer@redhat.com, colm@allcosts.net, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com, linux-api@vger.kernel.org, torvalds@linux-foundation.org, willy@infradead.org

On Tue, 15 Aug 2017 22:18:19 -0400 Rik van Riel <riel@redhat.com> wrote:

> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -80,6 +80,17 @@ static long madvise_behavior(struct
> > > vm_area_struct *vma,
> > > __		}
> > > __		new_flags &= ~VM_DONTCOPY;
> > > __		break;
> > > +	case MADV_WIPEONFORK:
> > > +		/* MADV_WIPEONFORK is only supported on anonymous
> > > memory. */
> > > +		if (vma->vm_file || vma->vm_flags & VM_SHARED) {
> > > +			error = -EINVAL;
> > > +			goto out;
> > > +		}
> > > +		new_flags |= VM_WIPEONFORK;
> > > +		break;
> > > +	case MADV_KEEPONFORK:
> > > +		new_flags &= ~VM_WIPEONFORK;
> > > +		break;
> > > __	case MADV_DONTDUMP:
> > > __		new_flags |= VM_DONTDUMP;
> > > __		break;
> > 
> > It seems odd to permit MADV_KEEPONFORK against other-than-anon vmas?
> 
> Given that the only way to set VM_WIPEONFORK is through
> MADV_WIPEONFORK, calling MADV_KEEPONFORK on an
> other-than-anon vma would be equivalent to a noop.
> 
> If new_flags == vma->vm_flags, madvise_behavior() will
> immediately exit.

Yes, but calling MADV_WIPEONFORK against an other-than-anon vma is
presumably a userspace bug.  A bug which will probably result in
userspace having WIPEONFORK memory which it didn't want.  The kernel
can trivially tell userspace that it has this bug so why not do so?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
