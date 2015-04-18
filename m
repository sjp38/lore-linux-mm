Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id CD3416B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 18:12:59 -0400 (EDT)
Received: by iebrs15 with SMTP id rs15so94304366ieb.3
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 15:12:59 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id x10si4733874igl.26.2015.04.18.15.12.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Apr 2015 15:12:59 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so45011042igb.0
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 15:12:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
References: <20150418205656.GA7972@pd.tnic>
	<CA+55aFxfGOw7VNqpDN2hm+P8w-9F2pVZf+VN9rZnDqGXe2VQTg@mail.gmail.com>
	<20150418215656.GA13928@node.dhcp.inet.fi>
	<CA+55aFxMx8xmWq7Dszu9h9dZQPGn7hj5GRBrJzh1hsQV600z9w@mail.gmail.com>
Date: Sat, 18 Apr 2015 18:12:56 -0400
Message-ID: <CA+55aFxLjBFUPYFJDGo236Ubdxy9s32gZ9VU43PA3RCkxJxdbw@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap.c:134! - page dumped because:
 VM_BUG_ON_PAGE(page_mapcount(page) != 0)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, x86-ml <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Apr 18, 2015 at 5:59 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Sat, Apr 18, 2015 at 5:56 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
>>
>> Andrea has already seen the bug and pointed to 8d63d99a5dfb as possible
>> cause. I don't see why the commit could broke anything, but it worth
>> trying to revert and test.
>
> Ahh, yes, that does look like a more likely culprit.

That said, I do think we should likely also do that

        WARN_ON_ONCE(PageHuge(page));

in __put_compound_page() rather than just silently saying "no refcount
changes for this magical case that shouldn't even happen".  If it
shouldn't happen, then we should warn about it, not try to ":handle"
some case that shouldn't happen and shouldn't matter.

Let's not play games in this area. This code has been stable for many
years, why are we suddenly doing random things here? There's something
to be said for "if it ain't broke..", and there's *definitely* a lot
to be said for "let's not complicate this even more".

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
