Date: Tue, 11 Nov 2008 23:03:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
Message-ID: <20081111220312.GJ10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com> <1226409701-14831-2-git-send-email-ieidus@redhat.com> <1226409701-14831-3-git-send-email-ieidus@redhat.com> <1226409701-14831-4-git-send-email-ieidus@redhat.com> <20081111123851.3d944f21.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081111123851.3d944f21.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, Nov 11, 2008 at 12:38:51PM -0800, Andrew Morton wrote:
> Please fully document that interface in the changelog so that we can
> review your decisions here.  This is by far the most important
> consideration - we can change all the code, but interfaces are for
> ever.

Yes, this is the most important point in my view. Even after we make
the ksm pages swappable it'll remain an invisible change to anybody
but us (it'll work better under VM pressure, but that's about it).

> uh-oh, ioctls.

Yes, it's all ioctl based. In very short, it assigns the task and
memory region to scan, and allows to start/stop the kernel thread that
does the scan while selecting how many pages to execute per scan and
how many scans to execute per second. The more pages per scan and the
more scans per second, the higher cpu utilization of the kernel thread.

It would also be possible to submit ksm in a way that has no API at
all (besides kernel module params tunable later by sysfs to set
pages-per-scan and scan-frequency). Doing that would allow us to defer
the API decisions. But then all anonymous memory in the system will be
scanned unconditionally even if there may be little to share for
certain tasks. It would perform quite well, usually the sharable part
is the largest part so the rest wouldn't generate an huge amount of
cpu waste. There's some ram waste too, as some memory has to be
allocated for every page we want to possibly share.

In some ways removing the API would make it simpler to use for non
virtualization environments where they may want to enable it
system-wide.

> ooh, a comment!

8)

> > +		kpage = alloc_page(GFP_KERNEL |  __GFP_HIGHMEM);
> 
> Stray whitepace.
> 
> Replace with GFP_HIGHUSER.

So not a cleanup, but an improvement (I agree highuser is better, this
isn't by far any higher-priority kernel alloc and it deserves to have
lower prio in the watermarks).

> The term "shared memory" has specific meanings in Linux/Unix.  I'm
> suspecting that its use here was inappropriate but I have insufficient
> information to be able to suggest alternatives.

We could call it create_shared_anonymous_memory but then what if it
ever becomes capable of sharing pagecache too? (I doubt it will, not
in the short term at least ;)

Usually when we do these kind of tricks we use the word cloning, so
perhaps also create_cloned_memory_area, so you can later say cloned
anonymous memory or cloned shared memory page instead of just KSM
page. But then this module would become KCM and not KSM 8). Perhaps we
should just go recursive and use create_ksm_memory_area.

> Generally: this review was rather a waste of your time and of mine
> because the code is inadequately documented.

Well, this was a great review considering how little the code was
documented, definitely not a waste of time on our end, it was very
helpful and the good thing is I don't see any controversial stuff.

The two inner loops are the core of the ksm scan, and they're aren't
very simple I've to say. Documenting won't be trivial but it's surely
possible, Izik already working on it I think! Apologies if any time
was wasted on your side!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
