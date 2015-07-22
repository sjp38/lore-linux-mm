Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 214149003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 15:44:24 -0400 (EDT)
Received: by iggf3 with SMTP id f3so141382676igg.1
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 12:44:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y62si2398799ioi.131.2015.07.22.12.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 12:44:23 -0700 (PDT)
Date: Wed, 22 Jul 2015 12:44:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v9 7/8] proc: export idle flag via kpageflags
Message-Id: <20150722124421.3313e8f007d76b386e1d61ec@linux-foundation.org>
In-Reply-To: <20150722162528.GN23374@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<4c1eb396150ee14d7c3abf1a6f36ec8cc9dd9435.1437303956.git.vdavydov@parallels.com>
	<20150721163500.528bd39bbbc71abc3c8d429b@linux-foundation.org>
	<20150722162528.GN23374@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 22 Jul 2015 19:25:28 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> On Tue, Jul 21, 2015 at 04:35:00PM -0700, Andrew Morton wrote:
> > On Sun, 19 Jul 2015 15:31:16 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> > 
> > > As noted by Minchan, a benefit of reading idle flag from
> > > /proc/kpageflags is that one can easily filter dirty and/or unevictable
> > > pages while estimating the size of unused memory.
> > > 
> > > Note that idle flag read from /proc/kpageflags may be stale in case the
> > > page was accessed via a PTE, because it would be too costly to iterate
> > > over all page mappings on each /proc/kpageflags read to provide an
> > > up-to-date value. To make sure the flag is up-to-date one has to read
> > > /proc/kpageidle first.
> > 
> > Is there any value in teaching the regular old page scanner to update
> > these flags?  If it's doing an rmap scan anyway...
> 
> I don't understand what you mean by "regular old page scanner". Could
> you please elaborate?

Whenever kswapd or direct reclaim perform an rmap scan, take that as an
opportunity to also update PageIdle().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
