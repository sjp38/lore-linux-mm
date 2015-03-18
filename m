Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id C0D456B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:41:05 -0400 (EDT)
Received: by lbcgn8 with SMTP id gn8so27330756lbc.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 04:41:05 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id lc11si12705454lac.26.2015.03.18.04.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 04:41:04 -0700 (PDT)
Message-ID: <5509644C.40502@yandex-team.ru>
Date: Wed, 18 Mar 2015 14:41:00 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
References: <20150318083040.7838.76933.stgit@zurg> <20150318095702.GA2479@node.dhcp.inet.fi>
In-Reply-To: <20150318095702.GA2479@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 18.03.2015 12:57, Kirill A. Shutemov wrote:
> On Wed, Mar 18, 2015 at 11:30:40AM +0300, Konstantin Khlebnikov wrote:
>> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>> Each user gets private copy of the code thus nobody will be able to exploit
>> pages in the page cache. This works for statically-linked binaries. Shared
>> libraries are still vulnerable, but setting suid bit will protect them too.
>
> Hm. Do we have suid/sgid semantic defiend for non-executables?
>
> To me we should do this for all file private mappings of the suid process
> or don't do it at all.

Yeah, this patch doesn't provide full protection.
That's just a proof-of-concept.

>
> And what about forked suid process which dropped privilages. We still have
> code pages shared.

User can get access to that private copy later but new suid
applications will get their own copy at exec.
Original page-cache pages are never exposed in pte.

>
> I don't think it worth it. The only right way to fix the problem is ECC
> memory.
>

ECC seems good protection until somebody figure out how to break it too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
