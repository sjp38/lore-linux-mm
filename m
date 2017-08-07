Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2DDB6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:42:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b184so1061233oih.9
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:42:43 -0700 (PDT)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id h76si5559093oic.33.2017.08.07.12.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:42:42 -0700 (PDT)
Received: by mail-io0-x229.google.com with SMTP id c74so6240015iod.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:42:42 -0700 (PDT)
Message-ID: <1502134960.1803.15.camel@gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 07 Aug 2017 15:42:40 -0400
In-Reply-To: <CAN=P9pi+8ufOFQJbKFDeAqHeBzBzvxsuG-dFD=_TpmRyU0vqmQ@mail.gmail.com>
References: 
	<CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
	 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
	 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
	 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
	 <1502131739.1803.12.camel@gmail.com>
	 <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
	 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
	 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
	 <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
	 <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com>
	 <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com>
	 <CAGXu5j+x=vFrd7Owu=CgQcF7YtFAgPxUVo6G=Jzk6fo6mOQZqg@mail.gmail.com>
	 <CAN=P9pg25a80so+RFxpUkm1=JAVtOj_T6CaO3GSZc2+A-PPk6A@mail.gmail.com>
	 <CAGXu5jKD0Z=BKxKLDtjKq6sLgoa36bJZmc88k4QRPOHyRQp3BQ@mail.gmail.com>
	 <CAN=P9pi+8ufOFQJbKFDeAqHeBzBzvxsuG-dFD=_TpmRyU0vqmQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>, Kees Cook <keescook@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

On Mon, 2017-08-07 at 12:40 -0700, Kostya Serebryany wrote:
> 
> 
> On Mon, Aug 7, 2017 at 12:34 PM, Kees Cook <keescook@google.com>
> wrote:
> > (To be clear, this subthread is for dealing with _future_ changes;
> > I'm
> > already preparing the revert, which is in the other subthread.)
> > 
> > On Mon, Aug 7, 2017 at 12:26 PM, Kostya Serebryany <kcc@google.com>
> > wrote:
> > > Oh, a launcher (e.g. just using setarch) would be a huge pain to
> > deploy.
> > 
> > Would loading the executable into the mmap region work? 
> 
> This is beyond my knowledge. :( 
> Could you explain? 
> 
> If we can do this w/o a launcher (and w/o re-executing), we should
> try. 

If you launch a program with /usr/lib/ld-2.25.so /usr/bin/foo right now,
that probably already works because it disables the separate base.

There's probably a way to get ASan linked executables to disable the
separate PIE base automatically, making the exe get mapped with other
mmap allocations / libraries. I think that's the best approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
