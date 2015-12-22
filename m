Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 16D9E6B0011
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:34:26 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l126so107678171wml.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 03:34:26 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id a8si42814864wmf.107.2015.12.22.03.34.24
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 03:34:24 -0800 (PST)
Date: Tue, 22 Dec 2015 12:34:23 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
Message-ID: <20151222113422.GE3728@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
 <20151216122642.GE29775@pd.tnic>
 <1450280642.29051.76.camel@hpe.com>
 <20151216154916.GF29775@pd.tnic>
 <1450283759.20148.11.camel@hpe.com>
 <20151216174523.GH29775@pd.tnic>
 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
 <20151216181712.GJ29775@pd.tnic>
 <1450302758.20148.75.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1450302758.20148.75.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Wed, Dec 16, 2015 at 02:52:38PM -0700, Toshi Kani wrote:
> This scheme may have a problem, though.  For instance, when someone writes
> a loadable module that searches for "foo", but the "foo" entry may be
> initialized in a distro kernel/driver that cannot be modified.  Since this
> search is only necessary to obtain a range initialized by other module,
> this scenario is likely to happen.  We no longer have ability to search for
> a new entry unless we modify the code that initializes the entry first.

Since when do we pay attention to out-of-tree modules which cannot be
changed?

Regardless, we don't necessarily need to change the callers - we could
add new ones of the form walk_iomem_resource_by_type() or whatever its
name is going to be which uses the ->type attribute of the resource and
phase out the old ones slowly. New code will call the better interfaces,
we should probably even add a checkpatch rule to check for that.

> Even if we avoid strcmp() with @name in the kernel, user applications will
> continue to use @name since that is the only type available in /proc/iomem.
>  For instance, kexec has its own search function with a string name.

See above.

> When a new commonly-used search name comes up, we can define it as a new
> extended I/O resource type similar to IORESOURCE_SYSTEM_RAM.  For the
> current remaining cases, i.e. crash, kexec, and einj, they have no impact
> to performance.  Leaving these special cases aside will keep the ability to
> search for any entry without changing the kernel, and save some memory
> space from adding the new 'type'.

Again, we can leave the old interfaces at peace but going forward, we
should make the searching for resources saner and stop using silly
strings.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
