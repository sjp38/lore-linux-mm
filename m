Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id AC5086B0037
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 17:05:04 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id l13so754579iga.16
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 14:05:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lb5si4762513igb.1.2014.07.08.14.05.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 14:05:03 -0700 (PDT)
Date: Tue, 8 Jul 2014 14:05:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Don't forget to set softdirty on file mapped fault
Message-Id: <20140708140501.6c293226bfd87e4dff7ef7fb@linux-foundation.org>
In-Reply-To: <20140708205448.GH17860@moon.sw.swsoft.com>
References: <20140708192151.GD17860@moon.sw.swsoft.com>
	<20140708131920.2a857d573e8cc89780c9fa1c@linux-foundation.org>
	<20140708204017.GG17860@moon.sw.swsoft.com>
	<20140708134511.4a32b7400a952541a31e9078@linux-foundation.org>
	<20140708205448.GH17860@moon.sw.swsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

On Wed, 9 Jul 2014 00:54:48 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Tue, Jul 08, 2014 at 01:45:11PM -0700, Andrew Morton wrote:
> > 
> > The user doesn't know or care about pte bits.
> > 
> > What actually *happens*?  Does criu migration hang?  Does it lose data?
> > Does it take longer?
> 
> Ah, I see. Yes, the softdirty bit might be lost that usespace program
> won't see that a page was modified. So data lose is possible.
> 
> > IOW, what would an end-user's bug report look like?
> > 
> > It's important to think this way because a year from now some person
> > we've never heard of may be looking at a user's bug report and
> > wondering whether backporting this patch will fix it.  Amongst other
> > reasons.
> 
> Here is updated changelog, sounds better?
> ---
> 
> In case if page fault happend on dirty filemapping the newly created pte
> may loose softdirty bit thus if a userspace program is tracking memory
> changes with help of a memory tracker (CONFIG_MEM_SOFT_DIRTY) it might
> miss modification of a memory page (which in worts case may lead to
> data inconsistency).

Much better, thanks.

It's a rather gross-looking bug and data inconsistency sounds serious. 
Do you think a -stable backport is needed?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
