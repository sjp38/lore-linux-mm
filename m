From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 3/6] mmu_notifier: add event information to address
 invalidation v2
Date: Mon, 30 Jun 2014 18:57:25 -0700
Message-ID: <CA+55aFxKs=LXNw+eg8JuGSBXpBUcjEu5iLm1gfZ3NSDF=PcmPw@mail.gmail.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
	<1403920822-14488-4-git-send-email-j.glisse@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403920822-14488-4-git-send-email-j.glisse@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, peterz@infraread.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
List-Id: linux-mm.kvack.org

On Fri, Jun 27, 2014 at 7:00 PM, J=C3=A9r=C3=B4me Glisse <j.glisse@gmai=
l.com> wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> The event information will be useful [...]

That needs to be cleaned up, though.

Why the heck are you making up ew and stupid event types? Now you make
the generic VM code do stupid things like this:

+       if ((vma->vm_flags & VM_READ) && (vma->vm_flags & VM_WRITE))
+               event =3D MMU_MPROT_RANDW;
+       else if (vma->vm_flags & VM_WRITE)
+               event =3D MMU_MPROT_WONLY;
+       else if (vma->vm_flags & VM_READ)
+               event =3D MMU_MPROT_RONLY;

which makes no sense at all. The names are some horrible abortion too
("RANDW"? That sounds like "random write" to me, not "read-and-write",
which is commonly shortened RW or perhaps RDWR. Same foes for
RONLY/WONLY - what kind of crazy names are those?

But more importantly, afaik none of that is needed. Instead, tell us
why you need particular flags, and don't make up crazy names like
this. As far as I can tell, you're already passing in the new
protection information (thanks to passing in the vma), so all those
badly named states you've made up seem to be totally pointless. They
add no actual information, but they *do* add crazy code like the above
to generic code that doesn't even WANT any of this crap. The only
thing this should need is a MMU_MPROT event, and just use that. Then
anybody who wants to look at whether the protections are being changed
to read-only, they can just look at the vma->vm_flags themselves.

So things like this need to be tightened up and made sane before any
chance of merging it.

So NAK NAK NAK in the meantime.

            Linus
