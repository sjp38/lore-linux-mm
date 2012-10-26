Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id F38836B0074
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 15:16:36 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so708511wib.2
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 12:16:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508ADD2F.6030805@redhat.com>
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
 <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com>
 <20121026132601.GC9886@gmail.com> <20121026144615.2276cd59@dull>
 <CA+55aFyS_iJcKz=-zSDK+bjYiNeEzy4T5FrrGL8HBsxTOSwpJQ@mail.gmail.com> <508ADD2F.6030805@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 Oct 2012 12:16:14 -0700
Message-ID: <CA+55aFxo5jHREHS_ftmM6Vy5+rei2KzzCbrsYJwqSB2TfvA=7w@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm,generic: only flush the local TLB in ptep_set_access_flags
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 26, 2012 at 11:57 AM, Rik van Riel <riel@redhat.com> wrote:
>
> It looks like do_wp_page also sets the write bit in the pte
> "entry" before passing it to ptep_set_access_flags, making
> that the place where the write bit is set in the pte.
>
> Is this a bug in do_wp_page?

Hmm. Right you are. That's indeed worth noting that it can indeed
change access permissions in that particular way (ie enabling writes).

So yeah, good catch. And it's ok to add the writeable bits like this
(and it can't race with hardware like the dirty bit can, since
hardware never sets writability).

In fact, it should probably be documented in the source code
somewhere. In particular, there's a very subtle requirement that you
can only set the writable bit if the dirty bit is also set at the same
time, for example.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
