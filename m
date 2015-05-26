Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 565E96B0073
	for <linux-mm@kvack.org>; Tue, 26 May 2015 10:42:52 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so90569424qkg.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:42:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si9270642qks.30.2015.05.26.07.42.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 07:42:51 -0700 (PDT)
Date: Tue, 26 May 2015 16:42:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150526144247.GJ26958@redhat.com>
References: <20150524193404.GD16910@cbox>
 <20150525141525.GB26958@redhat.com>
 <20150526080848.GA27075@cbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526080848.GA27075@cbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@linaro.org>
Cc: linux-mm@kvack.org, ebru.akagunduz@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, vbabka@suse.cz, zhangyanfei@cn.fujitsu.com, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

On Tue, May 26, 2015 at 10:08:48AM +0200, Christoffer Dall wrote:
> > echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
> 
> this returns -EINVAL.
> 

Oops sorry, I haven't re-read the code, pages_to_scan 0 does not make
sense, it would only be useful for debugging purposes because it
doesn't shut off khugepaged entirely, so it is ok that it returns
-EINVAL, just it won't allow this debug tweak...

> But I'm trying now with:
> 
> echo never > /sys/kernel/mm/transparent_hugepage/enabled
> 
> > 
> > and verify the problem goes away without having to revert the patch?
> 
> will let you know, so far so good...

I only intended to disable khugepaged, to validate the theory it was
that patch that made the difference.

Increasing the sleep time is equivalent to set pages_to_scan to 0, so
you can use this instead:

echo 3600000 >/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
echo 3600000 >/sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs

In addition to knowing if it still happens with THP disables, it's
interesting to know also if it happens with THP enabled but khugepaged
disabled.

> what is memhog?  I couldn't find the utility in Google...

Somebody answered, yes it's from numactl.

> I did try with the above settings and just push a bunch of data into
> ramfs and tmpfs and indeed the sytem died very quickly (on v4.0-rc4).

That's fine, memhog just was a way to hit swap. tmpfs pages aren't
candidate for khugepaged THP collapsing, so it'd be perhaps quicker to
reproduce with something like memhog that uses anonymous memory but it
still happens, as long as you hit swap it's ok.

If other arm don't exhibit this problem, perhaps it has to do with
some difference in THP, I recall there were two models for arm.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
