Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id EF5B26B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 13:02:24 -0400 (EDT)
Received: by qgez77 with SMTP id z77so13309683qge.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 10:02:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si9049990qkl.20.2015.09.09.10.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 10:02:24 -0700 (PDT)
Date: Wed, 9 Sep 2015 19:02:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 06/12] userfaultfd: selftest: avoid my_bcmp false
 positives with powerpc
Message-ID: <20150909170219.GD10639@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
 <1441745010-14314-7-git-send-email-aarcange@redhat.com>
 <1441767026.7854.12.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441767026.7854.12.camel@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On Wed, Sep 09, 2015 at 12:50:26PM +1000, Michael Ellerman wrote:
> On Tue, 2015-09-08 at 22:43 +0200, Andrea Arcangeli wrote:
> > Keep a non-zero placeholder after the count, for the my_bcmp
> > comparison of the page against the zeropage. The lockless increment
> > between 255 to 256 against a lockless my_bcmp could otherwise return
> > false positives on ppc32le.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  tools/testing/selftests/vm/userfaultfd.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> Without groking what the code is doing, this fix makes the test pass on my
> ppc64le box.

On ppc byte reads are "more" out of order, so you can read byte 1
before byte 0. This doesn't seem to happen on x86 (even though
smp_rmb() is not a noop on x86). Now the code didn't even have an
actual compiler barrier but gcc is unlikely to unroll the loop in a
unordered way so that wasn't a problem, but this patch takes care of
gcc too.

One side does a inc++ on a long long. The other side read byte 1
before byte 0, and check if they're both zero. When the inc long long
var transitions from 255 to 256 if you read it in reverse with little
endian, you'll see 0 0 and so my_bcmp would think the page is full of
zeros.

my_bcmp checks that we didn't map a zeropage in there by mistake (like
it would happen if userfaultfd wasn't registered on the anonymous
holes). So instead of relaying on the counter to be always > 0, I
added a further word after the counter that is never changing and not
zero, so we don't have to use any memory barrier for those out of
order checks.

On a side note (feel free to skip this part as it's userland): this is
also why I couldn't use bcmp because bcmp and memcmp return false
positive zeroes if the memory changes under it. In the sse4 unrolled
loop if it finds a difference, it can't tell if it should return > or
< 0 because it's a ptest and not a cmp insn, so then it has to repeat
the memory comparison (re-reading from memory a potentially different
copy of the memory that could have become equal). Problem is it's not
restarting the unrolled loop from where it stopped it, if this final
comparison returns zero and it's not the last byte to compare. In
short glibc memcmp/bcmp can very well return 0 before comparing all
memory that it is told to compare, if the memory is changing under
memcmp/bcmp.

It'd be enough to restart the unrolled loop if the "length" isn't zero
and the last final comparison returned zero, to fix memcmp/bcmp in
glibc. It's not getting fixed because it's not a bug by the C
standard, but it makes the SIMD accellerated bcmp/memcmp in glibc
unusable for lockless fast-path comparisons as it would lead to false
positives that would degrade performance. For example if glibc memcmp
was used to build the stable tree in KSM, it would lead to superfluous
write protections. KSM is in kernel of course so it's not affected by
the memcmp glibc implementation, but similar things can happen in
userland (like I found out the hard way in the userfaultfd program).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
