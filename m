Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id C7EA26B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 00:31:48 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so493024qcs.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 21:31:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1203202019140.1842@eggly.anvils>
References: <4F68795E.9030304@kernel.org>
	<alpine.LSU.2.00.1203202019140.1842@eggly.anvils>
Date: Wed, 21 Mar 2012 12:31:47 +0800
Message-ID: <CANejiEUyPSNQ7q85ZDz-B3iHikHLgZLBNOF-p4evkxjGo5+M0g@mail.gmail.com>
Subject: Re: [RFC]swap: don't do discard if no discard option added
From: Shaohua Li <shli@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Holger Kiehl <Holger.Kiehl@dwd.de>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-mm@kvack.org

2012/3/21 Hugh Dickins <hughd@google.com>:
> On Tue, 20 Mar 2012, Shaohua Li wrote:
>>
>> Even don't add discard option, swapon will do discard, this sounds buggy=
,
>> especially when discard is slow or buggy.
>
> It's not a bug in swapon, it's an intentional feature, made explicit in
> commit 339944663273 "swap: discard while swapping only if SWAP_FLAG_DISCA=
RD"
> and in the swapon(2) manpage. =A0We were also careful in wording the swap=
on(8)
> manpage and the comment on SWAP_FLAG_DISCARD in swap.h - too lawyerly ;-?
>
> It appears to be a bug in the Vertex 2: I did receive one other such
> report on a Vertex 2 fourteen months ago, and in the absence of further
> reports, we decided to consider that user's drive defective. =A0I wonder
> if Holger's drive is defective, or if it's true of all Vertex 2s, or
> if it depends on the firmware revision, and a later revision fixes it.
>
> If the latter (if there is a firmware revision which fixes it), then
> I think it's clear that SWAP_FLAG_DISCARD should continue to behave
> as it does at present, with discard at swapon independent of it.
>
> Holger, do you have the latest firmware on this drive?
> Have any other Vertex 2 users observed this behaviour?
>
> I've seen no such problem with the original OCZ Vertex, nor with
> their Vertex 3, nor with the Intel drives I've tried (and you
> report no problem with FusionIO's, though no advantage either).
>
> But if there's no good firmware for the Vertex 2, I'm not so sure
> what to do: two reports in fourteen months, on a superseded drive -
> is that strong enough to disable a feature which appeared to offer
> some advantage on others?
>
> Is there a lower level at which we could blacklist the Vertex 2
> to disable driver support for its discard?
Holger uses raid for swap. We currently didn't do discard request
merge as low SCSI driver doesn't allow. So for the raid0 case, we
will split big discard request to chunk size, which is 512k. This will
increase discard request number. This can be fixed later. But on
the other hand, if user doesn't explictly enable discard, why enable
it? Like fs, we didn't do runtime discard and only run trim occasionally
since discard is slow.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
