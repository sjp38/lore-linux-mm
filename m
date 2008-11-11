Date: Wed, 12 Nov 2008 00:03:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
Message-ID: <20081111230306.GP10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <1226409701-14831-4-git-send-email-ieidus@redhat.com> <20081111150345.7fff8ff2@bike.lwn.net> <491A0483.3010504@redhat.com> <20081111153028.422b301a@bike.lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111153028.422b301a@bike.lwn.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Jonathan,

On Tue, Nov 11, 2008 at 03:30:28PM -0700, Jonathan Corbet wrote:
> But it will fail in a totally silent and mysterious way.  Doesn't it
> seem better to verify the values when you can return a meaningful error
> code to the caller?

I think you're right, but just because find_extend_vma will have the
effect of growing the kernel stack down. We clearly don't set it on a
stack with KVM as there's nothing to share on the stack usually - we
only set it in the guest physical memory range. And things are safe
regardless as get_user_pages is verifying the values for us. Problem
is it's using find_extend_vma because it behaves like a page fault. We
must not behave like a pagefault, we're much closer to follow_page
only than a page fault. Not a big deal, but it can be improved by
avoiding to extend the stack somehow (likely simplest is to call
find_vma twice, first time externally, we hold mmap_sem externally so
all right).

> What about things like cache effects from scanning all those pages?  My
> guess is that, if you're trying to run dozens of Windows guests, cache
> usage is not at the top of your list of concerns, but I could be
> wrong.  Usually am...

Oh that's not an issue. This is all about trading some CPU for lots of
free memory. It pays off big as so many more VM can run. With desktop
virtualization and 1G systems, you reach a RAM bottleneck much quicker
than a CPU bottleneck. Perhaps not so quick on server virtualization
but the point is this is intentional. It may be possible to compute
the jhash (that's where the cpu is spent) with instructions that don't
pollute the cpu cache but I doubt it's going to make much an huge
difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
