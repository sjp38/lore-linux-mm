Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 674DF6B0012
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 20:41:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p9so7534134pfk.5
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 17:41:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t6-v6si9255178plr.503.2018.03.23.17.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 17:40:59 -0700 (PDT)
Subject: Re: [PATCH 00/11] Use global pages with PTI
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
Date: Fri, 23 Mar 2018 17:40:57 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 03/23/2018 11:26 AM, Linus Torvalds wrote:
> On Fri, Mar 23, 2018 at 10:44 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> This adds one major change from the last version of the patch set
>> (present in the last patch).  It makes all kernel text global for non-
>> PCID systems.  This keeps kernel data protected always, but means that
>> it will be easier to find kernel gadgets via meltdown on old systems
>> without PCIDs.  This heuristic is, I think, a reasonable one and it
>> keeps us from having to create any new pti=foo options
> 
> Sounds sane.
> 
> The patches look reasonable, but I hate seeing a patch series like
> this where the only ostensible reason is performance, and there are no
> performance numbers anywhere..

Well, rats.  This somehow makes things slower with PCIDs on.  I thought
I reversed the numbers, but I actually do a "grep -c GLB
/sys/kernel/debug/page_tables/kernel" and record that in my logs right
next to the output of time(1), so it's awfully hard to screw up.

This is time doing a modestly-sized kernel compile on a 4-core Skylake
desktop.

                        User Time       Kernel Time     Clock Elapsed
Baseline ( 0 GLB PTEs)  803.79          67.77           237.30
w/series (28 GLB PTEs)  807.70 (+0.7%)  68.07 (+0.7%)   238.07 (+0.3%)

Without PCIDs, it behaves the way I would expect.

I'll ask around, but I'm open to any ideas about what the heck might be
causing this.
