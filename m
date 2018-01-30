Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F274D6B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:31:49 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id d14so7718540wre.6
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 01:31:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l34sor6346494eda.37.2018.01.30.01.31.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 01:31:48 -0800 (PST)
Date: Tue, 30 Jan 2018 10:31:45 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180130093145.GE25930@phenom.ffwll.local>
References: <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
 <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
 <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
 <20180124110141.GA28465@dhcp22.suse.cz>
 <36b49523-792d-45f9-8617-32b6d9d77418@daenzer.net>
 <20180124115059.GC28465@dhcp22.suse.cz>
 <381a868c-78fd-d0d1-029e-a2cf4ab06d37@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <381a868c-78fd-d0d1-029e-a2cf4ab06d37@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com
Cc: Michal Hocko <mhocko@kernel.org>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel@daenzer.net>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, amd-gfx@lists.freedesktop.org, Roman Gushchin <guro@fb.com>

On Wed, Jan 24, 2018 at 01:11:09PM +0100, Christian Konig wrote:
> Am 24.01.2018 um 12:50 schrieb Michal Hocko:
> > On Wed 24-01-18 12:23:10, Michel Danzer wrote:
> > > On 2018-01-24 12:01 PM, Michal Hocko wrote:
> > > > On Wed 24-01-18 11:27:15, Michel Danzer wrote:
> > [...]
> > > > > 2. If the OOM killer kills a process which is sharing BOs with another
> > > > > process, this should result in the other process dropping its references
> > > > > to the BOs as well, at which point the memory is released.
> > > > OK. How exactly are those BOs mapped to the userspace?
> > > I'm not sure what you're asking. Userspace mostly uses a GEM handle to
> > > refer to a BO. There can also be userspace CPU mappings of the BO's
> > > memory, but userspace doesn't need CPU mappings for all BOs and only
> > > creates them as needed.
> > OK, I guess you have to bear with me some more. This whole stack is a
> > complete uknonwn. I am mostly after finding a boundary where you can
> > charge the allocated memory to the process so that the oom killer can
> > consider it. Is there anything like that? Except for the proposed file
> > handle hack?
> 
> Not that I knew of.
> 
> As I said before we need some kind of callback that a process now starts to
> use a file descriptor, but without anything from that file descriptor mapped
> into the address space.

For more context: With DRI3 and wayland the compositor opens the DRM fd
and then passes it to the client, which then starts allocating stuff. That
makes book-keeping rather annoying.

I guess a good first order approximation would be if we simply charge any
newly allocated buffers to the process that created them, but that means
hanging onto lots of mm_struct pointers since we want to make sure we then
release those pages to the right mm again (since the process that drops
the last ref might be a totally different one, depending upon how the
buffers or DRM fd have been shared).

Would it be ok to hang onto potentially arbitrary mmget references
essentially forever? If that's ok I think we can do your process based
account (minus a few minor inaccuracies for shared stuff perhaps, but no
one cares about that).
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
