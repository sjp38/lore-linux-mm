Date: Tue, 11 Nov 2008 15:30:28 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
Message-ID: <20081111153028.422b301a@bike.lwn.net>
In-Reply-To: <491A0483.3010504@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
	<1226409701-14831-3-git-send-email-ieidus@redhat.com>
	<1226409701-14831-4-git-send-email-ieidus@redhat.com>
	<20081111150345.7fff8ff2@bike.lwn.net>
	<491A0483.3010504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

[Let's see if I can get through the rest without premature sends...]

On Wed, 12 Nov 2008 00:17:39 +0200
Izik Eidus <ieidus@redhat.com> wrote:

> > Actually, it occurs to me that there's no sanity checks on any of
> > the values passed in by ioctl().  What happens if the user tells
> > KSM to scan a bogus range of memory?
> >     
> 
> Well get_user_pages() run in context of the process, therefore it
> should fail in "bogus range of memory"

But it will fail in a totally silent and mysterious way.  Doesn't it
seem better to verify the values when you can return a meaningful error
code to the caller?

The other ioctl() calls have the same issue; you can start the thread
with nonsensical values for the number of pages to scan and the sleep
time.

> 
> > Any benchmarks on the runtime cost of having KSM running?
> >     
> 
> This one is problematic, ksm can take anything from 0% to 100% cpu
> its all depend on how fast you run it.
> it have 3 parameters:
> number of pages to scan before it go to sleep
> maximum number of pages to merge while we scanning the above pages 
> (merging is expensive)
> time to sleep (when runing from userspace using /dev/ksm, we actually
> do it there (userspace)

What about things like cache effects from scanning all those pages?  My
guess is that, if you're trying to run dozens of Windows guests, cache
usage is not at the top of your list of concerns, but I could be
wrong.  Usually am...

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
