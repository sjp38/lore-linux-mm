Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CAC7D6B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 15:47:28 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id q67so5378467oig.14
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 12:47:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r47si3021531otc.479.2017.12.08.12.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 12:47:27 -0800 (PST)
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
 <87bmjbks4c.fsf@concordia.ellerman.id.au>
 <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
 <20171207195727.GA26792@bombadil.infradead.org>
 <87shclh3zc.fsf@concordia.ellerman.id.au> <20171208142714.GB7793@amd>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <289f0cc8-9e24-fc38-cb83-4223f9923940@redhat.com>
Date: Fri, 8 Dec 2017 21:47:21 +0100
MIME-Version: 1.0
In-Reply-To: <20171208142714.GB7793@amd>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On 12/08/2017 03:27 PM, Pavel Machek wrote:
> On Fri 2017-12-08 22:08:07, Michael Ellerman wrote:
>> If we had a time machine, the right set of flags would be:
>>
>>    - MAP_FIXED:   don't treat addr as a hint, fail if addr is not free
>>    - MAP_REPLACE: replace an existing mapping (or force or clobber)

> Actually, if we had a time machine... would we even provide
> MAP_REPLACE functionality?

Probably yes.  ELF loading needs to construct a complex set of mappings 
from a single file.  munmap (to create a hole) followed by mmap would be 
racy because another thread could have reused the gap in the meantime. 
The only alternative to overriding existing mappings would be mremap 
with MREMAP_FIXED, and that doesn't look like an improvement API-wise.

(The glibc dynamic linker uses an mmap call with an increased length to 
reserve address space and then loads additional segments with MAP_FIXED 
at the offsets specified in the program header.)

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
