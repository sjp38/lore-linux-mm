Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91D246B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:53:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id q129so3485842oic.6
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 07:53:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m187sor2021897oib.318.2018.03.15.07.53.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 07:53:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180315115055.GD23100@dhcp22.suse.cz>
References: <20180313224240.25295-1-neelx@redhat.com> <20180314141727.GE23100@dhcp22.suse.cz>
 <CACjP9X8u8Q2Jwp3CqYGJZhUdf0ivv4qGe+ZRB4A6+Z=z0vTLNQ@mail.gmail.com> <20180315115055.GD23100@dhcp22.suse.cz>
From: Daniel Vacek <neelx@redhat.com>
Date: Thu, 15 Mar 2018 15:53:22 +0100
Message-ID: <CACjP9X8xXMXwbku7yvpGV72XGZ2ZeAcEi4vtFVe_rf9+QZ19XA@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: fix boot hang in memmap_init_zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naresh Kamboju <naresh.kamboju@linaro.org>, Sudeep Holla <sudeep.holla@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Paul Burton <paul.burton@imgtec.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>

On Thu, Mar 15, 2018 at 12:50 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 15-03-18 02:30:41, Daniel Vacek wrote:
>> On Wed, Mar 14, 2018 at 3:17 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Tue 13-03-18 23:42:40, Daniel Vacek wrote:
>> >> On some architectures (reported on arm64) commit 864b75f9d6b01 ("mm/page_alloc: fix memmap_init_zone pageblock alignment")
>> >> causes a boot hang. This patch fixes the hang making sure the alignment
>> >> never steps back.
>> >
>> > I am sorry to be complaining again, but the code is so obscure that I
>>
>> No worries, I'm glad for any review. Which code exactly you do find
>> obscure? This patch or my former fix or the original commit
>> introducing memblock_next_valid_pfn()? Coz I'd agree the original
>> commit looks pretty obscure...
>
> As mentioned in the other email, the whole going back and forth in the
> same loop is just too ugly to live.

It's not really supposed to go back, but I guess you understand.

>> > would _really_ appreciate some more information about what is going
>> > on here. memblock_next_valid_pfn will most likely return a pfn within
>> > the same memblock and the alignment will move it before the old pfn
>> > which is not valid - so the block has some holes. Is that correct?
>>
>> I do not understand what you mean by 'pfn within the same memblock'?
>
> Sorry, I should have said in the same pageblock
>
>> And by 'the block has some holes'?
>
> memblock_next_valid_pfn clearly returns pfn which is within a pageblock
> and that is why we do not initialize pages in the begining of the block
> while move_freepages_block does really expect the full pageblock to be
> initialized properly. That is the fundamental problem, right?

Yes, that's correct.

>> memblock has types 'memory' (as usable memory) and 'reserved' (for
>> unusable mem), if I understand correctly.
>
> We might not have struct pages for invalid pfns. That really depends on
> the memory mode. Sure sparse mem model will usually allocate struct
> pages for whole memory sections but that is not universally true and
> adding such a suble assumption is simply wrong.

This is gray area for me. But if I understand correctly this
assumption comes from the code. It was already there and got broken
hence I was trying to keep it. If anything needs redesigning I'm all
for it. But I was just calming the fire here. I only didn't test on
arm, which seems to be the only one different.

> I suspect you are making strong assumptions based on a very specific
> implementation which might be not true in general. That was the feeling
> I've had since the patch was proposed for the first time. This is such a
> cluttered area that I am not really sure myself, thoug.

I understand. And again this is likely correct. I'll be glad for any
assistance here. My limited knowledge is the primary cause for lack of
relevant details I guess. What I checked looks like pfn_valid is a
generic function used by all arches but arm, which seems to be the
only one to implement CONFIG_HAVE_ARCH_PFN_VALID if I didn't miss
anything. So if this config is enabled on arm, it uses it's own
version of pfn_valid(). If not, I'd expect all arches behave the same.
That's where my assumption comes from.

> --
> Michal Hocko
> SUSE Labs
