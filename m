Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id C2C866B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:23:11 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so431568pbb.4
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 07:23:11 -0800 (PST)
Received: from psmtp.com ([74.125.245.200])
        by mx.google.com with SMTP id xj9si4935293pab.208.2013.11.18.07.23.09
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 07:23:10 -0800 (PST)
Date: Mon, 18 Nov 2013 10:22:55 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
Message-ID: <20131118152255.GA32168@redhat.com>
References: <20131115005049.GJ5116@anatevka.fc.hp.com>
 <20131115062417.GB9237@gmail.com>
 <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
 <5285C639.5040203@zytor.com>
 <20131115140738.GB6637@redhat.com>
 <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
 <52865CA1.5020309@zytor.com>
 <20131115183002.GE6637@redhat.com>
 <52866C0D.3050006@zytor.com>
 <52867309.4040406@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52867309.4040406@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 15, 2013 at 11:16:25AM -0800, H. Peter Anvin wrote:
> On 11/15/2013 10:46 AM, H. Peter Anvin wrote:
> > On 11/15/2013 10:30 AM, Vivek Goyal wrote:
> >>
> >> I agree taking assistance of hypervisor should be useful.
> >>
> >> One reason we use kdump for VM too because it makes life simple. There
> >> is no difference in how we configure, start and manage crash dumps
> >> in baremetal or inside VM. And in practice have not heard of lot of
> >> failures of kdump in VM environment.
> >>
> >> So while reliability remains a theoritical concern, in practice it
> >> has not been a real concern and that's one reason I think we have
> >> not seen a major push for alternative method in VM environment.
> >>
> > 
> > Another reason, again, is that it doesn't sit on all that memory.
> > 
> 
> This led me to a potentially interesting idea.  If we can tell the
> hypervisor about which memory blocks belong to kdump, we can still use
> kdump in its current form with only a few hypervisor calls thrown in.
> 
> One set of calls would mark memory ranges as belonging to kdump.  This
> would (a) make them protected,

This sounds good. We already have arch hooks to map/unmap crash kernel
ranges, crash_map_reserved_pages() and crash_unmap_reserved_pages(). Now x86,
should be able to use these hooks to tell hypervisor to remove mappings
for certain physical certain ranges and remap these back when needed. s390
already does some magic there.

> and (b) tell the hypervisor that these
> memory ranges will not be accessed and don't need to occupy physical RAM.

I am not sure if we need to do anything here. I am assuming that most of
the crashkernel memory has not been touched and does not occupy physical
memory till crash actually happens. We probably will touch only 20-30MB
of crashkernel memory during kernel load and that should ultimately make
its way to swap at some point of time.

And if that's true, then reserving 72M extra due to crashkernel=X,high
should not be a big issue in KVM guests. It will still be an issue on
physical servers though.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
