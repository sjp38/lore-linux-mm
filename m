Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id E5F476B025C
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 22:50:30 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so89577938igb.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 19:50:30 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id l12si6972001pdn.136.2015.09.08.19.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 19:50:30 -0700 (PDT)
Message-ID: <1441767026.7854.12.camel@ellerman.id.au>
Subject: Re: [PATCH 06/12] userfaultfd: selftest: avoid my_bcmp false
 positives with powerpc
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 09 Sep 2015 12:50:26 +1000
In-Reply-To: <1441745010-14314-7-git-send-email-aarcange@redhat.com>
References: <1441745010-14314-1-git-send-email-aarcange@redhat.com>
	 <1441745010-14314-7-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pavel Emelyanov <xemul@parallels.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, "Dr. David
 Alan Gilbert" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>

On Tue, 2015-09-08 at 22:43 +0200, Andrea Arcangeli wrote:
> Keep a non-zero placeholder after the count, for the my_bcmp
> comparison of the page against the zeropage. The lockless increment
> between 255 to 256 against a lockless my_bcmp could otherwise return
> false positives on ppc32le.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  tools/testing/selftests/vm/userfaultfd.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

Without groking what the code is doing, this fix makes the test pass on my
ppc64le box.

So if you like have a:

Tested-by: Michael Ellerman <mpe@ellerman.id.au>

cheers


git:master@linux-next(I)> ssh -t lebuntu sudo ./userfaultfd 128 32
nr_pages: 2048, nr_pages_per_cpu: 128
bounces: 31, mode: rnd racing ver poll, userfaults: 56 390 40 33 32 32 26 127 29 8 7 10 12 4 5 2
bounces: 30, mode: racing ver poll, userfaults: 247 39 29 39 28 17 40 23 21 17 18 15 14 2 2 2
bounces: 29, mode: rnd ver poll, userfaults: 140 120 169 120 90 100 136 106 46 35 14 0 1 0 0 0
bounces: 28, mode: ver poll, userfaults: 61 64 36 74 30 40 24 45 11 18 10 5 12 9 4 0
bounces: 27, mode: rnd racing poll, userfaults: 145 34 84 18 38 23 57 11 13 8 18 15 6 3 5 3
bounces: 26, mode: racing poll, userfaults: 32 23 19 43 22 23 9 21 21 15 5 12 16 5 12 2
bounces: 25, mode: rnd poll, userfaults: 92 118 107 122 95 41 50 49 27 30 61 13 2 3 0 0
bounces: 24, mode: poll, userfaults: 92 64 66 31 40 25 33 52 38 24 33 12 20 4 3 1
bounces: 23, mode: rnd racing ver, userfaults: 43 50 62 42 25 13 52 17 11 27 7 3 2 5 3 0
bounces: 22, mode: racing ver, userfaults: 18 16 24 15 18 19 39 16 15 13 7 6 8 5 9 4
bounces: 21, mode: rnd ver, userfaults: 188 195 141 104 136 99 51 30 40 32 20 23 1 0 0 0
bounces: 20, mode: ver, userfaults: 55 63 79 60 37 35 37 21 24 26 29 18 23 17 4 0
bounces: 19, mode: rnd racing, userfaults: 54 44 36 31 59 36 59 37 25 13 18 15 6 11 2 0
bounces: 18, mode: racing, userfaults: 106 73 121 36 91 62 43 37 36 27 12 12 9 11 6 1
bounces: 17, mode: rnd, userfaults: 157 146 119 121 96 78 78 75 75 25 29 10 0 1 0 0
bounces: 16, mode:, userfaults: 99 105 88 86 100 27 26 40 26 20 36 23 31 15 14 2
bounces: 15, mode: rnd racing ver poll, userfaults: 69 38 27 38 29 53 45 26 30 33 15 16 23 6 3 1
bounces: 14, mode: racing ver poll, userfaults: 40 32 61 58 39 45 12 69 67 11 12 10 4 2 2 1
bounces: 13, mode: rnd ver poll, userfaults: 125 192 161 154 153 63 53 25 53 96 2 0 0 0 0 0
bounces: 12, mode: ver poll, userfaults: 45 48 39 21 107 74 25 27 12 31 14 10 4 4 4 3
bounces: 11, mode: rnd racing poll, userfaults: 175 70 251 29 31 21 25 21 17 25 4 12 10 8 3 1
bounces: 10, mode: racing poll, userfaults: 11 19 9 10 26 10 11 4 11 2 1 1 0 2 1 0
bounces: 9, mode: rnd poll, userfaults: 102 61 96 159 109 71 57 64 34 54 53 23 13 6 0 0
bounces: 8, mode: poll, userfaults: 46 23 24 46 35 43 37 37 28 9 10 23 13 13 5 1
bounces: 7, mode: rnd racing ver, userfaults: 152 51 34 30 39 48 20 26 25 20 12 9 10 8 5 11
bounces: 6, mode: racing ver, userfaults: 19 32 40 33 29 43 23 19 15 15 11 14 4 2 5 3
bounces: 5, mode: rnd ver, userfaults: 124 114 162 132 71 84 58 61 39 47 13 22 23 7 7 0
bounces: 4, mode: ver, userfaults: 123 112 46 19 35 29 17 8 24 10 17 14 18 11 13 9
bounces: 3, mode: rnd racing, userfaults: 61 48 57 54 56 51 19 32 10 5 19 11 4 6 1 1
bounces: 2, mode: racing, userfaults: 21 12 8 14 11 17 7 13 6 10 13 5 1 2 4 2
bounces: 1, mode: rnd, userfaults: 153 121 129 139 105 101 92 83 23 46 24 0 0 0 0 0
bounces: 0, mode:, userfaults: 67 58 59 67 36 55 14 12 14 23 15 9 4 1 0 3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
