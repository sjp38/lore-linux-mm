Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 51E749003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 11:36:06 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so117692917wib.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:36:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bd2si19689170wib.97.2015.07.21.08.36.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 08:36:04 -0700 (PDT)
Message-ID: <55AE66DF.1060600@suse.cz>
Date: Tue, 21 Jul 2015 17:35:59 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add mlock
 flags to enable it
References: <1436288623-13007-1-git-send-email-emunson@akamai.com> <1436288623-13007-4-git-send-email-emunson@akamai.com> <20150708132351.61c13db6@lwn.net> <20150708203456.GC4669@akamai.com> <20150708151750.75e65859@lwn.net> <20150709184635.GE4669@akamai.com> <20150710101118.5d04d627@lwn.net> <20150710161948.GF4669@akamai.com>
In-Reply-To: <20150710161948.GF4669@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 07/10/2015 06:19 PM, Eric B Munson wrote:
> On Fri, 10 Jul 2015, Jonathan Corbet wrote:
>
>> On Thu, 9 Jul 2015 14:46:35 -0400
>> Eric B Munson <emunson@akamai.com> wrote:
>>
>>>> One other question...if I call mlock2(MLOCK_ONFAULT) on a range that
>>>> already has resident pages, I believe that those pages will not be locked
>>>> until they are reclaimed and faulted back in again, right?  I suspect that
>>>> could be surprising to users.
>>>
>>> That is the case.  I am looking into what it would take to find only the
>>> present pages in a range and lock them, if that is the behavior that is
>>> preferred I can include it in the updated series.
>>
>> For whatever my $0.02 is worth, I think that should be done.  Otherwise
>> the mlock2() interface is essentially nondeterministic; you'll never
>> really know if a specific page is locked or not.
>>
>> Thanks,
>>
>> jon
>
> Okay, I likely won't have the new set out today then.  This change is
> more invasive.  IIUC, I need an equivalent to __get_user_page() skips
> pages which are not present instead of faulting in and the call chain to
> get to it.  Unless there is an easier way that I am missing.

IIRC having page PageMlocked and put on unevictable list isn't necessary 
to prevent it from being reclaimed. It's just to prevent it from being 
scanned for reclaim in the first place. When attempting to unmap the 
page, vma flags are still checked, see the code in try_to_unmap_one(). 
You should probably extend the checks to your new VM_ flag as it is done 
for VM_LOCKED and then you shouldn't need to walk the pages to mlock 
them (although it would probably still be better for the accounting 
accuracy).

> Eric
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
