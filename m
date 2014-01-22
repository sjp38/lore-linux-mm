Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6096B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:45:58 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so972745pdj.2
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:45:57 -0800 (PST)
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
        by mx.google.com with ESMTPS id x3si5276670pbf.31.2014.01.22.14.45.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 14:45:56 -0800 (PST)
Received: by mail-pd0-f177.google.com with SMTP id x10so972133pdj.36
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:45:56 -0800 (PST)
Message-ID: <52E04A21.3050101@mit.edu>
Date: Wed, 22 Jan 2014 14:45:53 -0800
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
References: <20140122190816.GB4963@suse.de>
In-Reply-To: <20140122190816.GB4963@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On 01/22/2014 11:08 AM, Mel Gorman wrote:
> Cyrill,
> 
> Gimp is broken due to a kernel bug included in 3.12. It cannot open
> large files without failing memory allocations due to exceeding
> vm.max_map_count. The relevant bugzilla entries are
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=67651
> https://bugzilla.gnome.org/show_bug.cgi?id=719619#c0
> 
> They include details on how to reproduce the issue. In my case, a
> failure shows messages like this
> 
> 	(gimp:11768): GLib-ERROR **: gmem.c:110: failed to allocate 4096 bytes
> 
> 	(file-tiff-load:12038): LibGimpBase-WARNING **: file-tiff-load: gimp_wire_read(): error
> 	xinit: connection to X server lost
> 
> 	waiting for X server to shut down
> 	/usr/lib64/gimp/2.0/plug-ins/file-tiff-load terminated: Hangup
> 	/usr/lib64/gimp/2.0/plug-ins/script-fu terminated: Hangup
> 	/usr/lib64/gimp/2.0/plug-ins/script-fu terminated: Hangup
> 
> X-related junk is there was because I was using a headless server and
> xinit directly to launch gimp to reproduce the bug.
> 
> Automated bisection using mmtests (https://github.com/gormanm/mmtests)
> and the configuration file configs/config-global-dhp__gimp-simple (needs
> local web server with a copy of the image file) identified the following
> commit. Test case was simple -- try and open the large file described in
> the bug. I did not investigate the patch itself as I'm just reporting
> the results of the bisection. If I had to guess, I'd say that VMA
> merging has been affected.
> 
> d9104d1ca9662498339c0de975b4666c30485f4e is the first bad commit
> commit d9104d1ca9662498339c0de975b4666c30485f4e
> Author: Cyrill Gorcunov <gorcunov@gmail.com>
> Date:   Wed Sep 11 14:22:24 2013 -0700
> 
>     mm: track vma changes with VM_SOFTDIRTY bit
>     
>     Pavel reported that in case if vma area get unmapped and then mapped (or
>     expanded) in-place, the soft dirty tracker won't be able to recognize this
>     situation since it works on pte level and ptes are get zapped on unmap,
>     loosing soft dirty bit of course.
>     
>     So to resolve this situation we need to track actions on vma level, there
>     VM_SOFTDIRTY flag comes in.  When new vma area created (or old expanded)
>     we set this bit, and keep it here until application calls for clearing
>     soft dirty bit.
>     
>     Thus when user space application track memory changes now it can detect if
>     vma area is renewed.

Presumably some path is failing to set VM_SOFTDIRTY, thus preventing mms
from being merged.

That being said, this could cause vma blowups for programs that are
actually using this thing.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
