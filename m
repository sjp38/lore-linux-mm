Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C03E06B0518
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 12:59:05 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id r200-v6so20677209wmg.1
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 09:59:05 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id k131si3397448wmf.170.2018.11.15.09.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 09:59:04 -0800 (PST)
Date: Thu, 15 Nov 2018 18:58:58 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH RFC 3/6] kexec: export PG_offline to VMCOREINFO
Message-ID: <20181115175858.GC25056@zn.tnic>
References: <20181114211704.6381-1-david@redhat.com>
 <20181114211704.6381-4-david@redhat.com>
 <20181115061923.GA3971@dhcp-128-65.nay.redhat.com>
 <20181115111023.GC26448@zn.tnic>
 <4aa5d39d-a923-87de-d646-70b9cbfe62f0@redhat.com>
 <20181115115213.GE26448@zn.tnic>
 <9d19a844-9ae0-9520-c32a-0a4491f8de43@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <9d19a844-9ae0-9520-c32a-0a4491f8de43@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Dave Young <dyoung@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Baoquan He <bhe@redhat.com>, Omar Sandoval <osandov@fb.com>, Arnd Bergmann <arnd@arndb.de>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Lianbo Jiang <lijiang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>

On Thu, Nov 15, 2018 at 01:01:17PM +0100, David Hildenbrand wrote:
> Just saying that "I'm not the first to do it, don't hit me with a stick" :)

:-)

> Indeed. And we still have without makedumpfile. I think you are aware of
> this, but I'll explain it just for consistency: PG_hwpoison

No, I appreciate an explanation very much! So thanks for that. :)

> At some point we detect a HW error and mask a page as PG_hwpoison.
> 
> makedumpfile knows how to treat that flag and can exclude it from the
> dump (== not access it). No crash.
> 
> kdump itself has no clue about old "struct pages". Especially:
> a) Where they are located in memory (e.g. SPARSE)
> b) What their format is ("where are the flags")
> c) What the meaning of flags is ("what does bit X mean")
> 
> In order to know such information, we would have to do parsing of quite
> some information inside the kernel in kdump. Basically what makedumpfile
> does just now. Is this feasible? I don't think so.
> 
> So we would need another approach to communicate such information as you
> said. I can't think of any, but if anybody reading this has an idea,
> please speak up. I am interested.

Yeah but that ship has sailed. And even if we had a great idea, we'd
have to support kdump before and after the idea. And that would be a
serious mess.

And if you have a huge box with gazillion piles of memory and an alpha
particle passes through a bunch of them on its way down to the earth's
core, and while doing so, flips a bunch of bits, you need to go and
collect all those regions and update some list which you then need to
shove into the second kernel.

And you probably need to do all that through perhaps a piece of memory
which is used for communication between first and second kernel and that
list better fit in there, or you need to realloc. And that piece of
memory's layout needs to be properly defined so that the second kernel
can parse it correctly.

And so on...

> The *only* way right now we would have to handle such scenarios:
> 
> 1. While dumping memory and we get a machine check, fake reading a zero
> page instead of crashing.
> 2. While dumping memory and we get a fault, fake reading a zero page
> instead of crashing.

Yap.

> Indeed, and the basic design is to export these flags. (let's say
> "unfortunately", being able to handle such stuff in kdump directly would
> be the dream).

Well, AFAICT, the minimum work you need to always do before starting the
dumping is somehow generate that list of pages or ranges to not dump.
And that work needs to be done by the first or the second kernel, I'd
say.

If the first kernel would do it, then you'd have to probably have
callbacks to certain operations which go and add ranges or pages to
exclude, to a list which is then readily accessible to the second
kernel. Which means, when you reserve memory for the second kernel,
you'd have to reserve memory also for such a list.

But then what do you do when that memory gets filled up...?

So I guess exporting those things in vmcoreinfo is probably the only
thing we *can* do in the end.

Oh well, enough rambling... :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
