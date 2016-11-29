Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 014236B0260
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 12:48:36 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m203so305796698iom.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:48:35 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id l126si2877895itg.103.2016.11.29.09.48.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 09:48:35 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id k19so30810214iod.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 09:48:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129172854.GF9796@dhcp22.suse.cz>
References: <7189b1f6-98c3-9a36-83c1-79f2ff4099af@suse.cz> <20161122164822.GA5459@htj.duckdns.org>
 <CA+55aFwEik1Q-D0d4pRTNq672RS2eHpT2ULzGfttaSWW69Tajw@mail.gmail.com>
 <3e8eeadb-8dde-2313-f6e3-ef7763832104@suse.cz> <20161128171907.GA14754@htj.duckdns.org>
 <20161129072507.GA31671@dhcp22.suse.cz> <20161129163807.GB19454@htj.duckdns.org>
 <d50f16b5-296f-9c30-b61a-288aaef49e7e@suse.cz> <20161129171333.GE9796@dhcp22.suse.cz>
 <CA+55aFw4R7B8pAJ4TNVefdtCVAnZKY28i6_+5jQhoop60-NuQQ@mail.gmail.com> <20161129172854.GF9796@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Nov 2016 09:48:34 -0800
Message-ID: <CA+55aFxLWUj2uipfg-v+FSoxSH-ZJQrvnZP-Bs_C-Yd-Vqvcqg@mail.gmail.com>
Subject: Re: [PATCH] block,blkcg: use __GFP_NOWARN for best-effort allocations
 in blkcg
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marc MERLIN <marc@merlins.org>

On Tue, Nov 29, 2016 at 9:28 AM, Michal Hocko <mhocko@kernel.org> wrote:
> How does this warning help those who are watching the logs? What are
> they supposed to do about it? Unlike GFP_ATOMIC there is no tuning you
> can possibly do.

You can report it and it will get fixed.

It's not about tuning. It's about people like Tejun who made changes
and didn't do them right.

In other words, exactly the patch that this whole thread started with.

Except that because of the idiotic arguments about the *obvious*
patch, the patch gets delayed and not applied.

The whole __GFP_NOWARN thing is not some kind of newfangled thing that
suddenly became a problem. It's been there for decades. Why are you
arguing for stupidly removing it now?

> I am confused, how can anybody _rely_ on GFP_NOWAIT to succeed?

You can't (except perhaps during bootup).

BUT YOU HAVE TO HAVE A FALLBACK, AND SHOW THAT YOU ARE *AWARE* THAT
YOU CAN"T RELY ON IT.

Christ. What's so hard to understand about this?

And no, GFP_NOWAIT is not special. Higher orders have the exact same
issue. And they too need that __GFP_NOWARN to show that "yes, I know,
and yes, I have a fallback strategy".

Because that warning shows real bugs. Seriously. We had fix for this
pending for 4.10 already (nfsd just blithely assuming it can do big
allocations).

So stop the idiotic arguments. The whole point is that lots of people
don't think about allocations failing (and NOWAIT and friends do not
change that ONE WHIT), and __GFP_NOWARN is there exactly to show that
you thought about them.

The warning _has_ been useful. We're not hiding it by default, because
that makes the whole warning pointless.

Really.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
