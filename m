Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B9ED16B0078
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:06:06 -0400 (EDT)
Received: by wizk4 with SMTP id k4so146708689wiz.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:06:06 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id r8si18703029wia.94.2015.04.28.09.06.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 09:06:05 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so111541818wic.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:06:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1430231830-7702-1-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Date: Tue, 28 Apr 2015 19:06:04 +0300
Message-ID: <CAOJsxLG0Tr2QV8P55vJDOeUPoWw8xBextQ-qzj4E+PnOk9JBsQ@mail.gmail.com>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 28, 2015 at 5:36 PM, Mel Gorman <mgorman@suse.de> wrote:
> Struct page initialisation had been identified as one of the reasons why
> large machines take a long time to boot. Patches were posted a long time ago
> to defer initialisation until they were first used.  This was rejected on
> the grounds it should not be necessary to hurt the fast paths. This series
> reuses much of the work from that time but defers the initialisation of
> memory to kswapd so that one thread per node initialises memory local to
> that node.
>
> After applying the series and setting the appropriate Kconfig variable I
> see this in the boot log on a 64G machine
>
> [    7.383764] kswapd 0 initialised deferred memory in 188ms
> [    7.404253] kswapd 1 initialised deferred memory in 208ms
> [    7.411044] kswapd 3 initialised deferred memory in 216ms
> [    7.411551] kswapd 2 initialised deferred memory in 216ms
>
> On a 1TB machine, I see
>
> [    8.406511] kswapd 3 initialised deferred memory in 1116ms
> [    8.428518] kswapd 1 initialised deferred memory in 1140ms
> [    8.435977] kswapd 0 initialised deferred memory in 1148ms
> [    8.437416] kswapd 2 initialised deferred memory in 1148ms
>
> Once booted the machine appears to work as normal. Boot times were measured
> from the time shutdown was called until ssh was available again.  In the
> 64G case, the boot time savings are negligible. On the 1TB machine, the
> savings were 16 seconds.

FWIW,

Acked-by: Pekka Enberg <penberg@kernel.org>

for the whole series.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
