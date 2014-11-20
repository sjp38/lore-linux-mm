Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9642E6B0071
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 10:27:05 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id f51so2231853qge.18
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 07:27:05 -0800 (PST)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id c9si3037914qcm.44.2014.11.20.07.27.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 07:27:04 -0800 (PST)
Received: by mail-qg0-f41.google.com with SMTP id j5so2239596qga.0
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 07:27:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
References: <502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<20120822032057.GA30871@google.com>
	<50345232.4090002@redhat.com>
	<20130603195003.GA31275@evergreen.ssec.wisc.edu>
	<20141114163053.GA6547@cosmos.ssec.wisc.edu>
	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
	<20141118014135.GA17252@cosmos.ssec.wisc.edu>
	<546AB1F5.6030306@redhat.com>
	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>
	<CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>
	<CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
	<546BDB29.9050403@suse.cz>
	<CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>
	<546CC0CD.40906@suse.cz>
	<CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
	<CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
	<CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
Date: Thu, 20 Nov 2014 16:27:03 +0100
Message-ID: <CANN689E2DEOF4JryO3soCr4jTZM-oWCjafvSiFpRkSi31TNeUg@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Thu, Nov 20, 2014 at 3:42 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Thu, Nov 20, 2014 at 2:14 AM, Michel Lespinasse <walken@google.com> wrote:
>> On Wed, Nov 19, 2014 at 8:58 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>>> On Wed, Nov 19, 2014 at 7:09 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>> Also from reading http://lwn.net/Articles/383162/ I understand that correctness
>>>> also depends on the hierarchy and I wonder if there's a danger of reintroducing
>>>> a bug like the one described there.
>>>
>>> If I remember right that was fixed by linking non-exclusively mapped pages to
>>> root anon_vma instead of anon_vma from vma where fault has happened.
>>> After my patch this still works. Topology hierarchy actually isn't used.
>>> Here just one selected "root' anon_vma which dies last. That's all.
>>
>> That's not how I remember it.
>
> ??? That at the end of lwn article:
>
> [quote]
> The fix is straightforward; when linking an existing page to an
> anon_vma structure,
> the kernel needs to pick the one which is highest in the process hierarchy;
> that guarantees that the anon_vma will not go away prematurely.
> [/quote]
>
> nowdays this happens in __page_set_anon_rmap():
>
> /*
> * If the page isn't exclusively mapped into this vma,
> * we must use the _oldest_ possible anon_vma for the
> * page mapping!
> */
> if (!exclusive)
>     anon_vma = anon_vma->root;
>
> The rest treeish of topology affects only performance.

Ah, I see what you mean.

IIRC the !exclusive bit is for pages coming back from swap, where we
don't have enough tracking info to remember where the page was first
created so we have to assume the worst case (i.e. that it was created
in the root anon_vma). My understanding was that we don't exercise
this in the non-swap case. Looking back into it, it seems that we are
now doing this with ksm and migrate as well, though.

The point remains though that moving pages higher than necessary in
the anon_vma hierarchy is OK from a correctness perspective but could
have bad implications from a performance perspective.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
