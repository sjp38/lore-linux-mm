Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72D076B0575
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 16:05:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id t7so12186355qta.3
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 13:05:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d144si27050271qke.245.2017.08.01.13.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 13:05:53 -0700 (PDT)
Date: Tue, 1 Aug 2017 22:05:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2 ->
 crc32)
Message-ID: <20170801200550.GB24406@redhat.com>
References: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leesioh <solee@os.korea.ac.kr>
Cc: akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On Tue, Aug 01, 2017 at 09:07:35PM +0900, leesioh wrote:
> In ksm, the checksum values are used to check changes in page content and keep the unstable tree more stable.
> KSM implements checksum calculation with jhash2 hash function.
> However, because jhash2 is implemented in software,
> it consumes high CPU cycles (about 26%, according to KSM thread profiling results)
> 
> To reduce CPU consumption, this commit applies the crc32 hash function
> which is included in the SSE4.2 CPU instruction set.
> This can significantly reduce the page checksum overhead as follows.
> 
> I measured checksum computation 300 times to see how fast crc32 is compared to jhash2.
> With jhash2, the average checksum calculation time is about 3460ns,
> and with crc32, the average checksum calculation time is 888ns. This is about 74% less than jhash2.

crc32 may create more false positives than jhash2. crc32 only
guarantees a different value in return if fewer than N bit
changes. False positives in crc32 comparison, would result in more
unstable pages being added to the unstable tree, and if they're
changing as result of false positives it may make the unstable tree
more unstable leading to missed merges (in addition to the overhead of
adding those to the unstable tree in the first place and in addition
of risking an immediate cow post merge which would slowdown apps even
more).

I think if somebody wants a crc instead of a more proper hash (that is
less likely to generate false positives if a couple of bits changes)
it should be an option in sysfs not enabled by default, but overall I
think it's not worth this change for a downgrade to crc. There's the
risk an admin thinks it's going to make things runs faster because KSM
CPU utilization decreases, but missing the risk of increased CoWs in
app context or missed merges because of higher instability in the
unstable tree.

Still deploying hardware accelleration in the KSM hash is a
interesting idea that I don't recall has been tried. Could you try to
benchmark in userland (or kernel if you wish) software jhash2 vs
CONFIG_CRYPTO_SHA1_SSSE3 or CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL instead
of the accellerated crc?  (I don't know if GHASH API can fit our use
case though, but accellerated SHA1 sure would fit).  I suppose they'll
be slower than crc32, and probably slower than jhash2 too, however I
can't be sure by just thinking about it.

We've to also keep the floating point save and restore into account in
the real world, where ksm schedules often and may run interleaved in
the same CPU where an app uses the fpu a lot in userland (if the
interleaved app doesn't use the fpu in userland it won't create
overhead).

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
