Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id ECE9A6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 12:28:24 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id b14so2395878wer.16
        for <linux-mm@kvack.org>; Fri, 27 Jan 2012 09:28:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
References: <1327557574-6125-1-git-send-email-roland@kernel.org>
 <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
From: Roland Dreier <roland@kernel.org>
Date: Fri, 27 Jan 2012 09:28:03 -0800
Message-ID: <CAL1RGDVBR49QrAbkZ0Wa9Gh98HTwjtsQbFQ4Ws3Ra7rEjT1Mng@mail.gmail.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages() parameters
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-rdma@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Sigh, what a mess ... it seems what we really want to do is know
> if userspace might trigger a COW because or not, and only do a
> preemptive COW in that case. =A0(We're not really concerned with
> userspace fork()ing and setting up a COW in the future, since that's
> what we have MADV_DONTFORK for)
>
> The status quo works for userspace anonymous mappings but
> it doesn't work for my case of mapping a kernel buffer read-only
> into userspace. =A0And fixing my case breaks the anonymous case.
> Do you see a way out of this dilemma? =A0Do we need to add yet
> another flag to get_user_pages()?

So thinking about this a bit more... it seems what we want is at least
to first order that we do the equivalent of write=3D=3D1 exactly when the v=
ma
for a mapping has VM_WRITE set (or is it VMA_MAYWRITE / force=3D=3D1?
I don't quite understand the distinction between WRITE and MAYWRITE).

Right now, one call to get_user_pages() might involve more than one vma,
but we could simulate the above by doing find_vma() and making sure our
call to get_user_pages() goes one vma at a time.  Of course that would be
inefficient since get_user_pages() will redo the find_vma() internally, so =
it
would I guess make sense to add another FOLL_ flag to tell
get_user_pages() to do this?

Am I all wet, or am I becoming an MM hacker?

Thanks,
  Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
