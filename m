Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7595A6B00BC
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 18:08:01 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o8AM7Sh9006646
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 15:07:29 -0700
Received: by iwn33 with SMTP id 33so3428935iwn.14
        for <linux-mm@kvack.org>; Fri, 10 Sep 2010 15:07:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100910235022.74ec04de@basil.nowhere.org>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1284092586-1179-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <AANLkTikV9nXxMW8X9Wq+wGaJfzMEAmzTFrDNf8Aq4cTs@mail.gmail.com> <20100910235022.74ec04de@basil.nowhere.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 10 Sep 2010 15:07:08 -0700
Message-ID: <AANLkTinFqM4BSD0jkrqkrNxg-o+3eC6QQ6zq8jKdaLJx@mail.gmail.com>
Subject: Re: [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 10, 2010 at 2:50 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> Btw, why isn't the code in __page_set_anon_rmap() also doing this
>> cleaner version (ie a single "if (PageAnon(page)) return;" up front)?
>
> Perhaps I misunderstand the question, but __page_set_anon_rmap
> should handle Anon pages, shouldn't it?

I'm talking about this:

    if (!exclusive) {
        if (PageAnon(page))
            return;
        anon_vma = anon_vma->root;
    } else {
        .. big bad comment ...
        if (PageAnon(page))
            return;
    }

where both sides of the if-statement start off doing the same thing.

It would be much cleaner to just do

    ... big _comprehensible_ comment ...
    if (PageAnon(page))
        return;

    if (!exclusive)
        anon_vma = anon_vma->root;

which avoids that silly else that just does something that we always do.

The reason I reacted is that Naoya-san's patch did that cleaner
version for the hugetlb case. So when I compared it to the non-hugetlb
case I just went "Ewww..."

                             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
