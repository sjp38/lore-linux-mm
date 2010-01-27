Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B3D396B0078
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 12:45:43 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so312378fgg.8
        for <linux-mm@kvack.org>; Wed, 27 Jan 2010 09:45:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
References: <patchbomb.1264513915@v2.random>
	 <da09747e3b1d0368a0a6.1264513916@v2.random>
	 <alpine.LSU.2.00.1001271600450.25739@sister.anvils>
Date: Wed, 27 Jan 2010 19:45:41 +0200
Message-ID: <84144f021001270945k282c6169k572980a5a585f9e@mail.gmail.com>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Arnd Bergmann <arnd@arndb.de>, kyle@mcmartin.ca, deller@gmx.de, jejb@parisc-linux.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 6:37 PM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Tue, 26 Jan 2010, Andrea Arcangeli wrote:
>
>> From: Andrea Arcangeli <aarcange@redhat.com>
>>
>> Define MADV_HUGEPAGE.
>>
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>> ---
>>
>> diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mma=
n-common.h
>> --- a/include/asm-generic/mman-common.h
>> +++ b/include/asm-generic/mman-common.h
>> @@ -45,6 +45,8 @@
>> =A0#define MADV_MERGEABLE =A0 12 =A0 =A0 =A0 =A0 =A0/* KSM may merge ide=
ntical pages */
>> =A0#define MADV_UNMERGEABLE 13 =A0 =A0 =A0 =A0 =A0/* KSM may not merge i=
dentical pages */
>>
>> +#define MADV_HUGEPAGE =A0 =A0 =A0 =A015 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* W=
orth backing with hugepages */
>> +
>> =A0/* compatibility flags */
>> =A0#define MAP_FILE =A0 =A0 0
>
> It embarrasses me to find the time to comment on so trivial a patch,
> and none more interesting; but I have to say that I don't think this
> patch can be right - in two ways.
>
> You moved MADV_HUGEPAGE from 14 to 15 because someone noticed
> #define MADV_16K_PAGES 14 in arch/parisc/include/asm/mman.h?
>
> Well, if we need to respect that, then we ought to respect its
> /* The range 12-64 is reserved for page size specification. */:
> 15 would be intended for 32K pages.
>
> I don't know why parisc (even as far back as 2.4.0) wants those
> definitions: I guess to allow some peculiar-to-parisc program
> to build on Linux, yet fail with EINVAL when it runs? =A0I rather
> think they should never have been added (and perhaps could even
> be removed).
>
> But, whether 14 or 15 or something else, I expect you're preventing
> mm/madvise.c from building on alpha, mips, parisc and xtensa.
> Those arches don't include asm-generic/mman-common.h, because of
> various divergencies, of which MADV_16K_PAGES would be just one.
>
> So I think you should follow what we did with MADV_MERGEABLE:
> define it in asm-generic/mman-common.h and the four arches,
> use the expected number 14 wherever you can, and 67 for parisc.
>
> Or if you feel there's virtue in using the same number on all
> arches (it would be less confusing, yes) and want to pave that way
> (as we'd have better done with MADV_MERGEABLE), add a comment into
> four of those files to point to parisc's peculiar group, and use
> the same number 67 on all (perhaps via an asm-generic/madv-common.h).
>
> I'd take the lazy way out and follow what we did with MADV_MERGEABLE,
> unless Arnd (Mr Asm-Generic) would prefer something else.

Hey, lets bring some PARISC people to the party! Maybe MADV_16K_PAGES
can be fixed in a nice way?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
