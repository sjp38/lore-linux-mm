Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id A61BB6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 14:19:30 -0500 (EST)
Received: by mail-bk0-f54.google.com with SMTP id u14so25088bkz.13
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 11:19:29 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id q2si7763844bkr.259.2014.01.22.11.19.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 11:19:29 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id z5so664198lbh.40
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 11:19:29 -0800 (PST)
Date: Wed, 22 Jan 2014 23:19:28 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [Bug 67651] Bisected: Lots of fragmented mmaps cause gimp to
 fail in 3.12 after exceeding vm_max_map_count
Message-ID: <20140122191928.GQ1574@moon>
References: <20140122190816.GB4963@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122190816.GB4963@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, gnome@rvzt.net, drawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Wed, Jan 22, 2014 at 07:08:16PM +0000, Mel Gorman wrote:
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

Thanks a lot for report, Mel! I'm investigating...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
