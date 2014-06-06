Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f169.google.com (mail-ve0-f169.google.com [209.85.128.169])
	by kanga.kvack.org (Postfix) with ESMTP id ADBD86B00B0
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 19:16:56 -0400 (EDT)
Received: by mail-ve0-f169.google.com with SMTP id jx11so4155881veb.28
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 16:16:56 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id em3si7659987veb.76.2014.06.06.16.16.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 16:16:56 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id il7so4021832vcb.27
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 16:16:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1406061549500.9818@eggly.anvils>
References: <20140603042121.GA27177@redhat.com>
	<CALYGNiNV951SnBKdr0PEkgLbLCxy+YB6HJpafRr6CynO+a1sdQ@mail.gmail.com>
	<alpine.LSU.2.11.1406031524470.7878@eggly.anvils>
	<538F121E.9020100@oracle.com>
	<alpine.LSU.2.11.1406061549500.9818@eggly.anvils>
Date: Fri, 6 Jun 2014 16:16:55 -0700
Message-ID: <CA+55aFy939whF-vo+GyOhkyqgOEUGqAt-cmAB2gSOFHKBeGCPA@mail.gmail.com>
Subject: Re: 3.15-rc8 mm/filemap.c:202 BUG
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 6, 2014 at 4:05 PM, Hugh Dickins <hughd@google.com> wrote:
>
> [PATCH] mm: entry = ACCESS_ONCE(*pte) in handle_pte_fault
>
> Use ACCESS_ONCE() in handle_pte_fault() when getting the entry or orig_pte
> upon which all subsequent decisions and pte_same() tests will be made.
>
> I have no evidence that its lack is responsible for the mm/filemap.c:202
> BUG_ON(page_mapped(page)) in __delete_from_page_cache() found by trinity,
> and I am not optimistic that it will fix it.  But I have found no other
> explanation, and ACCESS_ONCE() here will surely not hurt.

The patch looks obviously correct to me, although like you, I have no
real reason to believe it really fixes anything. But we definitely
should just load it once, since it's very much an optimistic load done
before we take the real lock and re-compare.

I'm somewhat dubious whether it actually would change code generation
- it doesn't change anything with the test-configuration I tried with
- but it's unquestionably a good patch. And hey, maybe some
configurations have sufficiently different code generation that gcc
actually _can_ sometimes do reloads, perhaps explaining why some
people see problems. So it's certainly worth testing even if it
doesn't make any change to code generation with *my* compiler and
config..

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
