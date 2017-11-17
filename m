Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DED616B0276
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:56:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 4so3841175pge.8
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:56:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j1sor1773795pld.51.2017.11.17.14.56.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Nov 2017 14:56:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 17 Nov 2017 23:56:21 +0100
Message-ID: <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang Wang <wen.gang.wang@oracle.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Fri, Nov 17, 2017 at 11:30 PM, Wengang Wang <wen.gang.wang@oracle.com> wrote:
> Kasan advanced check, I'm going to add this feature.
> Currently Kasan provide the detection of use-after-free and out-of-bounds
> problems. It is not able to find the overwrite-on-allocated-memory issue.
> We sometimes hit this kind of issue: We have a messed up structure
> (usually dynamially allocated), some of the fields in the structure were
> overwritten with unreasaonable values. And kernel may panic due to those
> overeritten values. We know those fields were overwritten somehow, but we
> have no easy way to find out which path did the overwritten. The advanced
> check wants to help in this scenario.
>
> The idea is to define the memory owner. When write accesses come from
> non-owner, error should be reported. Normally the write accesses on a given
> structure happen in only several or a dozen of functions if the structure
> is not that complicated. We call those functions "allowed functions".
> The work of defining the owner and binding memory to owner is expected to
> be done by the memory consumer. In the above case, memory consume register
> the owner as the functions which have write accesses to the structure then
> bind all the structures to the owner. Then kasan will do the "owner check"
> after the basic checks.
>
> As implementation, kasan provides a API to it's user to register their
> allowed functions. The API returns a token to users.  At run time, users
> bind the memory ranges they are interested in to the check they registered.
> Kasan then checks the bound memory ranges with the allowed functions.
>
>
> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>
> 0001-mm-kasan-make-space-in-shadow-bytes-for-advanced-che.patch
> 0002-mm-kasan-pass-access-mode-to-poison-check-functions.patch
> 0003-mm-kasan-do-advanced-check.patch
> 0004-mm-kasan-register-check-and-bind-it-to-memory.patch
> 0005-mm-kasan-add-advanced-check-test-case.patch
>
>  include/linux/kasan.h |   16 ++
>  lib/test_kasan.c      |   73 ++++++++++++
>  mm/kasan/kasan.c      |  292 +++++++++++++++++++++++++++++++++++++++++++-------
>  mm/kasan/kasan.h      |   42 +++++++
>  mm/kasan/report.c     |   44 ++++++-
>  5 files changed, 424 insertions(+), 43 deletions(-)


+kasan-dev mailing list

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
