Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26ED36B034C
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 02:34:01 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id a12so528825pll.21
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 23:34:01 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id d3si1568494pfh.405.2017.12.05.23.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 23:34:00 -0800 (PST)
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <5f4fc834-274a-b8f1-bda0-5bcddc5902ed@nvidia.com>
Date: Tue, 5 Dec 2017 23:33:58 -0800
MIME-Version: 1.0
In-Reply-To: <20171206070355.GA32044@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On 12/05/2017 11:03 PM, Matthew Wilcox wrote:
> On Tue, Dec 05, 2017 at 08:54:35PM -0800, Matthew Wilcox wrote:
>> On Wed, Dec 06, 2017 at 03:51:44PM +1100, Michael Ellerman wrote:
>>> Cyril Hrubis <chrubis@suse.cz> writes:
>>>
>>>> Hi!
>>>>>> MAP_FIXED_UNIQUE
>>>>>> MAP_FIXED_ONCE
>>>>>> MAP_FIXED_FRESH
>>>>>
>>>>> Well, I can open a poll for the best name, but none of those you are
>>>>> proposing sound much better to me. Yeah, naming sucks...
>>>>
>>>> Given that MAP_FIXED replaces the previous mapping MAP_FIXED_NOREPLACE
>>>> would probably be a best fit.
>>>
>>> Yeah that could work.
>>>
>>> I prefer "no clobber" as I just suggested, because the existing
>>> MAP_FIXED doesn't politely "replace" a mapping, it destroys the current
>>> one - which you or another thread may be using - and clobbers it with
>>> the new one.
>>
>> It's longer than MAP_FIXED_WEAK :-P
>>
>> You'd have to be pretty darn strong to clobber an existing mapping.
> 
> I think we're thinking about this all wrong.  We shouldn't document it as
> "This is a variant of MAP_FIXED".  We should document it as "Here's an
> alternative to MAP_FIXED".
> 
> So, just like we currently say "exactly one of MAP_SHARED or MAP_PRIVATE",
> we could add a new paragraph saying "at most one of MAP_FIXED or
> MAP_REQUIRED" and "any of the following values".
> 
> Now, we should implement MAP_REQUIRED as having each architecture
> define _MAP_NOT_A_HINT, and then #define MAP_REQUIRED (MAP_FIXED |
> _MAP_NOT_A_HINT), but that's not information to confuse users with.
> 
> Also, that lets us add a third option at some point that is Yet Another
> Way to interpret the 'addr' argument, by having MAP_FIXED clear and
> _MAP_NOT_A_HINT set.
> 
> I'm not set on MAP_REQUIRED.  I came up with some awful names
> (MAP_TODDLER, MAP_TANTRUM, MAP_ULTIMATUM, MAP_BOSS, MAP_PROGRAM_MANAGER,
> etc).  But I think we should drop FIXED from the middle of the name.
> 

In that case, maybe:

    MAP_EXACT

? ...because that's the characteristic behavior. It doesn't clobber, but
you don't need to say that in the name, now that we're not including
_FIXED_ in the middle.

thanks,
John Hubbard
NVIDIA    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
