Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13FF96B0007
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 10:32:13 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id a12so3686612lfa.5
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 07:32:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m19sor233623lje.41.2018.02.11.07.32.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 07:32:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180211151433.xvza2mugfybyocoi@node.shutemov.name>
References: <4f64569f-b8ce-54f8-33d9-0e67216bb54c@yandex-team.ru>
 <151835937752.185602.5640977700089242532.stgit@buzz> <20180211151433.xvza2mugfybyocoi@node.shutemov.name>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sun, 11 Feb 2018 18:32:10 +0300
Message-ID: <CALYGNiMjuW4BM2tSUOUmJUu7kX0HEL1EN-YFi=cvtstQi3YeHQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/huge_memory.c: reorder operations in __split_huge_page_tail()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Sun, Feb 11, 2018 at 6:14 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sun, Feb 11, 2018 at 05:29:37PM +0300, Konstantin Khlebnikov wrote:
>> And replace page_ref_inc()/page_ref_add() with page_ref_unfreeze() which
>> is made especially for that and has semantic of smp_store_release().
>
> Nak on this part.
>
> page_ref_unfreeze() uses atomic_set() which neglects the situation in the
> comment you're removing.

Why? look into x86 smp_store_release
for PPro it use same sequence smp_wb + WRITE_ONCE
As I see spin_unlock uses exactly this macro.

Anyway if page_ref_unfreeze cannot handle races with
get_page_unless_zero() then it completely useless,

>
> You need at least explain why it's safe now.
>
> I would rather leave page_ref_inc()/page_ref_add() + explcit
> smp_mb__before_atomic().
>
> --
>  Kirill A. Shutemov
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
