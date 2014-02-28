Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 393666B0072
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 22:52:58 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so186659pbb.29
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 19:52:57 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wm7si401029pab.231.2014.02.27.19.52.56
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 19:52:56 -0800 (PST)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCHv3 0/2] mm: map few pages around fault address if they
 are in page cache
Date: Fri, 28 Feb 2014 03:52:54 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE04062F3E9@FMSMSX114.amr.corp.intel.com>
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwOe_m3cfQDGxmcBavhyQTqQQNGvACR4YPLaazM_0oyUw@mail.gmail.com>,<20140228001039.GB8034@node.dhcp.inet.fi>
In-Reply-To: <20140228001039.GB8034@node.dhcp.inet.fi>
Content-Language: en-CA
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>

I think the psbfb case is just horribly broken; they probably want to popul=
ate the entire VMA at mmap time rather than fault time.  It'll be less code=
 for them.=0A=
=0A=
ttm is more nuanced, and there're one or two other graphics drivers that ha=
ve similar requirements of "faulting around".  But all of the ones that try=
 it have the nasty feature of potentially faulting in some pages that weren=
't the one that actually faulted on, and then failing before faulting in th=
e requested one, then returning to userspace.=0A=
=0A=
Granted, this is a pretty rare case.  You'd have to be incredibly low on me=
mory to fail to allocate a page table page.  But it can happen, and shouldn=
't.=0A=
=0A=
So I was thinking about a helper that these drivers could use to "fault aro=
und" in ->fault, then Kirill let me in on ->map_pages, and I think this way=
 could work too.=0A=
=0A=
________________________________________=0A=
From: Kirill A. Shutemov [kirill@shutemov.name]=0A=
Sent: February 27, 2014 4:10 PM=0A=
To: Linus Torvalds=0A=
Cc: Kirill A. Shutemov; Andrew Morton; Mel Gorman; Rik van Riel; Andi Kleen=
; Wilcox, Matthew R; Dave Hansen; Alexander Viro; Dave Chinner; Ning Qu; li=
nux-mm; linux-fsdevel; Linux Kernel Mailing List=0A=
Subject: Re: [PATCHv3 0/2] mm: map few pages around fault address if they a=
re in page cache=0A=
=0A=
On Thu, Feb 27, 2014 at 01:28:22PM -0800, Linus Torvalds wrote:=0A=
> On Thu, Feb 27, 2014 at 11:53 AM, Kirill A. Shutemov=0A=
> <kirill.shutemov@linux.intel.com> wrote:=0A=
> > Here's new version of faultaround patchset. It took a while to tune it =
and=0A=
> > collect performance data.=0A=
>=0A=
> Andrew, mind taking this into -mm with my acks? It's based on top of=0A=
> Kirill's cleanup patches that I think are also in your tree.=0A=
>=0A=
> Kirill - no complaints from me. I do have two minor issues that you=0A=
> might satisfy, but I think the patch is fine as-is.=0A=
>=0A=
> The issues/questions are:=0A=
>=0A=
>  (a) could you test this on a couple of different architectures? Even=0A=
> if you just have access to intel machines, testing it across a couple=0A=
> of generations of microarchitectures would be good. The reason I say=0A=
> that is that from my profiles, it *looks* like the page fault costs=0A=
> are relatively higher on Ivybridge/Haswell than on some earlier=0A=
> uarchs.=0A=
=0A=
These numbers were from Ivy Bridge.=0A=
I'll bring some numbers for Westmere and Haswell.=0A=
=0A=
>  (b) I suspect we should try to strongly discourage filesystems from=0A=
> actually using map_pages unless they use the standard=0A=
> filemap_map_pages function as-is. Even with the fairly clean=0A=
> interface, and forcing people to use "do_set_pte()", I think the docs=0A=
> might want to try to more explicitly discourage people from using this=0A=
> to do their own hacks..=0A=
=0A=
We would need ->map_pages() at least for shmem/tmpfs. It should be=0A=
benefitial there.=0A=
=0A=
Also Matthew noticed that some drivers do ugly hacks like fault in whole=0A=
VMA on first page fault. IIUC, it's for performance reasons. See=0A=
psbfb_vm_fault() or ttm_bo_vm_fault().=0A=
=0A=
I thought it could be reasonable to have ->map_pages() there and do VMA=0A=
population get_user_pages() on mmap() instead.=0A=
=0A=
What do you think?=0A=
=0A=
--=0A=
 Kirill A. Shutemov=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
