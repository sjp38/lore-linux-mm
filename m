Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 837326B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 15:40:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so1364809wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 12:40:50 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id m197si39074684wmd.77.2016.04.28.12.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 12:40:49 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id n129so2015224wmn.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 12:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160428115858.GE31489@dhcp22.suse.cz>
References: <9459.1461686910@turing-police.cc.vt.edu>
	<20160427123139.GA2230@dhcp22.suse.cz>
	<CAMJBoFPWNx6UTqyw1XF46fZYNi=nBjHXNdWz+SDokqG3xEkjAA@mail.gmail.com>
	<20160428115858.GE31489@dhcp22.suse.cz>
Date: Thu, 28 Apr 2016 21:40:48 +0200
Message-ID: <CAMJBoFM3HYpfPRD2di6=QF_Ebo1fOmNCLPWzXF2RgWKB4cB6GA@mail.gmail.com>
Subject: Re: Confusing olddefault prompt for Z3FOLD
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Apr 28, 2016 at 1:58 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 28-04-16 13:35:45, Vitaly Wool wrote:
>> On Wed, Apr 27, 2016 at 2:31 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Tue 26-04-16 12:08:30, Valdis Kletnieks wrote:
>> >> Saw this duplicate prompt text in today's linux-next in a 'make oldconfig':
>> >>
>> >> Low density storage for compressed pages (ZBUD) [Y/n/m/?] y
>> >> Low density storage for compressed pages (Z3FOLD) [N/m/y/?] (NEW) ?
>> >>
>> >> I had to read the help texts for both before I clued in that one used
>> >> two compressed pages, and the other used 3.
>> >>
>> >> And 'make oldconfig' doesn't have a "Wait, what?" option to go back
>> >> to a previous prompt....
>> >>
>> >> (Change Z3FOLD prompt to "New low density" or something? )
>> >
>> > Or even better can we only a single one rather than 2 algorithms doing
>> > the similar thing? I wasn't following this closely but what is the
>> > difference to have them both?
>>
>> The v3 version of z3fold doesn't claim itself to be a low density storage :)
>> The reasons to have them both are listed in [1] and mentioned in [2].
>>
> Thanks for the pointer!
>
>> [1] https://lkml.org/lkml/2016/4/25/526
>
>> * zbud is 30% less object code
>
> This sounds like a lot but in fact:
>    text    data     bss     dec     hex filename
>    2063     104       8    2175     87f mm/zbud.o
>    3467     104       8    3579     dfb mm/z3fold.o

I get significantly larger code on an ARM64 machine...

> Does this difference actually matter for somebody to not use z3fold if
> the overal savings in the compressed memory are better? I also suspect
> that even small configs might not save too much because of the internal
> fragmentation.

Probably not, but I'm not the one to ask here. If I didn't want to
make something more memory efficient I wouldn't start on z3fold :)

>> * some system configurations might break if we removed zbud
>
> Why would they break? Are the two incompatible? Or to be more specific
> what should be the criteria to chose one over the other?
>
>> * zbud exports its own API while z3fold is designed to work via zpool
>
> $ git grep EXPORT mm/zbud.c include/linux/zbud.h
> $
>
> So the API can be used only from the kernel, right? I haven't checked
> users but why does the API actually matters.
>
> Or is there any other API I have missed.

Not sure really. zswap used to call zbud functions directly rather
than via zpool. z3fold was only intended to be used via zpool. That of
course may be changed, but I consider it right to have something
proven and working side-by-side with the new stuff and if the new
stuff supersedes the old one, well, we can remove the latter later.

>> * limiting the amount of zpool users doesn't make much sense to me,
>>   after all :)
>
> I am not sure I understand this part. Could you be more specific?

Well, the thought was trivial: if there is an API which provides
abstraction for compressed objects storage, why not have several users
of it rather than 1,5?  What we need to do is to provide a better
documentation (I must admit I wasn't that good in doing this) on when
to use what.

Thanks,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
